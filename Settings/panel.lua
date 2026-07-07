local _, ns = ...

-- Owns the SeramateSettings SavedVariable and the options panel. Two kinds of toggle, both
-- defaulting to enabled when absent: per-line (which rows show) and per-surface (which
-- tooltips the addon hooks).
local Settings_ = {}
ns.Settings = Settings_

local function store(scope)
	SeramateSettings = SeramateSettings or {}
	SeramateSettings[scope] = SeramateSettings[scope] or {}
	return SeramateSettings[scope]
end

function Settings_.isLineEnabled(key)
	return Settings_.get(key, "lines")
end

function Settings_.isSurfaceEnabled(key)
	return Settings_.get(key, "surfaces")
end

function Settings_.get(key, scope)
	local value = store(scope)[key]
	if value == nil then
		return true
	end
	return value
end

function Settings_.set(key, scope, value)
	store(scope)[key] = value and true or false
end

-- The per-line predicate the renderer uses to decide which rows to show.
function Settings_.enabler()
	return Settings_.isLineEnabled
end

local function makeCheckbox(parent, scope, key)
	local box = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	box:SetSize(24, 24)
	box:SetChecked(Settings_.get(key, scope))
	box:SetScript("OnClick", function(self)
		Settings_.set(key, scope, self:GetChecked())
	end)
	return box
end

local function addSectionHeader(panel, text, y)
	local label = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	label:SetPoint("TOPLEFT", 16, y)
	label:SetText(text)
	return y - 24
end

-- A single labelled checkbox bound to SeramateSettings[scope][key]; returns the next y.
local function addToggleRow(panel, text, scope, key, y)
	local box = makeCheckbox(panel, scope, key)
	box:SetPoint("TOPLEFT", 20, y)
	local label = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	label:SetPoint("LEFT", box, "RIGHT", 4, 0)
	label:SetText(text)
	return y - 28
end

local function buildCanvas()
	local panel = CreateFrame("Frame")
	panel.name = "Seramate PvP Inspect"

	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText("Seramate PvP Inspect")

	local sub = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
	sub:SetText("Choose what to show, and which tooltips to show it on.")

	local y = -64
	y = addSectionHeader(panel, "Lines", y)
	for _, row in ipairs(ns.Schema.rows) do
		y = addToggleRow(panel, row.section .. ": " .. row.label, "lines", row.key, y)
	end
	y = addToggleRow(panel, ns.Schema.titlesRow.label, "lines", ns.Schema.titlesRow.key, y)
	y = addToggleRow(panel, ns.Schema.updatedRow.label, "lines", ns.Schema.updatedRow.key, y)

	y = y - 10
	y = addSectionHeader(panel, "Surfaces", y)
	for _, surface in ipairs(ns.Schema.surfaces) do
		y = addToggleRow(panel, surface.label, "surfaces", surface.key, y)
	end

	return panel
end

local function registerPanel()
	if type(Settings) ~= "table" or type(Settings.RegisterCanvasLayoutCategory) ~= "function" then
		return
	end
	local panel = buildCanvas()
	-- RegisterCanvasLayoutCategory assigns a numeric category id. Overwriting category.ID with a
	-- string makes GetID() return that string, which OpenToCategory (C_SettingsUtil.OpenSettingsPanel)
	-- rejects as out-of-int-range. Keep the framework's id; store the category and read it at open time.
	local category = Settings.RegisterCanvasLayoutCategory(panel, "Seramate PvP Inspect")
	Settings.RegisterAddOnCategory(category)
	Settings_._category = category
end

function Settings_.openPanel()
	local category = Settings_._category
	if not category or type(Settings) ~= "table" or not Settings.OpenToCategory then
		return
	end
	local id = category:GetID()
	if type(id) == "number" then
		Settings.OpenToCategory(id)
	end
end

local function registerSlash()
	SLASH_SERAMATE1 = "/seramate"
	SLASH_SERAMATE2 = "/sera"
	SLASH_SERAMATE3 = "/sm"
	SlashCmdList["SERAMATE"] = function(msg)
		msg = (msg or ""):lower():gsub("%s+", "")
		if msg == "dbg" or msg == "debug" then
			SeramateSettings.debug = not (SeramateSettings and SeramateSettings.debug)
			print("|cff2ec7b8Seramate|r debug:", SeramateSettings.debug and "on" or "off")
			return
		end
		Settings_.openPanel()
	end
end

function Settings_.init()
	SeramateSettings = SeramateSettings or {}
	registerPanel()
	registerSlash()
end
