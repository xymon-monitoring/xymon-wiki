# Backport tracker rules

For any issue that tracks code to be backported into `xymon` from one source — a
downstream patch set, or a branch. Adopting these rules is optional: a tracker
adopts them by linking here from its profile (rule 11). This page names no
tracker.

## Goal

A backport tracker answers five questions for every change in its source —
**once each, with evidence**:

1. **Where does it belong** — on `main`, downstream (a repository that packages
   Xymon for a platform, and why not `main`), or nowhere?
2. **In which form** — as written, or another version?
3. **Is it there** yet?
4. **What is still owed**, and after what?
5. **Which comes next** — the order we intend to land the owed changes in, by
   priority, not by date.

A rule belongs on this page only if, without it, a tracker would answer one of
those questions wrongly, twice, or without evidence. Anything else is not a rule.

**Not the goal:** a log of how entries changed (the issue's edit history holds
that), a plan with dates, a copy of pull request descriptions, or a style guide
for prose.

## Rules

1. **Every change has one line.** One change per line, and every change in the
   source gets one; the profile says how completeness is counted. The profile may
   exclude a set of changes, with its reason, in its **Out of scope** field —
   excluded changes have no line, and a change that has a line is in scope.
2. **Each line has one verdict:**
   - `take as is` — port it as written;
   - `take, not as written — <reason>` — we want the change, not this form. If
     the reason is that a better version exists (on `main`, in a PR, on the other
     tracker), say where, and whether it covers the change fully or partly — and
     if partly, which part is missing. Only part of a change is wanted when the
     line names the part that is not, and why; a change whose better version
     sits inside a larger commit is wanted whole, and the line says that commit
     covers it fully;
   - `downstream — <who>` — not for `main`, but useful to a downstream
     repository, one that packages Xymon for a platform
     ([Downstream repositories](downstream-repositories.md)); `<who>` is that
     repository's name, as the profile's **Downstreams** field gives it. The
     line names what carries it there — a PR in that repository, or, when none
     can be named, the file — or says it is not carried yet. Where the line
     between the two runs is set on that page, and it moves, so the verdict is
     dated (rule 7);
   - `drop — <reason>` — wanted nowhere;
   - `undecided` — not triaged yet.

   *Exception:* a change with an upstream part and a downstream part carries one
   verdict for each, each naming its part — for example `take as is` for the
   code and `downstream — <who>` for its packaging file.
3. **The box says whether a PR is involved.** `[ ]` a PR is still needed —
   an `undecided` line carries `[ ]` until it is decided · `[x]` a PR, linked
   on the line, carries the change or made it unnecessary —
   merged or not · no box when no PR is involved (a drop or a downstream verdict
   on our own judgement, or a pointer).
4. **The icon says where it is.** 🟢 it is on `main`, naming the evidence — a
   commit, a merged PR, or a file and function. 🟢 also when the change reached
   `main` in another form: a PR that delivers the same feature counts, and the
   verdict is then `take, not as written` (covered fully by that PR).
   `drop — superseded` is only for a change whose need a PR removed without
   delivering it. 🟡 part of it is; say which part is missing. No icon: not on
   `main`. 🟢 and 🟡 rest on code: a commit, a PR, or the part found in a file
   and function; a count of matching lines is a measurement (rule 7) and sets no
   icon.
5. **Dependency order is `needs <id>`.** It names what must land first.
   Priority — the order among changes free to land — is the profile's
   **Layout**, and a section may give it as a milestone (the release its
   changes are aimed at, not a date); nothing else expresses order. A line may
   say which group will carry it, until a PR does — `carried with <group>
   (<commit>, …)`. The group is the Xymon feature the group delivers, named in
   Xymon's terms and the same way on every line that names it — never by
   another tracker's section or heading (rule 6). The commits, by id, are those
   that carry this change — its twin among them — the one carrying its feature
   first; a commit it only depends on is a `needs`, not a carrier. Once a PR
   carries the line, it names that PR instead (rule 9). A `needs`
   names a line — the change this one depends on — never a PR; the PR that
   carries that line
   is found on the line itself.
