# Archived changes

This folder holds changes that have been **applied, merged, and archived**.

## What `openspec archive` does

Running, after a change is merged:

```bash
openspec archive add-idempotent-transfers
```

performs two things:

1. **Folds the spec deltas into the living specification.** The `ADDED` /
   `MODIFIED` requirements from
   `openspec/changes/add-idempotent-transfers/specs/transfers/spec.md` are merged
   into the canonical capability at `openspec/specs/transfers/`, so the
   idempotency rule becomes part of NorthBank's permanent, always-true spec —
   no longer a pending proposal.
2. **Moves the change folder here**, timestamped
   (e.g. `2026-07-14-add-idempotent-transfers/`), as a record of what shipped.

Application code is not touched by archiving — it only updates the spec records.
