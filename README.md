# three.dev agent skills

Skills that teach AI coding agents how to integrate and work with
[three.dev](https://three.dev), following the
[Agent Skills](https://agentskills.io) standard.

## Install

The repository is an [Agent Plugin](https://agent-plugins.org): one install
gives an agent the skills below and the three.dev MCP server at
`https://mcp.three.dev/mcp`. The first tool call opens a browser sign-in to
three.dev; no API key to create or paste.

**Claude Code**

```bash
claude plugin marketplace add round3ai/skills
claude plugin install three-dev@three-dev
```

**Codex**

```bash
codex plugin marketplace add round3ai/skills
codex plugin install three-dev
```

**Cursor, VS Code, GitHub Copilot, Kiro, Cline** read the plugin manifest at
the repository root. Install from source with the client's plugin command, or
add `https://github.com/round3ai/skills` from its plugin marketplace where one
exists.

**Skills only**, for any other agent:

```bash
npx skills add round3ai/skills
```

This installs the skills but not the MCP server. To add the server by hand,
point the client at `https://mcp.three.dev/mcp` with the Streamable HTTP
transport, for example `claude mcp add --transport http three-dev
https://mcp.three.dev/mcp`. Or copy the `skills/three-dev` folder into your
agent's skills directory (`.claude/skills/`, `.agents/skills/`, or
equivalent).

Installed plugins and skills do not update themselves. Run
`claude plugin update three-dev` or `npx skills update` to pick up changes.

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
