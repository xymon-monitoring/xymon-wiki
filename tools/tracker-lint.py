#!/usr/bin/env python3
"""tracker-lint — check a backport tracker against the mechanical rules.

Checks the rules of docs/contributing/backport-tracker-rules.md that can be
decided without judgement, and prints one line per violation:

    lint: rule N · <line id or heading> · <what is wrong>

A tracker is stable when this prints nothing and exits 0. Rules that need
judgement (is a form better, is a heading a subject) are not checked here.

Usage:
    tools/tracker-lint.py [--repo OWNER/REPO] ISSUE
    tools/tracker-lint.py --body FILE [--sibling-body FILE]   # a local draft

With ISSUE, the body and the sibling tracker named in the profile's Owner
field are fetched with `gh`. With --body, the sibling is read from
--sibling-body when given, and the cross-tracker checks are skipped otherwise.
Standard library only; needs `gh` (authenticated) when fetching.
"""

import argparse
import json
import re
import subprocess
import sys

FIELDS = ["Goal", "Source", "Out of scope", "Ids", "Owner", "Downstreams", "Layout", "Extra marks"]
KINDS = {"[feature]", "[fix]", "[perf]", "[enh]", "[cleanup]"}
VERDICT = re.compile(r"\*\*(take as is|take, not as written — [^*]+|downstream — [^*]+|drop — [^*]+|undecided)\*\*")
POINTER = re.compile(r"\*\*delegated → #(\d+) ((?:`[^`]+`/?)+)\*\*")
ITEM = re.compile(r"^\s*- (\[[ x]\] )?(🟢 |🟡 )?(?:`\[[a-z]+\]` )?`([^`]+)`")
HASH = re.compile(r"`([0-9a-f]{7,40})`")
DATE = re.compile(r"20\d\d-\d\d-\d\d")
PR = re.compile(r"#(\d{2,})")


def fetch(repo, issue):
    out = subprocess.run(["gh", "api", f"repos/{repo}/issues/{issue}", "--jq", ".body"],
                         capture_output=True, text=True, check=True).stdout
    return out


def profile(body):
    f = {}
    for m in re.finditer(r"^- \*\*([A-Za-z ]+):\*\* ?(.*)$", body, re.M):
        if m.group(1) in FIELDS and m.group(1) not in f:
            f[m.group(1)] = m.group(2)
    return f


def items(body):
    """(lineno, box, icon, id, line) for every item line; fenced code excluded."""
    out, fence = [], False
    for n, line in enumerate(body.split("\n"), 1):
        if line.startswith("```"):
            fence = not fence
            continue
        if fence:
            continue
        m = ITEM.match(line)
        if m and (VERDICT.search(line) or POINTER.search(line)):
            out.append((n, (m.group(1) or "").strip(), (m.group(2) or "").strip(), m.group(3), line))
    return out


