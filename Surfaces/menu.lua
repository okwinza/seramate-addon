local _, ns = ...

-- A small read-only frame holding the character for Ctrl+C (WoW can't write the OS clipboard
-- directly), as Name-Server or as the profile URL; a switch on top picks which, and the choice
-- sticks. Auto-closes on Ctrl+C or when it loses focus; also Esc-closable via UISpecialFrames.
local copyFrame

local MENU_LABELS = { name = "Copy Name-Server", link = "Copy Profile Link" }

-- Fill the box with the chosen format, preselected for Ctrl+C, and check its radio. Re-checking
-- on every click matters: a CheckButton toggles itself, so the chosen one would clear.
local function showFormat(frame)
	local format = ns.Settings.copyFormat()
	for buttonFormat, button in pairs(frame.formatButtons) do
		button:SetChecked(buttonFormat == format)
	end
	frame.editBox:SetText(frame.texts[format])
	frame.editBox:SetCursorPosition(0)
	frame.editBox:HighlightText()
	frame.editBox:SetFocus()
end

-- Radios, not panel buttons: UIPanelButtonTemplate's locked highlight is also its hover look,
-- so the unchosen button looked chosen under the cursor.
local function createFormatSwitch(frame)
	local buttons = {}
	for index, option in ipairs(ns.Settings.COPY_OPTIONS) do
		local button = CreateFrame("CheckButton", nil, frame, "UIRadioButtonTemplate")
		button:SetPoint("TOPLEFT", 100 + (index - 1) * 130, -40)
		button.text:SetFontObject("GameFontHighlight")
		button.text:SetText(option.label)
		-- the label is clickable too
		button:SetHitRectInsets(0, -(button.text:GetStringWidth() + 5), 0, 0)
		button:SetScript("OnClick", function()
			ns.Settings.setCopyFormat(option.format)
			showFormat(frame)
		end)
		buttons[option.format] = button
	end
	return buttons
end

local function ensureCopyFrame()
	if copyFrame then
		return copyFrame
	end

	local frame = CreateFrame("Frame", "SeramateCopyFrame", UIParent, "BackdropTemplate")
	frame:SetSize(420, 124)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11 },
	})
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

	local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	title:SetPoint("TOP", 0, -16)
	title:SetText(ns.Util.header("Seramate Profile") .. " — press Ctrl+C")

	frame.formatButtons = createFormatSwitch(frame)

	local editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
	editBox:SetSize(380, 24)
	editBox:SetPoint("BOTTOM", 0, 22)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject("ChatFontNormal")
	editBox:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
		frame:Hide()
	end)
	editBox:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
	end)
	-- Auto-close once copied: Ctrl+C closes immediately (OnKeyUp, so the native copy has
	-- already run); losing focus to anywhere off the popup closes it too.
	editBox:SetScript("OnKeyUp", function(self, key)
		if ns.Util.isCopyShortcut(key, IsControlKeyDown()) then
			self:ClearFocus()
			frame:Hide()
		end
	end)
	-- Defer a frame: grabbing the movable frame clears focus on mouse-down (before OnDragStart),
	-- so hide only when the cursor has actually left the popup, not when dragging it.
	editBox:SetScript("OnEditFocusLost", function()
		C_Timer.After(0, function()
			if not frame:IsMouseOver() then
				frame:Hide()
			end
		end)
	end)
	frame.editBox = editBox

	tinsert(UISpecialFrames, "SeramateCopyFrame")
	copyFrame = frame
	return frame
end

-- texts: { name = "Name-Server", link = "https://seramate.com/..." }
local function showCopyFrame(texts)
	local frame = ensureCopyFrame()
	frame.texts = texts
	frame:Show()
	showFormat(frame)
end

-- Name-Server keeps the realm as the client handed it. Only the URL needs the English display
-- name: seramate.com 404s on a localized realm (e.g. ruRU "Свежеватель Душ"), while its search
-- box takes either spelling.
local function copyTexts(name, realm)
	return {
		name = ns.Util.fullName(name, realm),
		link = ns.Util.profileUrl(ns.region or "eu", name, ns.Keys.resolveRealm(realm)),
	}
end

-- Validate a (name, realm) pair, or nil if the name isn't a real character (empty, or a
-- stripped |K…|k substitution token). An empty realm means the player's own.
local function finalize(name, realm)
	name = ns.Util.cleanName(name)
	if name == "" then
		return nil
	end
	realm = ns.Util.cleanName(realm)
	if realm == "" then
		realm = (type(GetRealmName) == "function") and GetRealmName() or ""
	end
	return name, realm
