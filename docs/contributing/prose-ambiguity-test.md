# Prose ambiguity test

A way to measure whether rules text means one thing to its readers. It is a
technique, not a requirement: no repository asks for it, and a pull request is
not held back for lacking it. The rules themselves live in the repository they
govern — for `xymon`,
[CONTRIBUTING.md](https://github.com/xymon-monitoring/xymon/blob/main/CONTRIBUTING.md)
and [AGENTS.md](https://github.com/xymon-monitoring/xymon/blob/main/AGENTS.md).

A sentence is ambiguous when two careful readers, in the same situation, would
do different things because of it. That is the test `CONTRIBUTING.md` already
uses for "misleading", turned into a measurement: build concrete situations,
give them to several readers who cannot see each other's answers, and count
where their actions differ.

## When it is worth running

- **Rules text** — `CONTRIBUTING.md`, `AGENTS.md`, the rule parts of
  `tests/README.md`: many readers act on it, its sentences interact, and a split
  becomes an argument in review. Most worth it when review rounds keep finding
  new facts in the same text, which is the sign that reviewers are sampling it
  rather than covering it.
- **Not interface text** — a build or packaging `README`, a shipped sample: the
  reader can check it directly, by running the build or reading the file, and
  that catches more for far less.

It complements a sweep of each changed sentence against each rule, one rule per
entry; it does not replace it. The sweep asks whether a sentence contradicts a
rule. This asks whether readers act the same way on it.

## Method

1. **Sentences.** List the sentences the change adds or alters, with
   `file:line`.
2. **Scenarios.** Someone other than the author writes three or four situations
   per sentence: concrete, naming who acts and on what, each ending in "following
   these files, what do you do?". They are chosen to split readers — edge cases,
   two sentences that could each govern the same case. The expected readings go
   in a separate file that readers never see.
3. **Readers.** At least three, answering every scenario blind: the action,
   the lines that decide it, and a confidence, low when the text allowed two
   readings. Use more than one model; readers of one model tend to agree with
   each other.
4. **Scoring.** A scenario diverges when readers would do materially different
   things — a different action, a different place to record something, yes
   against no. Different wording for the same action is not divergence. A
   sentence's score is the share of its scenarios that diverged.
5. **Noise floor.** Run the readers twice on the same text. Scenarios that
   diverge in one run and not the other are noise; only a split that repeats is
   a signal.

After a fix, rerun the same scenarios and compare scenario by scenario. A total
can stay flat while every targeted split is resolved and new ones surface at the
noise level.

## Before anything leaves your machine

A subagent can see its host's private memory and may use it to write scenarios.
Read the scenarios before they go to a tool run by another company, and replace
anything private — hosts, accounts, one person's working rules — with neutral
stand-ins.

## What it cannot show

- Only the situations someone thought of are tested. A score of zero means no
  split was found, not that none exists.
- Agreement between models is not agreement between people.
- It is not deterministic, so it cannot be a CI gate: `tests/README.md` removes
  flaky tests rather than tolerating them.
- It costs several model runs and about an hour of wall time.

## In the pull request

The result is evidence and belongs in the description, as a short table: the
checks run and what each found. The exact counts go there, not here — they
describe one run of one text.