def lint(body, sibling_body=None):
    v = []
    add = lambda rule, where, what: v.append(f"lint: rule {rule} · {where} · {what}")
    prof = profile(body)
    lines = body.split("\n")

    # rule 8: the progress block comes first; rule 11: the profile, all fields, in order
    first = next((l for l in lines if l.strip()), "")
    if not first.startswith("**Progress** (generated "):
        add(8, "top", "the progress block is not the first thing in the issue")
    got = [m.group(1) for m in re.finditer(r"^- \*\*([A-Za-z ]+):\*\*", body, re.M) if m.group(1) in FIELDS]
    if got[:len(FIELDS)] != FIELDS:
        add(11, "profile", f"fields missing or out of order: {got}")

    cite = re.search(r"cited elsewhere as `([A-Za-z]+) ", prof.get("Ids", ""))
    prefix = cite.group(1) if cite else ""
    hash_ids = "commit hash" in prof.get("Ids", "")
    sibling = next(iter(PR.findall(prof.get("Owner", ""))), None)
    marks = prof.get("Extra marks", "")
    downstreams = prof.get("Downstreams", "")
    down_names = set(re.findall(r"`([\w.-]+/[\w.-]+)`", downstreams))
    uses_kinds = "kind tags" in marks
    kind_priority = bool(re.search(r"(?i)priority:[^.]*`\[(fix|feature)\]`", prof.get("Layout", "")))
    cond_values = set(re.findall(r"\*([^*]+?)\*", marks.split("never our decision")[0])) if "_(cond:" in marks else set()

    its = items(body)
    ids = {i for _, _, _, i, _ in its}
    ids |= {i.split()[0] for i in ids}

    for n, box, icon, iid, line in its:
        where = f"`{iid}` (L{n})"
        verdicts = VERDICT.findall(line)
        ptr = POINTER.search(line)
        # rule 2 — one verdict, of an allowed form
        # the one exception: an upstream part and a downstream part, one verdict each
        if len(verdicts) > 1 and not (len(verdicts) == 2 and verdicts[1].startswith("downstream — ")):
            add(2, where, "more than one verdict")
        vd = verdicts[0] if verdicts else ""
        dv = next((x for x in verdicts if x.startswith("downstream — ")), "")
        if "compare and take the best" in vd:
            add(2, where, "the reason is the generic tail, not this change's reason")
        if ("a different version exists elsewhere" in vd or "a better version exists" in vd) and not re.search(r"\*\*(fully|partly)\*\*|\b(fully|partly)\b", line):
            add(2, where, "another version is named without saying fully or partly")
        if "only part of it is wanted" in vd and not re.search(r"(?i)not wanted|unwanted|is not wanted|excluded", line):
            add(2, where, "\"only part of it is wanted\" but the line names no unwanted part")
        if vd.startswith("drop — out of scope"):
            add(1, where, "an out-of-scope change has no line (rule 1); \"out of scope\" is not a drop reason")
        if dv:
            vd_save, vd = vd, dv
        if vd.startswith("downstream — "):
            if not DATE.search(line):
                add(2, where, "a downstream verdict is dated (rule 7)")
            if not re.search(r"carried in|not carried|/pull/\d+|[\w-]+#\d+", line):
                add(2, where, "a downstream verdict names what carries it there, or says it is not carried yet")
            who = vd[len("downstream — "):]
            if down_names and not any(d in who for d in down_names):
                add(2, where, f"downstream \"{who[:40]}\" names no repository from the Downstreams field")
        if dv:
            vd = vd_save
        # rule 3 — the box
        if ptr and not verdicts and box and "split" not in line.lower():
            add(3, where, "a pointer carries no box")
        if (vd.startswith("take") or vd == "undecided") and not box and icon != "🟢":
            add(3, where, "a take or undecided line needs a box")
        if (vd.startswith("drop") or vd.startswith("downstream")) and box == "[ ]":
            add(3, where, "a drop or downstream line owes no PR, so it has no [ ] box")
        prs = [p for p in PR.findall(line) if p != sibling]
        if box == "[x]" and not prs:
            add(3, where, "[x] but no PR is linked")
        # rule 4 — the icon
        if icon == "🟢" and not (HASH.search(line) or prs or re.search(r"`\w+\(\)` in `[\w./-]+`", line)):
            add(4, where, "🟢 without a commit or PR as evidence")
        if icon == "🟢" and vd.startswith("drop — already in"):
            add(4, where, "already on main means wanted and landed: take + 🟢 — or no line, if the profile excludes it (rule 1)")
        # rule 5 — order only through `needs`
        for m in re.finditer(r"needs (`[^`]+`|#\d+)", line):
            t = m.group(1).strip("`")
            if not t.startswith("#") and t not in ids and not re.fullmatch(r"[0-9a-f]{7,40}", t):
                add(5, where, f"needs `{t}`, which is not a line here")
        if re.search(r"\bneeds (\*\*)?#\d+", line):
            add(5, where, "a `needs` names a line, never a PR")
        if kind_priority and not ptr and not re.search(r"`\[(feature|fix|perf|enh|cleanup)\]`", line):
            add(11, where, "Layout orders by kind tag, and this line has none")
        if re.search(r"(?i)\b(prereq for|pairs? with|port it first|sequence (it )?after|apply in phase order|rides (the|that)|lands with|arrives with|launches with|comes with the)\b", line):
            add(5, where, "order written as prose, not as `needs` or `carried with <commit>`")
        for m in re.finditer(r"carried with (?!(devel )?`[0-9a-f]{7,40}`|that commit)\S+", line):
            add(5, where, "`carried with` names a commit by id, not a group")
        # rule 6 — pointers only point; no description of another tracker
        if ptr and not verdicts:
            tail = line[ptr.end():]
            head = line[:ptr.start()]
            if not re.match(r"^\s*- `[0-9a-f]{7,40}` — $", head) and not re.match(r"^\s*- `\d+[^`]*` — $", head):
                add(6, where, "a pointer starts with its commit id and nothing else")
            if "·" in tail or DATE.search(tail) or VERDICT.search(tail):
                add(6, where, "a pointer carries only its id, target and subject")
        # the other tracker is cited only as `#N <id>`: anything else describes it
        if sibling:
            for m in re.finditer(rf"#{sibling}\b(?! `[^`]+`)", line):
                add(6, where, f"cites #{sibling} other than by an item's id: \"{line[max(0, m.start() - 30):m.end() + 30]}\"")
        # rule 6 — a part pointer names its part and nothing else
        if ptr and verdicts:
            seg = line[:ptr.start()]
            seg = seg[max(seg.rfind("·"), seg.rfind(";")) + 1:] + line[ptr.end():].split(";")[0].split("·")[0]
            if re.search(r"\d+ of (its|that|this)\b|\d+%|\bmeasured\b", seg):
                add(6, where, "a part pointer carries a measurement; it belongs on the owner's line")
        # rule 7 — checkable claims
        for m in re.finditer(r"\bmeasured 20\d\d-\d\d-\d\d(?!,? (against|across|at) )", line):
            clause = line[:m.start()]
            clause = clause[max(clause.rfind("·"), clause.rfind(";"), clause.rfind(" — ")) + 1:]
            if not HASH.search(clause):
                add(7, where, "a measurement names its date but not the commit or snapshot it was taken against")
        if "date unknown" in line:
            add(7, where, "a measurement without a date")
        for m in re.finditer(r"\b(measured|traced|verified|checked|analysed)\b", line):
            clause = re.split(r"[·;)]", line[m.start():])[0]
            if not DATE.search(clause) and not DATE.search(line[max(0, m.start() - 30):m.start()]):
                add(7, where, f"\"{m.group(1)}\" without a date in its clause")
                break
        if re.search(r"`[\w./-]+\.[ch]`(,? L\d+| line \d+)|`[\w./-]+\.[ch]:\d+`", line) and not re.search(r"`?\w+\(\)`?|`\w+\[\]`", line):   # a function, or a file-scope symbol
            add(7, where, "a line number without the function it is in")
        # rule 8 — a fact once: each PR and each commit named once per line
        unneeded = re.sub(r"needs (?:(?:`[^`]+`|#\d+)[ ,/]*)+", "", line)   # a `needs <id>` is not a repeat
        for ref, k in __import__("collections").Counter(
                ["#" + p for p in PR.findall(unneeded) if p != sibling]
                + [h[:7] for h in HASH.findall(unneeded)]).items():
            if k > 1:
                add(8, where, f"{ref} is named {k} times on the line")
        # rule 8 — no PR state
        if re.search(r"\*\*?(PR )?#\d+\*\*? \((merged|draft|ready)\)|#\d+ \((merged|draft|ready)\)|PR-ready", line):
            add(8, where, "a PR's state is read on the PR, not written here")
        # rule 11 — ids, marks
        tok = iid.split()[0]
        if hash_ids and not ptr and not re.fullmatch(r"[0-9a-f]{7,40}", tok):
            if not (tok in KINDS and re.search(r"^\s*- (\[[ x]\] )?(🟢 |🟡 )?`\[[a-z]+\]` `[0-9a-f]{7,40}`", line)):
                add(11, where, "the line does not start with its commit id (profile Ids)")
        if not hash_ids and prefix and not re.fullmatch(r"\d+", tok):
            add(11, where, "the line id is not the form the profile's Ids field gives")
        for c in re.findall(r"_\(cond: ([^)]+)\)_", line):
            if cond_values and c not in cond_values:
                add(11, where, f"cond mark \"{c}\" is not declared in Extra marks")
        if "⚠" in line and "⚠" not in marks:
            add(11, where, "⚠ is used but not declared in Extra marks")
        for t in re.findall(r"`(\[[a-z/?]+\])`", line):
            if t in KINDS and not uses_kinds:
                add(11, where, f"kind tag {t} used but not adopted in Extra marks")

    # rule 10 — counted headings, and headings glued to a list item
    for k, l in enumerate(lines):
        m = re.match(r"^\*\*(.*?)\((\d+)\)\*\*\s*$", l) or re.match(r"^\*\*.*— \*group of (\d+) (?:commits|patches)", l)
        if m:
            want = int(m.groups()[-1])
            mem, started = 0, False
            for x in lines[k + 1:]:
                if re.match(r"^\s*- ", x):
                    mem, started = mem + 1, True
                elif started and x.strip() == "":
                    break
                elif not started and x.strip() and not x.startswith("*"):
                    break
            if mem != want:
                add(10, l[:50], f"says {want}, holds {mem}")
        if k and l.startswith("**") and re.match(r"^\s*- ", lines[k - 1]):
            add(10, l[:50], "renders inside the list item above it (no blank line)")

    # rule 6 — both directions of every twin link
    if sibling_body is not None:
        sib_items = {i.split()[0]: line for _, _, _, i, line in items(sibling_body)}
        for n, _, _, iid, line in its:
            for m in POINTER.finditer(line):
                hs = {h[:7] for h in HASH.findall(line)}
                for t in re.findall(r"`([^`]+)`", m.group(2)):
                    tl = sib_items.get(t)
                    if tl is None:
                        add(6, f"`{iid}` (L{n})", f"points to #{m.group(1)} `{t}`, which has no line there")
                    elif hs and not any(h in tl for h in hs):
                        add(6, f"`{iid}` (L{n})", f"#{m.group(1)} `{t}` does not name {'/'.join(sorted(hs))} back")
        # a split line on the other tracker points for its shared part: not a second decision
        own = {h[:7]: iid for _, _, _, iid, line in items(sibling_body)
               if VERDICT.search(line) and not POINTER.search(line) and "delegated →" not in line
               for h in HASH.findall(line.split("—")[0])}
        for n, _, _, iid, line in its:
            if VERDICT.search(line) and not POINTER.search(line):
                for h in re.findall(r"= devel `([0-9a-f]{7,40})`", line):
                    if h[:7] in own:
                        add(6, f"`{iid}` (L{n})", f"twin {h[:7]} also carries its own verdict on the other tracker")
    return v


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("issue", nargs="?")
    ap.add_argument("--repo", default="xymon-monitoring/xymon")
    ap.add_argument("--body")
    ap.add_argument("--sibling-body")
    ap.add_argument("--count", action="store_true", help="print only the count per rule")
    a = ap.parse_args()
    if a.body:
        body = open(a.body, encoding="utf-8").read()
        sib = open(a.sibling_body, encoding="utf-8").read() if a.sibling_body else None
    elif a.issue:
        body = fetch(a.repo, a.issue)
        s = next(iter(PR.findall(profile(body).get("Owner", ""))), None)
        sib = fetch(a.repo, s) if s else None
    else:
        ap.error("give an ISSUE or --body FILE")
    v = lint(body, sib)
    if a.count:
        c = {}
        for x in v:
            r = x.split(" · ")[0]
            c[r] = c.get(r, 0) + 1
        print(json.dumps(dict(sorted(c.items())), ensure_ascii=False), "total", len(v))
    else:
        print("\n".join(v))
        print(f"lint: {len(v)} violation(s)")
    sys.exit(1 if v else 0)


if __name__ == "__main__":
    main()
