# Claude Code skills: which to install and how to review them

🇪🇸 [Leer en español](README.md)

The Spanish version is in the repository root and in [README.md](README.md); the English files are in `en/`.

A short, dated list of Claude Code skills and plugins with the exact install command, who publishes them and their
per-turn token cost measured with `claude plugin details`, plus a script that shows you what a plugin runs before you
trust it.

Full page: [ctrlia.dev (EN)](https://ctrlia.dev/en/recetas/skills-que-instalar.html) ·
[ctrlia.dev (ES)](https://ctrlia.dev/recetas/skills-que-instalar.html)

## What's included

- `en/skills.md`: the four ways to install, the recommended ones with their measured cost, how to measure
  any other, the 4-step security protocol and which ones to avoid.
- `en/review-plugin.sh`: shows the manifest, hooks, MCP servers, `bin/` executables, the
  `allowed-tools` of each `SKILL.md` and lines with downloads, `eval`, `base64` or deletions. **It only reads files**: it
  doesn't install, load or run anything from the plugin.

## How to use it

```bash
git clone https://github.com/carlosp5751258-lgtm/ctrlia-skills-que-instalar.git
# clone the plugin you want to review, without installing it:
git clone https://github.com/anthropics/claude-plugins-official /tmp/cpo
bash ctrlia-skills-que-instalar/en/review-plugin.sh /tmp/cpo/plugins/security-guidance
# if it looks fine, measure its cost and then install it:
claude --plugin-dir /tmp/cpo/plugins/security-guidance plugin details security-guidance
claude plugin install security-guidance@claude-plugins-official
```

The script doesn't decide for you: it shows you what to read. A plugin's hooks, MCP servers and executables run
**outside the sandbox** with your user permissions.

## Tested

- Claude Code **2.1.316** on Linux, 1 Nov 2026: the costs in the list come from `claude plugin details` on the official
  marketplace. The recommended ones haven't yet been used one by one on real tasks.
- `revisar-plugin.sh` (and its English copy `en/review-plugin.sh`): `bash -n`, a fake plugin folder (hook with `curl | sh`, skill with `allowed-tools: Bash(*)`, paths
  with spaces), an empty folder, a missing path (exits with code 2) and the official `security-guidance` plugin.

## License

MIT. Copyright (c) 2026 Ctrl+IA (Carlos P.). See [LICENSE](LICENSE).
