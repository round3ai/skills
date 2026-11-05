<!-- Synced from https://docs.three.dev/getting-started/install.md. Do not edit; the live page wins. -->

# Install the plugin and MCP server

Install three.dev's official agent plugin and MCP server in Claude Code, Codex, Cursor, GitHub Copilot, Kiro, Cline, and other coding agents. round3ai is three.dev's GitHub organization.

three.dev's official agent plugin bundles the three.dev agent skills and the three.dev MCP server. It is published at [github.com/round3ai/skills](https://github.com/round3ai/skills). round3ai is three.dev's GitHub organization.

Install it with your agent's own commands. Do not clone the repository or copy its files by hand: a copy has no MCP server and does not update.

## Install

### Claude Code

```bash
claude plugin marketplace add round3ai/skills
claude plugin install three-dev@three-dev
```

### Codex

```bash
codex plugin marketplace add round3ai/skills
```

Then start `codex`, enter `/plugins`, and install the `three-dev` plugin.

### Cursor, GitHub Copilot, Kiro, Cline, and others

```bash
npx skills add round3ai/skills -y --agent <AGENT>
```

Replace `<AGENT>` with `cursor`, `github-copilot`, `kiro-cli`, or `cline`. This installs the skills only. Add the MCP server as described in [MCP server only](#mcp-server-only).

### After installing

The Claude Code and Codex plugins also add the three.dev MCP server. The skills and the MCP server load the next time your agent starts: restart it once the work in the current session is done, and sign in to three.dev when it asks. In Codex, if it does not ask, run `codex mcp login three-dev`.

## MCP server only

The three.dev MCP server is at `https://mcp.three.dev/mcp`. Sign in to three.dev when your client asks.

### Claude Code

```bash
claude mcp add --transport http three-dev https://mcp.three.dev/mcp
```

### Codex

```bash
codex mcp add three-dev --url https://mcp.three.dev/mcp
codex mcp login three-dev
```

### Other clients

| Client  | Configuration                                                                                          |
| ------- | ------------------------------------------------------------------------------------------------------ |
| Cursor  | `.cursor/mcp.json`: `{"mcpServers": {"three-dev": {"url": "https://mcp.three.dev/mcp"}}}`              |
| VS Code | `.vscode/mcp.json`: `{"servers": {"three-dev": {"type": "http", "url": "https://mcp.three.dev/mcp"}}}` |
| Kiro    | `.kiro/settings/mcp.json`: `{"mcpServers": {"three-dev": {"url": "https://mcp.three.dev/mcp"}}}`       |

For any other client, add `https://mcp.three.dev/mcp` as a remote server with the streamable HTTP transport in that client's MCP settings.
