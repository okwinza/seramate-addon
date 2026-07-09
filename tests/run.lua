-- Pure-logic tests for the Seramate addon. Runs under a plain Lua 5.1 interpreter with a
-- minimal mocked WoW API — no in-client dependencies. Exits non-zero on any failure.
--   $ lua5.1 tests/run.lua

local passed, failed = 0, 0

local function check(name, cond)
	if cond then
		passed = passed + 1
	else
		failed = failed + 1
		print("FAIL: " .. name)
	end
end

local function eq(name, got, want)
	check(name .. " (got: " .. tostring(got) .. ")", got == want)
end

local function contains(name, haystack, needle)
	check(name .. " (in: " .. tostring(haystack) .. ")", type(haystack) == "string" and haystack:find(needle, 1, true) ~= nil)
end

-- ---- minimal WoW stubs -------------------------------------------------------
_G.IsInInstance = function() return false end
_G.GetRealmName = function() return "Tarren Mill" end
_G.print = print

-- ---- load modules under a shared namespace ----------------------------------
local ns = {}
local function load(path)
	local chunk = assert(loadfile(path))
	chunk("Seramate", ns)
end

load("Data/colors.lua")
load("Core/util.lua")
load("Data/realms.lua")
load("Data/realms_ru.lua")
load("Core/keys.lua")
load("Settings/schema.lua")
load("Core/guards.lua")
load("Core/render.lua")
load("Settings/panel.lua")

-- ---- Util.formatDate ---------------------------------------------------------
eq("formatDate normal", ns.Util.formatDate(20250707), "7 Jul 2025")
eq("formatDate garbage", ns.Util.formatDate(0), "?")
eq("formatDate bad month", ns.Util.formatDate(20259907), "20259907")

