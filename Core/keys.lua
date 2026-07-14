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

-- Returns the record plus its owning faction table: the title dictionary (`.T`) lives on
-- the owner, so the decoder needs both. (No `and`-chain on the last return — it would
-- truncate the second value and can yield `false` instead of nil.)
local function probe(key)
	local db = ns.DB
	if not db then
		return nil
	end
	local record = db.HORDE and db.HORDE[key]
	if record then
		return record, db.HORDE
	end
	record = db.ALLIANCE and db.ALLIANCE[key]
	if record then
		return record, db.ALLIANCE
	end
	return nil
end

-- Records ship titles as a dictionary-index string (`t="1,5,9"` into `owner.T`) so the DB
-- holds one flat string per record instead of nested tables (Lua GC cost). Decode on first
-- view and memoize — even on failure (missing dictionary, stale indexes) — so a hover never
-- re-parses. The memoized list REUSES the dictionary's {n,w} entry tables; never mutate them.
local function decodeTitles(record, owner)
	if type(record.titles) == "table" or type(record.t) ~= "string" then
		return
	end

	local titles = {}
	local dictionary = owner and owner.T
	if type(dictionary) == "table" then
		for index in record.t:gmatch("%d+") do
			local entry = dictionary[tonumber(index)]
			if entry then
				titles[#titles + 1] = entry
			end
		end
	end
	record.titles = titles
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

	local record, owner = probe(name .. "-" .. realmToken)
	if not record then
		local display = Keys.resolveRealm(realmToken)
		if display ~= realmToken then
			record, owner = probe(name .. "-" .. display)
		end
	end

	if record then
		decodeTitles(record, owner)
	end
	return record
end
