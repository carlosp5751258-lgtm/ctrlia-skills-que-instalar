#!/usr/bin/env bash
# revisar-plugin.sh — muestra qué ejecuta un plugin o una skill ANTES de confiar en él.
# Uso: revisar-plugin.sh <carpeta-del-plugin-o-skill>
# Solo lee archivos: no instala, no carga y no ejecuta nada del plugin.
set -euo pipefail
[ $# -eq 1 ] && [ -d "$1" ] || { echo "uso: $0 <carpeta-del-plugin-o-skill>" >&2; exit 2; }
P=${1%/}
seccion() { printf '\n== %s ==\n' "$1"; }
mostrar() { if [ -e "$1" ]; then cat "$1"; else echo "(no hay)"; fi; }

seccion "Manifiesto (.claude-plugin/plugin.json)"
mostrar "$P/.claude-plugin/plugin.json"
seccion "Hooks (hooks/hooks.json): se ejecutan FUERA del sandbox"
mostrar "$P/hooks/hooks.json"
seccion "Servidores MCP (.mcp.json): se ejecutan FUERA del sandbox"
mostrar "$P/.mcp.json"
seccion "Ejecutables (bin/): se añaden al PATH"
if [ -d "$P/bin" ]; then ls -la "$P/bin"; else echo "(no hay)"; fi

seccion "allowed-tools de cada SKILL.md (permisos que la skill se da a sí misma)"
n=0
while IFS= read -r -d '' f; do
  n=$((n + 1))
  printf '%s: %s\n' "${f#"$P"/}" "$(grep -m1 '^allowed-tools:' "$f" || echo '(sin allowed-tools)')"
done < <(find "$P" -name SKILL.md -print0)
[ "$n" -gt 0 ] || echo "(no hay SKILL.md)"

seccion "Líneas que conviene leer (descargas, eval, base64, borrados, red)"
grep -rnIE 'curl |wget |eval |base64|rm -rf|nc |/dev/tcp' "$P" || echo "(ninguna)"

printf '\nSi todo te cuadra, mide su coste antes de instalarlo:\n  claude --plugin-dir %q plugin details <nombre>\n' "$P"
