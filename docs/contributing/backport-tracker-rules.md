# Backport tracker rules

These rules are for any issue that tracks code to be backported into `xymon`:
changes from one source — a downstream patch set, or a branch — towards `main`,
one line per change. Adopting them is optional. A tracker adopts them by linking
here from its profile (P1), and this page names no tracker: which ones apply it is
read from their links, not recorded here. Everything true of one tracker alone —
its source, its ids, its sibling, its layout — goes in that tracker's **profile**
(axis P), never on this page.

Each rule has an id — an axis letter and a number — so a line or a review can
cite the rule it breaks ("breaks O8"). Each section is one **axis**: one
question a line answers, or one kind of discipline. A rule sits on exactly one
axis; rules that relate the axes to each other are on axis C.

| axis | question |
|---|---|
| **P** Profile | what is true of this tracker alone? |
| **L** Line | what is one line? |
| **O** Ownership | which line decides a change that two trackers hold? |
| **V** Verdict | what do we want done with the change? |
| **B** Box | is a PR owed, and which one carries it? |
| **I** Icon | where is the change already, on `main`? |
| **N** Needs | what must land first? |
| **A** Annotations | what else is said beside the verdict? |
| **C** Consistency | do the marks and lines agree with each other? |
| **E** Evidence | how is a claim dated and cited? |
| **S** Structure | how are lines grouped and headed? |

## P — Profile

- **P1.** A tracker that adopts these rules opens with a `### Rule` section that
  links to this page and states its profile. That link is the adoption; a
  tracker without one is not bound by this page.
- **P2.** A profile carries only what is true of that tracker, and nothing in it
  may contradict this page.
- **P3.** A profile has these fields, in this order; a field that does not apply
  says *none* rather than being left out:
  - **Source** — the kind of artifact tracked (a patch from a named patch set,
    or a commit from a named branch) and the snapshot it was taken from.
  - **Item id** — how a line names its artifact, and the abbreviation used to
    cite it outside the tracker (E5).
  - **Siblings and ownership** — the other trackers that can hold the same
    change, and which one **owns** it (O1).
  - **Box scope** — what this tracker's checkboxes cover: every item, or only
    the work it owns (O5).
  - **Extra marks** — marks particular to this source, each with its defining
    clause (A4).
  - **Kind tags** — if the tracker tags items by kind, the legend that defines
    each tag.
  - **Layout** — the top-level sections and what each one holds (S3), and which
    one holds settled lines (B5).
  - **Exclusions** — what is deliberately out of scope, and why.
  - **Checklists** — any progress list (S7).

## L — Line

- **L1.** One line = one artifact, always — one patch, or one commit, of the kind
  the profile names.
- **L2.** A bundle is a group, not a line: give it a heading, put each member on
  its own line beneath it, and let the heading carry what is true of all of them
  (S4).
- **L3.** Analysis true of only some members is written once, on one of them, and
  referenced from the others (`see <id>`) — never restated (C2). Dependencies
  are expressed the same way (N1).
- **L4.** A bullet that only elaborates its parent — a step, a caveat, a
  sub-task — is not a separate artifact, and needs no verdict, checkbox or
  cross-reference of its own.
- **L5.** The same underlying change may appear on two trackers — as a patch on
  one, as a commit on the other — linked by cross-reference (O8), never by shared
  ownership.

## O — Ownership

- **O1.** Where two trackers can hold the same change, their profiles name which
  one owns it. Delegation goes one way only, towards the owner: an item with a
  twin on the owner delegates to it (V5), and the owner never delegates back.
- **O2.** For a delegated item, the substantive verdict (V1–V4), its reason, the
  checkbox and every supporting detail live on the owner's line — exactly one
  line. The delegation marker is a pointer, not a second verdict.
