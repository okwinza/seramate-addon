<div align="center">

<img src=".github/assets/logo.png" width="120" alt="Seramate PvP Inspect" />

<h1>Seramate PvP Inspect</h1>

<p><em>See any player's PvP ratings and notable titles, right on their in-game tooltip.</em></p>

<p>
  <img src="https://img.shields.io/badge/WoW-Retail-FDA033?style=flat-square&labelColor=0E1013" alt="WoW Retail" />
  <img src="https://img.shields.io/badge/regions-EU%20%7C%20US-FDA033?style=flat-square&labelColor=0E1013" alt="Regions EU and US" />
  <img src="https://img.shields.io/badge/brackets-2v2%20%7C%203v3%20%7C%20RBG-FDA033?style=flat-square&labelColor=0E1013" alt="Brackets 2v2 3v3 RBG" />
  <img src="https://img.shields.io/badge/data-seramate.com-FDA033?style=flat-square&labelColor=0E1013" alt="Data from seramate.com" />
</p>

</div>

## What it does

Hover any player and Seramate PvP Inspect adds their arena and battleground standing to the tooltip. The data comes from Seramate's own PvP ladder database and is bundled into the addon, so lookups are instant and work fully offline while you play.

<table>
<tr><td><b>Current rating</b></td><td>2v2, 3v3, and Rated Battlegrounds</td></tr>
<tr><td><b>This-expansion peak</b></td><td>the highest rating hit in each bracket</td></tr>
<tr><td><b>Notable titles</b></td><td>the character's top titles, colored by prestige tier</td></tr>
<tr><td><b>Tier-colored ratings</b></td><td>green, blue, purple, and orange, so skill reads at a glance</td></tr>
<tr><td><b>Last Updated</b></td><td>a freshness date on every tooltip</td></tr>
<tr><td><b>Profile copy-link</b></td><td>right-click a player to copy their seramate.com profile</td></tr>
</table>

Titles are colored by prestige tier, low to high:

<div align="center">
  <img src=".github/assets/rank/combatant.png" width="40" alt="Combatant" />
  <img src=".github/assets/rank/challenger.png" width="40" alt="Challenger" />
  <img src=".github/assets/rank/rival.png" width="40" alt="Rival" />
  <img src=".github/assets/rank/duelist.png" width="40" alt="Duelist" />
  <img src=".github/assets/rank/elite.png" width="40" alt="Elite" />
  <img src=".github/assets/rank/legend.png" width="40" alt="Legend" />
  <img src=".github/assets/rank/gladiator.png" width="40" alt="Gladiator" />
  <img src=".github/assets/rank/r1.png" width="40" alt="Rank 1" />
</div>

## Where it shows

<table>
<tr><td><b>Tooltips</b></td><td>player unit frames, portraits, and nameplates</td></tr>
<tr><td><b>LFG / Premade Groups</b></td><td>group leaders in the results, and applicants to your group</td></tr>
<tr><td><b>Battle.net friends</b></td><td>online friends who are playing WoW</td></tr>
<tr><td><b>Right-click menu</b></td><td>the "Seramate Profile" copy-link</td></tr>
</table>

## Install

The download contains three folders. Drop all three into `World of Warcraft/_retail_/Interface/AddOns/`:

- **Seramate**: the addon itself (UI and logic), always loaded.
- **Seramate_DB_EU** and **Seramate_DB_US**: the bundled rating databases, one per region, loaded on demand so only your region is held in memory.

Reload or restart WoW after copying.

## Settings and commands

Type **`/seramate`** (or the shorter **`/sera`** or **`/sm`**) to open settings.

<div align="center">
  <img src=".github/assets/settings.png" width="560" alt="Seramate PvP Inspect settings panel" />
</div>

Two sets of toggles, all on by default:

- **Lines**: which rows appear. Current 2v2 / 3v3 / RBG, this-expansion 2v2 / 3v3 / RBG, Titles, and Last Updated.
- **Surfaces**: which tooltips the addon hooks. Character tooltip, LFG / Premade Groups, and Battle.net friends.

`/seramate dbg` (or `/seramate debug`) toggles debug messages on and off.

## Coverage and data

- **EU and US** characters who reached at least **1500** rating in any bracket this season.
- Data is bundled into the addon, so lookups are local with no network calls.
- Refreshed by new releases, published daily when the ladder changes.

## How it works

Seramate ingests the entire WoW PvP ladder. A backend command packs each region's ratings and titles into Lua files and publishes them; a GitHub Actions workflow fetches the latest data and cuts a release. In-game, the addon resolves the hovered character by `Name-Realm` and renders their ratings and titles into the tooltip.

## Development

Pure-Lua modules under `Core/`, `Surfaces/`, `Settings/`, with the generated realm map in `Data/realms.lua`. The bundled `*_HORDE.lua` / `*_ALLIANCE.lua` data files are not in git; the release workflow fetches them from R2 at build time.

- Lint: `luacheck .`
- Tests: `lua5.1 tests/run.lua` (pure-logic tests with a mocked WoW API).
- Release: `.github/workflows/release.yml` (fetch data from R2, then the BigWigs packager to a GitHub Release), triggered by a data refresh, a manual run, or the daily cron.

This is an original, clean-room implementation. None of the code, data, realm list, or naming of any third-party addon is used.

<div align="center"><sub>Data from <a href="https://seramate.com">seramate.com</a>. Artwork &copy; Seramate.</sub></div>
