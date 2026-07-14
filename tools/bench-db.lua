-- Benchmark the GC cost of loaded DB files — the driver of the in-game FPS impact.
-- WoW's incremental GC re-marks every live object each collection cycle, so what matters
-- is the live table count and how long a full mark/sweep takes, not the file size.
--   $ lua5.1 tools/bench-db.lua <file.lua> [more files...]
-- Pass both faction files of a region to mimic what one client loads. Compare an
-- old-format export against a new-format one (title dictionary + t="1,5,9" refs).

local files = { ... }
if #files == 0 then
	print("usage: lua5.1 tools/bench-db.lua <db-file.lua> [more files...]")
	os.exit(1)
end

local function countObjects(root)
	local tables, strings, seenTables, seenStrings = 0, 0, {}, {}
	local function walk(value)
		local kind = type(value)
		if kind == "string" then
			if not seenStrings[value] then
				seenStrings[value] = true
				strings = strings + 1
			end
			return
		end
		if kind ~= "table" or seenTables[value] then
			return
		end
		seenTables[value] = true
		tables = tables + 1
		for key, item in pairs(value) do
			walk(key)
			walk(item)
		end
	end
	walk(root)
	return tables, strings
end

-- Min over N cycles: full-collect cost is deterministic work, so the minimum is the
-- true cost and the rest is scheduler/frequency noise (significant under WSL2/VMs).
local function fullGcSeconds(rounds)
	local best
	for _ = 1, rounds do
		local start = os.clock()
		collectgarbage("collect")
		local elapsed = os.clock() - start
		if not best or elapsed < best then
			best = elapsed
		end
	end
	return best
end

collectgarbage("collect")
local baseKb = collectgarbage("count")
local baseGc = fullGcSeconds(15)

local loadStart = os.clock()
for _, path in ipairs(files) do
	assert(loadfile(path))()
end
local loadSeconds = os.clock() - loadStart

collectgarbage("collect")
local loadedKb = collectgarbage("count")
local loadedGc = fullGcSeconds(15)

local tables, strings = 0, 0
for name, value in pairs(_G) do
	if type(name) == "string" and name:find("^SeramateDB_") and type(value) == "table" then
		local t, s = countObjects(value)
		tables, strings = tables + t, strings + s
	end
end

print(string.format("files loaded:        %d", #files))
print(string.format("parse+exec time:     %.2f s", loadSeconds))
print(string.format("live heap:           %.1f MB (baseline %.1f KB)", (loadedKb - baseKb) / 1024, baseKb))
print(string.format("live tables:         %d", tables))
print(string.format("unique strings:      %d", strings))
print(string.format("full GC cycle:       %.1f ms (baseline %.2f ms)", loadedGc * 1000, baseGc * 1000))
