Git actions upstream workflow
============================

Purpose
-------
This document defines the **upstream, authoritative workflow** for
developing, maintaining, and promoting GitHub Actions.

Canonical governance rules live in:

- [git-rules.md](git-rules.md)
  - See action branches for `action/*` governance.

The standard contribution workflow is defined in:

- [git-contribution-flow.md](git-contribution-flow.md)

This document specifies **how GitHub Actions evolve upstream**.
It does not redefine governance.


Scope
-----
This workflow applies to:

- GitHub Actions under `.github/`,
- upstream maintenance and promotion of Actions.

It covers only:

- upstream Git operations for Actions,
- GitHub UI interactions related to Actions.

It does not cover:

- repository setup,
- branch governance rules,
- application code contributions,
- Action yaml design details.


Action branch model (optional)
------------------------------
Some GitHub Actions may be maintained in **dedicated upstream Action branches**
(e.g. `action/build`, `action/test`, `action/release`).

When used, these branches:

- should contain only `.github/` content,
- can serve as the canonical source for Actions,
- are promoted into `main` and/or `devel` via controlled merges.

If not used, Actions live directly on `main` and `devel`.


Authoritative action flow (ASCII)
---------------------------------

This diagram shows **Action-specific lifecycle steps**.
All standard operations (branching, committing, PR rules) follow
[git-contribution-flow.md](git-contribution-flow.md).

```text
────────────────────────────────────────────────────────────

STEP 1
  ┌───────────────────────────────┐
  │ UPSTREAM (READ-ONLY)          │
  │ xymon-monitoring/xymon        │
  └───────────────┬───────────────┘
                  │ Sync fork (GitHub UI)
                  │ main / devel / action/*
                  ▼
  ┌───────────────────────────────┐
  │ PERSONAL FORK                 │
  │ <user>/xymon                  │
  └───────────────┬───────────────┘

────────────────────────────────────────────────────────────
(Standard workflow applies from here)
────────────────────────────────────────────────────────────

STEP 2
  ┌───────────────────────────────┐
  │ ACTION WORK BRANCH            │
  │ action-<topic>                │
  │ from main / devel / action/*  │
  └───────────────┬───────────────┘
                  │ modify .github/
                  │ git commit / git push
                  ▼

STEP 4 (Optional)
  ┌───────────────────────────────┐
  │ FORK-SIDE VALIDATION          │
  │ non-authoritative             │
  └───────────────┬───────────────┘
                  │ manual promotion
                  │ (not automatic)

STEP 5 (IF USED)
                  │ promote / duplicate
                  ▼
  ┌───────────────────────────────┐
  │ UPSTREAM ACTION BRANCH        │
  │ action/<name>                 │
  └───────────────┬───────────────┘

STEP 6 (IF USED)
                  │ promotion to main/devel
                  ▼
  ┌───────────────────────────────┐
  │ UPSTREAM INTEGRATION          │
  │ main / devel                  │
  └───────────────┬───────────────┘

STEP 7
                  │ cleanup
                  ▼
  LOCAL + FORK cleaned

────────────────────────────────────────────────────────────
```


Workflow steps
--------------

Step 1 - ensure baselines are synced (UI)
-----------------------------------------
Ensure your personal fork is aligned with upstream before starting
any GitHub Actions work.

On GitHub (personal fork UI):

- Sync branch `main`
- Sync branch `devel`
- Sync relevant `action/*` branches (if used)

important:
Do not sync if you have commits on `main`, `devel`, or `action/*`.
Move any work in progress to a dedicated branch first.
These branches must remain clean.


Step 2 - create an action work branch
------------------------------------
Create a dedicated branch for Actions changes.

`main`, `devel`, and `action/*` are **baseline bases**.
Direct commits are allowed but strongly discouraged.

From `main`:
```
git checkout main
git switch -c action-<topic>
git push -u origin action-<topic>
```

From `devel`:
```
git checkout devel
git switch -c action-<topic>
git push -u origin action-<topic>
```

From an `action/*` branch:
```
git checkout action/<name>
git switch -c action-<topic>
git push -u origin action-<topic>
```


Step 3 - apply action changes
-----------------------------
Modify GitHub Actions or related automation
(typically under `.github/`).

Upstream workflows should keep branch filters restricted to integration
targets, typically `main` and `devel`.

Example:
```yaml
branches: [ main, devel ]
```

Upstream `workflow_dispatch` should be restricted to maintainers only.
Guard it with repository checks or permissions.

Example:
```yaml
on:
  workflow_dispatch:
  push:
    branches: [ main, devel ]

jobs:
  build:
    if: github.repository == 'xymon-monitoring/xymon'
```

```
git add .github/
git commit -m "Action: update GitHub Actions"
git push
```


Step 4 - optional: fork-side validation
---------------------------------------
When possible, validate behavior in the personal fork
(e.g. via fork-side PRs or Action runs).

Fork-side validation is non-authoritative and informational only.
Promotion to upstream is always manual.


Step 5 - promote to upstream action branch (if used)
----------------------------------------------------
If using `action/*` branches for reuse or long-term maintenance:

- Submit a Pull Request to the appropriate `action/<name>` branch.
- Maintain the Action independently from application code.


Step 6 - promote to main / devel
--------------------------------
If using `action/*`, promote from `action/<name>` into `main` and/or `devel`
via controlled upstream Pull Requests.

`devel` semantics follow [git-rules.md](git-rules.md).


Step 7 - cleanup
----------------
Remove temporary Action branches after completion.

Locally:
```
git branch -d action-<topic>
```

On the personal fork:
```
git push origin --delete action-<topic>
```


Key principles
--------------

- Upstream is the authoritative truth source.
- `action/*` branches are canonical when used.
- `main` is the stable integration target; `devel` is the active development baseline.
- Any step not described here follows [git-contribution-flow.md](git-contribution-flow.md).
