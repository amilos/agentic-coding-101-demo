---
name: openspec-archive
description: Archive a merged OpenSpec change (archive step) and fold its spec into the living spec.
---

You are running the OpenSpec **archive** step for a change that has been
**applied and merged**.

1. Confirm the change under `openspec/changes/<change-id>/` is merged to `main`.
2. Fold the change's spec delta (`specs/**/spec.md`, the `ADDED` / `MODIFIED`
   requirements) into the canonical, always-true specification under
   `openspec/specs/<capability>/`.
3. Move the change folder to `openspec/changes/archive/<YYYY-MM-DD>-<change-id>/`.
4. Summarise what became permanent spec and what was archived.

Nothing in the application code changes during archive — this only updates the
specification records.
