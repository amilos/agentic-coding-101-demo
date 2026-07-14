---
name: openspec-apply
description: Implement an approved OpenSpec change (apply step) by working its tasks.
---

You are running the OpenSpec **apply** step for a change under
`openspec/changes/<change-id>/`.

1. Read the change's `proposal.md`, `design.md`, `specs/**/spec.md` and
   `tasks.md`. Treat the spec delta as the source of truth for behaviour.
2. Implement the tasks in `tasks.md` **in order**, editing the application code
   (`src/PaymentService/...`) and adding xUnit tests under
   `tests/PaymentService.Tests`.
3. Tick each task in `tasks.md` (`- [x]`) as you complete it.
4. Run `dotnet test` and make it green. Do not change behaviour beyond the
   change's scope.
5. Open a PR from the session for review (Agent Merge decides when it lands).

Finish by summarising the code changes, the checked-off tasks, and the test
result. Leave the change folder in place — it is archived separately after merge.
