---
name: openspec-propose
description: Scaffold an OpenSpec change proposal (propose step) from a GitHub issue.
---

You are running the OpenSpec **propose** step.

Input: a change id and a source **GitHub issue** (e.g.
`add-idempotent-transfers`, from issue #6).

Do the following:

1. Read `openspec/project.md` for context on the NorthBank codebase and its
   conventions, and read the source issue (and any ADR it references) for the
   requirement.
2. Create `openspec/changes/<change-id>/` containing:
   - `proposal.md` — **Why**, **What changes**, **Scope** (in/out), **Impact**.
   - `design.md` — the technical approach, key decisions, edge cases, and
     alternatives considered.
   - `tasks.md` — a checkbox implementation checklist (unchecked).
   - `specs/<capability>/spec.md` — the **spec delta**: `## ADDED Requirements`
     (and `## MODIFIED Requirements` if changing existing ones), each
     `### Requirement:` written with a SHALL statement, followed by
     `#### Scenario:` blocks in **GIVEN / WHEN / THEN** form.
3. Keep the change **narrowly scoped** — one coherent change only. Push
   unrelated fixes out of scope and note them.
4. Do **not** write application code in this step. Only produce the artifacts
   above and present them for review.

Finish by summarising what files you created and asking the reviewer to confirm
or amend the proposal before `openspec-apply`.
