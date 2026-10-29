#!/usr/bin/env bash
#
# project-activity.sh — generate docs/about/project-activity.md
#
# Counts pull requests and reviews across the organisation's public
# repositories over the last 12 months, and the activity of each group, and
# writes the page. No person is named on it: per-person numbers belong in the
# organisation's private records, not on a public page.
#
# Usage:
#   tools/project-activity.sh [--org ORG] [--out FILE] [--since YYYY-MM-DD]
#
#   --org    organisation (default xymon-monitoring)
#   --out    page to write (default docs/about/project-activity.md)
#   --since  start of the window (default: 365 days before now)
#
# Needs: gh (authenticated), jq.

set -eu

org="xymon-monitoring"
out="docs/about/project-activity.md"
since=""
# The review table in xymon's CONTRIBUTING.md took effect on this date
# (commit 9c631aebd). Merges before it are counted, but not held against it.
rule_date="2026-09-13"

while [ $# -gt 0 ]; do
	case "$1" in
		--org) org="$2"; shift 2 ;;
		--out) out="$2"; shift 2 ;;
		--since) since="$2"; shift 2 ;;
		-h|--help) sed -n '3,20p' "$0"; exit 0 ;;
		*) echo "unknown argument: $1" >&2; exit 2 ;;
	esac
done

now=$(jq -nr 'now | todate')
[ -n "$since" ] || since=$(jq -nr 'now - 365*86400 | todate | .[0:10]')

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# ---- collect ---------------------------------------------------------------

gh api graphql --paginate -f org="$org" -f query='
query($org:String!, $endCursor:String) {
  organization(login:$org) {
    repositories(first:100, after:$endCursor, privacy:PUBLIC) {
      pageInfo { hasNextPage endCursor }
      nodes { name isArchived }
    }
  }
}' --jq '.data.organization.repositories.nodes[] | select(.isArchived|not) | .name' > "$work/repos"

: > "$work/prs.jsonl"
while read -r repo; do
	gh api graphql --paginate -f owner="$org" -f repo="$repo" -f query='
query($owner:String!, $repo:String!, $endCursor:String) {
  repository(owner:$owner, name:$repo) {
    pullRequests(first:50, after:$endCursor) {
      pageInfo { hasNextPage endCursor }
      nodes {
        number title url state isDraft createdAt mergedAt
        author { login } mergedBy { login }
        files(first:100) { nodes { path } }
        reviews(first:100) { nodes { author { login } state submittedAt } }
        timelineItems(first:50, itemTypes:[READY_FOR_REVIEW_EVENT, CONVERT_TO_DRAFT_EVENT]) {
          nodes { __typename ... on ReadyForReviewEvent { createdAt } ... on ConvertToDraftEvent { createdAt } }
        }
      }
    }
  }
}' --jq '.data.repository.pullRequests.nodes[]' \
	| jq -c --arg repo "$repo" '. + {repo:$repo}' >> "$work/prs.jsonl"
done < "$work/repos"