end

-- Unit-style menus: the character is in name+server, or on the unit token. Our own callback
-- taints the menu build, so every field here can arrive secret (see plainString).
local function resolveUnit(_, contextData)
	if not contextData then
		return nil
	end
	local name = ns.Util.plainString(contextData.name)
	local realm = ns.Util.plainString(contextData.server)
	local unit = ns.Util.plainString(contextData.unit)
	if not name and unit and UnitIsPlayer(unit) then
		name, realm = UnitName(unit)
	end
	return finalize(name, realm)
end

-- Battle.net-account menus: contextData.name is the account label (|K…|k token, battletag,
-- or real name), never a character — read the linked game account instead. Other menus must
-- NOT: the client fills accountInfo (via GUID) even on e.g. guild members who are also
-- friends, and there it names whatever character the friend is playing, not the clicked row.
local function resolveBnetAccount(_, contextData)
	local game = contextData and contextData.accountInfo and contextData.accountInfo.gameAccountInfo
	if game and (not BNET_CLIENT_WOW or game.clientProgram == BNET_CLIENT_WOW) then
		return finalize(ns.Util.plainString(game.characterName), ns.Util.plainString(game.realmName))
	end
	return nil
end

local function finalizeFullName(full)
	return finalize(ns.Keys.splitFullName(full))
end

-- Not unit popups: the client tags the Group Finder menus with no contextData, so the
-- character comes off the owning row (ns.LFG). leaderName is nil until you've signed up.
local function resolveSearchEntry(owner)
	return finalizeFullName(ns.LFG.leaderFullName(owner))
end

local function resolveApplicant(owner)
	return finalizeFullName(ns.LFG.applicantFullName(owner))
end

local MENU_RESOLVERS = {
	MENU_UNIT_PLAYER = resolveUnit,
	MENU_UNIT_PARTY = resolveUnit,
	MENU_UNIT_RAID_PLAYER = resolveUnit,
	MENU_UNIT_ENEMY_PLAYER = resolveUnit,
	MENU_UNIT_FRIEND = resolveUnit,
	MENU_UNIT_FRIEND_OFFLINE = resolveUnit,
	MENU_UNIT_BN_FRIEND = resolveBnetAccount,
	MENU_UNIT_COMMUNITIES_GUILD_MEMBER = resolveUnit,
	MENU_UNIT_COMMUNITIES_WOW_MEMBER = resolveUnit,
	MENU_UNIT_COMMUNITIES_MEMBER = resolveBnetAccount,
	MENU_LFG_FRAME_SEARCH_ENTRY = resolveSearchEntry,
	MENU_LFG_FRAME_MEMBER_APPLY = resolveApplicant,
}

local function addProfileButton(rootDescription, name, realm)
	if not name then
		return
	end
	-- Queue the divider + section title, then add the button; the queued header only renders
	-- once a real item follows. CreateTitle/CreateDivider aren't valid on the menu proxy — the
	-- Queue* API is (cf. TotalRP3 Modules/UnitPopups/UnitPopups.lua).
	rootDescription:QueueDivider()
	rootDescription:QueueTitle("Seramate")
	rootDescription:CreateButton(MENU_LABELS[ns.Settings.copyFormat()], function()
		showCopyFrame(copyTexts(name, realm))
	end)
	rootDescription:ClearQueuedDescriptions()
end

local function registerMenus()
	if type(Menu) ~= "table" or not Menu.ModifyMenu then
		ns.Util.debug("menu: Menu.ModifyMenu unavailable")
		return
	end
	for tag, resolve in pairs(MENU_RESOLVERS) do
		-- Each registration needs its OWN closure: the menu system keys registrations by the
		-- callback ("owner"), so reusing one function lets later tags replace earlier ones,
		-- leaving only the last tag hooked (cf. TotalRP3 UnitPopups OnModuleEnable).
		Menu.ModifyMenu(tag, function(owner, rootDescription, contextData)
			addProfileButton(rootDescription, resolve(owner, contextData))
		end)
	end
	ns.Util.debug("menu: menu hooks registered")
end

-- Register post-login, not at addon load: the Menu system isn't reliably hookable that early
-- (TotalRP3 registers in OnModuleEnable for the same reason).
local menuFrame = CreateFrame("Frame")
menuFrame:RegisterEvent("PLAYER_LOGIN")
menuFrame:SetScript("OnEvent", registerMenus)
