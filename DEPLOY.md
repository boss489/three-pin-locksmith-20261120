# Publication — three-pin-locksmith

Only this selected puzzle project is authorized for public publication at `boss489/three-pin-locksmith-20261120`. Godot 4.7.2 source remains in the project root; the release Web export remains in `web/`. GitHub Pages branch publishing cannot use `/web`, so `docs/` contains a byte-for-byte copy of the Web runtime and human-readable `OFL.txt`, plus `.nojekyll`. `docs/.gdignore` keeps the duplicate site out of future Godot imports. No engine replacement or hosted backend.

Preflight (2026-11-20): `gh auth status` and `gh api user` confirmed `boss489`; target API returned 404 before creation. Model and UI tests PASS; the latter emits teardown-only resource warnings. Existing Web PCK SHA-256: `7a5cd2e3e1f5df467984e6e24ee96d1ca3514220845358b4eb6e89b178edf572`. The font license in `assets/OFL.txt`, `web/OFL.txt`, and `docs/OFL.txt` matches. Staged scope is source/tests/licensed assets and the two Web runtime directories; `.godot`, `*.import`, and screenshots excluded. Text secret-pattern scan found no hits. `git diff --cached --check` found only existing trailing whitespace in three OFL copies and a generated HTML terminal blank line; license/export bytes left intact.

Rollback: disable GitHub Pages for this repository or change its source; take the repository private only if coordinated with the owner. Neither rollback should be confused with revocation of already-fetched public copies.

Public URL, remote SHA, Pages build and live asset/play verification are recorded below after deployment.
