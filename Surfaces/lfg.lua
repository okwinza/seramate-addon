local _, ns = ...

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
			local resultID = self and self.resultID
			if not resultID then
				return
			end
			local info = C_LFGList.GetSearchResultInfo(resultID)
			showFor(info and info.leaderName, "lfg:")
		end)
	end

	if type(LFGListApplicantMember_OnEnter) == "function" then
		hooksecurefunc("LFGListApplicantMember_OnEnter", function(self)
			local parent = self and self:GetParent()
			local applicantID = parent and parent.applicantID
			local memberIdx = self and self.memberIdx
			if not applicantID or not memberIdx then
				return
			end
			showFor(C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx), "lfgapp:")
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
