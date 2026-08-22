local _, ns = ...

-- Seramate tooltip color palette. Values are RRGGBB (util.lua wraps them into "|cffRRGGBB").
-- Edit visually with tools/tooltip-colors.html, then paste the exported map here.
ns.Colors = {
	header  = "ff8000",
	section = "ffd100",
	label   = "ffffff",
	-- Compact folds a bracket name and its rating onto one line, so the name needs a color of
	-- its own: in Full they sit in separate columns, but folded they'd both read as values.
	bracket = "9d9d9d",
	rating = { -- highest threshold first; first match wins
		{ min = 2700, color = "ff8000" },
		{ min = 2400, color = "0070dd" },
		{ min = 2100, color = "1eff00" },
		{ min = 1750, color = "1eff00" },
		{ min = 0,    color = "ffffff" },
	},
	-- By PvpTitleAchievement weight; highest first, first match wins. `key` is the stable
	-- identity the per-tier color override is stored under (SeramateSettings.titleColors),
	-- `label` is what the Title Colors settings page shows — colors here are the defaults.
	title = {
		{ min = 92, key = "rank1", label = "Rank 1", color = "ffd100" }, -- arena / shuffle / blitz
		{ min = 90, key = "gladiator", label = "Gladiator", color = "ff8000" },
		{ min = 70, key = "legend", label = "Legend", color = "34fedc" },
		{ min = 65, key = "elite", label = "Elite / Hero", color = "34fedc" }, -- Hero of the Alliance/Horde is weight 66
		{ min = 50, key = "duelist", label = "Strategist / Duelist", color = "0070dd" },
		{ min = 40, key = "rival", label = "Rival / Challenger", color = "1eff00" },
		{ min = 0,  key = "combatant", label = "Combatant", color = "9d9d9d" },
	},
}
