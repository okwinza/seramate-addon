local _, ns = ...

-- The Group Finder row layout — which Blizzard frame carries which id — is encoded here once,
-- for the tooltip hooks below and for menu.lua. Names return raw; every consumer ends in a
-- scrub (see Util.plainString).
ns.LFG = {}

function ns.LFG.leaderFullName(row)
	local resultID = row and row.resultID
	if not resultID then
		return nil
	end
	local info = C_LFGList.GetSearchResultInfo(resultID)
	return info and info.leaderName
end

function ns.LFG.applicantFullName(button)
	local parent = button and button:GetParent()
	local applicantID = parent and parent.applicantID
	local memberIdx = button and button.memberIdx
	if not applicantID or not memberIdx then
		return nil
	end
	return C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx)
end

-- The guard token is built here, from the scrubbed name: a secret concatenates fine but the
-- token is later compared, which tainted code may not do to a secret-derived value.
local function showFor(fullName, tokenPrefix)
	fullName = ns.Util.plainString(fullName)
	if not fullName then
		return
	end
	local name, realm = ns.Keys.splitFullName(fullName)
	local record = ns.Keys.lookup(name, realm)
	if record and ns.Guard.claim(GameTooltip, tokenPrefix .. fullName) then
		ns.Render.renderInto(GameTooltip, record, "lfg")
	end
end

local function installHooks()
	if type(LFGListSearchEntry_OnEnter) == "function" then
		hooksecurefunc("LFGListSearchEntry_OnEnter", function(self)
			showFor(ns.LFG.leaderFullName(self), "lfg:")
		end)
	end

	if type(LFGListApplicantMember_OnEnter) == "function" then
		hooksecurefunc("LFGListApplicantMember_OnEnter", function(self)
			showFor(ns.LFG.applicantFullName(self), "lfgapp:")
		end)
	end
end

-- The Group Finder UI is load-on-demand, so its OnEnter globals may not exist yet at addon
-- load; hook once it's present.
if type(EventUtil) == "table" and EventUtil.ContinueOnAddOnLoaded then
	EventUtil.ContinueOnAddOnLoaded("Blizzard_GroupFinder", installHooks)
else
	installHooks()
end
