local _, ns = ...

-- Post-call on the unit tooltip (frames + nameplates). Fires on every refresh, so the GUID
-- guard keeps us from stacking duplicate lines.
local function onUnitTooltip(tooltip, data)
	if tooltip ~= GameTooltip then
		return
	end

	-- World-cursor tooltips (12.x) fill unit/guid with secret values; scrub them or the
	-- UnitIsPlayer/GetPlayerInfoByGUID calls below hard-error.
	local _, unit = tooltip:GetUnit()
	unit = ns.Util.plainString(unit)
	local guid = ns.Util.plainString(data and data.guid)
		or ns.Util.plainString(unit and UnitGUID(unit))

	local name, realm
	if unit and UnitIsPlayer(unit) then
		name, realm = UnitName(unit)
	elseif guid then
		local _, _, _, _, _, resolvedName, resolvedRealm = GetPlayerInfoByGUID(guid)
		name, realm = resolvedName, resolvedRealm
	end

	-- Both resolvers return secrets in restricted contexts. (Keys.lookup scrubs realm itself.)
	name = ns.Util.plainString(name)
	if not name then
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
