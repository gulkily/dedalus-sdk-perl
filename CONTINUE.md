# Continuation notes

Async coverage now includes models, health checks, and sample scripts for embeddings/images. Remaining focus areas from `CHECKLIST.md`:

1. Finish "Support nested sub-resources and consistent signatures" by reviewing remaining resources in the Python SDK (chat submodules, potential files endpoints).
2. Tackle other checklist items: file helper parity is mostly done via `Dedalus::Util::Multipart`, but we still need CI/tooling, additional tests, and release documentation.

Consider adding async wrappers for any new resources you implement going forward so parity stays intact.

When resuming, run `git status` (repo clean except for personal files like `examples/gdi_exclamation.wav`) and refer to `PLAN.md` / `CHECKLIST.md` to choose the next task.