6. **One change, one decision.** When two trackers hold the same change, their
   profiles name the owner. The owner's line names its twin by id, and how much
   of it matches, measured; the other tracker's line only points —
   `delegated → #<owner> <id>` — and carries no verdict of its own. A pointer
   only points: its commit id, its target, and at most the commit's subject as
   its name; everything else about the change — verdict, form, measurements,
   what is owed — is on the twin it points to. Those two
   ids are the only way either line refers to the other tracker, and a line
   cites any other tracker only by an item's id: a line does not describe
   another tracker's lines, verdicts or sections, because such a copy goes stale
   as soon as that line changes, and nothing shows it.
   `tracker-progress --check` verifies that every pointer's target names the
   pointer's change back. A pointer names every line that claims the change;
   where only part of a change has a twin, the line points for that part and
   keeps a verdict for the rest. A part pointer names its part by file,
   function or hunk, and nothing else — no measurement and no verdict; those
   are on the owner's line. A line with no twin writes *none* once that has
   been measured.
7. **Claims can be checked.** A measurement says when, and against which commit
   or snapshot (a patch set is measured against a named release of it).
   Code is cited by file and function — or by the symbol, for code outside any
   function (a line number may be added); commits and
   PRs by their id. For a patch set, "is it there" is checked against the
   patch's added lines in `main`'s files. A reverse dry-run proves only a
   floor, and only when forced (without `--force`, GNU `patch` silently
   un-reverses `-R` and every test matches): a change ported by hand does not
   reverse-apply, and one whose removed line survives elsewhere reverse-applies
   without being there.
8. **A fact is written once.** Prose does not repeat a mark, and nothing is
   written that can be read elsewhere — a PR's state, another line's verdict.
   A line names each PR and each commit once: later text on the same line refers
   to it as "that PR" or "that commit". A `needs <id>` or a `carried with`
   always names its ids, and is not counted as a repeat. A measurement's date and commit are its
   citation, not a separate fact: each line that states a measurement names
   them, even when every line in a section was measured the same day against
   the same commit.
   The issue body is the tracker: everything the goal asks is answered there,
   and nothing only in a comment. A comment may discuss; whatever it decides
   moves into the body.
   One exception: a tracker may carry a single **progress block**, generated from
   its own lines by a script (the wiki's `tools/tracker-progress.sh`) and never
   edited by hand, that names its date and the script. It counts: lines ·
   pointers · wanted (`take …`) and, of those, landed (🟢) · in a PR (`[x]`,
   no 🟢) · without a PR (`[ ]`) · downstream · dropped · undecided — headed by
   two shares of the tracker's own lines (pointers left out): **settled**, owing
   nothing more (landed, downstream or dropped), and **decided** (any verdict but
   `undecided`). It sits first in the issue, above the profile.
9. **Analysis goes where its subject is.** A line's analysis answers the goal's
   questions about its source change — do we want it, in which form (twin,
   coverage, what is not taken and why), is it there, what is owed. When a PR
   carries the change, the line may name what the PR leaves out or does
   differently from the change, as far as that decides the verdict (fully or
   partly, and what is missing); how the PR's code does it, and how it is
   sequenced against other PRs, belongs in that PR's description. The line and its carrier name each other: the line links the
   PR, and the PR's title names the change in its trailing parenthesis, in the
   tracker's citation form (the profile's **Ids**). A PR that only makes a change
   unnecessary is exempt.
10. **Lines are grouped by subject** (the part of Xymon they touch). A heading
    says only what is true of every line under it, and so may one sentence
    opening a section; anything more belongs on the lines.
