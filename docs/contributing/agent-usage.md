# Using AI agents within limited budgets

A way to spend AI agents' time where it finds the most, when their budgets
run out. It is a technique, not a requirement: no repository asks for it, and
a pull request is not held back for lacking it. The rules live in the
repository they govern: for `xymon`,
[CONTRIBUTING.md](https://github.com/xymon-monitoring/xymon/blob/main/CONTRIBUTING.md)
and [AGENTS.md](https://github.com/xymon-monitoring/xymon/blob/main/AGENTS.md).
Whatever this page suggests, the evidence they ask for stays the same.

## Roles, not tools

Give each piece of work to a role, and each role to whichever agent can fill it
now:

| role | does | needs |
|---|---|---|
| deep analyst | the first analysis, once: the design, whether a defect can be reached, the other places the same defect sits | a strong model, and time |
| fast verifier | each iteration: is this finding fixed, does the test fail without the fix, did the change add anything in those lines | any fast model: the questions are narrow and checkable |
| independent gate | the last review, once, cold, without the author's conclusions | the most independent reader available (below) |

The independent gate is an agent's review, made before the change is offered.
It does not replace the review by a person that CONTRIBUTING.md asks for, and
AGENTS.md (*Reviews*) leaves choosing and asking a reviewer to the author, never
to an agent.

Spend the strong model at the start and at the end. A design flaw found only at
the end makes every cheap iteration before it wasted work.

## Change models where the question is open

Switching models at every iteration looks like more coverage, but it costs more
than it finds. A new reader brings its own remarks, often about form or taste,
so each round opens new ones and the iterations stop converging. A finding can no
longer be traced to the change rather than to the reader. And each new model
reads everything again to answer a narrow question: whether a check fails without
the fix has one answer, whichever model gives it.

Keep one fast verifier through the iterations of a change, and take another only
when it becomes unavailable: the questions are closed, so any model will do. Put
the variety where the questions are open, in the first analysis and the last
review; with budget left, the last review can go to two different readers in
turn.

## Split the last review by the kind of question

The last review asks two kinds of question, and they need different readers:

| part | asks | ideally | otherwise |
|---|---|---|---|
| 1. the earlier findings again | is each finding from the iterations still fixed in the final version? This catches one fix undoing another, which the iterations miss | no agent: the tests that pin each finding, run again | the fast verifier, for what no test can reach (a manual page, a commit message) |
| 2. one open question | what is missing? Asked cold, without the earlier conclusions | the most independent strong reader available | one degree down, said so |

Run part 1 first. If a finding has come back, the change goes back to iterating
before the costly reading of part 2 is spent on a version that will change. And
pin findings with tests wherever you can: a test rechecks its finding for nothing,
the same way every time, while only the open question can find something new, so
that is where the depth goes.

Part 1 also gives the final "nothing found" its content: the list of earlier
findings, each with its state.

## Independence comes in degrees

Models trained by the same provider share much of their data and methods, so
they are likely to miss the same things. That is a reasonable assumption, not a
measured one. Several models from one provider differ mostly in depth, which
suits the fast and deep roles, more than in independence.

| degree | the last review is read by |
|---|---|
| strong | a model from another provider |
| medium | another model from the same provider, in a fresh context |
| weak | the same model, in a fresh context |

When you report a review, say which degree it had. CONTRIBUTING.md's pre-review
already asks whose run each check is, and gives an AI tool's finding in the words
of whoever reports it, without naming the tool; AGENTS.md forbids crediting one.
So give the degree, not the product.

Sending work to another provider sends it to another company: read what goes out
first, as *Before anything leaves your machine* in the
[prose ambiguity test](prose-ambiguity-test.md#before-anything-leaves-your-machine)
describes.

## Ask for deliverables, not for problems

"Review this" invites a reader to stop at the first plausible "nothing found".
Ask for what the verdict rests on instead: every caller of the function, every
number in the description recomputed, every claim of the commit message checked
against a line. A short change gets a shallow answer unless the reading itself
is the deliverable. Count what the reviewer actually read before trusting a
clean verdict.

## Modes, chosen by what is left

Decide before each heavy task, from what is available at that moment:

| mode | when | broad sweeps | analysis and the last review | builds and tests |
|---|---|---|---|---|
| normal | every agent available | a fast model | strong model first; the most independent reader last | as needed |
| one agent out | an agent reports its usage limit, and when it resets | a fast model | the last review one degree down, said so; or wait for the reset if the change can wait, and note when | as needed |
| frugal | the main budget is running low | a fast model, short reports | a deep pass only where it matters; optional reviews postponed, and listed | the tests that cover the change, on a build kept between runs |

An agent that has run out often says so, and when it resets, in answer to any
request; where it does, a one-line probe before relying on it costs almost
nothing. Your own main budget you usually see only from its usage page.

## Delegate the reading that floods the context

In a long session, what fills the main agent's context is less its own
reasoning than the output it read: lists of pull requests, logs, diffs, searches
through history. A sub-agent can do such a sweep on a fast model and hand back
only its conclusion, so the main context, reread at every turn, grows more
slowly. The total number of tokens does not necessarily fall, since the
sub-agent reads too; what falls is the price per token of that reading, and the
weight carried by every later turn.

Parallel sub-agents pay off only for long, independent series. A handful of
small fixes done in a row is usually quicker than coordinating them.

## What no mode saves on

The checks a change is judged by are not a review and are never cut: the test
that fails without the fix and passes with it, the platform the result was
really obtained on, and every number recomputed rather than carried over. When a
budget is tight, claim less, rather than check less.
