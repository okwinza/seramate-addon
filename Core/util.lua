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
		ramp[#ramp + 1] = { min = tier.min, color = esc(tier.color) }
	end
	return ramp
end

local BRAND = esc(palette.header)
local SECTION = esc(palette.section)
local LABEL = esc(palette.label)
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

function Util.titleColor(weight)
	for _, tier in ipairs(TITLE_TIERS) do
		if weight >= tier.min then
			return tier.color
		end
	end
	return LABEL
end

function Util.titleText(name, weight)
	return Util.colorize(name, Util.titleColor(weight or 0))
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
	if type(text) ~= "string" then
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
