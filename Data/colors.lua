local _, ns = ...

-- Seramate tooltip color palette. Values are RRGGBB (util.lua wraps them into "|cffRRGGBB").
-- Edit visually with tools/tooltip-colors.html, then paste the exported map here.
ns.Colors = {
	header  = "ff8000",
	section = "ffd100",
	label   = "ffffff",
	rating = { -- highest threshold first; first match wins
		{ min = 2700, color = "ff8000" },
		{ min = 2400, color = "0070dd" },
		{ min = 2100, color = "1eff00" },
		{ min = 1750, color = "1eff00" },
		{ min = 0,    color = "ffffff" },
	},
	title = { -- by PvpTitleAchievement weight; highest first, first match wins
		{ min = 92, color = "ffd100" }, -- Rank 1 (arena / shuffle / blitz)
		{ min = 90, color = "ff8000" }, -- Gladiator
		{ min = 70, color = "34fedc" }, -- Legend
		{ min = 65, color = "34fedc" }, -- Elite (and Hero of the Alliance/Horde, weight 66)
		{ min = 50, color = "0070dd" }, -- Strategist / Duelist
		{ min = 40, color = "1eff00" }, -- Rival / Challenger
		{ min = 0,  color = "9d9d9d" }, -- Combatant
	},
}
