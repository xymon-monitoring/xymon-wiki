# AI Agent Contribution Directives (Draft)

Scope

- General directives for any AI-assisted contribution (patch generation, PR drafting, review assistance).
- The `xymon` repository carries its own instructions for coding agents in
  [`AGENTS.md`](https://github.com/xymon-monitoring/xymon/blob/main/AGENTS.md),
  which tools load from the checkout. That file is authoritative for work in
  that tree — attribution, what the test suite rejects, where things are — and
  this page does not restate it.
- The rules every contributor follows apply to AI-assisted work as well, and
  they are in each repository's `CONTRIBUTING.md` — for `xymon`,
  [CONTRIBUTING.md](https://github.com/xymon-monitoring/xymon/blob/main/CONTRIBUTING.md):
  one change per pull request, and say what you verified and how. This page is
  what an AI-assisted contribution needs on top of that.

## Mandatory Rules

1) No scope creep
- Do not add unrelated changes (formatting, refactors, opportunistic cleanups).

2) Preserve behavior unless explicitly requested
- Do not change defaults, semantics, or feature gates beyond what is required.

3) Minimize diff and surface area
- Prefer local changes.
- Avoid new files/layers/frameworks unless explicitly required.

4) Maintain reviewer ergonomics
- Changes must be easy to review, easy to revert, and logically grouped.
- Avoid mechanical churn.

## Required Output Structure (for any proposed change)

- Context:
- Problem:
- Root cause:
- Change:
- Risk:
- Validation commands:
- Evidence required (outputs/logs to paste):

## Validation Protocol When the AI Cannot Run Tests

- Provide exact commands for:
  - configure/build
  - relevant runtime checks
- Request concrete artifacts:
  - configure output excerpt
  - build output tail (or error)
  - OS/compiler/dependency versions
  - runtime log lines demonstrating behavior

## Build / Detection Constraints

If proposing any detection change, the AI must specify:

- detection criteria and ordering
- flag/macro names produced
- where those flags are consumed
- how consistency is ensured (headers/cflags/libs/call sites)

## Prohibited Behaviors

- Inventing test results, environment details, or tool outputs.
- Quietly changing behavior without explicit request.
- Introducing a new compatibility layer because it "feels cleaner".
- Large stylistic rewrites that increase diff noise.

## Review Interaction Protocol

- Apply maintainer feedback with minimal churn.
- Do not introduce additional improvements in the same review iteration.
- If the approach is rejected, stop and propose the smallest alternative.
