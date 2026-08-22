<div align="center">

<img src=".github/assets/logo.png" width="120" alt="Seramate PvP Inspect" />

<h1>Seramate PvP Inspect</h1>

<p><em>See any player's PvP ratings and notable titles, right on their in-game tooltip.</em></p>

<p>
  <img src="https://img.shields.io/badge/WoW-Retail-FFB347?style=flat-square&labelColor=0E1013" alt="WoW Retail" />
  <img src="https://img.shields.io/badge/regions-EU%20%7C%20US-FFB347?style=flat-square&labelColor=0E1013" alt="Regions EU and US" />
  <img src="https://img.shields.io/badge/brackets-2v2%20%7C%203v3%20%7C%20RBG%20%7C%20Shuffle%20%7C%20Blitz-FFB347?style=flat-square&labelColor=0E1013" alt="Brackets 2v2 3v3 RBG Shuffle Blitz" />
  <img src="https://img.shields.io/badge/data-seramate.com-FFB347?style=flat-square&labelColor=0E1013" alt="Data from seramate.com" />
  <img src="https://img.shields.io/badge/updates-daily-FFB347?style=flat-square&labelColor=0E1013" alt="Updates daily" />
  <a href="https://www.curseforge.com/wow/addons/seramate-pvp-inspect"><img src="https://img.shields.io/curseforge/dt/1607724?style=flat-square&labelColor=0E1013&color=FFB347" alt="CurseForge downloads" /></a>
</p>

</div>

<div align="center"><img src=".github/assets/surfaces/friends.png" width="320" alt="Ratings on a Battle.net friend tooltip" /></div>

## What it does

Hover any player and Seramate PvP Inspect adds their arena and battleground standing to the tooltip. The data comes from Seramate's own PvP ladder database and is bundled into the addon, so lookups are instant and work fully offline.

<table>
<tr><td><b>Current rating</b></td><td>2v2, 3v3, Rated Battlegrounds, Solo Shuffle, and Battleground Blitz</td></tr>
<tr><td><b>This-expansion peak</b></td><td>the highest rating hit in each bracket</td></tr>
<tr><td><b>Notable titles</b></td><td>the character's top titles, colored by prestige tier</td></tr>
<tr><td><b>Tier-colored ratings</b></td><td>green, blue, purple, and orange, so skill reads at a glance</td></tr>
<tr><td><b>Last Updated</b></td><td>a freshness date on every tooltip</td></tr>
<tr><td><b>Profile copy-link</b></td><td>right-click a player to copy their seramate.com profile</td></tr>
</table>

Title tiers, low to high:

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

Seramate PvP Inspect hooks every surface where other players appear.

### Character tooltips

Player unit frames, portraits, and nameplates — hover anyone to see their ratings and titles.

### LFG / Premade Groups

Group leaders in the Premade Groups results, and applicants to your own group.

### Battle.net friends

Online friends currently playing WoW, on the friends-list tooltip.

### Guild & Communities

Members in the guild panel and WoW communities, on the roster hover tooltip — including
the expanded Roster view, where the stock UI shows no tooltip at all.

## Copy Seramate Profile

Right-click a player and hit **Copy Profile Link**. The popup opens with their seramate.com URL already selected, and closes itself once you press Ctrl+C.

The entry is in every right-click menu a character has:

- players in the world, and party or raid frames
- enemy players
- your friends list — online, offline, and Battle.net friends
- guild and community rosters
- the Group Finder — both the listings you browse and the applicants to your own group

<div align="center"><img src=".github/assets/surfaces/copy-profile.png" width="460" alt="Copy dialog with a preselected seramate.com profile URL" /></div>

## Install

Install it from [CurseForge](https://www.curseforge.com/wow/addons/seramate-pvp-inspect) and leave auto-update on, so the bundled ratings stay current.

To install by hand instead: the download contains three folders. Drop all three into `World of Warcraft/_retail_/Interface/AddOns/`:

- **Seramate**: the addon itself (UI and logic), always loaded.
- **Seramate_DB_EU** and **Seramate_DB_US**: the bundled rating databases, one per region, loaded on demand so only your region is held in memory.

Reload or restart WoW after copying.

## Settings and commands

Type **`/seramate`** (or the shorter **`/sera`** or **`/sm`**) to open settings.

<div align="center">
  <img src=".github/assets/settings.png" width="560" alt="Seramate PvP Inspect settings panel" />
</div>

Two sets of toggles, all on by default:

- **Lines**: which rows appear. Current 2v2 / 3v3 / RBG / Shuffle / Blitz, this-expansion 2v2 / 3v3 / RBG / Shuffle / Blitz, Titles, and Last Updated.
- **Surfaces**: which tooltips the addon hooks. Character tooltip, LFG / Premade Groups, Battle.net friends, and Guild & Communities.

Plus display controls:

- **Layout**: Full (default) or Compact. Compact folds each rating section to a single line and shows only your best title; hold **Shift** while opening and viewing the tooltip to show all titles.
- **In Combat**: what happens while you're fighting — same as usual (default), force the compact summary, or hide the Seramate block entirely.
- **In Instances**: the same choices for arenas, battlegrounds, dungeons and raids.
- **Title Colors** (its own settings page): pick your own color for each title tier, with a per-tier reset back to the defaults.

`/seramate dbg` (or `/seramate debug`) toggles debug messages on and off.

## Coverage and data

- **EU and US** characters who reached at least **1500** rating in any bracket this season
  (**1800** for Solo Shuffle and Battleground Blitz), plus anyone who reached **1800** in any
  bracket earlier in the expansion — so the database stays useful in the first weeks of a new
  season, before anyone has re-climbed.
- Refreshed by new releases, published daily when the ladder changes.

## How it works

Seramate ingests the entire WoW PvP ladder. A backend command packs each region's ratings and titles into Lua files and publishes them; a GitHub Actions workflow fetches the latest data and cuts a release. In-game, the addon resolves the hovered character by `Name-Realm` and renders their ratings and titles into the tooltip.

## Development

Pure-Lua modules under `Core/`, `Surfaces/`, `Settings/`, with the generated realm map in `Data/realms.lua`. The bundled `*_HORDE.lua` / `*_ALLIANCE.lua` data files are not in git; the release workflow fetches them from R2 at build time.

- Lint: `luacheck .`
- Tests: `lua5.1 tests/run.lua` (pure-logic tests with a mocked WoW API).
- Release: `.github/workflows/release.yml` (fetch data from R2, then the BigWigs packager to a GitHub Release), triggered by a data refresh, a manual run, or the daily cron.

## Support Seramate

If you'd like to help keep Seramate growing — and pick up a few perks along the way — check out our [Patreon page](https://seramate.com/patreon).

<div align="center">
  <a href="https://seramate.com/patreon">
    <img src=".github/assets/patreon-button.png" width="352" alt="Become a patron" />
  </a>
</div>

<div align="center"><sub>Data from <a href="https://seramate.com">seramate.com</a>. Artwork &copy; Seramate.</sub></div>
