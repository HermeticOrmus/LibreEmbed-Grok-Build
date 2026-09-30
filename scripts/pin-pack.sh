#!/usr/bin/env bash
# Keep this edition's pack entries pinned to the Claude Code pack it extends.
#
# .grok-plugin/marketplace.json carries two kinds of entries: the Grok-native
# plugin that lives in this repo (a "./plugins/..." source), and every plugin
# of the matching pack as a remote entry pinned to one commit of the pack.
# Grok reads the pack's plugin folders as they are. The pin keeps an install
# reproducible; re-pinning keeps the edition living with the pack.
#
# Usage:
#   scripts/pin-pack.sh          re-pin every remote entry to the pack's main HEAD,
#                                add entries for new pack plugins, drop entries for
#                                removed ones, and print the diff
#   scripts/pin-pack.sh --check  change nothing; exit 1 when a pinned SHA is not on
#                                the pack's main branch, or when the remote entry
#                                names differ from the pack's current plugin names
#
# Needs git, curl and jq. Set GITHUB_TOKEN (or GH_TOKEN) to lift the GitHub API
# rate limit; CI passes the workflow token.
set -euo pipefail

PACK="HermeticOrmus/LibreEmbed-Claude-Code"
BRANCH="main"
# The pack plugins this edition carries, as a jq filter over the pack manifest.
SELECT='.plugins[]'

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MK="$ROOT/.grok-plugin/marketplace.json"
URL="https://github.com/$PACK.git"

die() { echo "pin-pack: $*" >&2; exit 1; }

for tool in git curl jq; do
  command -v "$tool" >/dev/null || die "$tool is required"
done
[[ -f "$MK" ]] || die "missing $MK"

github_api() {
  local token="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
  local auth=()
  [[ -n "$token" ]] && auth=(-H "Authorization: Bearer $token")
  curl -fsSL "${auth[@]}" -H "Accept: application/vnd.github+json" "https://api.github.com/$1"
}

pack_head() {
  local sha
  sha="$(git ls-remote "$URL" "refs/heads/$BRANCH" | cut -f1)"
  [[ "$sha" =~ ^[0-9a-f]{40}$ ]] || die "could not read $BRANCH of $URL"
  echo "$sha"
}

pack_manifest() {
  curl -fsSL "https://raw.githubusercontent.com/$PACK/$1/.claude-plugin/marketplace.json" \
    || die "could not fetch the pack manifest at $1"
}

pack_names() { jq -r "[$SELECT | .name] | sort | .[]"; }

pinned_names() { jq -r '[.plugins[] | select(.source | type == "object") | .name] | sort | .[]' "$MK"; }

check() {
  local fail=0 head url sha repo status
  head="$(pack_head)"

  while IFS=$'\t' read -r url sha; do
    repo="${url#https://github.com/}"
    repo="${repo%.git}"
    status="$(github_api "repos/$repo/compare/$sha...$BRANCH" | jq -r '.status')" || status="missing"
    case "$status" in
      identical|ahead) echo "ok: $repo@${sha:0:12} is on $BRANCH ($status)" ;;
      *) echo "FAIL: $repo@$sha is not on $BRANCH ($status)"; fail=1 ;;
    esac
  done < <(jq -r '[.plugins[] | select(.source | type == "object") | .source | [.url, .sha] | @tsv] | unique | .[]' "$MK")

  local want have
  want="$(pack_manifest "$head" | pack_names)"
  have="$(pinned_names)"
  if [[ "$want" == "$have" ]]; then
    echo "ok: $(grep -c . <<<"$have") remote entries match the pack plugins at $BRANCH ${head:0:12}"
  else
    echo "FAIL: the pack's plugins changed since the last pin."
    diff <(echo "$have") <(echo "$want") | sed -n 's/^< /  gone from the pack: /p; s/^> /  new in the pack:   /p'
    echo "Run scripts/pin-pack.sh and commit .grok-plugin/marketplace.json."
    fail=1
  fi
  return "$fail"
}

pin() {
  local head old before remote
  head="$(pack_head)"
  old="$(jq -r '[.plugins[] | select(.source | type == "object") | .source.sha] | unique | join(", ")' "$MK")"
  before="$(pinned_names | grep -c . || true)"

  remote="$(pack_manifest "$head" | jq --arg url "$URL" --arg sha "$head" "[
    $SELECT
    | (.source | ltrimstr(\"./\")) as \$path
    | {name, description, version, category, keywords}
    | with_entries(select(.value != null))
    | . + {source: {source: \"url\", url: \$url, sha: \$sha, path: \$path}}
  ]")" || die "could not read the pack plugins"
  # A pack plugin needs a "./plugins/<name>" source to pin by path.
  jq -e 'all(.[]; .source.path | type == "string" and startswith("plugins/"))' <<<"$remote" >/dev/null \
    || die "a pack plugin has a source outside plugins/; pin it by hand"

  TMP="$(mktemp)"
  trap 'rm -f "$TMP"' EXIT
  jq --argjson remote "$remote" \
    '.plugins = ([.plugins[] | select(.source | type == "string")] + $remote)' "$MK" > "$TMP"

  if cmp -s "$MK" "$TMP"; then
    echo "pin-pack: already pinned to $PACK@${head:0:12}; $(jq length <<<"$remote") remote entries, no change"
    return 0
  fi
  diff -u --label "a/.grok-plugin/marketplace.json" --label "b/.grok-plugin/marketplace.json" "$MK" "$TMP" || true
  mv "$TMP" "$MK"
  trap - EXIT
  echo "pin-pack: pinned $(jq length <<<"$remote") remote entries to $PACK@${head:0:12} (was ${old:-none})"
  if [[ "$(jq length <<<"$remote")" != "$before" ]]; then
    echo "pin-pack: the entry count changed from $before; update the Depth table in README.md and docs/DEPTH_MATRIX.md"
  fi
}

case "${1:-}" in
  --check) check ;;
  "") pin ;;
  -h|--help) sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//' ;;
  *) die "unknown option: $1 (try --help)" ;;
esac
