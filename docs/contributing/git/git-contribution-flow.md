Git contribution flow - local -> personal -> upstream
====================================================

Welcome
-------
This guide shows a simple and safe way to contribute.
If you have not set up your fork and remotes yet, start with
[git-setup.md](git-setup.md).


Authoritative flow (step-based)
-------------------------------

```text
STEP 1
  ┌───────────────────────────────┐
  │ UPSTREAM (READ-ONLY)          │
  │ xymon-monitoring/xymon        │
  │ authoritative source          │
  └───────────────┬───────────────┘
                  │
                  │ git fetch / git diff
                  │
STEP 2            │
  ┌───────────────▼───────────────┐
  │ PERSONAL FORK                 │
  │ <user>/xymon                  │
  │ writable mirror               │
  └───────────────┬───────────────┘
                  │
STEP 3            │
  ┌───────────────▼───────────────┐
  │ LOCAL WORKING COPY            │
  │ developer machine             │
  │ create work branch            │
  └───────────────┬───────────────┘
                  │
STEP 4            │
  ┌───────────────▼───────────────┐
  │ LOCAL WORKING COPY            │
  │ commit changes                │
  └───────────────┬───────────────┘
                  │
                  │ git push
                  │
                  ▼
  ┌───────────────────────────────┐
  │ PERSONAL FORK                 │
  │ feature branch                │
  └───────────────┬───────────────┘
                  │
STEP 5            │ sync fork/local
                  │
STEP 6 (Optional) │ fork PR
                  │
STEP 7            │ upstream PR
                  │
                  ▼
  ┌───────────────────────────────┐
  │ UPSTREAM (READ-ONLY)          │
  │ review and merge              │
  └───────────────┬───────────────┘
                  │
STEP 8            │ cleanup
                  │
                  ▼
  LOCAL + FORK cleaned
```


Rules
-----

- Upstream is the authoritative truth source.
- All verification is done against upstream.
- All writes go to the personal fork.
- Direct development on `main` and `devel` is allowed but strongly discouraged.
- `main` and `devel` are preferred as branching bases and merge targets.
- All upstream changes happen via Pull Requests only.


Step 1 - check upstream status
------------------------------
Use the baseline verification in [git-setup.md](git-setup.md) (phase 5).

Step 2 - sync your personal fork (if needed)
--------------------------------------------
If your fork is behind, sync it in the GitHub UI:

- Click "Sync fork"
- Choose "Update branch"


Step 3 - create a work branch
-----------------------------
Branch from `main` or `devel`:
```
git checkout main
git switch -c <branch>
git push -u origin <branch>
```

```
git checkout devel
git switch -c <branch>
git push -u origin <branch>
```


Step 4 - make your change
-------------------------
```
git add <files>
git commit -m "<message>"
git push
```


Step 5 - sync your fork and local with upstream (recommended)
---------------------------------------------------
Before opening any PR, make sure your fork and local branches are not behind upstream.

If it is, sync it using the GitHub UI:

- Click "Sync fork"
- Choose "Update branch"

important:
`main` and `devel` are moving targets: they advance as upstream evolves.

Do not sync if you have commits on `main` or `devel`.
GitHub will warn that syncing will overwrite those changes.

Move any work in progress to a dedicated branch first.
This is why committing directly on `main` or `devel` is strongly discouraged.


Step 6 - optional (recommended): open a fork PR
----------------------------------------------
It is recommended to open a Pull Request in your fork first,
in order to run CI and validate changes before opening
the upstream PR.


Step 7 - open the upstream PR
-----------------------------
Open the upstream PR:
```
<your-github-username>/xymon:<branch>
-> xymon-monitoring/xymon:main (or devel)
```

Step 7a - Accidental upstream Pull Request
-----------------------------------------
If a Pull Request is opened to upstream by mistake:

- Open the Pull Request
- Click "Close pull request"
- Optional comment:
  "Closed – PR opened by mistake, branch preserved in personal fork."


Step 8 - clean up
-----------------
After merge:
```
git branch -d <branch>
git push origin --delete <branch>
```
