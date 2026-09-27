# Backport tracker rules

For any issue that tracks code to be backported into `xymon` from one source — a
downstream patch set, or a branch. Adopting these rules is optional: a tracker
adopts them by linking here from its profile (rule 10). This page names no
tracker.

## Goal

A backport tracker answers four questions for every change in its source —
**once each, with evidence**:

1. **Do we want it** on `main`?
2. **In which form** — as written, or another version?
3. **Is it there** yet?
4. **What is still owed**, and after what?

A rule belongs on this page only if, without it, a tracker would answer one of
those questions wrongly, twice, or without evidence. Anything else is not a rule.

**Not the goal:** a log of how entries changed (the issue's edit history holds
that), a plan with dates, a copy of pull request descriptions, or a style guide
for prose.

## Rules

1. **Every change has one line.** One change per line, and every change in the
   source gets one; the profile says how completeness is counted.
2. **Each line has one verdict:**
   - `take as is` — port it as written;
   - `take, not as written — <reason>` — we want the change, not this form. If
     the reason is that a better version exists (on `main`, in a PR, on the other
     tracker), say where, and whether it covers the change fully or partly — and
     if partly, which part is missing;
   - `drop — <reason>`;
   - `undecided` — not triaged yet.
3. **The box says whether a PR is involved.** `[ ]` a PR is still needed ·
   `[x]` a PR, linked on the line, carries the change or made it unnecessary —
   merged or not · no box when no PR is involved (a drop on our own judgement, or
   a pointer).
4. **The icon says where it is.** 🟢 it is on `main`, naming the evidence — a
   commit, a merged PR, or a file and function. 🟡 part of it is; say which part
   is missing. No icon: not on `main`.
5. **Order is `needs <id>`.** It names what must land first, and nothing else
   expresses order.
6. **One change, one decision.** When two trackers hold the same change, their
   profiles name the owner. The other tracker's line only points —
   `delegated → #<owner> <id>` — and carries no verdict of its own. A pointer
   names every line that claims the change; where only part of a change has a
   twin, the line points for that part and keeps a verdict for the rest.
7. **Claims can be checked.** A measurement says when, and against which commit.
   Code is cited by file and function (a line number may be added); commits and
   PRs by their id.
8. **A fact is written once.** Prose does not repeat a mark, and nothing is
   written that can be read elsewhere — a PR's state, another line's verdict.
9. **Lines are grouped by subject** (the part of Xymon they touch). A heading
   says only what is true of every line under it.
10. **The profile** opens the tracker, under `### Rule`, links to this page, and
    holds everything true of that tracker alone:
    - **Goal** — this tracker's version of the goal above;
    - **Source** — what is tracked, and the snapshot it came from;
    - **Ids** — how a line names its change, and how it is cited elsewhere;
    - **Owner** — which tracker decides a change two trackers hold;
    - **Layout** — the top-level sections, and which holds settled lines;
    - **Extra marks** — any mark this tracker adds, with its meaning.

    A field that does not apply says *none*.

## Example

An invented tracker, issue #9001, with deliberately fake ids:

```
### Rule

This tracker follows the backport tracker rules (link). Profile:
- Goal: decide each of the 40 patches in example-pkg 1.2, and land every
  wanted one on main once, in its best form.
- Source: example-pkg 1.2 patch set.
- Ids: the patch number, cited elsewhere as `EX N`.
- Owner: this tracker owns every change it shares with #9002.
- Layout: Next · Later · Settled.
- Extra marks: none.

### Next

- [ ] `7` fix-null-deref.patch — take as is — crash on an empty hostname
- [ ] `11` new-option.patch — take as is — needs `7`
- [x] `8` long-names.patch — take, not as written — PR #9100 covers it fully (a rewrite)

### Settled

- [x] 🟢 `9` typo.patch — take as is — PR #9050, on main as `deadbee`
- `10` solaris8.patch — drop — dead platform
```

A line on the sibling tracker #9002, whose change has a twin here:

```
- `cafe123` — delegated → #9001 `7` — fix null dereference in hostname parsing
```

What each line shows:

| line | rules |
|---|---|
| `7` | a verdict (2); a PR still owed (3) |
| `11` | order through `needs` (5) |
| `8` | another form, located and "fully" (2); the PR carries it (3) |
| `9` | on `main`, with its evidence (4); its PR has merged, still `[x]` (3) |
| `10` | a reasoned drop, no PR involved so no box (2, 3) |
| `cafe123` | a pointer to the owner, no verdict of its own (6) |
