local _, ns = ...

-- GetCurrentRegion() ids. Only regions Seramate exports have a data addon; the rest simply
-- never load and every lookup misses (empty working tables).
local REGION_BY_ID = { [1] = "US", [2] = "KR", [3] = "EU", [4] = "TW", [5] = "CN" }

ns.DB = { HORDE = {}, ALLIANCE = {} }

local function loadRegionData()
	local id = (type(GetCurrentRegion) == "function") and GetCurrentRegion() or nil
	local region = id and REGION_BY_ID[id] or nil
	ns.region = region and region:lower() or nil

	if not region then
		ns.Util.debug("unknown region id", tostring(id))
		return
	end

	local addonName = "Seramate_DB_" .. region
	if not C_AddOns.GetAddOnInfo(addonName) then
		ns.Util.debug("no data addon installed for region", region)
		return
	end

	local loaded, reason = C_AddOns.LoadAddOn(addonName)
	if not loaded then
		ns.Util.debug("failed to load", addonName, tostring(reason))
		return
	end

	ns.DB.HORDE = _G["SeramateDB_" .. region .. "_HORDE"] or {}
	ns.DB.ALLIANCE = _G["SeramateDB_" .. region .. "_ALLIANCE"] or {}
	ns.Util.debug("loaded", addonName)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
	ns.Settings.init()
	loadRegionData()
end)