- **O3.** A delegated line carries exactly three things and nothing else: its
  identity (the artifact's id and title — for a commit, its hash and subject),
  the marker, and any group heading above it. No reason, no checkbox, no icon,
  no analysis.
- **O4.** Anything the delegating side knows that the owning line lacks is moved
  there, never duplicated.
- **O5.** Split lines: where one artifact bundles a slice that has a twin on the
  owner with unrelated work, the line carries the marker for the delegated slice
  and a verdict plus checkbox for the remainder it still owns — and says which is
  which. So a delegating tracker's checkboxes cover only the work it owns. A group
  may be partly or wholly delegated; where every member is delegated, the group
  is a reference section, not that tracker's work.
- **O6.** Ownership terminates. Exactly one line holds the substantive verdict
  for a change; following the pointers must reach it, and the chain must never
  return to where it started. A line that hands its verdict to another must not
  be handed it back.
- **O7.** A pointer is total: a delegation marker names every item that claims
  that artifact, not the first one found. An item it omits is orphaned from the
  decision meant to cover it.
- **O8.** Name the counterpart on the sibling tracker — its twin — when one
  exists. A counterpart is in exactly one of three states: **named** · **not
  traced** (suspected, unconfirmed) · **none** — and *none* is written only once
  it has been measured, saying when and against what. Silence means the question
  has not been asked, not that the answer is no. On a delegating tracker the
  counterpart is named by the delegation marker; there, this rule applies only to
  a line that is not delegated, or only partly (a split).
- **O9.** Where both twins exist and differ, name both and take the best of the
  two; assert that one form wins only once the comparison is recorded, on the
  owning line.
- **O10.** A counterpart names you back: where one tracker names its twin, the
  other names it too. A mapping asserted on one side only is unverified.

## V — Verdict

- **V0.** Exactly one verdict per item line, required: one of V1–V5 and nothing
  else. A group heading is not an item line: it carries no verdict, no checkbox
  and no icon of its own.
- **V1.** **`drop — <reason>`** — we don't want this change on `main`.
  *Reasons:* already in `main` · obsolete / dead platform · N/A on `main` (no
  effect, no callers) · harmful as written · incomplete as written · superseded
  · workaround for a problem fixed elsewhere · site-specific tuning, not general
  · build churn, better done natively · packaging or debug — downstream's
  business · *other — state it*.
- **V2.** **`take as is`** — port it as written.
- **V3.** **`take, not as written — <reason>`** — we want the change, not this
  form. *Reasons:* needs improvement (bugs, docs, style) · a different version
  exists elsewhere — on the other tracker, on `main`, or in an open PR — compare
  and take the best (V6) · only part of it is wanted · needs a prerequisite first
  · *other — state it*.
- **V4.** **`undecided`** — not triaged yet. Write the word; don't leave it blank.
- **V5.** **`delegated → #<owner> <id>`** — only on a tracker that delegates
  (O1). Fills the verdict slot without deciding anything; the line carries only
  what O3 allows. Never used on the owning tracker.
- **V6.** "A different version exists elsewhere" names where it is, and says
  whether it covers this item **fully or partly**. The judgement is about the
  feature, not the patch. It covers fully when it does the same thing; when it
  does it better (a rewrite covers the feature completely and may share no text
  at all); or when it omits a part we have decided we do not want — name that
  part and why. Only a *wanted*, unimplemented part is a gap, and a
  partly-covered line says which part is missing. Shared-line counts are
  evidence, never the measure; an unlocated "a better version exists" is not a
  reason.
- **V7.** Prefer the form that already exists. Source artifacts are the source,
  not the target: where a corrected version of the same change is already on
  `main`, or in an open PR ready for review, that form is what we take, and the
  artifact this line tracks becomes a reference, not the work. This is why 🟢
  reports the outcome rather than the resemblance (I2), and why the carrier is
  the undrafted PR (B3).
- **V8.** A slot is defined by what may occupy it, never by what may not. A
  closed list of allowed values excludes everything else by construction; a
  second list of forbidden values can only restate it or contradict it.

## B — Box

The checkbox's presence is the default hypothesis that a PR will be needed.

- **B1.** **`[ ]`** — a PR is expected here; none carries it yet. Default for
  every `take …` and `undecided` line.
- **B2.** **`[x]`** — a PR carries it, linked on the line. That PR is the
  **carrier**; any other PR named on the line is context. A tick does **not**
  mean merged — that is 🟢's job (I2).
- **B3.** Choosing among carriers: where more than one PR would carry an item,
  the carrier is the one ready for review — an undrafted PR over a draft. A draft
  proposes how the work might be done; an undrafted PR offers to land it. Name
  every live PR that would carry it — the chosen one as the carrier, the rest as
  context — so a reader sees each route the change could take. One closed without
  merging, or one that has since dropped the change, is not named: it carries
  nothing. Between two of equal standing, prefer the one scoped to this item
  alone.
- **B4.** A PR settles a line two ways: by carrying its change, or by removing
  the need for it. So a `drop — superseded` line takes `[x]` and names the PR
  that superseded it — the question is resolved, and the reader can see by what.
  Such a line never becomes 🟢, however its superseder ends up: the icon reports
  where this line's change is, and a superseded change never reaches `main`.
- **B5.** A supersede is not settled until its superseder lands. While that PR is
  open the drop is conditional — if the PR is abandoned the change is wanted
  again — so the line keeps its place and `needs <that PR>`, and moves to the
  profile's settled section only once the PR merges.
- **B6.** **plain point `-`** — no PR is involved: the line is delegated to its
  owner, or it is a `drop` we reached on our own judgement with no PR resolving
  it.
- **B7.** A carrier carries: a PR named by `[x]` must actually settle the line —
  contain the change, or, on a `drop — superseded`, remove the need for it. A PR
  that never had it, or has since dropped it, is not a carrier.

## I — Icon

The status icon says where the change already is, and nothing else.

- **I1.** 🟡 **partly in `main`** — some of it is genuinely absent; the line says
  which part is missing.
- **I2.** 🟢 **in `main`** — the change is there and nothing is outstanding,
  however it was shaped: a port merged in a corrected or different form is 🟢,
  not 🟡, because the icon reports the outcome, not the resemblance.
- **I3.** No icon means not in `main` — the default, never marked. Where absence
  has actually been verified, say so in words.
- **I4.** The icon states a fact about the code, never about PRs or intentions:
  "in a PR" is `[x]` plus the link, and "diff before porting" is the verdict
  `take, not as written`. Beware the near-homonym: "only part of it is
  **wanted**" is a verdict reason (V3), not a presence claim — 🟡 is only for
  what is already there.
- **I5.** 🟢 is deliberately redundant: it can always be derived, from a merged
  carrier or from the evidence I7 requires. It is kept because the list is read
  by people, and "already landed" must be visible at a glance rather than
  resolved from PR states one line at a time. It is the only reading promoted to
  a mark (C3).
- **I6.** A delegated line carries no icon: its state is tracked on the owner's
  line.
- **I7.** Any claim that a change is already in `main` — 🟢, or a
  `drop — already in `main`` verdict — names the evidence: the `main`-side
  commit, the merged PR that brought it, or the file and symbol where it lives
  (E3). An unreferenced claim is a guess, not a verdict. Not yet merged is not
  `main`: a change waiting in an open or draft PR is `drop — superseded`,
  pointing at that PR (B5).

## N — Needs

- **N1.** A dependency is written **`needs <id>`** — the id of the item that must
  land first — once per line, with every prerequisite named inside that one mark
  (`` needs `A` `B` `C` ``), in that exact form. Prose such as "rides",
  "requires" or "prerequisite" is not a substitute, though it may stay as
  explanation. A dependency is never a bare PR reference.
- **N2.** Carrier and dependency are different roles: an item ships *with* its
  carrier and *after* its dependencies. An item never `needs` the PR that
  carries it — that PR is its vehicle (B2), not a prerequisite.
- **N3.** Nothing marks *blocked*: that is read from `needs <id>` plus the state
  of the item it names, so it cannot go stale. "What can start now" is every
  `[ ]` line with no `needs`, or whose `needs` target is already merged.

## A — Annotations

Marks that sit beside a verdict. Each answers a different question, and none of
them replaces the verdict.

- **A1.** **`PARKED`** — priority. Deliberately not being worked on now. It says
  nothing about whether we want the change.
- **A2.** **`no longer applies cleanly`** — a measurement. The artifact does not
  apply to `main` cleanly — for a patch at `--fuzz=0`, for a commit as a
  conflict-free cherry-pick — as of the date given. Context drift, not a verdict:
  a change can still be wanted and hand-ported.
- **A3.** **⚠** — emphasis, never status. It highlights a caveat in prose — a
  conflict, a risk, a stale measurement. It is not a verdict, not an icon, and
  never the only place a fact lives: whatever it emphasises also sits in its
  proper field.
- **A4.** A profile may define further marks of this kind for its source (P3);
  each is defined there, with the same force as a rule here.

## C — Consistency

- **C1.** Every mark has exactly one defining rule: box → B · icon → I ·
  verdict → V · `needs` → N · `PARKED`, `no longer applies cleanly`, ⚠ → A ·
  a profile's extra marks and kind tags → that profile. A mark with no rule is
  not a mark: define it, or stop using it.
- **C2.** Say it once, within a line too: no mark may restate another, and no
  prose may restate a mark. Where a line carries a mark, the surrounding text
  adds something the mark does not say — *which* part, *which* symbol, *why* —
  or says nothing at all ("requires `65`" beside `needs `65`` is a repetition;
  "(its keywords)" is not). The same holds within the prose: no fact twice on one
  line. A line fails if any of these holds — keep the more precise statement and
  delete the other:
  1. the mark's own words reappear in the prose — beside `drop — superseded`, the
     prose says *by what*, never "superseded" again;
  2. an id appears twice in the same role — one PR named twice as the carrier,
     one commit named twice as the twin;
  3. a relationship is explained twice — "reimplementation, not a cherry-pick"
     said in two places.

  When two fields would carry the same fact, keep the one whose axis owns it.
- **C3.** Derived state is read, not recorded. If a fact can be read from
  something else — a PR's state, another item's verdict, whether a `needs`
  target has landed — do not write it down: a recorded state is stale the moment
  the thing it describes moves; a reading is always current. This is C2
  extended over time, and it retired ⏳ (it
  meant `[x]` and not yet merged — exactly `[x]` with no icon), 🔴 (it meant
  "no 🟡/🟢") and a *blocked* mark. The one exception is 🟢 (I5).
- **C4.** Marks must not contradict. The box says what is *owed* (`[ ]` a PR,
  `[x]` a merge, `-` nothing), the icon where the code *is*, the verdict what we
  decided, `needs` what must come first. Read a line's marks together as one
  sentence before writing it; if that sentence contradicts itself, one half is
  wrong — and which half is a question about the code, not about the wording.
  Keeping the axes separate is what makes them cross-checkable.
  Two that bite: 🟢 says nothing is owed, so it takes `[x]` or a plain point and
  never `[ ]` (🟡 leaves the rest owed, so it takes any box); and carriage is
  asserted by the box alone, so prose naming a carrier beside a `[ ]` means the
  box or the prose is wrong.
- **C5.** Claims about other lines hold there too. A pointer, a carrier, a twin
  or a delegation asserts something about a second line; the assertion is a
  defect unless that line bears it out — see O6, O7, O10 and B7.

## E — Evidence

- **E1.** Date what you establish. A measurement or a manual verification records
  when it was made and against what — the `main` commit, or the source commit,
  it was checked against. An undated claim cannot be refreshed or trusted, only
  re-done. Say "date unknown" rather than leave it implied.
- **E2.** Citations resolve, or they are defects. Every commit hash, PR number
  and item id cited must exist and name what it claims to name. A hash that
  resolves to no commit, a `needs` pointing at no line, or two abbreviations of
  one commit on two lines is a defect to fix, not a note to keep. Compare hashes
  by their full object id, not by the text.
- **E3.** Cite an artifact by its permanent id, never by where it sits; cite a
  place in code by file and symbol (`lib/loadhosts.c`, `xmh_item()`). A line
  number may accompany the symbol but never replace it, and it is a measurement
  like any other (E1). A bare `file:line` is a defect — line numbers shift on
  every edit, and a reader cannot tell a stale one from a live one.
- **E4.** A commit is citable once it is reachable from `main` or from the
  tracked branch. A sha on a PR branch is not: the branch rebases and the id
  dies — silently, and only for other readers, since it still resolves in the
  clone that wrote it. Cite the PR for work in flight, and the permanent commit
  once one exists.
- **E5.** A pull request porting a tracked artifact names it in its title, in the
  single trailing parenthesis: the owning tracker's id first, then the other's,
  each with the abbreviation its profile sets, separated by a comma —
  `(<owner-abbr> <id>, <other-abbr> <id>)`. Several ids on one side are joined by
  `/` and listed, not summarised. Where only one side exists, only that side is
  named.
- **E6.** Record findings, not the record's history. A finding about the artifact
  stays — "mapping to `X` disproven (0%)", "already on `main` as `Y`" — because
  it stops someone re-deriving it. How the entry got here does not ("moved from
  Bucket 5", "corrects an earlier note"): the issue's edit history holds that,
  and the line's position already says where it sits.

## S — Structure

- **S1.** Lines that will produce work are grouped by **subject** — the part of
  Xymon the change touches (xymonlaunch, proxy, RRD, channel/IPC, history,
  client, web, lib, build …) — not by where the patch came from or how it was
  measured. Subject grouping is what makes the list readable and lets PRs and
  commits be organised by subject. It does not imply one PR per group: a subject may take several
  PRs, and one PR may span several subjects — but only as far as one reviewer
  can still read it in a sitting. A bundle of commits across many areas can sit
  unreviewed for months and close unmerged; the narrowest coherent PR is the one
  that lands.
- **S2.** Dropped lines need no subject grouping, and stay together.
- **S3.** Exactly two levels of grouping: the bucket, and the phase under it. A
  bucket (a top-level section, named in the profile's *Layout*) is a
  disposition — what we have decided to do with everything inside. A phase is
  the only thing that may sit under it. Nothing nests under a phase — no family,
  no sub-group, no second roster; a subject, a commit family and a delivery step
  are all phases, told apart by their name, not their depth. When a phase grows a
  would-be sub-group, promote it to its own phase, never indent it: a third level
  is where joint claims hide — it reads as belonging to the parent's members too,
  and it gives a member somewhere to keep its verdict other than its own line.
- **S4.** A bucket or family heading may carry any statement true of **every**
  line under it — a delegation, the family PR, a shared blocker or risk — and
  those lines need not repeat it. The verdict always stays on the line, so a line
  reads on its own. A line that contradicts its heading is in the wrong group:
  move it. A heading over delegated lines may carry the family's shared facts
  (its PR, blocker or risk); per-change analysis still lives on the owner's line.
- **S5.** A heading names no PR — none, ever: not a member's carrier, not the
  family's own PR, not a shared risk, not the delivery chain. A heading carries
  the subject and nothing that can go stale: PR numbers move, merge, close and get
  superseded, and a heading is the one place nobody re-reads when they do.
  Whatever a PR reference would say belongs on the lines it is true of — or,
  where it is genuinely about the whole section, in that section's prose. A
  group-level PR claim is also usually a joint one, true of the group but of no
  member exactly, which hides that members differ.
- **S6.** The first blank line after the members closes the group; one directly
  under the heading, where Markdown convention puts it, does not. Everything
  between the heading and the closing blank line is a member, and the count in
  the heading must match. Items that follow are their own artifacts, not members.
- **S7.** A checklist named in a profile is a plain progress list, where `[x]`
  just means done.
