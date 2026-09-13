# Shortening text without losing it

`CONTRIBUTING.md` says a description is shortened losslessly or not at all, and that
shortening comes last. This page is the working version of that rule: the operations
that are safe, the ones that only look safe, and the test that separates them.

It applies to any prose the project carries — a pull request description, a review
comment, a commit message, a code comment, a manual page, an issue. The surface table
in `CONTRIBUTING.md` says where a fact belongs; this says what to do when the text
holding it has grown.

## The test

Before each cut, name what a reader could no longer do.

| the answer | verdict |
|---|---|
| "read it a second time" | cut it |
| "check the claim" | keep it — that is a citation |
| "understand why" | keep it — that is the reason someone would otherwise undo the change |
| "know whether it affects them" | keep it — that is the specifics |

## Lossless — the information survives

1. **Deduplicate.** The same fact stated twice in one document. One RFC carried
   "DNS answers with addresses, not machines" in four places; three went and the
   argument was unaffected.
2. **Relocate.** Move a block to where its reader is rather than delete it. A blocking
   analysis moved from a pull request body into a comment on the same pull request: the
   body shrank by a fifth, the analysis stayed one click from the `blocked` label.
3. **Merge overlapping sections.** Two sections making one argument become one. A
   section titled "Why the two phases differ" turned out to restate an earlier item
   four times over; deleting it lost one clause, which moved into that item.
4. **Delete superseded text.** Prose describing a design that was replaced. One RFC
   still argued against synthesising host entries weeks after that stopped being the
   proposal — the argument was sound and answered a question nobody was asking.
5. **Cut the audience-less.** Notes to self, questions already answered, expired status.
   A review comment still asked "happy to add that here or keep it separate — say which
   you prefer" about work split into its own issue three weeks earlier.
6. **State the rule instead of the enumeration.** Five examples illustrating one rule
   become the rule and one example. Keep the enumeration when the examples differ in
   kind rather than in detail — see the traps.
7. **Compress prose, not facts.** Remove connectives, hedges, and sentences restating
   the one before. Turn a paragraph into a table when the table carries the same facts:
   one section went from 452 lines to 287 that way with nothing dropped.
8. **Let each fact live at its natural level.** A fact about what the code does belongs
   in the code comment, with the prose pointing at it. Two prose copies of a code fact
   is how a pull request came to claim an RRDtool version floor that its own header
   comment denied, for three weeks, after the author had already retracted it.
9. **Reference instead of restate** — only when the reader can reach the target. This
   is the operation that turns into a trap: pointing an admin at a `README` that is not
   installed removes the information for them.

## Lossy — these look like editing

- **Dropping citations and line numbers.** They are the evidence. Without them a claim
  becomes an assertion, and the next person to check it has to rediscover it.
- **Dropping the why.** The reason behind a decision is what stops someone undoing it.
  A comment saying "this resets unconditionally rather than asserting a version floor"
  is what prevents a well-meaning version probe being added later.
- **Dropping the failure mode or severity.** That is what justifies a label, a priority
  or a block. "systemctl reload would report success while every task kept its old
  configuration" is the sentence that earns the `blocked` label.
- **Dropping one of two proofs that look alike.** Two verification tables can test
  different things — path substitution per build type, and the three states of a
  variable. Check what each proves before calling either redundant.
- **Generalising specifics.** "Anything keyed on mtimes" loses who is affected;
  "pre-3.5 Linux kernels, and permanently on macOS" is what lets a reader decide
  whether the note is about them.
- **Pulling an answer out of the thread that asked the question.** The same measurement
  is context in a description and a rebuttal in the reply where the concern was raised.

## Shorten last

While a change is still moving, editing its text for length desynchronises it rather
than compressing it: what survives the cut describes the previous revision. Every
shortening pass over a moving document in one session was followed by an analysis pass
finding stale text the shortening had just created — a removed mechanism still named in
four places, headings that no longer matched their content, a section arguing against a
design already dropped.

Shorten when a re-read turns up nothing new. That, not a length target, is the signal.
