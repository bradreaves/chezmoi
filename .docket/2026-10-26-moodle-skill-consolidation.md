# Moodle skill consolidation — 2026-10-26

The legacy `~/.claude/skills/moodle-grading` skill was compared with the teaching-tools
LMS plugin under NC State Google Drive's `My Drive/_Teaching/teaching-tools`.

## Preserved differences

- Added the per-student extension route to `lms-admin`, its Moodle binding and
  `moodle-recipes.md`: resolve the recipient by email, use the current course timezone
  and default due time explicitly, write the individual override, then compare
  `lastattempt.extensionduedate` with the intended epoch timestamp.
- Added explicit duplicate-ID preflight for the baseline and edited grading sheets.
  The current helper does not explicitly reject duplicate rows, so the skill requires
  this additional check before use.
- Added the comments-feedback capability check. The existing writer always sends
  comments fields; stop if that plugin is disabled and adapt the writer before use.
- Preserved explicit per-student write previews and stop-on-first-failure behavior.
  Use `post --only` and `verify --only` per approved student because the existing
  unrestricted batch helper continues after a per-student write error.

The existing plugin already covers read-only discovery, participant identity, staged
files and hashes, duplicate-document caveats, late submissions, Numbers/Sheets export
pitfalls, stable CSV identity, blank-grade confirmation, HTML feedback, independent
grade and feedback reads, credential handling, and destructive-operation approval.
Its newer CSV column names and split read/write clients were retained. No runtime
script was changed and no live LMS API was called. Plugin manifest version is 1.0.1.

## Validation and availability

`bash scripts/check-seam.sh` passed all checks. Codex's supported plugin installer
refreshed `lms@teaching-tools`; all five modified source files match the installed
cache byte-for-byte. Start a new session to load the updated skill instructions.

Claude has this directory marketplace registered but no global LMS installation.
Its existing course-scoped setup remains unchanged; enable/install the LMS plugin in
the intended course context as documented by teaching-tools. No global Claude settings
were changed to enable it everywhere.

The marketplace is not a Git repository. Its updated source lives in the existing
Google Drive directory; server-side Drive upload completion was not verified. The
sibling `2026-10-26-moodle-consolidation.patch` preserves the exact five-file update
in this Git repository independently of Drive upload state. Apply it from the
teaching-tools root to the preceding source version with:

```sh
git apply --check /path/to/2026-10-26-moodle-consolidation.patch
git apply /path/to/2026-10-26-moodle-consolidation.patch
```

The patch was checked in reverse against the updated source and contains no credentials.
The old local skill is retired to Trash after this record is committed and pushed.
