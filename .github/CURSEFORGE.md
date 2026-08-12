# Seramate PvP Inspect

_See any player's PvP ratings and notable titles, right on their in-game tooltip._

![WoW Retail](https://img.shields.io/badge/WoW-Retail-FFB347?style=flat-square&labelColor=0E1013) ![Regions EU and US](https://img.shields.io/badge/regions-EU%20%7C%20US-FFB347?style=flat-square&labelColor=0E1013) ![Brackets 2v2 3v3 RBG Shuffle Blitz](https://img.shields.io/badge/brackets-2v2%20%7C%203v3%20%7C%20RBG%20%7C%20Shuffle%20%7C%20Blitz-FFB347?style=flat-square&labelColor=0E1013) ![Data from seramate.com](https://img.shields.io/badge/data-seramate.com-FFB347?style=flat-square&labelColor=0E1013) ![Updates daily](https://img.shields.io/badge/updates-daily-FFB347?style=flat-square&labelColor=0E1013)

![Ratings on a Battle.net friend tooltip](https://cdn.seramate.com/addon/assets/surfaces/friends.png)

## What it does

Hover any player and Seramate PvP Inspect adds their arena and battleground standing to the tooltip. The data comes from Seramate's own PvP ladder database and is bundled into the addon, so lookups are instant and work fully offline.

| &nbsp; | &nbsp; |
| --- | --- |
| **Current rating** | 2v2, 3v3, Rated Battlegrounds, Solo Shuffle, and Battleground Blitz |
| **This-expansion peak** | the highest rating hit in each bracket |
| **Notable titles** | the character's top titles, colored by prestige tier |
| **Tier-colored ratings** | green, blue, purple, and orange, so skill reads at a glance |
| **Last Updated** | a freshness date on every tooltip |
| **Profile copy-link** | right-click a player to copy their seramate.com profile |

## Where it shows

Seramate PvP Inspect hooks every surface where other players appear.

### Character tooltips

Player unit frames, portraits, and nameplates — hover anyone to see their ratings and titles.

### LFG / Premade Groups

Group leaders in the Premade Groups results, and applicants to your own group.

### Battle.net friends

Online friends currently playing WoW, on the friends-list tooltip.

### Guild & Communities

Members in the guild panel and WoW communities, on the roster hover tooltip — including the expanded Roster view, where the stock UI shows no tooltip at all.

## Copy Seramate Profile

Right-click a player and hit **Copy Profile Link**. The popup opens with their seramate.com URL already selected, and closes itself once you press Ctrl+C.

The entry is in every right-click menu a character has:

- players in the world, and party or raid frames
- enemy players
- your friends list — online, offline, and Battle.net friends
- guild and community rosters
- the Group Finder — both the listings you browse and the applicants to your own group

![Copy dialog with a preselected seramate.com profile URL](https://cdn.seramate.com/addon/assets/surfaces/copy-profile.png)

## Install (CurseForge)

Press the [**Download**] button — that's it. Leave auto-update on in the CurseForge app, so the bundled ratings stay current.

## Install (Manual)

The download contains three folders. Drop all three into `World of Warcraft/_retail_/Interface/AddOns/`:

- **Seramate**: the addon itself (UI and logic), always loaded.
- **Seramate_DB_EU** and **Seramate_DB_US**: the bundled rating databases, one per region, loaded on demand so only your region is held in memory.

Reload or restart WoW after copying.

## Settings and commands

Type **`/seramate`** (or the shorter **`/sera`** or **`/sm`**) to open settings.

![Seramate PvP Inspect settings panel](https://cdn.seramate.com/addon/assets/settings.png)

## Coverage and data

- **EU and US** characters who reached at least **1500** rating in any bracket this season (**1800** for Solo Shuffle and Battleground Blitz).
- Refreshed by new releases, published daily.

## Support Seramate

If you'd like to help keep Seramate growing — and pick up a few perks along the way — check out our [Patreon page](https://seramate.com/patreon).

<a href="https://seramate.com/patreon"><img src="https://cdn.seramate.com/addon/assets/patreon-button.png" width="352" alt="Become a patron"></a>
