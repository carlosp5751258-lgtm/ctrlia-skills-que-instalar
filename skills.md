# Skills de Claude Code: cuáles instalar, cómo y cuáles evitar

Lista revisada el 1-nov-2026 con Claude Code 2.1.316. Página completa: https://ctrlia.dev/recetas/skills-que-instalar.html

## Skill, plugin y marketplace en un minuto

Una **skill** es una carpeta con un archivo `SKILL.md` (instrucciones con una descripción) y, si hace falta, scripts y recursos. Claude la carga cuando la tarea encaja con su descripción, o la invocas tú con `/nombre`. Puede vivir en tres sitios:

- **Tu usuario:** `~/.claude/skills/<nombre>/SKILL.md`, disponible en todos tus proyectos.
- **El proyecto:** `.claude/skills/<nombre>/SKILL.md`, se hace commit para el equipo.
- **Dentro de un plugin:** entonces se llama `/plugin:skill`.

Un **plugin** es un paquete que puede traer skills, agentes, hooks y servidores MCP o LSP. Un **marketplace** es el catálogo del que Claude Code descarga plugins: `claude-plugins-official` se añade solo la primera vez que abres una sesión interactiva; los demás se añaden a mano.

Ojo con el contexto: según la [documentación oficial de skills](https://code.claude.com/docs/es/skills), cada skill de la lista añade su descripción a tu contexto **en cada turno**, aunque no la uses; el contenido completo solo se carga al invocarla. Si quieres crear la tuya, sigue la receta [Crea tu primera skill](https://ctrlia.dev/recetas/primera-skill.html).

## Cómo instalar: los cuatro caminos

1. **Desde el marketplace oficial, dentro de una sesión:** `/plugin install frontend-design@claude-plugins-official`. En la sesión este comando no instala al momento: abre el panel con los detalles para que revises qué añade y elijas el ámbito (tú en todos los proyectos, todo el repositorio o solo tú en este repositorio). Para explorar, escribe `/plugin` y busca en la pestaña Discover.
2. **Desde la shell, sin abrir sesión:** `claude plugin install <nombre>@claude-plugins-official` (ámbito de usuario por defecto; añade `--scope project` para el repositorio).
3. **Desde otro marketplace de Anthropic**, como el de skills de ejemplo: `/plugin marketplace add anthropics/skills` y después `/plugin install document-skills@anthropic-agent-skills` o `example-skills@anthropic-agent-skills`. El comunitario se añade con `/plugin marketplace add anthropics/claude-plugins-community` y se instala con el sufijo `@claude-community`.
4. **Copiando la carpeta** de la skill a `~/.claude/skills/` o `.claude/skills/`.

Comprueba con `claude plugin list` o escribiendo `/` y buscando el nombre.

```bash
claude plugin install frontend-design@claude-plugins-official
claude plugin list
claude plugin details frontend-design   # tokens por turno (Always-on)
```

Dentro de una sesión, las skills oficiales de ejemplo de Anthropic:

```text
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropic-agent-skills
/plugin install example-skills@anthropic-agent-skills
```

## Recomendadas (revisadas el 1-nov-2026, coste medido)

Todas están en `claude-plugins-official`. El coste por turno se midió en nuestro PC (Linux, Claude Code 2.1.316) con `claude plugin details` sobre las carpetas del marketplace oficial.

| Plugin | Quién lo publica | Qué hace | Coste por turno |
| --- | --- | --- | --- |
| `frontend-design` | Anthropic | Interfaces con diseño cuidado, evita la estética genérica de IA | ~80 tokens |
| `skill-creator` | Anthropic | Crea, mejora y mide tus propias skills | ~114 tokens |
| `commit-commands` | Anthropic | `/commit`, `/commit-push-pr` y limpieza de ramas borradas | ~105 tokens |
| `security-guidance` | Anthropic | 4 hooks que avisan de patrones inseguros al editar y revisan el diff al terminar | ~0 tokens (son hooks) |
| `claude-md-management` | Anthropic | Mantener tu CLAUDE.md al día | sin medir |
| `playwright` | Microsoft (socio) | Servidor MCP para automatizar el navegador | sin medir |
| `context7` | Upstash (socio) | Servidor MCP remoto con documentación actualizada | sin medir |
| `superpowers` | Comunidad (obra/superpowers) | Lluvia de ideas, TDD rojo-verde, depuración sistemática; el catálogo oficial lo fija a un commit concreto | sin medir |

Dos avisos: los hooks de `security-guidance` **se ejecutan fuera del sandbox**, y `superpowers`, `playwright` y `context7` no se midieron porque se descargan de repositorios externos. Instala de una en una y mide antes de añadir la siguiente.

## Mide lo que te cuesta antes de quedártela

Cada skill y cada plugin activo suman tokens a todos tus mensajes. Para verlo **antes** de instalar, clona el repositorio y apunta a la carpeta del plugin; **después** de instalar, basta `claude plugin details <nombre>`.

```bash
git clone https://github.com/anthropics/claude-plugins-official /tmp/cpo
claude --plugin-dir /tmp/cpo/plugins/skill-creator plugin details skill-creator
# Salida medida el 1-nov-2026: Skills (1) skill-creator · Always-on: ~114 tok
```

La línea `Always-on` es lo que añade a cada sesión, y la tabla por componente dice qué skill o agente pesa más. En nuestra prueba, un paquete de 34 skills y 4 agentes sumaba **~3 669 tokens fijos por turno**, unas 45 veces lo que una sola skill como `frontend-design`.

Otras herramientas para controlar el gasto:

- `/skill-doctor` (Claude Code 2.1.252 o posterior), dentro de una sesión, muestra cuánto cuesta cada skill y cuántas veces se usa, para que apagues las que no usas.
- En `/plugin`, pestaña Installed, aparecen agrupadas las que no se han usado recientemente.
- Para apagar sin desinstalar: `claude plugin disable <nombre>@<marketplace>`.
- Para que una skill tuya no gaste contexto y solo se use a mano, pon `disable-model-invocation: true` en su cabecera.

## Revísala antes de instalar: protocolo de seguridad

La [documentación de seguridad de plugins](https://code.claude.com/docs/en/plugins/security) es clara: un plugin puede ejecutar código arbitrario en tu máquina con tus privilegios de usuario, y Anthropic no controla qué MCP, archivos o software incluyen los plugins. Los hooks, los monitores y los servidores MCP de un plugin **se ejecutan fuera del sandbox** y tus reglas de permisos no los cubren.

Protocolo en cuatro pasos:

1. `claude plugin marketplace list` para ver de dónde viene cada marketplace. Los nombres oficiales solo se aceptan si vienen de `github.com/anthropics/`.
2. Lee el panel de detalles en `/plugin`: la sección **Will install** lista comandos, agentes, skills, hooks y servidores.
3. Lee el código: `hooks/hooks.json` (qué ejecuta cada hook), `.mcp.json` (qué comando o URL arranca cada servidor) y todo lo que haya en `bin/`.
4. Revisa el campo `allowed-tools` de las skills de un repositorio ajeno: se aplica aunque no hayas aceptado confiar en la carpeta, y una skill puede darse a sí misma permisos amplios.

```bash
claude plugin marketplace list          # origen de cada marketplace
P=/tmp/cpo/plugins/security-guidance
cat "$P/hooks/hooks.json" 2>/dev/null   # comandos de cada hook
cat "$P/.mcp.json" 2>/dev/null          # servidores MCP que arranca
ls -la "$P/bin" 2>/dev/null             # ejecutables que añade al PATH
```

En el repositorio tienes `revisar-plugin.sh`, que hace los pasos 3 y 4 de una vez sobre cualquier carpeta de plugin. Recuerda además que la actualización automática puede cambiar los archivos que revisaste: en marketplaces de terceros viene apagada; déjala así. Para endurecer lo que Claude puede hacer, mira también [Hooks de seguridad](https://ctrlia.dev/recetas/hooks-seguridad.html).

## Cuáles evitar (o pensártelo dos veces)

1. **Skills que duplican lo que Claude Code ya trae.** La versión 2.1.316 incluye skills integradas como `/code-review`, `/simplify`, `/debug`, `/loop`, `/batch`, `/verify` y `/claude-api`; instalar otra con el mismo propósito solo suma contexto.
2. **Paquetes enormes «todo en uno»** si vas a usar dos skills: pagas cientos o miles de tokens por turno por el resto.
3. **Plugins de terceros con hooks o servidores MCP locales que no puedas leer**, o cuyo repositorio no fije versiones: se ejecutan con tus permisos y pueden cambiar con cada actualización.
4. **Tutoriales viejos que piden `/plugin marketplace add anthropics/claude-code`:** ese marketplace (`claude-code-plugins`) está obsoleto; usa `claude-plugins-official`.
5. **Skills copiadas de webs o directorios sin autor ni repositorio:** el texto de una skill entra en el contexto como instrucciones y puede intentar que Claude haga cosas que no pediste. Si una skill te sirve, mejor cópiala a tu proyecto, léela y fíjala en tu repositorio.

Si ya instalaste algo dudoso, quítalo y borra su carpeta en `~/.claude/plugins/cache/`:

```bash
claude plugin disable frontend-design@claude-plugins-official
claude plugin uninstall frontend-design@claude-plugins-official --scope user
```

## Qué probamos y qué falta

Probado el 1-nov-2026 en Linux con Claude Code 2.1.316: `claude plugin details` sobre las carpetas del marketplace oficial dio los costes de la tabla (`frontend-design` ~80, `skill-creator` ~114, `code-review` ~22, `commit-commands` ~105 y `security-guidance` ~0 tokens con 4 hooks) y ~3 669 tokens para un paquete de 34 skills ya instalado. Falta instalar cada recomendada en una carpeta de prueba, usarla en una tarea real y pasar `/skill-doctor`; cuando lo hagamos, actualizaremos esta página y su fecha.

Para ir más allá: servidores MCP en [MCP para programadores](https://ctrlia.dev/recetas/mcp-para-programadores.html), subagentes en [Subagentes](https://ctrlia.dev/recetas/subagentes.html) y la ruta completa en [Empieza aquí](https://ctrlia.dev/recetas/empieza-aqui.html).
