# Agent recipes

The concrete commands behind [Using AI agents within limited budgets](agent-usage.md),
for the tools that page leaves unnamed. Tools change faster than techniques, so each
recipe says the version it was last checked with; one that stops working is a reason
to update this page, not the technique. Like that page, nothing here is a requirement.

## A reviewer from another provider, run from the command line

Both recipes below hand a change to an outside reader: read-only, non-interactive,
the diff on stdin, the answer on stdout. Run them from inside the repository.

### Codex as the reviewer

Checked with codex-cli 0.167.1.

```
git diff <base>...<head> | codex exec --sandbox read-only -c model_reasoning_effort=high "$(cat prompt.txt)"
```

- `--sandbox read-only` lets it read the tree and change nothing.
- `model_reasoning_effort` trades time for depth: `high` for the last review, lower for
  a quick check. A deep review of a small change can take around ten minutes or more, so
  run it in the background.
- The commands it ran are in its output, as lines containing `bin/bash -lc` in this
  version. Count them before trusting a clean verdict: a run that ran none answered from
  the diff alone.
- When it has run out of its allowance it says so, with the time it resets, in answer to
  any request: a one-word request is a cheap probe.
- What is left is recorded in each of its session files, under
  `~/.codex/sessions/YEAR/MONTH/DAY/*.jsonl`, as `rate_limits`: a `primary` window
  (5 hours) and a `secondary` one (a week), each with `used_percent` and `resets_at`
  (a Unix time). The newest file gives the latest figures, without spending anything.

### Claude as the reviewer

Checked with Claude Code 2.1.330.

```
git diff <base>...<head> | claude -p --permission-mode plan --model <alias> "$(cat prompt.txt)"
```

- `-p` runs it non-interactively; `--permission-mode plan` keeps it read-only.
- `--model` takes an alias: `haiku` for a quick check, `sonnet` or `opus` for a deep
  review. `--output-format json` gives a machine-readable answer.

### For both

- Pin both commits in the prompt, and say not to look for any other branch, commit or
  pull request: a reviewer left to find the change itself has been seen to review a
  different one.
- Ask for deliverables, as [the technique](agent-usage.md#ask-for-deliverables-not-for-problems)
  describes: every caller, every sentence against the code, every number recomputed.
- Read what goes out first: the diff and the prompt go to another company. See
  *Before anything leaves your machine* in the
  [prose ambiguity test](prose-ambiguity-test.md#before-anything-leaves-your-machine).
- Verify every finding before acting on it. In a pull request to `xymon`, report it in
  your own words without naming the tool, as CONTRIBUTING.md's pre-review asks.

## A helper inside a Claude Code session

Checked with Claude Code 2.1.330. A session can hand work to a sub-agent through its
Agent tool and get back only the sub-agent's report, which keeps long reading out of
the main session:

- `subagent_type`: `Explore` for a read-only sweep, `general-purpose` for work;
  `model`: a fast one (`haiku`, `sonnet`) for sweeps; `isolation: worktree` when several
  sub-agents write in parallel.
- The brief is all it knows: the goal, what is already ruled out, the paths, and the
  report wanted (its length, facts only).
- Its report is the output of a model: check what you rely on.
- It is the same provider as the session, so as a reviewer it is another model of the
  same provider, not an independent reader.
