std = "lua51"
max_line_length = false
codes = true

-- Files we author. Generated data, the realm map, and the test harness are not linted.
exclude_files = {
	"Seramate_DB_US/*.lua",
	"Seramate_DB_EU/*.lua",
	"Data/realms.lua",
	"tests/",
	".release/",
}

-- Addon-owned globals + Blizzard tables we write a field into.
globals = {
	"SeramateSettings",
	"SLASH_SERAMATE1",
	"SLASH_SERAMATE2",
	"SLASH_SERAMATE3",
	"SlashCmdList",
}

-- Blizzard API surface the addon touches (read-only).
read_globals = {
	"CreateFrame", "GameTooltip", "FriendsTooltip", "UIParent", "UISpecialFrames",
	"UnitName", "UnitGUID", "UnitIsPlayer", "GetRealmName", "GetNormalizedRealmName",
	"GetCurrentRegion", "GetPlayerInfoByGUID", "IsInInstance", "InCombatLockdown",
	"UnitAffectingCombat", "issecretvalue", "IsControlKeyDown", "IsShiftKeyDown",
	"C_AddOns", "C_LFGList", "C_BattleNet", "C_Timer",
	"TooltipDataProcessor", "Enum", "Menu", "Settings",
	"hooksecurefunc", "EventUtil", "GetMouseFoci",
	"LFGListSearchEntry_OnEnter", "LFGListApplicantMember_OnEnter",
	"BackdropTemplateMixin", "CreateColor", "wipe", "tinsert",
	"FRIENDS_BUTTON_TYPE_BNET", "BNET_CLIENT_WOW",
}
