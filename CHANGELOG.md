# Changelog

## Unreleased

- New "In Combat" setting (`/seramate`): choose what the tooltip does while you're fighting —
  show everything (default), a compact summary (one line per rating section plus your best
  title), or hide the Seramate block entirely.

- Performance: the bundled databases no longer hold any per-record Lua tables — titles are
  a shared per-file dictionary with per-record index references, and bracket ratings are
  packed strings; both decode lazily on first tooltip view. Versus the old format this cuts
  the database size by ~60%, in-game memory by ~67% and Lua GC cycle cost by ~64% (the
  cause of reported FPS degradation a few minutes into a session). Fully compatible with
  old-format databases.
- Initial release: PvP rating tooltips (2v2 / 3v3 / RBG) on unit frames, nameplates, the
  LFG browser, and the Battle.net friends list; right-click "Seramate Profile" copy-link;
  per-region bundled databases (EU / US); in-game settings (`/seramate`).
