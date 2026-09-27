#!/usr/bin/env bash
#
# tracker-progress.sh — progress block and carrier check for a backport tracker
#
# Implements rule 8 (the progress block) and rule 9 (a line and its carrier PR
# name each other) of docs/contributing/backport-tracker-rules.md.
#
# Usage:
#   tools/tracker-progress.sh [--repo OWNER/REPO] [--check] [--apply] ISSUE
#
#   (default)  print the progress block computed from the issue's lines
#   --check    also verify, for every line whose box is [x], that the PR it
#              links names the change back in its title (rule 9); a line whose
#              verdict is "drop — superseded" is exempt
#   --apply    write the block into the issue body, replacing an earlier one,
#              or inserting it after the profile if there is none
#
# Needs: gh (authenticated), awk, grep, sed.

set -eu

repo="xymon-monitoring/xymon"
check=0
apply=0
issue=""

while [ $# -gt 0 ]; do
	case "$1" in
		--repo) repo="$2"; shift 2 ;;
		--check) check=1; shift ;;
		--apply) apply=1; shift ;;
		-h|--help) sed -n '3,17p' "$0"; exit 0 ;;
		-*) echo "unknown option: $1" >&2; exit 2 ;;
		*) issue="$1"; shift ;;
	esac
done
[ -n "$issue" ] || { echo "usage: $0 [--repo OWNER/REPO] [--check] [--apply] ISSUE" >&2; exit 2; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

gh api "repos/$repo/issues/$issue" --jq .body > "$tmp/body"

# One record per item line: box<TAB>icon<TAB>id<TAB>kind<TAB>line
#   kind: pointer | take | drop | downstream | superseded | undecided
# A line is an item when it starts with "- ", optionally a box and an icon,
# then a backquoted id, and carries a verdict or a delegation marker. Lines in
# fenced code blocks are not items.
awk '
	/^```/ { fence = !fence; next }
	fence { next }
	{
		line = $0
		if (line !~ /^[ \t]*- /) next
		rest = line; sub(/^[ \t]*- /, "", rest)
		box = ""
		if (rest ~ /^\[[ x]\] /) { box = substr(rest, 1, 3); rest = substr(rest, 5) }
		icon = ""
		if (index(rest, "🟢 ") == 1) { icon = "green"; rest = substr(rest, length("🟢 ") + 1) }
		else if (index(rest, "🟡 ") == 1) { icon = "yellow"; rest = substr(rest, length("🟡 ") + 1) }
		if (rest !~ /^`[^`]+`/) next
		id = rest; sub(/^`/, "", id); sub(/`.*/, "", id); sub(/ .*/, "", id)
		kind = ""
		if (line ~ /\*\*take as is\*\*|\*\*take, not as written/) kind = "take"
		else if (line ~ /\*\*drop — superseded\*\*/) kind = "superseded"
		else if (line ~ /\*\*downstream — /) kind = "downstream"
		else if (line ~ /\*\*drop — /) kind = "drop"
		else if (line ~ /\*\*undecided\*\*/) kind = "undecided"
		else if (line ~ /delegated → #[0-9]+/) kind = "pointer"
		if (kind == "") next
		printf "%s\t%s\t%s\t%s\t%s\n", box, icon, id, kind, line
	}
' "$tmp/body" > "$tmp/items"

count() { awk -F'\t' "$1" "$tmp/items" | wc -l | tr -d ' '; }
lines=$(count '1')
pointers=$(count '$4=="pointer"')
wanted=$(count '$4=="take"')
landed=$(count '$4=="take" && $2=="green"')
inpr=$(count '$4=="take" && $1=="[x]" && $2!="green"')
nopr=$(count '$4=="take" && $1=="[ ]"')
dropped=$(count '$4=="drop" || $4=="superseded"')
downstream=$(count '$4=="downstream"')
undecided=$(count '$4=="undecided"')

block="**Progress** (generated $(date +%Y-%m-%d) by \`tracker-progress\`): $lines lines · $pointers pointers · wanted $wanted — landed $landed · in a PR $inpr · without a PR $nopr · downstream $downstream · dropped $dropped · undecided $undecided"
echo "$block"

status=0
if [ "$check" = 1 ]; then
	# The citation prefix comes from the profile: "cited elsewhere as `TBT N`"
	# or "cited elsewhere as `devel <hash>`".
	prefix=$(grep -o -E 'cited elsewhere as `[A-Za-z]+ ' "$tmp/body" | head -1 | sed -E 's/.*`//; s/ $//')
	[ -n "$prefix" ] || { echo "check: no citation form in the profile's Ids field" >&2; exit 1; }
	# The sibling tracker's number, from the profile's Owner field, is not a PR.
	sibling=$(grep -E '^- \*\*Owner:\*\*' "$tmp/body" | grep -o -E '#[0-9]+' | head -1 | tr -d '#')
	awk -F'\t' '$1=="[x]" && $4!="superseded" { print $3 "\t" $5 }' "$tmp/items" |
	while IFS="$(printf '\t')" read -r id line; do
		pr=""
		for n in $(printf '%s\n' "$line" | grep -o -E '#[0-9]{2,}' | tr -d '#'); do
			[ "$n" = "$sibling" ] && continue
			[ "$n" = "$issue" ] && continue
			pr=$n; break
		done
		if [ -z "$pr" ]; then echo "check: $id is [x] but links no PR"; continue; fi
		title=$(gh pr view "$pr" -R "$repo" --json title --jq .title 2>/dev/null) || { echo "check: $id links #$pr, which is not a PR"; continue; }
		key=$id
		case "$prefix" in devel) key=$(printf '%s' "$id" | cut -c1-7) ;; esac
		paren=$(printf '%s' "$title" | sed -n 's/.*(\([^()]*\))[[:space:]]*$/\1/p')
		if printf '%s' "$paren" | grep -q -E "(^|[ /,])$prefix [^)]*" && \
		   printf '%s' "$paren" | grep -q -E "(^|[ /])$key[0-9a-f]*([/ ,]|$)"; then
			:
		else
			echo "check: $id → #$pr, but the PR title does not name it: $title"
		fi
	done > "$tmp/check"
	if [ -s "$tmp/check" ]; then cat "$tmp/check"; status=1; else echo "check: every carrier names its line back"; fi
fi

if [ "$apply" = 1 ]; then
	if grep -q -E '^\*\*Progress\*\* \(generated ' "$tmp/body"; then
		# replace the earlier block
		awk -v block="$block" '/^\*\*Progress\*\* \(generated / { print block; next } { print }' "$tmp/body" > "$tmp/new"
	else
		# insert it after the profile's last field
		awk -v block="$block" '{ print } /^- \*\*Extra marks:\*\*/ && !ins { print ""; print block; ins = 1 }' "$tmp/body" > "$tmp/new"
	fi
	grep -q -F "$block" "$tmp/new" || { echo "apply: could not place the block" >&2; exit 1; }
	# no trailing newlines: each upload would otherwise add an empty line
	printf '%s' "$(cat "$tmp/new")" > "$tmp/upload"
	gh issue edit "$issue" -R "$repo" --body-file "$tmp/upload" > /dev/null
	echo "apply: block written to $repo#$issue"
fi

exit $status
