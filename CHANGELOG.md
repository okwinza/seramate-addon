# Changelog

- Copy a player as Name-Server: a switch on the copy popup flips between the seramate.com
  link and the character's `Name-Server` (`Seraphita-ArgentDawn`), ready for `/w`, `/inv` or
  a search box. It remembers your pick, and the right-click entry follows it
  ("Copy Name-Server").

- Compact layout: bracket names now have their own muted color, so "2v2 1840" reads as a name
  and a rating rather than one run of text — Full is unchanged (the two sit in separate
  columns there). Tune it as "Bracket name" in `tools/tooltip-colors.html`.

- "Copy Profile Link" in more right-click menus: enemy players, guild & community rosters,
  offline friends, and the Group Finder — both group leaders in the browser and applicants
  to your listing.
- Fix: Lua error `attempt to compare field 'name' (a secret string value…)` when right-clicking
  a player to open the unit menu. The 12.x client hides the name behind a secret value there, so
  the addon now reads the character off the unit — "Copy Profile Link" works again. The tooltip,
  Group Finder, guild and Battle.net surfaces are hardened against the same thing.
- Guild & Communities: hovering a roster member shows their ratings — including the
  expanded Roster view, where the stock UI shows no tooltip at all. Own toggle under
  Surfaces.
- Battleground Blitz ratings: current and this-expansion Blitz rows next to the other
  brackets, with their own Lines toggles. Characters enter the database at 1800+ Blitz,
  the same bar as Solo Shuffle.
- New "Title Colors" settings page: pick your own color for each title tier, with a
  per-tier reset back to the default.

- The "Copy Profile Link" popup now closes itself once you've copied — on Ctrl+C, or when
  you click away — instead of needing a separate Escape press. Dragging it to reposition
  still works.
- Fix: Lua error `bad argument #1 to 'UnitIsPlayer' … Secret values are only allowed during
  untainted execution` when the game showed a world-cursor tooltip (12.x hands addons
  secret unit/GUID values there; the addon now ignores them).
- New "In Instances" setting: what the tooltip does inside arenas, battlegrounds, dungeons
  and raids — same as usual (default), force the compact summary, or hide the Seramate
  block entirely, for those who don't want it while pvping.

- New "Layout" setting (`/seramate`): render the tooltip Full (default) or Compact — the
  compact style folds each rating section to a single line and shows only your best title,
  and now applies everywhere, not just in combat.
- New "In Combat" setting: what the tooltip does while you're fighting — same as usual
  (default), force the compact summary, or hide the Seramate block entirely.

- Performance: the bundled databases no longer hold any per-record Lua tables — titles are
  a shared per-file dictionary with per-record index references, and bracket ratings are
  packed strings; both decode lazily on first tooltip view. Versus the old format this cuts
  the database size by ~60%, in-game memory by ~67% and Lua GC cycle cost by ~64% (the
  cause of reported FPS degradation a few minutes into a session). Fully compatible with
  old-format databases.
- Initial release: PvP rating tooltips (2v2 / 3v3 / RBG) on unit frames, nameplates, the
  LFG browser, and the Battle.net friends list; right-click "Seramate Profile" copy-link;
  per-region bundled databases (EU / US); in-game settings (`/seramate`).
