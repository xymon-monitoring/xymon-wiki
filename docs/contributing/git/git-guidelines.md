Git guidelines - best practices
==============================

Purpose
-------
This document gives simple, practical advice
for working with Git in this project.

Official Git rules and repository governance are defined in:

- [git-rules.md](git-rules.md)

This document does not define rules.


Scope
-----
These guidelines apply to everyday development work.


Working guidelines
------------------

- Keep commits focused so the project history stays easy to read
- Use your personal fork to test and integrate changes


Branch practices
----------------

- Use a separate branch for any change that is more than a small fix
- Keep branches short-lived and remove them after merge


Commit messages
---------------

- Write clear commit messages
- Avoid unnecessary or purely automatic commits
- A squashed commit should still clearly describe the change


Pull request practices
----------------------

- Split large changes into smaller PRs when possible
- If a change must be large, explain why in the PR description


Review practices
----------------

- Explain what your PR does and why
- Avoid mixing refactoring and behavior changes if possible


Things to avoid
---------------

- Very large or unclear commits
- Long-lived branches without a clear purpose
- Risky changes on main branches without review
- Changing shared history without coordination


If something goes wrong
-----------------------

- Find the last working state
- Fix or restore carefully


Key idea
--------
Prefer clear, careful work over rigid process.
