# Claude Code skills: which to install, how, and which to avoid

List reviewed on 1 Nov 2026 with Claude Code 2.1.316. Full page: https://ctrlia.dev/en/recetas/skills-que-instalar.html

## Skill, plugin and marketplace in one minute

A **skill** is a folder with a `SKILL.md` file (instructions with a description) and, if needed, scripts and resources. Claude loads it when the task matches its description, or you invoke it with `/name`. It can live in three places:

- **Your user:** `~/.claude/skills/<name>/SKILL.md`, available in all your projects.
- **The project:** `.claude/skills/<name>/SKILL.md`, committed for the team.
- **Inside a plugin:** then it is called `/plugin:skill`.

A **plugin** is a package that can bring skills, agents, hooks and MCP or LSP servers. A **marketplace** is the catalog Claude Code downloads plugins from: `claude-plugins-official` is added automatically the first time you open an interactive session; the others are added by hand.

Watch your context: according to the [official skills documentation](https://code.claude.com/docs/en/skills), every listed skill adds its description to your context **on every turn**, even if you don't use it; the full content only loads when invoked. If you want to write your own, follow the [Create your first skill](https://ctrlia.dev/en/recetas/primera-skill.html) recipe.

## How to install: the four ways

1. **From the official marketplace, inside a session:** `/plugin install frontend-design@claude-plugins-official`. Inside a session this command does not install right away: it opens the details panel so you can review what it adds and pick the scope (you in all projects, the whole repository, or only you in this repository). To browse, type `/plugin` and look in the Discover tab.
2. **From the shell, without opening a session:** `claude plugin install <name>@claude-plugins-official` (user scope by default; add `--scope project` for the repository).
3. **From another Anthropic marketplace**, such as the example skills one: `/plugin marketplace add anthropics/skills` and then `/plugin install document-skills@anthropic-agent-skills` or `example-skills@anthropic-agent-skills`. The community one is added with `/plugin marketplace add anthropics/claude-plugins-community` and installed with the `@claude-community` suffix.
4. **Copying the skill folder** into `~/.claude/skills/` or `.claude/skills/`.

Check with `claude plugin list` or by typing `/` and searching for the name.

```bash
claude plugin install frontend-design@claude-plugins-official
claude plugin list
claude plugin details frontend-design   # tokens per turn (Always-on)
```

Inside a session, Anthropic's official example skills:

```text
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropic-agent-skills
/plugin install example-skills@anthropic-agent-skills
```

## Recommended (reviewed 1 Nov 2026, measured cost)

All of them are in `claude-plugins-official`. The per-turn cost was measured on our PC (Linux, Claude Code 2.1.316) with `claude plugin details` on the official marketplace folders.

| Plugin | Publisher | What it does | Cost per turn |
| --- | --- | --- | --- |
| `frontend-design` | Anthropic | Well-designed interfaces, avoids the generic AI look | ~80 tokens |
| `skill-creator` | Anthropic | Creates, improves and measures your own skills | ~114 tokens |
| `commit-commands` | Anthropic | `/commit`, `/commit-push-pr` and cleanup of deleted branches | ~105 tokens |
| `security-guidance` | Anthropic | 4 hooks that warn about insecure patterns while editing and review the diff at the end | ~0 tokens (they are hooks) |
| `claude-md-management` | Anthropic | Keep your CLAUDE.md up to date | not measured |
| `playwright` | Microsoft (partner) | MCP server to automate the browser | not measured |
| `context7` | Upstash (partner) | Remote MCP server with up-to-date documentation | not measured |
| `superpowers` | Community (obra/superpowers) | Brainstorming, red-green TDD, systematic debugging; the official catalog pins it to a specific commit | not measured |

Two warnings: the `security-guidance` hooks **run outside the sandbox**, and `superpowers`, `playwright` and `context7` were not measured because they download from external repositories. Install one at a time and measure before adding the next.

## Measure what it costs before keeping it

Every active skill and plugin adds tokens to all your messages. To see it **before** installing, clone the repository and point at the plugin folder; **after** installing, `claude plugin details <name>` is enough.

```bash
git clone https://github.com/anthropics/claude-plugins-official /tmp/cpo
claude --plugin-dir /tmp/cpo/plugins/skill-creator plugin details skill-creator
# Output measured on 1 Nov 2026: Skills (1) skill-creator · Always-on: ~114 tok
```

The `Always-on` line is what it adds to every session, and the per-component table tells you which skill or agent weighs the most. In our test, a bundle of 34 skills and 4 agents added **~3,669 fixed tokens per turn**, about 45 times a single skill like `frontend-design`.

Other tools to keep spending under control:

- `/skill-doctor` (Claude Code 2.1.252 or later), inside a session, shows how much each skill costs and how often it is used, so you can turn off the ones you don't use.
- In `/plugin`, Installed tab, the ones not used recently are grouped together.
- To turn one off without uninstalling: `claude plugin disable <name>@<marketplace>`.
- To stop a skill of yours from using context and only run it by hand, set `disable-model-invocation: true` in its header.

## Review it before installing: security protocol

The [plugin security documentation](https://code.claude.com/docs/en/plugins/security) is clear: a plugin can run arbitrary code on your machine with your user privileges, and Anthropic does not control which MCP servers, files or software plugins include. A plugin's hooks, monitors and MCP servers **run outside the sandbox** and your permission rules do not cover them.

Four-step protocol:

1. `claude plugin marketplace list` to see where each marketplace comes from. Official names are only accepted if they come from `github.com/anthropics/`.
2. Read the details panel in `/plugin`: the **Will install** section lists commands, agents, skills, hooks and servers.
3. Read the code: `hooks/hooks.json` (what each hook runs), `.mcp.json` (which command or URL starts each server) and everything in `bin/`.
4. Check the `allowed-tools` field of skills from someone else's repository: it applies even if you haven't accepted trusting the folder, and a skill can grant itself broad permissions.

```bash
claude plugin marketplace list          # origin of each marketplace
P=/tmp/cpo/plugins/security-guidance
cat "$P/hooks/hooks.json" 2>/dev/null   # commands of each hook
cat "$P/.mcp.json" 2>/dev/null          # MCP servers it starts
ls -la "$P/bin" 2>/dev/null             # executables it adds to PATH
```

The repository includes `review-plugin.sh`, which runs steps 3 and 4 in one go on any plugin folder. Also remember that auto-update can change the files you reviewed: it is off by default for third-party marketplaces; leave it that way. To harden what Claude can do, see also [Security hooks](https://ctrlia.dev/en/recetas/hooks-seguridad.html).

## Which to avoid (or think twice about)

1. **Skills that duplicate what Claude Code already ships.** Version 2.1.316 includes built-in skills such as `/code-review`, `/simplify`, `/debug`, `/loop`, `/batch`, `/verify` and `/claude-api`; installing another with the same purpose only adds context.
2. **Huge "all in one" bundles** if you'll use two skills: you pay hundreds or thousands of tokens per turn for the rest.
3. **Third-party plugins with hooks or local MCP servers you can't read**, or whose repository doesn't pin versions: they run with your permissions and can change with every update.
4. **Old tutorials that ask for `/plugin marketplace add anthropics/claude-code`:** that marketplace (`claude-code-plugins`) is deprecated; use `claude-plugins-official`.
5. **Skills copied from websites or directories with no author or repository:** a skill's text enters the context as instructions and may try to make Claude do things you didn't ask for. If a skill is useful, better copy it into your project, read it and pin it in your repository.

If you already installed something dubious, remove it and delete its folder in `~/.claude/plugins/cache/`:

```bash
claude plugin disable frontend-design@claude-plugins-official
claude plugin uninstall frontend-design@claude-plugins-official --scope user
```

## What we tested and what's pending

Tested on 1 Nov 2026 on Linux with Claude Code 2.1.316: `claude plugin details` on the official marketplace folders gave the costs in the table (`frontend-design` ~80, `skill-creator` ~114, `code-review` ~22, `commit-commands` ~105 and `security-guidance` ~0 tokens with 4 hooks) and ~3,669 tokens for an installed bundle of 34 skills. Still pending: installing each recommendation in a test folder, using it on a real task and running `/skill-doctor`; when we do, we'll update this page and its date.

To go further: MCP servers in [MCP for developers](https://ctrlia.dev/en/recetas/mcp-para-programadores.html), subagents in [Subagents](https://ctrlia.dev/en/recetas/subagentes.html) and the full route in [Start here](https://ctrlia.dev/en/recetas/empieza-aqui.html).
