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
# The groups table needs a token that can read team membership and org roles
# (GH_TOKEN with read:org). Without one it is marked unavailable and the rest
# of the page is still written.
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

# Groups: optional, needs read:org.
groups_ok=1
{
	gh api --paginate "orgs/$org/members?role=admin&per_page=100" --jq '.[].login' > "$work/g-owners" &&
	gh api --paginate "orgs/$org/members?per_page=100" --jq '.[].login' > "$work/g-members" &&
	gh api --paginate "orgs/$org/teams/maintainers/members?per_page=100" --jq '.[].login' > "$work/g-maintainers" &&
	gh api --paginate "orgs/$org/teams/contributors/members?per_page=100" --jq '.[].login' > "$work/g-contributors"
} 2>/dev/null || groups_ok=0
# Without read:org, the members API answers with public members only; that
# is not the membership, so treat an owner list shorter than 1 as unavailable.
[ "$groups_ok" = 1 ] && [ -s "$work/g-owners" ] || groups_ok=0

tojson() { jq -R . "$1" | jq -s .; }
if [ "$groups_ok" = 1 ]; then
	jq -n --argjson o "$(tojson "$work/g-owners")" --argjson m "$(tojson "$work/g-members")" \
	      --argjson mt "$(tojson "$work/g-maintainers")" --argjson c "$(tojson "$work/g-contributors")" \
	      '{owners:$o, members:$m, maintainers:$mt, contributors:$c}' > "$work/groups.json"
else
	echo 'null' > "$work/groups.json"
fi

# ---- compute and write -----------------------------------------------------

jq -s -r --arg now "$now" --arg since "$since" --arg rule "$rule_date" \
	--slurpfile G "$work/groups.json" -f /dev/stdin "$work/prs.jsonl" > "$work/page.md" <<'JQ'
