local _, ns = ...

-- The single source of truth that drives BOTH the tooltip renderer and the settings panel:
-- each bracket row maps a display label + per-line setting key to a path into a character
-- record. Titles + Last Updated are handled as their own toggles (see render.lua).
local Schema = {}
ns.Schema = Schema

Schema.SECTIONS = { "Current Rating", "This Expansion" }

Schema.rows = {
	{ key = "cur_2v2", section = "Current Rating", label = "2v2", src = "cur", bracket = "v2" },
	{ key = "cur_3v3", section = "Current Rating", label = "3v3", src = "cur", bracket = "v3" },
	{ key = "cur_rbg", section = "Current Rating", label = "RBG", src = "cur", bracket = "rbg" },
	{ key = "cur_shuffle", section = "Current Rating", label = "Shuffle", src = "cur", bracket = "sh" },

	{ key = "exp_2v2", section = "This Expansion", label = "2v2", src = "exp", bracket = "v2" },
	{ key = "exp_3v3", section = "This Expansion", label = "3v3", src = "exp", bracket = "v3" },
	{ key = "exp_rbg", section = "This Expansion", label = "RBG", src = "exp", bracket = "rbg" },
	{ key = "exp_shuffle", section = "This Expansion", label = "Shuffle", src = "exp", bracket = "sh" },
}

Schema.titlesRow = { key = "titles", label = "Titles" }
Schema.updatedRow = { key = "updated", label = "Last Updated" }

-- The tooltip surfaces the addon hooks; each has its own on/off toggle in the panel.
Schema.surfaces = {
	{ key = "unit", label = "Character tooltip" },
	{ key = "lfg", label = "LFG / Premade Groups" },
	{ key = "bnet", label = "Battle.net friends" },
}

-- Right-hand tooltip text for a bracket row (rating), or nil when there's no data for it.
function Schema.value(row, record)
	local sub = record[row.src]
	if type(sub) ~= "table" then
		return nil
	end

	local rating = sub[row.bracket]
	if type(rating) ~= "number" or rating <= 0 then
		return nil
	end

	return ns.Util.ratingText(rating)
end

-- Every toggleable key (per-line bracket rows + Titles + Last Updated), for the panel.
function Schema.keys()
	local keys = {}
	for _, row in ipairs(Schema.rows) do
		keys[#keys + 1] = row.key
	end
	keys[#keys + 1] = Schema.titlesRow.key
	keys[#keys + 1] = Schema.updatedRow.key
	return keys
end