# ---- comment-only edits ----------------------------------------------------
# A merge without an approval whose code files changed only comment lines is
# allowed by the merge table's "typo, comment" row. Only the candidates are
# looked at: xymon pull requests merged since the review rule with no approval
# and a file outside the documentation, build and platform sets.
allowed_re='^docs/|\.(md|[1578]|cfg|cfg\.DIST)$|^README|^(RELEASENOTES|CREDITS|Changes|COPYING)$|^(build|tests|tools|\.github)/|^configure|^Makefile|^client/xymonclient-(aix|darwin|sunos)\.sh$|^xymond/client/(aix|darwin|solaris|sunos)\.c$'
: > "$work/comment-only"
jq -r --arg rule "$rule_date" --arg re "$allowed_re" '
  select(.repo=="xymon" and .mergedAt != null and .mergedAt >= $rule)
  | . as $p
  | select(([.reviews.nodes[] | select(.state=="APPROVED" and .author.login != $p.author.login)] | length) == 0)
  | select([.files.nodes[]?.path] | length > 0 and any(test($re) | not))
  | .number' "$work/prs.jsonl" | while read -r n; do
	verdict=$(gh api "repos/$org/xymon/pulls/$n/files" 2>/dev/null | jq -r --arg re "$allowed_re" '
	  [ .[] | select(.filename | test($re) | not) | .patch // "" | split("\n")[]
	    | select(test("^[-+]") and (test("^[-+]{3} ") | not))
	    | sub("^[-+]"; "") | gsub("^[[:space:]]+|[[:space:]]+$"; "")
	    | select(. != "") ]
	  | if length > 0 and all(test("^(/\\*|\\*|//|#)")) then "yes" else "no" end' 2>/dev/null || true)
	if [ "$verdict" = yes ]; then echo "$n" >> "$work/comment-only"; fi
done

# ---- compute and write -----------------------------------------------------

jq -s -r --arg now "$now" --arg since "$since" --arg rule "$rule_date" \
	--argjson commentonly "$(jq -R 'tonumber' "$work/comment-only" | jq -s .)" \
	-f /dev/stdin "$work/prs.jsonl" > "$work/page.md" <<'JQ'
def h(a;b): (((b|fromdateiso8601)-(a|fromdateiso8601))/3600);
def d(a;b): (h(a;b)/24);
def med: sort | if length==0 then null elif length%2==1 then .[(length/2|floor)] else ((.[length/2-1]+.[length/2])/2) end;
def mean: if length==0 then null else (add/length) end;
def p90: sort | if length==0 then null else .[((length*0.9)|floor)] end;
def fmt_d: if . == null then "—" elif . < 1 then "\((.*24)|floor) h" else "\((.*10|round)/10) days" end;
def pct(a;b): if b==0 then "—" else "\((a*100/b)|round)%" end;
def others(p): [p.reviews.nodes[] | select(.author.login != null and .author.login != p.author.login)];
def approved_at(p): [others(p)[] | select(.state=="APPROVED") | .submittedAt] | sort | .[0];
def first_ready(p): ([p.timelineItems.nodes[] | {t:.__typename, at:.createdAt}] | sort_by(.at)) as $e
  | if ($e|length)==0 then (if p.isDraft then null else p.createdAt end)
    elif $e[0].t=="ReadyForReviewEvent" then $e[0].at else p.createdAt end;
def component: (.title | capture("^(?<c>[A-Za-z0-9_.+/-]+):").c) // "";
# Classification by the files a pull request touches; by its title when the
# file list is missing (more than 100 files, or an API gap).
def docs_path: test("^docs/|\\.(md|[1578]|cfg|cfg\\.DIST)$|^README|^(RELEASENOTES|CREDITS|Changes|COPYING)$");
def build_path: test("^(build|tests|tools|\\.github)/|^configure|^Makefile");
# This page's own allowance, not a project rule: until the first release that
# ships them, nobody but their author can run the AIX, Solaris and macOS
# clients, so a change to one is counted with what may merge unreviewed.
def platform_path: test("^client/xymonclient-(aix|darwin|sunos)\\.sh$|^xymond/client/(aix|darwin|solaris|sunos)\\.c$");
def paths: [.files.nodes[]?.path];
def title_docs: (component | test("^(docs|README|RELEASING|CONTRIBUTING|AGENTS|RELEASENOTES|CREDITS|Changes)$|\\.(md|cfg|[1578])$"));
def title_build: (component | test("^(build|ci|tests|tools)$"));
def title_platform: (component | test("^(client|xymonclient-(aix|darwin|sunos)|aix|darwin|solaris|sunos)$")) and (.title | test("aix|darwin|macos|solaris|sunos"; "i"));
def is_docs: if (paths|length) > 0 then (paths | all(docs_path)) else title_docs end;
def is_build: if (paths|length) > 0 then ((paths | all(docs_path or build_path)) and (is_docs|not)) else title_build end;
def is_platform: if (paths|length) > 0 then ((paths | all(docs_path or build_path or platform_path)) and (is_docs|not) and (is_build|not)) else title_platform end;
def is_comment_only: (.repo=="xymon") and (.number as $n | $commentonly | index($n) != null);
def is_allowed: (is_docs or is_build or is_platform or is_comment_only);
def row: "| " + join(" | ") + " |";
# light(good; bad): 🟢 when the good test holds, 🔴 when the bad one does, 🟡 between.
def light(good; bad): if good then "🟢" elif bad then "🔴" else "🟡" end;
def qlist: map("\"\(.)\"") | join(", ");
def nlist: map(tostring) | join(", ");
def ymax: (max // 0) as $m | if $m < 5 then 5 else ((($m*1.15)/5|ceil)*5) end;
def palette: "%%{init: {\"themeVariables\": {\"xyChart\": {\"plotColorPalette\": \"#3b6fd8, #e07b2a\"}}}}%%";
def mm_bar_o(orient; title; ylabel; labels; values):
  "```mermaid", palette, "xychart-beta\(orient)", "    title \"\(title)\"", "    x-axis [\(labels|qlist)]",
  "    y-axis \"\(ylabel)\" 0 --> \(values|ymax)", "    bar [\(values|nlist)]", "```";
def mm_bar(title; ylabel; labels; values): mm_bar_o(""; title; ylabel; labels; values);

[ .[] | select(.createdAt >= $since) | . as $p
  | . + {fr: first_ready($p), ap: approved_at($p), rv: others($p)} ] as $all
| ($all | map(select(.repo=="xymon"))) as $x
| ($all | map(select(.mergedAt))) as $merged
| ($x | map(select(.mergedAt))) as $xm
| ($all | map(select(.state=="OPEN" and (.isDraft|not) and .ap==null))) as $wait
| ([$all[] | .rv[] | .author.login] | group_by(.) | map(length) | sort | reverse) as $ranks
| ($ranks | add // 0) as $rtotal
| (reduce $ranks[] as $r ({s:0,n:0}; if .s < 0.8*$rtotal then {s:(.s+$r), n:(.n+1)} else . end) | .n) as $p80
| ($now[0:4]|tonumber) as $ny | ($now[5:7]|tonumber) as $nm
| ([range(11;-1;-1)] | map(($ny*12 + $nm - 1 - .) as $k | "\($k/12|floor)-\(($k%12)+1 | if . < 10 then "0\(.)" else tostring end)")) as $months
| ($all | map(.createdAt[0:7]) | min // $now[0:7]) as $first
| ($months | map(select(. >= $since[0:7] and . >= $first))) as $months
# Capacity, from the last four whole months: review requests arriving, and what
# one active reviewer approves in a month (median over those months).
| ($months[-5:-1]) as $recent
| ($recent | map(. as $m | $x | map(select(.fr and .fr[0:7]==$m)) | length)) as $arrive
| ($recent | map(. as $m | {a:($x|map(select(.ap and .ap[0:7]==$m))|length),
      r:([$x[]|.rv[]|select(.submittedAt[0:7]==$m)|.author.login]|unique|length)})
      | map(select(.r>0) | .a/.r)) as $pace
| ($arrive|med) as $inflow
| ($pace|med) as $perrev
| ($recent | map(. as $m | [$x[]|.rv[]|select(.submittedAt[0:7]==$m)|.author.login]|unique|length) | med) as $active_rev
| (if ($perrev//0) > 0 then (($inflow/$perrev)|ceil) else null end) as $needed
| ([$all[] | select(.createdAt[0:7] as $m | $months[-3:]|index($m)) | .author.login] | unique) as $q_authors
| ($all | group_by(.author.login) | map(min_by(.createdAt)) | map(select(.createdAt[0:7] as $m | $months[-3:]|index($m))) | length) as $q_new
| ($x | map(select(.mergedAt and .ap==null and (is_allowed|not)))) as $code_noappr
| "# Project activity",
  "",
  "Generated \($now[0:10]) by `tools/project-activity.sh`, from the GitHub API, over the pull requests opened since \($since). No person is named here; the numbers are counts. What each one counts is at the end, under [How this is counted](#how-this-is-counted).",
  "",
  "## Summary",
  "",
  ( ($recent | map(. as $m | $x | map(select(.fr and .fr[0:7]==$m)) | length) | add // 0) as $r_in
    | ($recent | map(. as $m | $x | map(select(.ap and .ap[0:7]==$m)) | length) | add // 0) as $r_ap
    | ($wait|map(select(d(.fr;$now)>30))|length) as $w30
    | ($code_noappr|map(select(.mergedAt >= $rule))|length) as $cna
    | (["January","February","March","April","May","June","July","August","September","October","November","December"][($recent[0][5:7]|tonumber)-1]) as $since_month
    | "Each line is one question about the project, with a light: 🟢 fine, 🟡 watch, 🔴 needs people. What each light means by the numbers is under [How this is counted](#how-this-is-counted).",
      "",
      "- \(light($r_in==0 or $r_ap >= 0.9*$r_in; $r_ap < 0.6*$r_in)) **Review does not keep up with what arrives.** Of the \($r_in) `xymon` pull requests that became ready for review since \($since_month), \($r_ap) were approved (\(pct($r_ap;$r_in))).",
      "- \(light($w30 <= 5; $w30 > 20)) **Pull requests wait a long time.** \($w30) of the \($wait|length) now waiting for a first review have waited more than a month.",
      "- \(light($p80 >= 6; $p80 <= 3)) **Review rests on few people.** \($p80) \(if $p80==1 then "person does" else "people do" end) 80% of the reviewing; the busiest does \(pct($ranks[0]//0; $rtotal)) of it.",
      "- \(light($cna == 0; $cna > 0)) **\(if $cna==0 then "No code is merged without a review." else "Code is merged without a review." end)** Since the review rule of \($rule), \(if $cna==0 then "no" else "\($cna)" end) code \(if $cna==1 then "change was" else "changes were" end) merged in `xymon` without an approval. Before the rule no review was asked for, so earlier merges are not counted.",
      "- \(light($q_new >= 3; $q_new == 0)) **Few new contributors arrive.** \($q_new) of the \($q_authors|length) people who opened a pull request in the last three months \(if $q_new==1 then "was" else "were" end) new." ),
  "",
  "## Help wanted",
  "",
  "Review is the project's bottleneck, and everyone is welcome to help fill the gap — no membership is needed to review a pull request or to open one.",
  "",
  "| | Value |",
  "|---|---|",
  (["Review requests arriving in `xymon` in a typical month (median of the last four whole months)", "\($inflow // "—")"] | row),
  (["Approvals one active reviewer gives in a month (median, same months)", "\(if $perrev then ($perrev*10|round)/10 else "—" end)"] | row),
  (["Reviewers active in a month (median, same months)", "\($active_rev)"] | row),
  (["Reviewers needed to keep up (estimate)", "\($needed // "—")\(if $needed and $needed > $active_rev then " — about \(($needed - $active_rev)|ceil) missing" else "" end)"] | row),
  (["Pull request authors in the last three months / of them new", "\($q_authors|length) / \($q_new)"] | row),
  "",
  "The estimate divides the arrivals by one reviewer's pace; it is a range read from a few months, not a target.",
  "",
  "How to help:",
  "",
  "- **Review** one of the pull requests waiting longest, listed under [Waiting for review](#waiting-for-review): read it, try it if you can, and approve it or say what is wrong. A review from someone who runs Xymon in production is worth as much as one from a developer.",
  "- **Contribute**: pick an issue and open a pull request — [First contribution](../contributing/git/first-contribution.md) says how.",
  "- **Talk to us** on the mailing list, linked from [Project & community](project-and-community.md).",
  "",
  "## Review in `xymon`",
  "",
  "Bars: pull requests that became ready for review. Line: approvals. The gap between them is review that did not happen.",
  "",
  ( ($months | map(. as $m | $x | map(select(.fr and .fr[0:7]==$m)) | length)) as $rd
    | ($months | map(. as $m | $x | map(select(.ap and .ap[0:7]==$m)) | length)) as $apm
    | "```mermaid", palette, "xychart-beta", "    title \"Review requests and approvals, by month\"",
      "    x-axis [\($months|qlist)]", "    y-axis \"Pull requests\" 0 --> \(($rd + $apm)|ymax)",
      "    bar [\($rd|nlist)]", "    line [\($apm|nlist)]", "```" ),
  "",
  "| Month | Became ready | Approved | Merged | Merged without an approval: allowed | needing a review | Reviews | Reviewers |",
  "|---|---|---|---|---|---|---|---|",
  ( $months[] as $m
    | [ $m, "\($x|map(select(.fr and .fr[0:7]==$m))|length)", "\($x|map(select(.ap and .ap[0:7]==$m))|length)",
        "\($xm|map(select(.mergedAt[0:7]==$m))|length)", "\($xm|map(select(.mergedAt[0:7]==$m and .ap==null and is_allowed))|length)", "\($xm|map(select(.mergedAt[0:7]==$m and .ap==null and (is_allowed|not)))|length)",
        "\([$x[]|.rv[]|select(.submittedAt[0:7]==$m)]|length)", "\([$x[]|.rv[]|select(.submittedAt[0:7]==$m)|.author.login]|unique|length)" ] | row ),
  "",
  "Each column counts by its own date: became ready, approved and reviewed in that month, or merged in that month. **Reviews** counts every review, approving or not. **Allowed** is what the merge table lets a maintainer merge without a review, as [How this is counted](#how-this-is-counted) says; **needing a review** is code merged without one.",
  "",
  "Reviews submitted, by reviewer; each column is one person.",
  "",
  ( if ($ranks|length)==0 then "No reviews in the window." else
    ("| Reviewer | " + ([range(1; ($ranks|length)+1)] | map("#\(.)") | join(" | ")) + " |"),
    ("|---|" + ([$ranks[]] | map("---|") | join(""))),
    ("| Reviews | " + ($ranks | map(tostring) | join(" | ")) + " |") end ),
  "",
  "## Waiting for review",
  "",
  "| Measure | Value |",
  "|---|---|",
  (["Waiting now", "\($wait|length)"] | row),
  (["Waiting: median / mean / longest", "\($wait|map(d(.fr;$now))|med|fmt_d) / \($wait|map(d(.fr;$now))|mean|fmt_d) / \($wait|map(d(.fr;$now))|max|fmt_d)"] | row),
  (["More than 30 / 90 days", "\($wait|map(select(d(.fr;$now)>30))|length) / \($wait|map(select(d(.fr;$now)>90))|length)"] | row),
  "",
  ( ($wait | map(d(.fr;$now))) as $ages
    | mm_bar("Ready pull requests waiting, by time waited"; "Pull requests"; ["under 7 days", "7 to 30 days", "30 to 90 days", "over 90 days"];
        [ ($ages|map(select(. < 7))|length), ($ages|map(select(. >= 7 and . < 30))|length),
          ($ages|map(select(. >= 30 and . < 90))|length), ($ages|map(select(. >= 90))|length) ]) ),
  "",
  "Waiting longest, oldest first — a reviewer is welcome on any of them:",
  "",
  ( $wait | sort_by(.fr)[0:5][] | "- [\(.repo)#\(.number)](\(.url)) — \(.title) (\(d(.fr;$now)|fmt_d))" ),
  "",
  "## Pull requests by repository",
  "",
  "Only `xymon` asks for a review before a merge; the other repositories are pushed to directly, so a merge without an approval there is the normal way. **Open** counts every open pull request, drafts and approved ones included, which is why it is more than the number waiting for review.",
  "",
  "| Repository | Opened | Merged | Merged with an approval | Merged without | Closed unmerged | Open |",
  "|---|---|---|---|---|---|---|",
  ( $all | group_by(.repo) | sort_by(-length)[] | select(length >= 10) | . as $g
    | [ "`\($g[0].repo)`", "\($g|length)", "\($g|map(select(.mergedAt))|length)",
        "\($g|map(select(.mergedAt and .ap))|length)", "\($g|map(select(.mergedAt and .ap==null))|length)",
        "\($g|map(select(.state=="CLOSED"))|length)", "\($g|map(select(.state=="OPEN"))|length)" ] | row ),
  "",
  ( ($all | group_by(.repo) | map(select(length < 10))) as $small
    | if ($small|length) == 0 then empty
      else "\($small|length) smaller \(if ($small|length)==1 then "repository" else "repositories" end) with fewer than 10 pull requests \(if ($small|length)==1 then "is" else "are" end) left out: \($small | map("`\(.[0].repo)`") | join(", "))." end ),
  "",
  "## How this is counted",
  "",
  "**Waiting for review** means ready (not a draft), still open, and without an approval from someone other than its author; it is measured from the first time the pull request was ready. A **review** is a GitHub review by someone other than the author; a plain comment is not one.",
  "",
  "A merge without an approval is **allowed** or **needing a review** by the files the pull request touches; a pull request with no file list is classified by its title's component instead:",
  "",
  "| Counted as | When every file is | May merge without a review |",
  "|---|---|---|",
  "| documentation | under `docs/`, a manual page, a `.md` file, a configuration sample, `README*`, `RELEASENOTES`, `CREDITS` or `Changes` | yes — `CONTRIBUTING.md`'s merge table |",
  "| build, CI, tests | documentation, or under `build/`, `tests/`, `tools/` or `.github/`, or `configure` | yes — the same table |",
  "| AIX, Solaris and macOS clients | the above, or `client/xymonclient-aix.sh`, `client/xymonclient-darwin.sh`, `client/xymonclient-sunos.sh`, `xymond/client/aix.c`, `xymond/client/darwin.c`, `xymond/client/solaris.c` | counted as yes by this page until the first release that ships them, since nobody but their author can run them yet; not a project rule |",
  "| comment | a code file whose changed lines are all comment lines | yes — the same table's \"typo, comment\" row |",
  "| code | anything else | no |",
  "",
  "The summary's lights are this page's own thresholds, chosen to make a change visible; they are not project rules:",
  "",
  "| Line | 🟢 when | 🔴 when |",
  "|---|---|---|",
  "| review keeps up | ≥ 90% of what became ready in the last four whole months was approved | < 60% |",
  "| pull requests wait | ≤ 5 have waited more than 30 days | > 20 |",
  "| review rests on few people | ≥ 6 people do 80% of the reviews | ≤ 3 |",
  "| code merged without a review | none since the review rule | ≥ 1 |",
  "| new contributors | ≥ 3 in the last three months | none |",
  "",
  "**Not counted**: discussion on the mailing list and in chat; reviews given as plain comments; an owner's administrative work; changes pushed without a pull request, which is how most wiki pages are written."

JQ

mv "$work/page.md" "$out"
echo "wrote $out ($(wc -l < "$out") lines)" >&2
