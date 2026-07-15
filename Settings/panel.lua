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

-- The base tooltip layout, applied both in and out of combat (combat can override it below).
local LAYOUT_MODES = { full = true, compact = true }

Settings_.LAYOUT_OPTIONS = {
	{ mode = "full", label = "Full" },
	{ mode = "compact", label = "Compact" },
}

function Settings_.layoutMode()
	local mode = SeramateSettings and SeramateSettings.layout
	if LAYOUT_MODES[mode] then
		return mode
	end
	return "full"
end

function Settings_.setLayoutMode(mode)
	SeramateSettings = SeramateSettings or {}
	SeramateSettings.layout = LAYOUT_MODES[mode] and mode or "full"
end

-- What the tooltip does while in combat. "inherit" uses the base layout above; the others
-- override it. ("show" is the pre-Layout value name and still maps to inherit.)
local COMBAT_MODES = { inherit = true, compact = true, hide = true }

Settings_.COMBAT_OPTIONS = {
	{ mode = "inherit", label = "Same as usual" },
	{ mode = "compact", label = "Compact summary" },
	{ mode = "hide", label = "Hide" },
}

function Settings_.combatMode()
	local mode = SeramateSettings and SeramateSettings.combat
	if mode == "show" then
		return "inherit"
	end
	if COMBAT_MODES[mode] then
		return mode
	end
	return "inherit"
end

function Settings_.setCombatMode(mode)
	SeramateSettings = SeramateSettings or {}
	SeramateSettings.combat = COMBAT_MODES[mode] and mode or "inherit"
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

-- A mutually exclusive radio group bound to get/set mode accessors; returns the next y.
local function addRadioRows(panel, y, options, getMode, setMode)
	local buttons = {}
	local function refresh()
		local current = getMode()
		for _, button in ipairs(buttons) do
			button:SetChecked(button.mode == current)
		end
	end

	for _, option in ipairs(options) do
		local button = CreateFrame("CheckButton", nil, panel, "UIRadioButtonTemplate")
		button:SetSize(16, 16)
		button:SetPoint("TOPLEFT", 24, y - 4)
		button.mode = option.mode
		button:SetScript("OnClick", function(self)
			setMode(self.mode)
			refresh()
		end)

		local label = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		label:SetPoint("LEFT", button, "RIGHT", 4, 0)
		label:SetText(option.label)

		buttons[#buttons + 1] = button
		y = y - 24
	end

	refresh()
	return y
end

-- A scrollable content frame filling the canvas. The Settings canvas layout does not scroll
-- on its own, and our controls are taller than the viewport, so widgets are parented to this
-- child (not the panel) and the child grows to fit. Returns panel, content, setContentHeight.
local function buildScrollableCanvas()
	local panel = CreateFrame("Frame")
	panel.name = "Seramate PvP Inspect"

	local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", 3, -3)
	scroll:SetPoint("BOTTOMRIGHT", -27, 3) -- leave room for the scrollbar on the right

	local content = CreateFrame("Frame", nil, scroll)
	content:SetSize(1, 1)
	scroll:SetScrollChild(content)
	-- Match the child width to the viewport so anchors and wrapping stay correct as it resizes.
	scroll:SetScript("OnSizeChanged", function(_, width)
		content:SetWidth(width)
	end)

	local function setContentHeight(bottomY)
		content:SetHeight(math.abs(bottomY) + 16)
	end

	return panel, content, setContentHeight
end

local function buildCanvas()
	local panel, content, setContentHeight = buildScrollableCanvas()

	local title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText("Seramate PvP Inspect")

	local sub = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
	sub:SetText("Choose what to show, and which tooltips to show it on.")

	local y = -64
	y = addSectionHeader(content, "Layout", y)
	y = addRadioRows(content, y, Settings_.LAYOUT_OPTIONS, Settings_.layoutMode, Settings_.setLayoutMode)

	y = y - 10
	y = addSectionHeader(content, "Lines", y)
	for _, row in ipairs(ns.Schema.rows) do
		y = addToggleRow(content, row.section .. ": " .. row.label, "lines", row.key, y)
	end
	y = addToggleRow(content, ns.Schema.titlesRow.label, "lines", ns.Schema.titlesRow.key, y)
	y = addToggleRow(content, ns.Schema.updatedRow.label, "lines", ns.Schema.updatedRow.key, y)

	y = y - 10
	y = addSectionHeader(content, "Surfaces", y)
	for _, surface in ipairs(ns.Schema.surfaces) do
		y = addToggleRow(content, surface.label, "surfaces", surface.key, y)
	end

	y = y - 10
	y = addSectionHeader(content, "In Combat", y)
	y = addRadioRows(content, y, Settings_.COMBAT_OPTIONS, Settings_.combatMode, Settings_.setCombatMode)

	setContentHeight(y)
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
