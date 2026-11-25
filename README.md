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

## What this plugin sends and changes

**The MCP server**, `https://mcp.three.dev/mcp`. You sign in to three.dev
when your client asks. It receives only the tool calls your agent makes and
reads nothing else from your machine.

**The `three-dev-setup` skill**, run in your repository:

- Before its first call to three.dev, it tells you what it sends to
  `api.three.dev`: this machine's name, the repository folder's name, your
  agent's name, and a short report of how the setup ended. No code and no
  keys.
- You approve the connection once, in your browser. three.dev then issues a
  key for your app, `THREE_DEV_API_KEY`, which goes straight into the app's
  env file and never into the conversation. If git does not ignore that file,
  the skill adds it to `.gitignore`.
- In your code it changes only the LLM calls: their base URL, which points at
  the three.dev proxy, `gate.three.dev`, a few `X-Three-*` headers, and the
  key variable. It adds an env file loader (`python-dotenv` or `dotenv`) only
  when the app needs one. Your provider key stays where it is and is
  forwarded to your provider untouched.
- It checks the wiring with one short request through the proxy, marked as a
  test so three.dev does not store it.
- If an interrupted setup is resumed, it sends the key from the env file to
  `api.three.dev`, the service that issued it, in a request header, without
  printing it.

**The `three-dev-failure-modes` skill** reads the traffic three.dev recorded
through the MCP server. It sets a failure mode's severity, or dismisses or
restores one, only when you ask, and edits your code, prompt or configuration
only after you say yes.

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
