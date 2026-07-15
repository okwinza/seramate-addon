local _, ns = ...

local Render = {}
ns.Render = Render

-- Build the ordered list of tooltip operations for a record. Pure (no WoW calls) so it can
-- be unit-tested: `enabled(key)` decides which lines show. A rating section renders only if
-- at least one of its rows has data + is enabled; titles render as one line each (colored by
-- prestige tier); a blank line precedes every section so a toggled-off section leaves no
-- double gap. Returns {} when nothing renders.
function Render.build(record, enabled, leadingBlank)
	local Util = ns.Util
	local Schema = ns.Schema
	local ops = {}

	for _, sectionName in ipairs(Schema.SECTIONS) do
		local rows = {}
		for _, row in ipairs(Schema.rows) do
			if row.section == sectionName and enabled(row.key) then
				local value = Schema.value(row, record)
				if value then
					rows[#rows + 1] = { label = row.label, value = value }
				end
			end
		end

		if #rows > 0 then
			ops[#ops + 1] = { kind = "blank" }
			ops[#ops + 1] = { kind = "title", text = Util.section(sectionName .. ":") }
			for _, r in ipairs(rows) do
				ops[#ops + 1] = { kind = "double", left = Util.label("  " .. r.label), right = r.value }
			end
		end
	end

	local titlesRow = Schema.titlesRow
	if enabled(titlesRow.key) and type(record.titles) == "table" and #record.titles > 0 then
		ops[#ops + 1] = { kind = "blank" }
		ops[#ops + 1] = { kind = "title", text = Util.section(titlesRow.label .. ":") }
		for _, title in ipairs(record.titles) do
			ops[#ops + 1] = { kind = "line", text = "  " .. Util.titleText(title.n, title.w) }
		end
	end

	local updated = Schema.updatedRow
	if enabled(updated.key) and type(record.upd) == "number" then
		ops[#ops + 1] = { kind = "blank" }
		ops[#ops + 1] = { kind = "double", left = Util.label(updated.label .. ":"), right = Util.formatDate(record.upd) }
	end

	if #ops == 0 then
		return ops
	end

	table.insert(ops, 1, { kind = "title", text = Util.header("Seramate") })
	-- The leading blank separates our block from the tooltip's existing lines; skip it when the
	-- tooltip is empty (the standalone Bnet frame), where it would just be a blank first line.
	if leadingBlank ~= false then
		table.insert(ops, 1, { kind = "blank" })
	end
	return ops
end

local function bestTitle(record)
	if type(record.titles) ~= "table" then
		return nil
	end
	local best
	for _, title in ipairs(record.titles) do
		if not best or (title.w or 0) > (best.w or 0) then
			best = title
		end
	end
	return best
end

-- Compact variant for combat: the same data folded to one line per rating section plus the
-- single best title, no Last Updated. Same enabled() contract as build().
function Render.buildCompact(record, enabled, leadingBlank)
	local Util = ns.Util
	local Schema = ns.Schema
	local ops = {}

	for _, sectionName in ipairs(Schema.SECTIONS) do
		local parts = {}
		for _, row in ipairs(Schema.rows) do
			if row.section == sectionName and enabled(row.key) then
				local value = Schema.value(row, record)
				if value then
					parts[#parts + 1] = Util.label(row.label) .. " " .. value
				end
			end
		end

		if #parts > 0 then
			ops[#ops + 1] = {
				kind = "double",
				left = Util.section((Schema.SHORT[sectionName] or sectionName) .. ":"),
				right = table.concat(parts, "  "),
			}
		end
	end

	local title = enabled(Schema.titlesRow.key) and bestTitle(record) or nil
	if title then
		ops[#ops + 1] = { kind = "line", text = Util.titleText(title.n, title.w) }
	end

	if #ops == 0 then
		return ops
	end

	table.insert(ops, 1, { kind = "title", text = Util.header("Seramate") })
	if leadingBlank ~= false then
		table.insert(ops, 1, { kind = "blank" })
	end
	return ops
end

-- Which rendering a tooltip gets: the base layout normally, with the combat setting able to
-- override it while fighting. Returns "full" | "compact" | "hide". Pure, so it's unit-tested.
function Render.resolveMode(inCombat, layout, combat)
	local base = layout == "compact" and "compact" or "full"
	if not inCombat then
		return base
	end
	if combat == "hide" then
		return "hide"
	end
	if combat == "compact" then
		return "compact"
	end
	return base -- "inherit"
end

function Render.renderInto(tooltip, record, surface)
	if surface and not ns.Settings.isSurfaceEnabled(surface) then
		return false
	end

	local mode = Render.resolveMode(ns.Util.inCombat(), ns.Settings.layoutMode(), ns.Settings.combatMode())
	if mode == "hide" then
		return false
	end

	local hasContent = type(tooltip.NumLines) == "function" and tooltip:NumLines() > 0
	local builder = mode == "compact" and Render.buildCompact or Render.build
	local ops = builder(record, ns.Settings.enabler(), hasContent)
	if #ops == 0 then
		return false
	end

	for _, op in ipairs(ops) do
		if op.kind == "blank" then
			tooltip:AddLine(" ")
		elseif op.kind == "double" then
			tooltip:AddDoubleLine(op.left, op.right)
		else -- "title" or "line": a single left-aligned line
			tooltip:AddLine(op.text)
		end
	end

	tooltip:Show()
	return true
end
