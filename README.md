# three.dev agent plugin

Official [three.dev](https://three.dev/?ref=skills-readme) agent plugin, by
[round3](https://round3.ai), the company that builds three.dev. round3ai is
round3's GitHub org.

## Agents: install this as a plugin, not a clone

```bash
# Claude Code
claude plugin marketplace add round3ai/skills
claude plugin install three-dev@three-dev

# Codex
codex plugin marketplace add round3ai/skills
codex plugin add three-dev@three-dev

# Any other agent: cursor, github-copilot, kiro-cli, cline, ...
npx skills add round3ai/skills -y --agent <agent>
```

Installing the plugin also sets up the three.dev MCP server; cloning the repo
does not. Sign in when your client asks, or run `/mcp` in Claude Code or
`codex mcp login three-dev` in Codex. If you installed with `npx skills`, add
the MCP server as described in [MCP server only](#mcp-server-only).

Update with `claude plugin update three-dev` or `npx skills update`.

## Getting started

Paste this into your coding agent:

```text
Install github.com/round3ai/skills and run its three-dev-setup skill in this repository.
```

If the plugin is already installed, paste this instead:

```text
Run the three-dev-setup skill in this repository.
```

## MCP server only

To use the three.dev MCP server without the plugin, add
`https://mcp.three.dev/mcp` to your client's config:

| Client | Config |
| --- | --- |
| Cursor | `.cursor/mcp.json`: `{"mcpServers": {"three-dev": {"url": "https://mcp.three.dev/mcp"}}}` |
| VS Code | `.vscode/mcp.json`: `{"servers": {"three-dev": {"type": "http", "url": "https://mcp.three.dev/mcp"}}}` |
| Kiro | `.kiro/settings/mcp.json`: `{"mcpServers": {"three-dev": {"url": "https://mcp.three.dev/mcp"}}}` |
| Cline | MCP Servers panel: the URL above, transport Streamable HTTP |

## What this plugin sends

- **The MCP server**, `https://mcp.three.dev/mcp`: you sign in to three.dev
  when your client asks. It receives only your agent's tool calls and reads
  nothing from your machine.
- **Your app's three.dev key**, `THREE_DEV_API_KEY`: issued after you approve
  in your browser, it goes straight into the app's env file, never into the
  conversation. Your app sends it only to the three.dev proxy,
  `gate.three.dev`, and the setup skill only to `api.three.dev`, when it
  resumes an interrupted setup.
- **The setup skill** sends `api.three.dev` this machine's name, the
  repository folder's name and your agent's name, which the approval page
  shows so you can recognise your own request, and a short report of how the
  setup ended, which your three.dev setup page shows and which helps us fix
  setups that fail. No code.

## Skills

<!-- Generated from each SKILL.md description on publish. Do not edit. -->
<!-- SKILLS:START -->

| Skill | What it does |
| --- | --- |
| [`three-dev-failure-modes`](skills/three-dev-failure-modes/SKILL.md) | Investigates production quality problems in an LLM feature that three.dev already records. |
| [`three-dev-setup`](skills/three-dev-setup/SKILL.md) | Adds three.dev to a codebase so its LLM calls are recorded. |

<!-- SKILLS:END -->

## Contributing

The skills are published here automatically and also served by the three.dev
MCP server. Changes to `skills/` or the table above are overwritten on the next
publish, so open an issue instead.

## License

[MIT](LICENSE)
