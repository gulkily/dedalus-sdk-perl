# Dedalus Perl SDK Methodology

This methodology explains how we will execute the implementation plan, capture knowledge from the Python SDK, and keep work auditable. It is intentionally lightweight so we can iterate as we learn more.

## Guiding principles
- Mirror user-facing behavior from the Python SDK while embracing idiomatic Perl tooling.
- Ship in testable increments so we can demo progress and surface issues early.
- Prefer automation over manual drift: shared helpers for serialization, retries, and models minimize copy/paste bugs.
- Keep every discovery documented in-repo to preserve context for future contributors.

## Work artifacts
- `PLAN.md` describes the high-level phases.
- `CHECKLIST.md` is the source of truth for day-to-day work; update it as soon as a task is started or completed so status never lags reality.
- `NOTES-python-audit.md` (create on first audit session) will capture findings while reading the Python SDK: date, files touched, API behaviors, open questions.
- Tests under `t/` serve as executable specs; each new feature should include or update tests.

## Execution loop
1. **Select next checklist item**: Pull the highest-priority unchecked item from `CHECKLIST.md`. If a task is large, break it into subtasks directly in the checklist before starting.
2. **Research / audit**: When the task depends on Python SDK behavior, log findings in `NOTES-python-audit.md` so we never re-discover the same detail.
3. **Design stub**: Sketch module/file layout and interfaces (docstrings, POD, or comments) before writing code to keep reviewers aligned.
4. **Implement incrementally**: Commit small, logically complete changes. Reuse shared helpers and keep interfaces consistent with the Python reference.
5. **Test immediately**: Add or update unit/integration tests; run the relevant test subset before moving on. Document gaps in the notes file if tests are deferred.
6. **Update docs/checklist**: Mark the checklist checkbox immediately, note any follow-ups, and extend README/API docs if the change affects users. Do not end a work session without updating `CHECKLIST.md` to reflect what changed.
7. **Commit per checklist step**: Once an item (or coherent sub-item) is complete and documented, create a git commit referencing that checklist line so history mirrors the checklist. If work spans multiple steps, split into separate commits accordingly.

## Knowledge capture while inspecting the Python SDK
- Create `NOTES-python-audit.md` with sections per Python component (e.g., resources, helpers, streaming, tests).
- For each file inspected, add:
  - Date + author initials
  - Filename/path
  - Key behaviors/contracts to replicate
  - Open questions or TODOs
  - Links back to checklist items or GitHub issues if applicable
- Reference this log when creating Perl modules so reviewers can trace how requirements were derived.

## Reviews and quality gates
- Every feature PR should include: code, tests, doc updates, and a link to the relevant checklist items.
- Run lint + tests (once available) in CI; locally, run the same commands before opening a PR.
- For risky areas (streaming, async, multipart) require an additional maintainer review focused on parity with the Python SDK.

## Release cadence
- Target releases per major milestone (e.g., after completing resource modules, after adding async support).
- Each release requires: updated `Changes`, version bump, passing CI, and documentation of new features/known gaps.

Adhering to this methodology keeps implementation predictable, ensures knowledge from the Python SDK is preserved, and gives us clear checkpoints toward a full-featured Perl SDK.
