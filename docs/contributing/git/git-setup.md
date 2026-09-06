Git setup - procedures
=====================

Purpose
-------
This document defines the canonical setup and maintenance procedure
for contributors using a personal fork.

Authoritative governance rules live in:

- [git-rules.md](git-rules.md)

This document is procedural and scoped to the contributor workflow.


Authoritative flow (phased)
--------------------------

```text
PHASE 1
  ┌───────────────────────────────┐
  │ GitHub UI                     │
  │ Create personal fork          │
  │ <user>/xymon                  │
  └───────────────┬───────────────┘
                  │
PHASE 2           │ git clone
  ┌───────────────▼───────────────┐
  │ LOCAL WORKING COPY            │
  │ developer machine             │
  └───────────────┬───────────────┘
                  │
PHASE 3           │ git remote add upstream
                  │ upstream = fetch-only
                  │
PHASE 4           │ verify remotes
                  │
PHASE 5           │ baseline verification
                  │ compare against upstream
                  │
PHASE 6           │ controlled restore (if required)
                  │
PHASE 7           │ contribution workflow
                  │ see git-contribution-flow.md
```


Rules
-----

- Upstream is the single authoritative truth source.
- All baseline verification is performed against upstream.
- Origin (personal fork) is a writable mirror used only as a sync and PR source.
- Upstream is fetch-only and modified only via Pull Requests.
- Push is allowed only to the personal fork.
- main = stable / release


Phase 0 - prerequisites
----------------------

- A GitHub account
- Git installed locally
- A personal fork is allowed; direct upstream pushes are not

Reference:

- [git-installation.md](git-installation.md)


Phase 1 - create personal fork (GitHub UI)
-----------------------------------------
On GitHub:

- Fork xymon-monitoring/xymon
- Result:
  `<your-github-username>/xymon`


Phase 2 - clone personal fork (local)
------------------------------------
Using gh (recommended):
```
gh repo clone <your-github-username>/xymon
cd xymon
```

Or using git:
```
git clone https://github.com/<your-github-username>/xymon.git
cd xymon
```


Phase 3 - declare upstream (fetch-only)
--------------------------------------
The upstream remote represents the authoritative repository and is
intentionally configured as fetch-only.

If you cloned with `gh`, the `upstream` remote already exists: `gh repo clone`
adds the parent of a fork as `upstream`, and also makes the parent the default
repository for every later `gh` command. Skip the `remote add` and point `gh`
back at your fork:
```
git remote set-url --push upstream DISABLED
gh repo set-default <your-github-username>/xymon
```

If you cloned with `git`, add the remote first:
```
git remote add upstream https://github.com/xymon-monitoring/xymon.git
git remote set-url --push upstream DISABLED
```

Either way, make the fork the default push target:
```
git config remote.pushDefault origin
```

Why all three: with push rights on the upstream repository, `gh pr create`
pushes an unpushed branch to the *default* repository without asking, and a
branch that tracks `upstream/main` pushes to upstream. The disabled push URL
is the guard that holds whatever the defaults are.


Phase 4 - verify remotes
-----------------------
```
git remote -v
```


Phase 5 - baseline verification (against upstream)
-------------------------------------------------
Baseline verification is always performed against upstream.

This step checks your local branches directly against upstream,
so you see the authoritative state instead of your fork.
```
git fetch upstream
git diff main upstream/main
```

Expected result:

- No output means your branch matches upstream.
- Differences mean your branch is ahead or behind and should be aligned before you branch.


Phase 6 - controlled restore (optional)
--------------------------------------
Non-destructive attempt (from the current local branch):
```
git fetch upstream
git rebase upstream/main
```

Destructive restore (tracked files only):
```
git stash
git reset --hard upstream/main
git stash pop
```

Warnings:

- Tracked changes are discarded.
- Untracked files are preserved.
- git clean is intentionally not used.
- Back up anything important before running a destructive reset.

Backup options (recommended):
```
git stash -u
```
```
cp -a . ../xymon-backup
```


Phase 7 - contribution workflow
-------------------------------
Day-to-day development, PR flow, and cleanup are defined in:

- [git-contribution-flow.md](git-contribution-flow.md)


End of procedure
----------------
This procedure is complete for the defined scope and relies on
GitHub UI actions and referenced governance documents.
