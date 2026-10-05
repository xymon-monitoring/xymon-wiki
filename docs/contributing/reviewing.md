# Reviewing a pull request

How to review a pull request in `xymon`: the tools and the steps. The rules —
what a pre-review and a review record, and when a change may merge without a
review — live in
[CONTRIBUTING.md](https://github.com/xymon-monitoring/xymon/blob/main/CONTRIBUTING.md),
under *Pull requests*, *Pre-review* and *Reviews*. This page does not restate
them; where the two disagree, `CONTRIBUTING.md` is right and this page is stale.

## Get the pull request locally

    gh pr checkout 1234

Building is not `./configure && make`: `configure` asks its questions
interactively and refuses to run again while a `Makefile` exists. For a
non-interactive build, copy the environment variables the *build* job sets in
[`.github/workflows/build.yml`](https://github.com/xymon-monitoring/xymon/blob/main/.github/workflows/build.yml),
then run `./configure --server` and `make`, as the server leg does. The client
legs use `--client` with the `CONFTYPE` their matrix entry sets.

Then the suite, or one test on its own:

    XYMON_VARIANT=server ./tests/testsuite
    ./tests/client/fs-filter-linux.sh

`tests/README.md` says what each directory holds and what the exit codes mean.

## Start from the pre-review

A pre-review, where there is one, is the author's account of what was checked
and what was not. It tells you where to spend your time, not what to conclude:

- **What it says most needs the approver** — start there.
- **Left open for the approver** — a judgement the author could not make: a
  design choice, a compatibility risk, a platform nobody could run. These are
  yours to decide.
- **Not checked**, and rows whose check was only *read* — look at these next.
- **Run, with a result** — you need not rerun them. Rerun one when you doubt it,
  or run it where the author could not; say which you did.

Then review the rest of the diff against the base. A pre-review that turns out
wrong is a finding to report, not by itself a reason to withhold approval.

With no pre-review, the whole diff is yours from the start.

## Check that a test fails without its fix

A test proves a fix only if it fails when the fix is removed. To check a pull
request's tests that way, on a tree carrying every other open pull request:

    build/pin-check.sh --pr 1234

On a branch you have checked out, before or after pushing:

    build/pin-check.sh --local

Both revert files in the working tree, so they refuse a dirty one. Do not run
`git clean -fd` around them: in a configured tree it removes the `Makefile` and
`include/config.h`, every test then skips, and a skip reads as a fix correctly
pinned.

| outcome | what it means for the review |
|---|---|
| `ok` | the test fails without the fix; nothing to do |
| `FLAG` | the test passes without the fix, and the change added it: the fix is unguarded — a finding |
| `modified` | it passes, but the change only edited an existing test; read that edit |
| `control` | it passes on purpose, and its header says so |
| `cannot verify` | another change rewrote the same lines, so the revert did not apply; needs a person |
| `no usable test` | it fails on the intact tree too, so it proves nothing either way |

The script's header has the method. The *pin check* workflow runs it weekly over
every open pull request and can be started by hand from the Actions tab, for one
pull request or all.

## Find what it collides with

- **Conflicts.** The *pr conflicts* workflow test-merges open pull requests that
  touch the same files, weekly or on demand from the Actions tab, and lists the
  pairs that cannot both merge in its job summary.
- **Dependencies.** A pull request that needs another one first says so on a line
  of its own: `Depends-on: #1234`. A daily job reads those lines and keeps three
  labels true: `blocked` (something has to land first), `unblocks` (something is
  waiting on it), and `deps-none-found`. A dependency written any other way is
  not seen.

## Write the review

`CONTRIBUTING.md` *Reviews* says what an approving review records. In practice it
can be a few lines of prose. An illustration, not a real review — an approval of
#446, which moves a shell `case` out of a command substitution, might read:

> Approving at `d307d00f2`. Verified: the moved `case` block is unchanged —
> compared the old and new file, ignoring indentation; only `local f` is new.
> Only read: the macOS bash 3.2 run, which is the author's. Beyond the
> pre-review: read the rest of the diff; nothing else changes. Found nothing.
> Could not check: bash 3.2 myself, having no macOS host.

A re-approval after a push that changed nothing you checked can be one line,
naming the new head.

## Merge without a review

`CONTRIBUTING.md` *Pull requests* has the table of which changes may merge
without a review. Where it allows one, a maintainer merges past the ruleset and
says so in the pull request:

    gh pr comment 1234 --body "Merged without a review under the documentation row of the review table (CONTRIBUTING.md), as a maintainer bypass."
    gh pr merge 1234 --merge --admin

`--merge` keeps each commit as it stands, which is why every commit message has
to read on its own. Merge only once the checks are green.

## A worked example

#446 is a pull request whose pre-review a reviewer can follow row by row. Its
table, shortened:

| What was checked | How | Result |
|---|---|---|
| the `case` filter is unchanged by the move | old and new block extracted and compared, ignoring indentation | identical; one new line, `local f` |
| it still selects the same scripts | old and new step run under bash 5, file lists compared | the same files |
| nothing else broke on bash 4+ | CI, Linux — a bash that parsed the old code too, so no breakage, not the fix | passes |
| the bash 3.2 failure, and the fix | the checker on macOS bash 3.2, before and after — the author's run | before: syntax error, exit 0 with no check run; after: checks run, pass |

It ends: *all checked; nothing is left open*. A reviewer reads it as: the first
two rows can be rerun in seconds, the third is evidence of no breakage only, and
the fourth is the author's run on a platform the reviewer may not have — so that
is what the review says it only read, or reruns.