-- ---- Util rating color tiers (asserted against the palette so edits don't break tests) ----
contains("rating >=2700 tier1", ns.Util.ratingText(2750), ns.Colors.rating[1].color)
contains("rating >=2400 tier2", ns.Util.ratingText(2405), ns.Colors.rating[2].color)
contains("rating >=1750 band", ns.Util.ratingText(1840), ns.Colors.rating[4].color)
contains("rating base", ns.Util.ratingText(1500), ns.Colors.rating[#ns.Colors.rating].color)

-- ---- Util title tier colors: Legend (70) and Elite (65) are separate tiers -----------------
contains("title r1", ns.Util.titleText("Crimson Gladiator", 100), ns.Colors.title[1].color)
contains("title gladiator", ns.Util.titleText("Gladiator", 90), ns.Colors.title[2].color)
contains("title legend (w70)", ns.Util.titleText("Legend", 70), ns.Colors.title[3].color)
contains("title elite (w65)", ns.Util.titleText("Elite", 65), ns.Colors.title[4].color)
contains("title duelist", ns.Util.titleText("Duelist", 50), ns.Colors.title[5].color)
contains("title rival", ns.Util.titleText("Rival", 45), ns.Colors.title[6].color)
contains("title combatant", ns.Util.titleText("Combatant", 35), ns.Colors.title[#ns.Colors.title].color)
contains("title text keeps name", ns.Util.titleText("Duelist: DF S4", 50), "Duelist: DF S4")

-- ---- Util.cleanName (strip WoW UI escapes) -----------------------------------
eq("cleanName plain unchanged", ns.Util.cleanName("Xyz"), "Xyz")
eq("cleanName strips obfuscation token", ns.Util.cleanName("|Kj35|k"), "")
eq("cleanName strips color codes", ns.Util.cleanName("|cff00ff00Xyz|r"), "Xyz")
eq("cleanName keeps hyperlink text", ns.Util.cleanName("|Hplayer:Xyz|hXyz|h"), "Xyz")
eq("cleanName trims", ns.Util.cleanName("  Xyz  "), "Xyz")
eq("cleanName non-string", ns.Util.cleanName(nil), "")

-- ---- Util.profileUrl ---------------------------------------------------------
eq("profileUrl basic",
	ns.Util.profileUrl("eu", "Xyz", "Tarren Mill"),
	"https://seramate.com/eu/Tarren%20Mill/Xyz")
contains("profileUrl apostrophe", ns.Util.profileUrl("us", "Kael'thas", "R"), "Kael%27thas")
local ptUrl = ns.Util.profileUrl("eu", "N", "Aggra (Português)")
contains("profileUrl utf8 e-circumflex", ptUrl, "%C3%AA")
contains("profileUrl paren", ptUrl, "%28")

-- ---- Keys.normalizeRealm -----------------------------------------------------
eq("normalize spaces", ns.Keys.normalizeRealm("Tarren Mill"), "TarrenMill")
eq("normalize hyphen", ns.Keys.normalizeRealm("Azjol-Nerub"), "AzjolNerub")
eq("normalize apostrophe", ns.Keys.normalizeRealm("Kael'thas"), "Kaelthas")
eq("normalize parens", ns.Keys.normalizeRealm("Aggra (Português)"), "AggraPortuguês")

-- ---- realms.lua map + Keys.resolveRealm --------------------------------------
check("realms map populated", type(ns.Realms) == "table" and ns.Realms["TarrenMill"] ~= nil)
eq("resolve normalized form", ns.Keys.resolveRealm("TarrenMill"), "Tarren Mill")
eq("resolve display form", ns.Keys.resolveRealm("Tarren Mill"), "Tarren Mill")
eq("resolve accented", ns.Keys.resolveRealm("AggraPortuguês"), "Aggra (Português)")
eq("resolve unknown passthrough", ns.Keys.resolveRealm("Nonexistent"), "Nonexistent")

-- localized (ruRU) realm names -> canonical English (Bnet/LFG hand back the friend's locale)
eq("resolve russian spaced", ns.Keys.resolveRealm("Свежеватель Душ"), "Soulflayer")
eq("resolve russian as bnet returns it", ns.Keys.resolveRealm("СвежевательДуш"), "Soulflayer")
eq("resolve russian hyphenated", ns.Keys.resolveRealm("Король-лич"), "Lich King")

-- ---- Keys.splitFullName ------------------------------------------------------
local n1, r1 = ns.Keys.splitFullName("Xyz-TarrenMill")
check("split name", n1 == "Xyz" and r1 == "TarrenMill")
local n2, r2 = ns.Keys.splitFullName("Xyz-Azjol-Nerub")
check("split realm with hyphen", n2 == "Xyz" and r2 == "Azjol-Nerub")
local n3, r3 = ns.Keys.splitFullName("SoloName")
check("split no realm", n3 == "SoloName" and r3 == nil)

-- ---- Keys.lookup (dual-faction + realm resolution) ---------------------------
local REC = {
	cur = { v2 = 1840, v3 = 1875, sh = 2405 },
	exp = { v2 = 2010, v3 = 2055, sh = 2450 },
	titles = {
		{ n = "Crimson Gladiator: The War Within Season 3", w = 100 },
		{ n = "Duelist: Dragonflight Season 4", w = 50 },
	},
	upd = 20250707,
}
ns.DB = {
	HORDE = { ["Xyz-Tarren Mill"] = REC, ["Мокдэмвпхх-Soulflayer"] = REC },
	ALLIANCE = { ["Ally-Ravencrest"] = REC },
}
check("lookup direct display", ns.Keys.lookup("Xyz", "Tarren Mill") == REC)
check("lookup normalized realm", ns.Keys.lookup("Xyz", "TarrenMill") == REC)
check("lookup nil realm falls back to GetRealmName", ns.Keys.lookup("Xyz", nil) == REC)
check("lookup alliance faction", ns.Keys.lookup("Ally", "Ravencrest") == REC)
check("lookup miss", ns.Keys.lookup("Xyz", "Nonexistent") == nil)
check("lookup empty name", ns.Keys.lookup("", "Tarren Mill") == nil)
-- the reported bug: Cyrillic char on a ruRU realm, realm handed back localized
check("lookup russian realm spaced", ns.Keys.lookup("Мокдэмвпхх", "Свежеватель Душ") == REC)
check("lookup russian realm as bnet returns it", ns.Keys.lookup("Мокдэмвпхх", "СвежевательДуш") == REC)

-- ---- Guard.claim -------------------------------------------------------------
local function fakeTooltip()
	local t = {}
	function t:HookScript(evt, fn) if evt == "OnHide" then self._hide = fn end end
	function t:fireHide() if self._hide then self._hide(self) end end
	return t
end
local tt = fakeTooltip()
check("claim first guid", ns.Guard.claim(tt, "g1") == true)
check("claim repeat guid skips", ns.Guard.claim(tt, "g1") == false)
check("claim new guid renders", ns.Guard.claim(tt, "g2") == true)
check("claim nil always renders 1", ns.Guard.claim(tt, nil) == true)
check("claim nil always renders 2", ns.Guard.claim(tt, nil) == true)
tt:fireHide()
check("claim after hide re-renders", ns.Guard.claim(tt, "g2") == true)

-- ---- Render.build ------------------------------------------------------------
local function allEnabled() return true end
local function noneEnabled() return false end

local function flatten(ops)
	local parts = {}
	for _, op in ipairs(ops) do
		parts[#parts + 1] = (op.text or "") .. (op.left or "") .. "\t" .. (op.right or "")
	end
	return table.concat(parts, "\n")
end

local function countKind(ops, kind)
	local n = 0
	for _, op in ipairs(ops) do
		if op.kind == kind then n = n + 1 end
	end
	return n
end

local ops = ns.Render.build(REC, allEnabled)
check("build non-empty", #ops > 0)
check("build starts with blank", ops[1].kind == "blank")
check("build header second", ops[2].kind == "title")
contains("build header text", ops[2].text, "Seramate")

-- leadingBlank=false (empty tooltip, e.g. the Bnet frame): header is the very first line
local noLead = ns.Render.build(REC, allEnabled, false)
check("no leading blank when suppressed", noLead[1].kind == "title")
contains("suppressed build still has header", noLead[1].text, "Seramate")
local text = flatten(ops)
contains("build current rating section", text, "Current Rating:")
contains("build cur 2v2", text, "1840")
contains("build this expansion section", text, "This Expansion:")
contains("build exp 2v2", text, "2010")
contains("build titles section", text, "Titles:")
contains("build title name", text, "Crimson Gladiator: The War Within Season 3")
contains("build title r1 gold", text, "ffd100")
contains("build title duelist blue", text, "0070dd")
contains("build last updated", text, "7 Jul 2025")
check("build one line op per title", countKind(ops, "line") == 2)

-- ---- Shuffle bracket rows ------------------------------------------------------
local function findDouble(list, labelSub, valueSub)
	for index, op in ipairs(list) do
		if op.kind == "double" and op.left:find(labelSub, 1, true) and op.right:find(valueSub, 1, true) then
			return index, op
		end
	end
	return nil
end

local curShuffleAt, curShuffle = findDouble(ops, "Shuffle", "2405")
local expShuffleAt, expShuffle = findDouble(ops, "Shuffle", "2450")
check("cur shuffle renders as a double op", curShuffle ~= nil)
check("exp shuffle renders as a double op", expShuffle ~= nil)
-- 2405/2450 sit in the >=2400 tier; the value must carry that tier color, not the label color
contains("cur shuffle rating tier-colored", curShuffle and curShuffle.right or "", ns.Colors.rating[2].color)
contains("exp shuffle rating tier-colored", expShuffle and expShuffle.right or "", ns.Colors.rating[2].color)
-- section placement: cur shuffle before the This Expansion header, exp shuffle after it
local expHeaderAt
for index, op in ipairs(ops) do
	if op.kind == "title" and (op.text or ""):find("This Expansion:", 1, true) then expHeaderAt = index end
end
check("cur shuffle in Current Rating section", curShuffleAt ~= nil and expHeaderAt ~= nil and curShuffleAt < expHeaderAt)
check("exp shuffle in This Expansion section", expShuffleAt ~= nil and expHeaderAt ~= nil and expShuffleAt > expHeaderAt)

-- shuffle keys are toggleable and hide only their own lines
local function shuffleDisabled(key) return key ~= "cur_shuffle" and key ~= "exp_shuffle" end
local noShuffleText = flatten(ns.Render.build(REC, shuffleDisabled))
check("shuffle toggles hide shuffle lines", not noShuffleText:find("Shuffle", 1, true))
contains("other lines survive shuffle toggle", noShuffleText, "1840")
contains("titles survive shuffle toggle", noShuffleText, "Titles:")
local schemaKeys = table.concat(ns.Schema.keys(), ",")
contains("panel exposes cur_shuffle", schemaKeys, "cur_shuffle")
contains("panel exposes exp_shuffle", schemaKeys, "exp_shuffle")

-- sparsity: only cur + upd present
local SPARSE = { cur = { v3 = 1875 }, exp = {}, titles = {}, upd = 20250101 }
local sparseText = flatten(ns.Render.build(SPARSE, allEnabled))
contains("sparse has cur", sparseText, "1875")
check("sparse has no expansion section", not sparseText:find("This Expansion:", 1, true))
check("sparse has no titles section", not sparseText:find("Titles:", 1, true))
check("no shuffle line without sh data", not sparseText:find("Shuffle", 1, true))

-- everything disabled -> nothing renders
check("all-disabled builds empty", #ns.Render.build(REC, noneEnabled) == 0)

-- ---- Settings toggles (per-line + per-surface, default on) --------------------
check("line default enabled", ns.Settings.isLineEnabled("cur_2v2") == true)
check("surface default enabled", ns.Settings.isSurfaceEnabled("unit") == true)
ns.Settings.set("titles", "lines", false)
check("line toggled off", ns.Settings.isLineEnabled("titles") == false)
ns.Settings.set("bnet", "surfaces", false)
check("surface toggled off", ns.Settings.isSurfaceEnabled("bnet") == false)
check("line/surface scopes independent", ns.Settings.isLineEnabled("bnet") == true)
check("enabler reflects line toggles", ns.Settings.enabler()("titles") == false)

-- ---- summary -----------------------------------------------------------------
print(string.format("\n%d passed, %d failed", passed, failed))
os.exit(failed == 0 and 0 or 1)
