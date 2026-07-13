---
name: pii-redaction-check
description: Flags personally identifiable information (account numbers, owner names, email addresses) written to logs or console output. Starter template — complete the body in Station 6, then run it over TransferService.cs.
---

# PII redaction check

> STARTER TEMPLATE — attendees complete this skill in Station 6.
> Fill in the sections marked TODO, then install and invoke the skill.

Scan the supplied code (or the current diff) for personally identifiable
information that reaches a log sink or the console without redaction.

## What counts as PII (TODO: refine)

- [ ] Account numbers / account ids (e.g. `1001`, `1002`)
- [ ] Account owner names
- [ ] Email addresses
- [ ] TODO: add any other fields your team treats as sensitive

## What to scan (TODO)

TODO: describe the sinks to inspect, for example `Console.Write*`, logging
calls, exception messages, and trace output. Note which files or folders are
in scope.

## Detection guidance (TODO)

TODO: describe how to recognise each PII type (patterns or heuristics) and how
to tell a safe reference from an unsafe one (e.g. a masked value such as
`****1001` is acceptable).

## Output format (TODO)

TODO: define the report shape — for each finding include the `file:line`, the
PII type, the offending snippet, and a suggested redaction.
