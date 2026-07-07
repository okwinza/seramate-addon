local _, ns = ...

-- Tooltip post-calls fire repeatedly on the same tooltip (every refresh) without Blizzard
-- clearing our custom lines, so naive appends grow without bound. `claim` returns true only
-- the first time a given unit token is seen on a tooltip; the token is cleared on Hide so
-- the next hover renders fresh.
local Guard = {}
ns.Guard = Guard

local function ensureHideHook(tooltip)
	if tooltip.__seramateHideHooked then
		return
	end
	tooltip.__seramateHideHooked = true
	tooltip:HookScript("OnHide", function(self)
		self.__seramateToken = nil
	end)
end

-- token = the unit GUID where available, else a normalized name. A nil token can't be
-- deduped (some tooltip states have no GUID yet), so we allow the render but don't remember
-- it — never let a nil match a previous nil and swallow a real new unit.
function Guard.claim(tooltip, token)
	if token == nil then
		return true
	end
	if tooltip.__seramateToken == token then
		return false
	end

	tooltip.__seramateToken = token
	ensureHideHook(tooltip)
	return true
end
