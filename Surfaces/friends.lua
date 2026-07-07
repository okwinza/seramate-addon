local _, ns = ...

-- The Battle.net friends list uses FriendsTooltip, which is a bespoke frame (not a
-- GameTooltip and not extensible via TooltipDataProcessor). We render into our own
-- GameTooltip-templated frame anchored beside it.
local panel

local function ensurePanel()
	if panel then
		return panel
	end
	panel = CreateFrame("GameTooltip", "SeramateBnetTooltip", UIParent, "GameTooltipTemplate")
	panel:SetFrameStrata("TOOLTIP")
	return panel
end

local function resolveHoveredCharacter()
	local button = FriendsTooltip and FriendsTooltip.button
	if not button or not button.id then
		return nil
	end
	if FRIENDS_BUTTON_TYPE_BNET and button.buttonType ~= FRIENDS_BUTTON_TYPE_BNET then
		return nil
	end

	local info = C_BattleNet.GetFriendAccountInfo(button.id)
	local game = info and info.gameAccountInfo
	if not game or not game.isOnline then
		return nil
	end
	if BNET_CLIENT_WOW and game.clientProgram ~= BNET_CLIENT_WOW then
		return nil
	end
	if not game.characterName or not game.realmName then
		return nil
	end
	return game.characterName, game.realmName
end

local function onFriendsTooltipShow()
	local frame = ensurePanel()
	local name, realm = resolveHoveredCharacter()
	local record = name and ns.Keys.lookup(name, realm) or nil
	if not record then
		frame:Hide()
		return
	end

	frame:SetOwner(FriendsTooltip, "ANCHOR_NONE")
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", FriendsTooltip, "TOPRIGHT", 2, 0)
	frame:ClearLines()
	if not ns.Render.renderInto(frame, record, "bnet") then
		frame:Hide()
	end
end

if FriendsTooltip then
	hooksecurefunc(FriendsTooltip, "Show", onFriendsTooltipShow)
	FriendsTooltip:HookScript("OnHide", function()
		if panel then
			panel:Hide()
		end
	end)
end
