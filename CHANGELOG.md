# Changelog

## Unreleased

- Performance: titles in the bundled databases are now a shared per-file dictionary with
  per-record index references, decoded lazily on first tooltip view. Cuts the database
  size by ~60% and roughly halves its in-game memory and Lua GC cost (the cause of
  reported FPS degradation a few minutes into a session). Fully compatible with old-format
  databases.
- Initial release: PvP rating tooltips (2v2 / 3v3 / RBG) on unit frames, nameplates, the
  LFG browser, and the Battle.net friends list; right-click "Seramate Profile" copy-link;
  per-region bundled databases (EU / US); in-game settings (`/seramate`).
