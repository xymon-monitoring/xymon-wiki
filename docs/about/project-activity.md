# Project activity

Generated 2026-10-29 by `tools/project-activity.sh`, from the GitHub API, over the pull requests opened since 2025-10-29. No person is named here; the numbers are counts. What each one counts is at the end, under [How this is counted](#how-this-is-counted).

## Summary

| | Question | Value | 🟢 when | 🔴 when |
|---|---|---|---|---|
| 🔴 | Does review keep up with what arrives? (`xymon`, last four whole months) | 279 became ready · 144 approved (52%) | ≥ 90% approved | < 60% |
| 🔴 | Ready pull requests waiting more than 30 days | 41 of 81 waiting | ≤ 5 | > 20 |
| 🟡 | People doing 80% of the reviews | 4 (busiest: 33% of all reviews) | ≥ 6 | ≤ 3 |
| 🔴 | Code merged in `xymon` without an approval | 1 since the review rule (2026-09-13) · 4 in the whole window | 0 since the rule | ≥ 1 |
| 🟡 | New pull request authors in the last three months | 2 (of 6 authors) | ≥ 3 | 0 |

The thresholds are this page's own, chosen to make a change visible; they are not project rules.

## Help wanted

Review is the project's bottleneck, and everyone is welcome to help fill the gap — no membership is needed to review a pull request or to open one.

| | Value |
|---|---|
| Review requests arriving in `xymon` in a typical month (median of the last four whole months) | 46.5 |
| Approvals one active reviewer gives in a month (median, same months) | 4 |
| Reviewers active in a month (median, same months) | 4.5 |
| Reviewers needed to keep up (estimate) | 12 — about 8 missing |
| Pull request authors in the last three months / of them new | 6 / 2 |

The estimate divides the arrivals by one reviewer's pace; it is a range read from a few months, not a target.

How to help:

- **Review** one of the pull requests waiting longest, listed under [Waiting for review](#waiting-for-review): read it, try it if you can, and approve it or say what is wrong. A review from someone who runs Xymon in production is worth as much as one from a developer.
- **Contribute**: pick an issue and open a pull request — [First contribution](../contributing/git/first-contribution.md) says how.
- **Talk to us** on the mailing list, linked from [Project & community](project-and-community.md).

## Review in `xymon`

Bars: pull requests that became ready for review. Line: approvals. The gap between them is review that did not happen.

```mermaid
%%{init: {"themeVariables": {"xyChart": {"plotColorPalette": "#3b6fd8, #e07b2a"}}}}%%
xychart-beta
    title "Review requests and approvals, by month"
    x-axis ["2026-01", "2026-02", "2026-03", "2026-04", "2026-05", "2026-06", "2026-07", "2026-08", "2026-09", "2026-10"]
    y-axis "Pull requests" 0 --> 175
    bar [22, 9, 2, 4, 22, 41, 52, 148, 38, 110]
    line [10, 9, 0, 2, 10, 17, 26, 96, 5, 21]
```

| Month | Became ready | Approved | Merged | Merged without an approval: allowed | needing a review | Reviews | Reviewers |
|---|---|---|---|---|---|---|---|
| 2026-01 | 22 | 10 | 10 | 0 | 0 | 14 | 4 |
| 2026-02 | 9 | 9 | 8 | 0 | 0 | 28 | 4 |
| 2026-03 | 2 | 0 | 0 | 0 | 0 | 0 | 0 |
| 2026-04 | 4 | 2 | 2 | 0 | 0 | 2 | 2 |
| 2026-05 | 22 | 10 | 9 | 0 | 0 | 14 | 2 |
| 2026-06 | 41 | 17 | 17 | 2 | 1 | 31 | 6 |
| 2026-07 | 52 | 26 | 30 | 0 | 0 | 30 | 5 |
| 2026-08 | 148 | 96 | 108 | 10 | 2 | 111 | 4 |
| 2026-09 | 38 | 5 | 14 | 9 | 0 | 5 | 4 |
| 2026-10 | 110 | 21 | 87 | 65 | 1 | 29 | 3 |

Each column counts by its own date: became ready, approved and reviewed in that month, or merged in that month. **Reviews** counts every review, approving or not. **Allowed** is what the merge table lets a maintainer merge without a review, as [How this is counted](#how-this-is-counted) says; **needing a review** is code merged without one.

Reviews submitted, by reviewer; each column is one person.

| Reviewer | #1 | #2 | #3 | #4 | #5 | #6 | #7 | #8 | #9 | #10 |
|---|---|---|---|---|---|---|---|---|---|---|
| Reviews | 87 | 56 | 51 | 33 | 30 | 3 | 1 | 1 | 1 | 1 |

## Waiting for review

| Measure | Value |
|---|---|
| Waiting now | 81 |
| Waiting: median / mean / longest | 36.9 days / 49.5 days / 153.3 days |
| More than 30 / 90 days | 41 / 11 |

```mermaid
%%{init: {"themeVariables": {"xyChart": {"plotColorPalette": "#3b6fd8, #e07b2a"}}}}%%
xychart-beta
    title "Ready pull requests waiting, by time waited"
    x-axis ["under 7 days", "7 to 30 days", "30 to 90 days", "over 90 days"]
    y-axis "Pull requests" 0 --> 45
    bar [5, 35, 30, 11]
```

Waiting longest, oldest first — a reviewer is welcome on any of them:

- [xymon#111](https://github.com/xymon-monitoring/xymon/pull/111) — build: drop the make-era platform targets nobody builds (#85) (153.3 days)
- [xymon#135](https://github.com/xymon-monitoring/xymon/pull/135) — build: make SNMP a configure option like RRD, SSL and LDAP, still off by default (150.5 days)
- [xymon#150](https://github.com/xymon-monitoring/xymon/pull/150) — xymon-snmpcollect: stop polling the next IP when an agent answers NOSUCHNAME (140.3 days)
- [xymon#151](https://github.com/xymon-monitoring/xymon/pull/151) — svcstatus: stop the trends-page locator redirect loop with SKIPLOC (TBT 44) (140.3 days)
- [xymon#152](https://github.com/xymon-monitoring/xymon/pull/152) — do_rrd: remember an RRD exists instead of stat()ing it every update (TBT 214, devel f106d8840) (140.2 days)

## Pull requests by repository

Only `xymon` asks for a review before a merge; the other repositories are pushed to directly, so a merge without an approval there is the normal way. **Open** counts every open pull request, drafts and approved ones included, which is why it is more than the number waiting for review.

| Repository | Opened | Merged | Merged with an approval | Merged without | Closed unmerged | Open |
|---|---|---|---|---|---|---|
| `xymon` | 465 | 285 | 195 | 90 | 79 | 101 |
| `xymon-rpm` | 100 | 94 | 0 | 94 | 3 | 3 |
| `xymon-wiki` | 29 | 29 | 0 | 29 | 0 | 0 |
| `homebrew-xymon` | 20 | 20 | 0 | 20 | 0 | 0 |
| `xymon-experimental` | 18 | 18 | 0 | 18 | 0 | 0 |

3 smaller repositories with fewer than 10 pull requests are left out: `xymon-client-windows-powershell`, `xymon-discussion-public`, `xymon-plugins`.

## How this is counted

**Waiting for review** means ready (not a draft), still open, and without an approval from someone other than its author; it is measured from the first time the pull request was ready. A **review** is a GitHub review by someone other than the author; a plain comment is not one.

A merge without an approval is **allowed** or **needing a review** by the files the pull request touches; a pull request with no file list is classified by its title's component instead:

| Counted as | When every file is | May merge without a review |
|---|---|---|
| documentation | under `docs/`, a manual page, a `.md` file, a configuration sample, `README*`, `RELEASENOTES`, `CREDITS` or `Changes` | yes — `CONTRIBUTING.md`'s merge table |
| build, CI, tests | documentation, or under `build/`, `tests/`, `tools/` or `.github/`, or `configure` | yes — the same table |
| Solaris and macOS clients | the above, or `client/xymonclient-darwin.sh`, `client/xymonclient-sunos.sh`, `xymond/client/darwin.c`, `xymond/client/solaris.c` | counted as yes by this page until the first release that ships them, since nobody but their author can run them yet; not a project rule |
| code | anything else | no |

**Not counted**: discussion on the mailing list and in chat; reviews given as plain comments; an owner's administrative work; changes pushed without a pull request, which is how most wiki pages are written.
