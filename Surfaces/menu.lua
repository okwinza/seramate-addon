local _, ns = ...

-- A small read-only frame holding the profile URL for Ctrl+C (WoW can't write the OS
-- clipboard directly). Auto-closes on Ctrl+C or when it loses focus; also Esc-closable
-- via UISpecialFrames.
local copyFrame

local function ensureCopyFrame()
	if copyFrame then
		return copyFrame
	end

	local frame = CreateFrame("Frame", "SeramateCopyFrame", UIParent, "BackdropTemplate")
	frame:SetSize(420, 96)
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

local function showCopyFrame(url)
	local frame = ensureCopyFrame()
	frame.editBox:SetText(url)
	frame.editBox:SetCursorPosition(0)
	frame.editBox:HighlightText()
	frame:Show()
	frame.editBox:SetFocus()
end

-- Canonicalize + validate a (name, realm) pair into the profile key form, or nil if the name
-- isn't a real character (empty, or a stripped |K…|k substitution token).
local function finalize(name, realm)
	name = ns.Util.cleanName(name)
	if name == "" then
		return nil
	end
	realm = ns.Util.cleanName(realm)
	if realm == "" then
		realm = (type(GetRealmName) == "function") and GetRealmName() or ""
	end
	-- Canonicalize to the English display name so the profile URL matches seramate.com
	-- (a localized realm, e.g. ruRU "Свежеватель Душ", would otherwise 404).
	return name, ns.Keys.resolveRealm(realm)
end

local function resolveTarget(contextData)
	if not contextData then
		return nil
	end

	-- Battle.net friend menu: contextData.name is the BNet account tag (a |K…|k substitution
	-- token, not the WoW character), so read the character straight from the game account info.
	local game = contextData.accountInfo and contextData.accountInfo.gameAccountInfo
	if game and (not BNET_CLIENT_WOW or game.clientProgram == BNET_CLIENT_WOW) then
		return finalize(game.characterName, game.realmName)
	end

	-- Unit / player menus: the character is in name+server, or on the unit token.
	local name = contextData.name ~= "" and contextData.name or nil
	local realm = contextData.server ~= "" and contextData.server or nil
	local unit = ns.Util.scrubSecret(contextData.unit)
	if not name and unit and UnitIsPlayer(unit) then
		name, realm = UnitName(unit)
	end
	return finalize(name, realm)
end

local function addProfileButton(_, rootDescription, contextData)
	local name, realm = resolveTarget(contextData)
	if not name then
		return
	end
	-- Queue the divider + section title, then add the button; the queued header only renders
	-- once a real item follows. CreateTitle/CreateDivider aren't valid on the menu proxy — the
	-- Queue* API is (cf. TotalRP3 Modules/UnitPopups/UnitPopups.lua).
	rootDescription:QueueDivider()
	rootDescription:QueueTitle("Seramate")
	rootDescription:CreateButton("Copy Profile Link", function()
		showCopyFrame(ns.Util.profileUrl(ns.region or "eu", name, realm))
	end)
	rootDescription:ClearQueuedDescriptions()
end

local function registerMenus()
	if type(Menu) ~= "table" or not Menu.ModifyMenu then
		ns.Util.debug("menu: Menu.ModifyMenu unavailable")
		return
	end
	local tags = {
		"MENU_UNIT_PLAYER",
		"MENU_UNIT_PARTY",
		"MENU_UNIT_RAID_PLAYER",
		"MENU_UNIT_FRIEND",
		"MENU_UNIT_BN_FRIEND",
	}
	for _, tag in ipairs(tags) do
		-- Each registration needs its OWN closure: the menu system keys registrations by the
		-- callback ("owner"), so reusing one function lets later tags replace earlier ones,
		-- leaving only the last tag hooked (cf. TotalRP3 UnitPopups OnModuleEnable).
		Menu.ModifyMenu(tag, function(owner, rootDescription, contextData)
			addProfileButton(owner, rootDescription, contextData)
		end)
	end
	ns.Util.debug("menu: registered", #tags, "unit menu hooks")
end

-- Register post-login, not at addon load: the Menu system isn't reliably hookable that early
-- (TotalRP3 registers in OnModuleEnable for the same reason).
local menuFrame = CreateFrame("Frame")
menuFrame:RegisterEvent("PLAYER_LOGIN")
menuFrame:SetScript("OnEvent", registerMenus)