def h(a;b): (((b|fromdateiso8601)-(a|fromdateiso8601))/3600);
def d(a;b): (h(a;b)/24);
def med: sort | if length==0 then null else .[(length/2|floor)] end;
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
def is_docs: (component | test("^(docs|README|RELEASING|CONTRIBUTING|AGENTS)$|\\.[1578]$"));
def is_build: (component | test("^(build|ci|tests|tools)$"));
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
| ($x | map(select(.mergedAt and .ap==null and (is_docs|not) and (is_build|not)))) as $code_noappr
| "# Project activity",
  "",
  "Generated \($now[0:10]) by `tools/project-activity.sh`, from the GitHub API. Window: pull requests opened since \($since), in the organisation's public repositories. No person is named here; the numbers are counts.",
  "",
  "**Waiting for review** means ready (not a draft), still open, and without an approval from someone other than its author; it is measured from the first time the pull request was ready. A **review** is a GitHub review by someone other than the author; a plain comment is not one.",
  "",
  "## Help wanted",
  "",
  "Review is the project's bottleneck, and everyone is welcome to help fill the gap — no membership is needed to review a pull request or to open one.",
  "",
  "| | Value |",
  "|---|---|",
  (["Review requests arriving in `xymon` (median of the last four whole months)", "\($inflow // "—") a month"] | row),
  (["Approvals one active reviewer gives in a month (median, same months)", "\(if $perrev then ($perrev*10|round)/10 else "—" end)"] | row),
  (["Reviewers active in a month (median, same months)", "\($active_rev)"] | row),
  (["Reviewers needed to keep up (estimate)", "\($needed // "—")\(if $needed and $needed > $active_rev then " — about \($needed - $active_rev) missing" else "" end)"] | row),
  (["Pull request authors in the last three months / of them new", "\($q_authors|length) / \($q_new)"] | row),
  "",
  ( if $needed then mm_bar("Reviewers in a month: active and needed"; "Reviewers"; ["active", "needed"]; [$active_rev, $needed]) else empty end ),
  "",
  "How to help:",
  "",
  "- **Review** one of the pull requests waiting longest, listed under [Waiting for review](#waiting-for-review): read it, try it if you can, and approve it or say what is wrong. A review from someone who runs Xymon in production is worth as much as one from a developer.",
  "- **Contribute**: pick an issue and open a pull request — [First contribution](../contributing/git/first-contribution.md) says how.",
  "- **Talk to us** on the mailing list, linked from [Project & community](project-and-community.md).",
  "",
  "The estimate divides the arrivals by one reviewer's pace; it is a range read from a few months, not a target.",
  "",
  "## Summary",
  "",
  ( ($recent | map(. as $m | $x | map(select(.fr and .fr[0:7]==$m)) | length) | add // 0) as $r_in
    | ($recent | map(. as $m | $x | map(select(.ap and .ap[0:7]==$m)) | length) | add // 0) as $r_ap
    | ($wait|map(select(d(.fr;$now)>30))|length) as $w30
    | ($code_noappr|map(select(.mergedAt >= $rule))|length) as $cna
    | "| | Question | Value | 🟢 when | 🔴 when |",
      "|---|---|---|---|---|",
      ([ light($r_in==0 or $r_ap >= 0.9*$r_in; $r_ap < 0.6*$r_in), "Does review keep up with what arrives? (`xymon`, last four whole months)", "\($r_in) became ready · \($r_ap) approved (\(pct($r_ap;$r_in)))", "≥ 90% approved", "< 60%" ] | row),
      ([ light($w30 <= 5; $w30 > 20), "Ready pull requests waiting more than 30 days", "\($w30) of \($wait|length) waiting", "≤ 5", "> 20" ] | row),
      ([ light($p80 >= 6; $p80 <= 3), "People doing 80% of the reviews", "\($p80) (busiest: \(pct($ranks[0]//0; $rtotal)) of all reviews)", "≥ 6", "≤ 3" ] | row),
      ([ light($cna == 0; $cna > 0), "Code merged in `xymon` without an approval since the review rule (\($rule))", "\($cna)", "0", "≥ 1" ] | row),
      ([ light($q_new >= 3; $q_new == 0), "New pull request authors in the last three months", "\($q_new) (of \($q_authors|length) authors)", "≥ 3", "0" ] | row) ),
  "",
  "The thresholds are this page's own, chosen to make a change visible; they are not project rules.",
  "",
  ( if $G[0] == null then
      "## Groups\n\nUnavailable: reading team membership needs a token with `read:org`."
    else
      ($G[0]) as $g
      | def act($u): {o:($all|map(select(.author.login==$u))|length), r:($all|map(select([.rv[]|select(.author.login==$u)]|length>0))|length)};
        def grow(name; list): (list | map(act(.))) as $a
          | [name, "\(list|length)", "\($a|map(select(.r>=1))|length)", "\($a|map(select(.r>=5))|length)", "\($a|map(select(.o>=1))|length)", "\($a|map(select(.o==0 and .r==0))|length)"] | row;
      "## Groups\n\nWhat each group grants and expects is on [Project organisation](project-organisation.md).\n\n| Group | Holders | Reviewed others' pull requests (≥1) | (≥5) | Opened a pull request (≥1) | Neither |\n|---|---|---|---|---|---|\n"
      + grow("maintainers"; $g.maintainers) + "\n" + grow("contributors"; $g.contributors)
      + "\n\nOrganisation owners: \($g.owners|length). Their activity is not published here: how many administrator accounts are idle is a security question, and it is tracked where access is managed."
    end ),
  "",
  "## Pull requests by repository",
  "",
  "| Repository | Opened | Merged | Merged with an approval | Merged without | Merged by their own author | Closed unmerged | Open |",
  "|---|---|---|---|---|---|---|---|",
  ( $all | group_by(.repo) | sort_by(-length)[] | . as $g
    | [ "`\($g[0].repo)`", "\($g|length)", "\($g|map(select(.mergedAt))|length)",
        "\($g|map(select(.mergedAt and .ap))|length)", "\($g|map(select(.mergedAt and .ap==null))|length)",
        "\($g|map(select(.mergedAt and .author.login==.mergedBy.login))|length)",
        "\($g|map(select(.state=="CLOSED"))|length)", "\($g|map(select(.state=="OPEN"))|length)" ] | row ),
  "",
  ( ( [ $all | group_by(.repo)[] | select(map(select(.mergedAt))|length > 0)
      | {r:.[0].repo, n:(map(select(.mergedAt))|length), a:(map(select(.mergedAt and .ap))|length)} ] | sort_by(-.n) ) as $rp
  | mm_bar_o(" horizontal"; "Share of merges that had an approval, by repository"; "% of merges"; ($rp|map(.r)); ($rp|map((.a*100/.n)|round)))),
  "",
  "## Review in `xymon`",
  "",
  "| Measure | Value |",
  "|---|---|",
  (["Review verdicts", ([$x[] | .rv[] | .state] | group_by(.) | map("\(.[0]|ascii_downcase|gsub("_";" ")) \(length)") | join(" · "))] | row),
  (["Merged with an approval", "\($xm|map(select(.ap))|length) of \($xm|length) (\(pct($xm|map(select(.ap))|length; $xm|length)))"] | row),
  (["Merged without an approval: documentation / build, CI, tests / code", "\($xm|map(select(.ap==null and is_docs))|length) / \($xm|map(select(.ap==null and is_build))|length) / \($xm|map(select(.ap==null and (is_docs|not) and (is_build|not)))|length)"] | row),
  (["Time from ready to first approval: median / mean / longest", "\($x|map(select(.ap and .fr and .fr <= .ap)|d(.fr;.ap))|med|fmt_d) / \($x|map(select(.ap and .fr and .fr <= .ap)|d(.fr;.ap))|mean|fmt_d) / \($x|map(select(.ap and .fr and .fr <= .ap)|d(.fr;.ap))|max|fmt_d)"] | row),
  (["Time from ready to merge: median / slowest tenth", "\($xm|map(select(.fr)|d(.fr;.mergedAt))|med|fmt_d) / \($xm|map(select(.fr)|d(.fr;.mergedAt))|p90|fmt_d)"] | row),
  "",
  "Classification by title: a title starting `docs:`, a manual page, `README:`, `RELEASING:`, `CONTRIBUTING:` or `AGENTS:` counts as documentation; `build:`, `ci:`, `tests:` or `tools:` as build, CI and tests; anything else as code.",
  "",
  "## By month (`xymon`)",
  "",
  "Bars: pull requests that became ready for review. Line: approvals. The gap between them is review that did not happen.",
  "",
  ( ($months | map(. as $m | $x | map(select(.fr and .fr[0:7]==$m)) | length)) as $rd
    | ($months | map(. as $m | $x | map(select(.ap and .ap[0:7]==$m)) | length)) as $apm
    | "```mermaid", palette, "xychart-beta", "    title \"Review requests and approvals, by month\"",
      "    x-axis [\($months|qlist)]", "    y-axis \"Pull requests\" 0 --> \(($rd + $apm)|ymax)",
      "    bar [\($rd|nlist)]", "    line [\($apm|nlist)]", "```" ),
  "",
  "| Month | Became ready | Approved | Merged | Merged without an approval | Reviews | Reviewers |",
  "|---|---|---|---|---|---|---|",
  ( $months[] as $m
    | [ $m, "\($x|map(select(.fr and .fr[0:7]==$m))|length)", "\($x|map(select(.ap and .ap[0:7]==$m))|length)",
        "\($xm|map(select(.mergedAt[0:7]==$m))|length)", "\($xm|map(select(.mergedAt[0:7]==$m and .ap==null))|length)",
        "\([$x[]|.rv[]|select(.submittedAt[0:7]==$m)]|length)", "\([$x[]|.rv[]|select(.submittedAt[0:7]==$m)|.author.login]|unique|length)" ] | row ),
  "",
  "## Who reviews",
  "",
  "Reviews submitted, by rank; each slice and each column is one person.",
  "",
  ( if ($ranks|length)==0 then empty else
    "```mermaid", "pie showData title Share of all reviews, by reviewer rank",
    ( $ranks | to_entries[] | "    \"#\(.key+1)\" : \(.value)" ), "```" end ),
  "",
  ( if ($ranks|length)==0 then "No reviews in the window." else
    ("| Rank | " + ([range(1; ($ranks|length)+1)] | map(tostring) | join(" | ")) + " |"),
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
  "## Not counted",
  "",
  "Discussion on the mailing list and in chat; reviews given as plain comments; an owner's administrative work; changes pushed without a pull request, which is how most wiki pages are written."
JQ

mv "$work/page.md" "$out"
echo "wrote $out ($(wc -l < "$out") lines)" >&2
