local _, ns = ...

-- Post-call on the unit tooltip (frames + nameplates). Fires on every refresh, so the GUID
-- guard keeps us from stacking duplicate lines.
local function onUnitTooltip(tooltip, data)
	if tooltip ~= GameTooltip then
		return
	end

	local _, unit = tooltip:GetUnit()
	local guid = (data and data.guid) or (unit and UnitGUID(unit))

	local name, realm
	if unit and UnitIsPlayer(unit) then
		name, realm = UnitName(unit)
	elseif guid then
		local _, _, _, _, _, resolvedName, resolvedRealm = GetPlayerInfoByGUID(guid)
		name, realm = resolvedName, resolvedRealm
	end

	if not name or name == "" then
		return
	end
	if not ns.Guard.claim(tooltip, guid or name) then
		return
	end

	local record = ns.Keys.lookup(name, realm)
	if record then
		ns.Render.renderInto(tooltip, record, "unit")
	end
	-- Mark the post-render line count: unit frames rebuild the tooltip every ~0.2s (their
	-- UpdateTooltip loop), and the mark is how claim() detects the rebuild and lets us
	-- render again instead of leaving the default tooltip (self-portrait flicker).
	ns.Guard.mark(tooltip)
end

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, onUnitTooltip)
end
