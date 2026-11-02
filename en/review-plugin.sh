#!/usr/bin/env bash
# review-plugin.sh — shows what a plugin or skill runs BEFORE you trust it.
# Usage: review-plugin.sh <plugin-or-skill-folder>
# Read-only: it does not install, load or run anything from the plugin.
set -euo pipefail
[ $# -eq 1 ] && [ -d "$1" ] || { echo "usage: $0 <plugin-or-skill-folder>" >&2; exit 2; }
P=${1%/}
section() { printf '\n== %s ==\n' "$1"; }
show() { if [ -e "$1" ]; then cat "$1"; else echo "(none)"; fi; }

section "Manifest (.claude-plugin/plugin.json)"
show "$P/.claude-plugin/plugin.json"
section "Hooks (hooks/hooks.json): they run OUTSIDE the sandbox"
show "$P/hooks/hooks.json"
section "MCP servers (.mcp.json): they run OUTSIDE the sandbox"
show "$P/.mcp.json"
section "Executables (bin/): added to the PATH"
if [ -d "$P/bin" ]; then ls -la "$P/bin"; else echo "(none)"; fi

section "allowed-tools of each SKILL.md (permissions the skill grants itself)"
n=0
while IFS= read -r -d '' f; do
  n=$((n + 1))
  printf '%s: %s\n' "${f#"$P"/}" "$(grep -m1 '^allowed-tools:' "$f" || echo '(no allowed-tools)')"
done < <(find "$P" -name SKILL.md -print0)
[ "$n" -gt 0 ] || echo "(no SKILL.md)"

section "Lines worth reading (downloads, eval, base64, deletions, network)"
grep -rnIE 'curl |wget |eval |base64|rm -rf|nc |/dev/tcp' "$P" || echo "(none)"

printf '\nIf everything looks right, measure its cost before installing it:\n  claude --plugin-dir %q plugin details <name>\n' "$P"
