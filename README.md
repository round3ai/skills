# three.dev agent skills

Skills that teach AI coding agents how to integrate and work with
[three.dev](https://three.dev), following the
[Agent Skills](https://agentskills.io) standard.

## Install

```bash
npx skills add round3ai/skills
```

Works with Claude Code, Cursor, Codex, GitHub Copilot, Gemini CLI, Windsurf,
Cline, OpenCode, Amp, and any other agent that supports the standard. To copy
the files by hand, put the `skills/three-dev` folder in your agent's skills
directory (`.claude/skills/`, `.agents/skills/`, or equivalent).

Installed skills do not update themselves. Run `npx skills update` to pick up
changes.

## Skills

| Skill | Use it when |
| --- | --- |
| [`three-dev`](skills/three-dev/SKILL.md) | Adding three.dev to a codebase, or extending an existing integration: routing LLM calls through the proxy, use cases, sessions, tags, and quality metrics. |

The skill works on its own. With the
[three.dev MCP server](https://docs.three.dev) connected it reads the live
docs and checks recorded traffic; without it, it uses the docs copies under
`references/`.

## Keeping the docs copies current

Files under `skills/three-dev/references/` marked "Synced from" are copies of
pages on docs.three.dev. Do not edit them; edit the docs, then run:

```bash
./scripts/sync-references.sh
```

and commit the diff.

## License

[MIT](LICENSE)
