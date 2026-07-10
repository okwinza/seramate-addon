local _, ns = ...

-- Tooltip post-calls fire repeatedly on the same tooltip (every refresh) without Blizzard
-- clearing our custom lines, so naive appends grow without bound — but unit FRAMES (player
-- portrait, target frame) go further: their UpdateTooltip loop re-SetUnit()s every ~0.2s,
-- which rebuilds the tooltip and WIPES our lines. `claim` therefore dedupes per unit token
-- only while the lines we rendered are still present (line count hasn't dropped below the
-- post-render mark); a rebuild re-claims so the surface renders again. Token and mark are
-- cleared on Hide so the next hover starts fresh.
local Guard = {}
ns.Guard = Guard

local function ensureHideHook(tooltip)
	if tooltip.__seramateHideHooked then
		return
	end
	tooltip.__seramateHideHooked = true
	tooltip:HookScript("OnHide", function(self)
		self.__seramateToken = nil
		self.__seramateNumLines = nil
	end)
end

-- Whether the lines rendered after the last claim are still on the tooltip. When there is
-- no mark (or no NumLines), assume intact — that degrades to the plain per-token dedupe.
local function linesIntact(tooltip)
	if tooltip.__seramateNumLines == nil or type(tooltip.NumLines) ~= "function" then
		return true
	end
	return tooltip:NumLines() >= tooltip.__seramateNumLines
end

-- token = the unit GUID where available, else a normalized name. A nil token can't be
-- deduped (some tooltip states have no GUID yet), so we allow the render but don't remember
-- it — never let a nil match a previous nil and swallow a real new unit.
function Guard.claim(tooltip, token)
	if token == nil then
		return true
	end
	if tooltip.__seramateToken == token and linesIntact(tooltip) then
		return false
	end

	tooltip.__seramateToken = token
	tooltip.__seramateNumLines = nil
	ensureHideHook(tooltip)
	return true
end

-- Call after rendering (or deciding there is nothing to render) so the next refresh can
-- tell "our lines are intact" from "the tooltip was rebuilt under us".
function Guard.mark(tooltip)
	tooltip.__seramateNumLines = type(tooltip.NumLines) == "function" and tooltip:NumLines() or nil
end
