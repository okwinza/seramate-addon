local _, ns = ...

local Util = {}
ns.Util = Util

-- Colors come from the palette in Data/colors.lua (edit visually with tools/tooltip-colors.html).
-- Values there are RRGGBB; wrap them into WoW's "|cffRRGGBB" escape here.
local palette = ns.Colors or {}
local function esc(rgb)
	return "|cff" .. (rgb or "ffffff")
end

local function tierRamp(list)
	local ramp = {}
	for _, tier in ipairs(list or {}) do
		ramp[#ramp + 1] = { min = tier.min, key = tier.key, color = esc(tier.color) }
	end
	return ramp
end

local BRAND = esc(palette.header)
local SECTION = esc(palette.section)
local LABEL = esc(palette.label)
local BRACKET = esc(palette.bracket)
local TIERS = tierRamp(palette.rating)       -- rating breakpoints, highest first
local TITLE_TIERS = tierRamp(palette.title)  -- PvpTitleAchievement weight, highest first

local MONTHS = {
	"Jan", "Feb", "Mar", "Apr", "May", "Jun",
	"Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
}

function Util.colorize(text, colorCode)
	return colorCode .. text .. "|r"
end

function Util.ratingColor(rating)
	for _, tier in ipairs(TIERS) do
		if rating >= tier.min then
			return tier.color
		end
	end
	return LABEL
end

function Util.ratingText(rating)
	return Util.colorize(tostring(rating), Util.ratingColor(rating))
end

-- A user override from the Title Colors settings page wins over the palette default.
-- Resolved per call, not at load: panel.lua (ns.Settings) loads after this file, and the
-- override can change any time the settings page is open.
local function tierColor(tier)
	local override = tier.key and ns.Settings and ns.Settings.titleColor(tier.key)
	if override then
		return esc(override)
	end
	return tier.color
end

function Util.titleColor(weight)
	for _, tier in ipairs(TITLE_TIERS) do
		if weight >= tier.min then
			return tierColor(tier)
		end
	end
	return LABEL
end

function Util.titleText(name, weight)
	return Util.colorize(name, Util.titleColor(weight or 0))
end

-- A color as the settings store it: exactly six hex digits ("RRGGBB", no escape prefix).
function Util.isHexColor(value)
	return type(value) == "string" and value:find("^%x%x%x%x%x%x$") ~= nil
end

-- "RRGGBB" -> 0-1 floats (the color picker's format); nil when malformed.
function Util.hexToRgb(hex)
	if not Util.isHexColor(hex) then
		return nil
	end
	return tonumber(hex:sub(1, 2), 16) / 255,
		tonumber(hex:sub(3, 4), 16) / 255,
		tonumber(hex:sub(5, 6), 16) / 255
end

-- 0-1 floats -> "rrggbb", clamped so picker jitter can't produce an invalid store value.
function Util.rgbToHex(r, g, b)
	local function byte(value)
		value = math.floor((tonumber(value) or 0) * 255 + 0.5)
		return math.max(0, math.min(255, value))
	end
	return string.format("%02x%02x%02x", byte(r), byte(g), byte(b))
end

-- `upd` is a YYYYMMDD integer; render a friendly, locale-free date ("7 Jul 2025").
function Util.formatDate(yyyymmdd)
	if type(yyyymmdd) ~= "number" or yyyymmdd < 19000101 then
		return "?"
	end

	local year = math.floor(yyyymmdd / 10000)
	local month = math.floor(yyyymmdd / 100) % 100
	local day = yyyymmdd % 100
	if month < 1 or month > 12 then
		return tostring(yyyymmdd)
	end

	return string.format("%d %s %d", day, MONTHS[month], year)
end

function Util.header(text)
	return Util.colorize(text, BRAND)
end

function Util.section(text)
	return Util.colorize(text, SECTION)
end

function Util.label(text)
	return Util.colorize(text, LABEL)
end

-- A bracket name standing next to its own rating (the compact line), where the label color
-- would be indistinguishable from an uncolored sub-1750 rating.
function Util.bracket(text)
	return Util.colorize(text, BRACKET)
end

-- The one way to read a string the client handed us. WoW 12.x marks some values "secret"
-- (world-cursor tooltips, unit menus, restricted-context UnitName): reading one is fine, but
-- once our own code taints the execution, comparing or boolean-testing it is a Lua error and
-- `:gsub` on it is a banned indexed access. A secret carries nothing we could read, and an
-- empty string already means "absent", so both collapse to nil. The secret test has to come
-- before every comparison below, including `== ""`.
function Util.plainString(value)
	if value ~= nil and type(issecretvalue) == "function" and issecretvalue(value) then
		return nil
	end
	if type(value) ~= "string" or value == "" then
		return nil
	end
	return value
end

-- True when a key event is the copy shortcut (Ctrl+C). Pure, so it's unit-tested;
-- IsControlKeyDown() may return 1/nil on older clients, so coerce.
function Util.isCopyShortcut(key, isControlDown)
	return (key == "C" or key == "c") and not not isControlDown
end

function Util.inCombat()
	if type(InCombatLockdown) == "function" and InCombatLockdown() then
		return true
	end
	if type(UnitAffectingCombat) == "function" and UnitAffectingCombat("player") then
		return true
	end
	return false
end

function Util.inInstance()
	if type(IsInInstance) ~= "function" then
		return false
	end
	local inside = IsInInstance()
	return inside and true or false
end

function Util.debug(...)
	if not (SeramateSettings and SeramateSettings.debug) then
		return
	end
	print("|cff2ec7b8Seramate|r:", ...)
end

-- Percent-encode like PHP's rawurlencode: keep only unreserved chars, encode every other
-- byte (multi-byte UTF-8 realm names become a run of %XX bytes, which is correct).
function Util.urlEncode(text)
	return (text:gsub("[^%w%-%.%_%~]", function(char)
		return string.format("%%%02X", string.byte(char))
	end))
end

-- WoW hands addons names that can carry UI escape sequences: class-color codes
-- (|cAARRGGBB ... |r) and, in rated PvP, |K...|k substitution tokens standing in for an
-- obfuscated name the client resolves privately. Strip them so a name never leaks raw
-- escapes into a profile URL; a name that reduces to empty (an obfuscated token) is not a
-- real character we can link to.
function Util.cleanName(text)
	text = Util.plainString(text)
	if not text then
		return ""
	end
	text = text:gsub("|H.-|h(.-)|h", "%1")
	text = text:gsub("|K.-|k", "")
	text = text:gsub("|T.-|t", ""):gsub("|A.-|a", "")
	text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
	text = text:gsub("^%s+", ""):gsub("%s+$", "")
	return text
end

-- Canonical seramate.com profile URL. Realm is the display NAME (encoded, spaces -> %20);
-- a hyphen slug 404s. Mirrors the backend ToolFormatHelper::seramateProfileUrl.
function Util.profileUrl(region, name, realmName)
	return string.format(
		"https://seramate.com/%s/%s/%s",
		Util.urlEncode(region),
		Util.urlEncode(realmName),
		Util.urlEncode(name)
	)
end
