# Skills de Claude Code: cuáles instalar y cómo revisarlas

🇬🇧 [Read in English](README.en.md)

Lista corta y fechada de skills y plugins para Claude Code con el comando exacto de instalación, quién los publica y su
coste en tokens por turno medido con `claude plugin details`, más un script que te enseña qué ejecuta un plugin antes de
que confíes en él.

Página completa: [ctrlia.dev (ES)](https://ctrlia.dev/recetas/skills-que-instalar.html) ·
[ctrlia.dev (EN)](https://ctrlia.dev/en/recetas/skills-que-instalar.html)

## Qué incluye

- `skills.md` / `skills.en.md`: los cuatro caminos de instalación, las recomendadas con su coste medido, cómo medir
  cualquier otra, el protocolo de seguridad en 4 pasos y cuáles evitar.
- `revisar-plugin.sh`: muestra el manifiesto, los hooks, los servidores MCP, los ejecutables de `bin/`, el `allowed-tools`
  de cada `SKILL.md` y las líneas con descargas, `eval`, `base64` o borrados. **Solo lee archivos**: no instala, no carga
  y no ejecuta nada del plugin.

## Cómo usarlo

```bash
git clone https://github.com/carlosp5751258-lgtm/ctrlia-skills-que-instalar.git
# clona el plugin que quieres revisar, sin instalarlo:
git clone https://github.com/anthropics/claude-plugins-official /tmp/cpo
bash ctrlia-skills-que-instalar/revisar-plugin.sh /tmp/cpo/plugins/security-guidance
# si te cuadra, mide su coste y después instálalo:
claude --plugin-dir /tmp/cpo/plugins/security-guidance plugin details security-guidance
claude plugin install security-guidance@claude-plugins-official
```

El script no decide por ti: te enseña lo que tienes que leer. Los hooks, los servidores MCP y los ejecutables de un plugin
se ejecutan **fuera del sandbox** con tus permisos de usuario.

## Probado

- Claude Code **2.1.316** en Linux, 1-nov-2026: los costes de la lista salen de `claude plugin details` sobre el
  marketplace oficial. Las recomendadas aún no se han usado una a una en tareas reales.
- `revisar-plugin.sh`: `bash -n`, una carpeta de plugin falsa (hook con `curl | sh`, skill con `allowed-tools: Bash(*)`,
  rutas con espacios), una carpeta vacía, una ruta inexistente (sale con código 2) y el plugin oficial `security-guidance`.

## Licencia

MIT. Copyright (c) 2026 Ctrl+IA (Carlos P.). Ver [LICENSE](LICENSE).