11. **The profile** opens the tracker, after the progress block if there is one,
    under `### Rule`; it links to this page at the commit whose rules it follows, and
    holds everything true of that tracker alone:
    - **Goal** — this tracker's version of the goal above;
    - **Source** — what is tracked, the snapshot it came from, and how
      completeness is counted;
    - **Out of scope** — the sets of changes deliberately not tracked, each with
      its reason;
    - **Ids** — how a line names its change, and how it is cited elsewhere;
    - **Owner** — which tracker decides a change two trackers hold;
    - **Downstreams** — the downstream repositories a change may be offered to,
      and where to reach each;
    - **Layout** — the top-level sections, and which holds settled lines; and
      the priority, given either by the order of the sections or by one stated
      criterion that orders every line (for example its kind tag, then its
      risk);
    - **Extra marks** — any mark this tracker adds, with its meaning.

    A field that does not apply says *none*.

## Stability

A tracker is stable when `tools/tracker-lint.py` reports nothing. Its profile
names the rules commit it follows; a rules change moves that commit and is
re-linted as a whole, and a batch of edits is applied only if it lowers the
violation count and adds none.

## Optional: kind tags

A tracker may tag each line with the kind of change, to help reading. They
decide no verdict, box or icon, so they are not a rule; a tracker that uses
them says so in its profile's **Extra marks**, and its **Layout** may use them
as its priority criterion (rule 11).

- `[feature]` — a new capability
- `[fix]` — corrects a bug
- `[perf]` — makes something faster or cheaper
- `[enh]` — improves existing behaviour (logging, output, compatibility)
- `[cleanup]` — removes dead or obsolete code

## Optional: the warning mark

A tracker may mark a line `⚠` for a risk or a condition to know before acting
on it. Like the kind tags it decides nothing, and a tracker that uses it says so
in its profile's **Extra marks**.

## Example

An invented tracker, issue #9001, with deliberately fake ids:

```
Progress (generated 2026-01-10 by tracker-progress): settled 3 of 6 (50%) ·
decided 6 of 6 (100%) — 6 lines · 0 pointers · wanted 4 — landed 1 · in a PR 1 ·
without a PR 2 · downstream 1 · dropped 1 · undecided 0

### Rule

This tracker follows the backport tracker rules (link). Profile:
- Goal: every patch example-pkg 1.2 applies.
- Source: example-pkg 1.2 patch set.
- Out of scope: its test-suite patches (not shipped code).
- Ids: the patch number, cited elsewhere as `EX N`.
- Owner: this tracker owns every change it shares with #9002.
- Downstreams: `example/example-distro`.
- Layout: Next · Later · Settled.
- Extra marks: none.

### Next

- [ ] `7` fix-null-deref.patch — take as is — crash on an empty hostname; twin
  `cafe123` on #9002 (all its lines, measured 2026-01-10 against `beef001`)
- [ ] `11` new-option.patch — take as is — needs `7`
- [x] `8` long-names.patch — take, not as written — PR #9100 covers it fully (a rewrite)

### Settled

- [x] 🟢 `9` typo.patch — take as is — PR #9050, on main as `deadbee`
- `10` solaris8.patch — drop — dead platform; twin: none (measured 2026-01-10
  against `beef001`)
- `12` distro-paths.patch — downstream — `example/example-distro` — installs
  under `/opt` (2026-01-10); main keeps the configurable prefix — not carried yet
```

The PR carrying `8` names it back in its title — `long-names: keep full host
names in the status line (EX 8)` — so the line and the PR point at each other.

A line on the sibling tracker #9002, whose change has a twin here:

```
- `cafe123` — delegated → #9001 `7` — fix null dereference in hostname parsing
```

What each line shows:

| line | rules |
|---|---|
| `7` | a verdict (2); a PR still owed (3); its twin, with a checkable measurement — the only reference to the other tracker (6, 7) |
| `11` | order through `needs` (5) |
| `8` | another form, located and "fully" (2); the PR carries it (3), and names it back (9) |
| `9` | on `main`, with its evidence (4); its PR has merged, still `[x]` (3) |
| `10` | a reasoned drop, no PR involved so no box (2, 3); no twin, measured (6) |
| `12` | a downstream verdict naming its repository, dated, saying whether it is carried there; no PR, so no box (2, 3, 7) |
| `cafe123` | a pointer to the owner, no verdict of its own — the only reference to the other tracker (6) |
