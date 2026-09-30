# Project activity

Generated 2026-09-30 by `tools/project-activity.sh`, from the GitHub API. Window: pull requests opened since 2025-09-30, in the organisation's public repositories. No person is named here; the numbers are counts.

**Waiting for review** means ready (not a draft), still open, and without an approval from someone other than its author; it is measured from the first time the pull request was ready. A **review** is a GitHub review by someone other than the author; a plain comment is not one.

## Help wanted

Review is the project's bottleneck, and everyone is welcome to help fill the gap — no membership is needed to review a pull request or to open one.

| | Value |
|---|---|
| Review requests arriving in `xymon` (median of the last four whole months) | 52 a month |
| Approvals one active reviewer gives in a month (median, same months) | 5.2 |
| Reviewers active in a month (median, same months) | 5 |
| Reviewers needed to keep up (estimate) | 10 — about 5 missing |
| Pull request authors in the last three months / of them new | 6 / 3 |

How to help:

- **Review** one of the pull requests waiting longest, listed under [Waiting for review](#waiting-for-review): read it, try it if you can, and approve it or say what is wrong. A review from someone who runs Xymon in production is worth as much as one from a developer.
- **Contribute**: pick an issue and open a pull request — [First contribution](../contributing/git/first-contribution.md) says how.
- **Talk to us** on the mailing list, linked from [Project & community](project-and-community.md).

The estimate divides the arrivals by one reviewer's pace; it is a range read from a few months, not a target.

## Summary

| Question | Value |
|---|---|
| Does review keep up with what arrives? (`xymon`, window) | 338 became ready · 175 approved |
| Ready pull requests waiting more than 30 days | 43 of 62 waiting |
| People doing 80% of the reviews | 4 (busiest: 37% of all reviews) |
| Code merged in `xymon` without an approval since the review rule (2026-09-13) | 0 |
| Distinct pull request authors | 10 |

## Groups

What each group grants and expects is on [Project organisation](project-organisation.md).

| Group | Holders | Reviewed others' pull requests (≥1) | (≥5) | Opened a pull request (≥1) | Neither |
|---|---|---|---|---|---|
| maintainers | 10 | 7 | 5 | 6 | 2 |
| contributors | 10 | 3 | 0 | 3 | 6 |

Organisation owners: 13. Their activity is not published here: how many administrator accounts are idle is a security question, and it is tracked where access is managed.

## Pull requests by repository

| Repository | Opened | Merged | Merged with an approval | Merged without | Merged by their own author | Closed unmerged | Open |
|---|---|---|---|---|---|---|---|
| `xymon` | 356 | 198 | 174 | 24 | 125 | 74 | 84 |
| `xymon-rpm` | 79 | 71 | 0 | 71 | 70 | 2 | 6 |
| `xymon-wiki` | 27 | 27 | 0 | 27 | 27 | 0 | 0 |
| `homebrew-xymon` | 18 | 18 | 0 | 18 | 18 | 0 | 0 |
| `xymon-discussion-public` | 4 | 4 | 0 | 4 | 4 | 0 | 0 |
| `xymon-plugins` | 3 | 2 | 0 | 2 | 0 | 0 | 1 |
| `xymon-client-windows-powershell` | 2 | 1 | 0 | 1 | 1 | 0 | 1 |

## Review in `xymon`

| Measure | Value |
|---|---|
| Review verdicts | approved 177 · changes requested 3 · commented 41 · dismissed 14 |
| Merged with an approval | 174 of 198 (88%) |
| Merged without an approval: documentation / build, CI, tests / code | 14 / 4 / 6 |
| Time from ready to first approval: median / mean / longest | 2.7 days / 12.9 days / 134.9 days |
| Time from ready to merge: median / slowest tenth | 2.5 days / 40.2 days |

Classification by title: a title starting `docs:`, a manual page, `README:`, `RELEASING:`, `CONTRIBUTING:` or `AGENTS:` counts as documentation; `build:`, `ci:`, `tests:` or `tools:` as build, CI and tests; anything else as code.

## By month (`xymon`)

| Month | Became ready | Approved | Merged | Merged without an approval | Reviews | Reviewers |
|---|---|---|---|---|---|---|
| 2026-01 | 22 | 10 | 10 | 0 | 14 | 4 |
| 2026-02 | 9 | 9 | 8 | 0 | 28 | 4 |
| 2026-03 | 2 | 0 | 0 | 0 | 0 | 0 |
| 2026-04 | 4 | 2 | 2 | 0 | 2 | 2 |
| 2026-05 | 22 | 10 | 9 | 0 | 14 | 2 |
| 2026-06 | 41 | 17 | 17 | 3 | 31 | 6 |
| 2026-07 | 52 | 26 | 30 | 0 | 30 | 5 |
| 2026-08 | 148 | 96 | 108 | 12 | 111 | 4 |
| 2026-09 | 38 | 5 | 14 | 9 | 5 | 4 |

## Who reviews

Reviews submitted, by rank; each column is one person.

| Rank | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| Reviews | 87 | 47 | 41 | 33 | 20 | 3 | 1 | 1 | 1 | 1 |

## Waiting for review

| Measure | Value |
|---|---|
| Waiting now | 62 |
| Waiting: median / mean / longest | 38.3 days / 48.9 days / 252.2 days |
| More than 30 / 90 days | 43 / 12 |

Waiting longest, oldest first — a reviewer is welcome on any of them:

- [xymon#36](https://github.com/xymon-monitoring/xymon/pull/36) — ci: build on FreeBSD, OpenBSD, NetBSD and in Debian and RPM containers (252.2 days)
- [xymon#111](https://github.com/xymon-monitoring/xymon/pull/111) — build: drop the make-era platform targets nobody builds (#85) (124.7 days)
- [xymon#135](https://github.com/xymon-monitoring/xymon/pull/135) — build: integrate SNMP into the configure framework (consistent, off by default) (122 days)
- [xymon#138](https://github.com/xymon-monitoring/xymon/pull/138) — build: drop bundled c-ares 1.15.0, build against system c-ares (121.1 days)
- [xymon#150](https://github.com/xymon-monitoring/xymon/pull/150) — snmpcollect: don't fail over to the next IP on NOSUCHNAME (fixes #137) (111.7 days)

## Not counted

Discussion on the mailing list and in chat; reviews given as plain comments; an owner's administrative work; changes pushed without a pull request, which is how most wiki pages are written.
