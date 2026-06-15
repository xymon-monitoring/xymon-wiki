Git governance - canonical rules
================================

Governance intent
-----------------
These rules protect baseline branches (`main`, `devel`)
and the long-term health of the project.

They do not restrict who may contribute
or how contributors work in their own forks.

All contributions are welcome via Pull Requests.

Scope
-----

- local development environments
- personal GitHub forks
- safe contribution to the upstream repository


Repository roles
----------------
UPSTREAM  : authoritative repository (read-only via git)
PERSONAL  : contributor fork (integration, testing, CI)
LOCAL     : developer working copy


Reference baselines
-------------------
When you sync, make sure `main` and `devel` match upstream.

Baseline protection
-------------------
`main` and `devel` are long-term reference branches.

Any change reaching a baseline branch is considered high-impact
and therefore requires explicit human validation.

- `main` represents a production-quality state
- `devel` is the active development baseline


Action branches
---------------
When used, `action/*` branches are the canonical location
for GitHub Actions changes:

- `action/*` branches should contain only `.github/` content
- Work branches may be created from `action/*`
- Direct commits are discouraged to keep changes reviewable
- Promotion to `main` or `devel` happens via Pull Request


Review and merge policy
-----------------------
Integration into `main` or `devel` requires review by two people:

- one author
- one independent reviewer

If an exception is needed, it must be clearly explained
in the Pull Request.

Allowed merge modes include:

- squash
- merge commit
- rebase

Hard rules
----------

- Upstream is fetch-only; make all changes in PERSONAL or LOCAL
- Treat `main` and `devel` the same way: branch from them and avoid direct commits
- Use work branches for non-trivial changes
- Any divergence from baselines must be intentional


Document authority
------------------
This document is the authoritative reference for Git governance
in this project.

All other Git-related documents (processes, workflows, CI flows)
must align with these rules and must not redefine them.

If something conflicts with this document, this document takes precedence.
