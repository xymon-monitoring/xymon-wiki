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
#              verdict is "drop — superseded" is exempt; and, for every pointer,
#              that its target line exists on the owning tracker and names the
#              pointer's commit back (rule 6)
#   --apply    write the block at the top of the issue body, replacing an
#              earlier one wherever it stands
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
		-h|--help) sed -n '3,19p' "$0"; exit 0 ;;
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
# the headline counts only this tracker's own lines: a pointer is decided elsewhere
own=$((lines - pointers))
settled=$((landed + downstream + dropped))
decided=$((own - undecided))
pct() { if [ "$2" -gt 0 ]; then echo $(( ($1 * 100 + $2 / 2) / $2 )); else echo 0; fi; }

block="**Progress** (generated $(date +%Y-%m-%d) by \`tracker-progress\`): **settled $settled of $own ($(pct $settled $own)%)** · decided $decided of $own ($(pct $decided $own)%) — $lines lines · $pointers pointers · wanted $wanted — landed $landed · in a PR $inpr · without a PR $nopr · downstream $downstream · dropped $dropped · undecided $undecided"
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
		# the carrier is written in bold (**PR #N** or **#N**); fall back to
		# the first PR number on the line
		for n in $(printf '%s\n' "$line" | grep -o -E '\*\*(PR )?#[0-9]{2,}\*\*' | grep -o -E '[0-9]+') \
		         $(printf '%s\n' "$line" | grep -o -E '#[0-9]{2,}' | tr -d '#'); do
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

	# Rule 6: a pointer's target line must exist on the owning tracker and
	# name the pointer's change back (one of the commit ids on the pointer).
	awk -F'\t' '$4=="pointer" { print $5 }' "$tmp/items" > "$tmp/pointers"
	if [ -s "$tmp/pointers" ]; then
		for owner in $(grep -o -E 'delegated → #[0-9]+' "$tmp/pointers" | grep -o -E '[0-9]+' | sort -u); do
			gh api "repos/$repo/issues/$owner" --jq .body > "$tmp/owner$owner"
		done
		while IFS= read -r line; do
			owner=$(printf '%s\n' "$line" | grep -o -E 'delegated → #[0-9]+' | head -1 | grep -o -E '[0-9]+')
			targets=$(printf '%s\n' "$line" | sed -n 's/.*delegated → #[0-9]* \(\(`[^`]*`\/\{0,1\}\)*\).*/\1/p' | grep -o -E '`[^`]+`' | tr -d '`')
			ids=$(printf '%s\n' "$line" | grep -o -E '`[0-9a-f]{7,40}`' | tr -d '`' | cut -c1-7 | sort -u)
			[ -n "$ids" ] || { echo "check: pointer names no commit id: $(printf '%s' "$line" | cut -c1-80)"; continue; }
			for t in $targets; do
				tl=$(grep -E "^[[:space:]]*- (\[[ x]\] )?(🟢 |🟡 )?\`$t[\` ]" "$tmp/owner$owner" | head -1)
				if [ -z "$tl" ]; then echo "check: #$issue points to #$owner $t, which has no line there"; continue; fi
				back=0
				for h in $ids; do printf '%s' "$tl" | grep -q "$h" && back=1; done
				[ "$back" = 1 ] || echo "check: #$owner $t does not name back $(printf '%s' "$ids" | tr '\n' ' ' | sed 's/ $//') (pointed to from #$issue)"
			done
		done < "$tmp/pointers" > "$tmp/twins"
		if [ -s "$tmp/twins" ]; then cat "$tmp/twins"; status=1; else echo "check: every pointer's target names its change back"; fi
	fi
fi

if [ "$apply" = 1 ]; then
	# drop an earlier block (and the blank line after it), then write the new
	# one first: the block opens the tracker, above the profile (rule 8)
	awk '/^\*\*Progress\*\* \(generated / { skip = 1; next } skip && /^$/ { skip = 0; next } { skip = 0; print }' "$tmp/body" > "$tmp/rest"
	{ printf '%s\n\n' "$block"; sed '/./,$!d' "$tmp/rest"; } > "$tmp/new"
	grep -q -F "$block" "$tmp/new" || { echo "apply: could not place the block" >&2; exit 1; }
	# no trailing newlines: each upload would otherwise add an empty line
	printf '%s' "$(cat "$tmp/new")" > "$tmp/upload"
	gh issue edit "$issue" -R "$repo" --body-file "$tmp/upload" > /dev/null
	echo "apply: block written to $repo#$issue"
fi

exit $status
