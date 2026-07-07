local _, ns = ...

local Keys = {}
ns.Keys = Keys

-- Strip the exact characters the realm-map generator strips (space, hyphen, apostrophe,
-- period, parentheses) with no case folding — so WoW's normalized forms ("TarrenMill",
-- "AzjolNerub") resolve to the same map key as the display name ("Tarren Mill").
function Keys.normalizeRealm(realm)
	return (realm:gsub("[ %-'%.%(%)]", ""))
end

-- Turn whatever WoW handed us (display, normalized, or a slug) into the exporter's exact
-- realm display name via the generated map; fall back to the input when unknown.
function Keys.resolveRealm(realmToken)
	local realms = ns.Realms
	if not realms then
		return realmToken
	end
	return realms[Keys.normalizeRealm(realmToken)] or realmToken
end

-- Split a combined "Name-Realm" string (LFG / roster) on the first hyphen. Realm names can
-- themselves contain hyphens ("Azjol-Nerub"), so only the first split matters; character
-- names never contain one.
function Keys.splitFullName(full)
	local name, realm = full:match("^(.-)%-(.+)$")
	if name then
		return name, realm
	end
	return full, nil
end

local function probe(key)
	local db = ns.DB
	if not db then
		return nil
	end
	local horde = db.HORDE and db.HORDE[key]
	if horde then
		return horde
	end
	return db.ALLIANCE and db.ALLIANCE[key]
end

-- Look up a character's record. realmToken may be nil (same realm as the player), a display
-- name, or a normalized form. Tries the raw token first (usually the exact key), then the
-- map-resolved display name; probes Horde then Alliance since the caller rarely knows the
-- unit's faction.
function Keys.lookup(name, realmToken)
	if not name or name == "" then
		return nil
	end

	if not realmToken or realmToken == "" then
		realmToken = (type(GetRealmName) == "function") and GetRealmName() or nil
	end
	if not realmToken or realmToken == "" then
		return nil
	end

	local record = probe(name .. "-" .. realmToken)
	if record then
		return record
	end

	local display = Keys.resolveRealm(realmToken)
	if display ~= realmToken then
		record = probe(name .. "-" .. display)
	end
	return record
end
