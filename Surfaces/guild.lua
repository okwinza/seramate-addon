local _, ns = ...

-- The guild panel (Communities frame) member rows build a plain GameTooltip in
-- CommunitiesMemberListEntryMixin:OnEnter — no unit behind it, so the unit surface never
-- fires. We append to that tooltip. In the expanded Roster view Blizzard's OnEnter
-- early-returns with no tooltip at all unless a column is truncated; there we build our
-- own (owner + name line) so ratings still show.

-- Battle.net communities list battletags, not characters; skip them. Guild and WoW
-- character communities both carry Name-Realm member names. Blizzard's own OnEnter treats
-- missing club info as a guild, so we do too.
local function isCharacterClub(entry)
	local memberList = entry.GetMemberList and entry:GetMemberList()
	local clubInfo = memberList and memberList.GetSelectedClubInfo and memberList:GetSelectedClubInfo()
	if not clubInfo then
		return true
	end
	return not (Enum and Enum.ClubType and clubInfo.clubType == Enum.ClubType.BattleNet)
end

local function onMemberEnter(entry)
	local memberInfo = entry.GetMemberInfo and entry:GetMemberInfo()
	local fullName = memberInfo and memberInfo.name
	if not fullName or fullName == "" or not isCharacterClub(entry) then
		return
	end

	local name, realm = ns.Keys.splitFullName(fullName)
	local record = ns.Keys.lookup(name, realm)
	if not record then
		return
	end

	local built = false
	if not GameTooltip:IsShown() or GameTooltip:GetOwner() ~= entry then
		GameTooltip:SetOwner(entry)
		GameTooltip:AddLine(fullName)
		built = true
	end

	local rendered = ns.Guard.claim(GameTooltip, "guild:" .. fullName)
		and ns.Render.renderInto(GameTooltip, record, "guild")
	if built and not rendered then
		GameTooltip:Hide() -- don't leave a bare name-only tooltip Blizzard wouldn't have shown
	end
end

local function installHooks()
	local mixin = CommunitiesMemberListEntryMixin
	if type(mixin) == "table" and type(mixin.OnEnter) == "function" then
		-- Rows are created lazily by the scroll box after the LoD addon loads, so every
		-- row copies the hooked method out of the mixin table.
		hooksecurefunc(mixin, "OnEnter", onMemberEnter)
	end
end

if type(EventUtil) == "table" and EventUtil.ContinueOnAddOnLoaded then
	EventUtil.ContinueOnAddOnLoaded("Blizzard_Communities", installHooks)
else
	installHooks()
end
