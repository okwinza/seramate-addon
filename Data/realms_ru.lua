local _, ns = ...

-- Data/realms_ru.lua -- GENERATED (do not edit by hand).
-- The Battle.net friend API (and some unit/LFG paths) hand back realm names in the *other*
-- player's client locale. EU Russian realms carry an English canonical name (our key form)
-- but render in Cyrillic on ruRU clients, e.g. "Свежеватель Душ" for "Soulflayer". Map the space/punctuation-stripped
-- Cyrillic form to the canonical English name so resolveRealm() bridges them on every surface.
-- Sourced from Blizzard's realm index (locale ru_RU), matched by realm id to Seramate's realm
-- table; clean-room, not derived from any third-party addon.
if not ns.Realms then ns.Realms = {} end
local russian = {
	["Ясеневыйлес"]="Ashenvale",  -- Ясеневый лес
	["Азурегос"]="Azuregos",  -- Азурегос
	["ЧерныйШрам"]="Blackscar",  -- Черный Шрам
	["ПиратскаяБухта"]="Booty Bay",  -- Пиратская Бухта
	["Борейскаятундра"]="Borean Tundra",  -- Борейская тундра
	["СтражСмерти"]="Deathguard",  -- Страж Смерти
	["ТкачСмерти"]="Deathweaver",  -- Ткач Смерти
	["Подземье"]="Deepholm",  -- Подземье
	["ВечнаяПесня"]="Eversong",  -- Вечная Песня
	["Дракономор"]="Fordragon",  -- Дракономор
	["Галакронд"]="Galakrond",  -- Галакронд
	["Голдринн"]="Goldrinn",  -- Голдринн
	["Гордунни"]="Gordunni",  -- Гордунни
	["Седогрив"]="Greymane",  -- Седогрив
	["Гром"]="Grom",  -- Гром
	["Ревущийфьорд"]="Howling Fjord",  -- Ревущий фьорд
	["Корольлич"]="Lich King",  -- Король-лич
	["Разувий"]="Razuvious",  -- Разувий
	["СвежевательДуш"]="Soulflayer",  -- Свежеватель Душ
	["Термоштепсель"]="Thermaplugg",  -- Термоштепсель
}
for token, canonical in pairs(russian) do
	ns.Realms[token] = canonical
end
