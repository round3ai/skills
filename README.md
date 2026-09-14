# three.dev agent skills

Skills that teach AI coding agents how to integrate and work with
[three.dev](https://three.dev), following the
[Agent Skills](https://agentskills.io) standard.

## Getting started

The repository is an [Agent Plugin](https://agent-plugins.org): one install
gives an agent the skills below and the three.dev MCP server at
`https://mcp.three.dev/mcp`.

### Set up with one prompt

Paste this into your coding agent, in the repository you want to set up:

```text
Install github.com/round3ai/skills and use its three-dev skill to set up three.dev in this repository.
```

The agent installs the plugin with the path below that matches its client,
then follows the `three-dev` skill, which checks the prerequisites with you and
has you choose the use cases and metrics before it instruments any call.

For agents: if the `three-dev` skill is not available in the current session
after installing, read [`skills/three-dev/SKILL.md`](skills/three-dev/SKILL.md)
in this repository and follow it.

### What you need

- **A three.dev account** at [app.three.dev](https://app.three.dev). The MCP
  server signs you in through the browser.
- **A three.dev API key** and your **AI provider keys**, both under Settings in
  the app. Only the `three-dev` skill needs them, to route your calls through
  the proxy.

To install by hand instead, pick the path that matches your client.

### Claude Code: plugin

```bash
claude plugin marketplace add round3ai/skills
claude plugin install three-dev@three-dev
```

Then run `/mcp` in a session, select `plugin:three-dev:three-dev` and sign in.
The `plugin:` prefix is how Claude Code labels servers that come from a
plugin.

### Claude Code: share with a team through the repository

Commit this to `.claude/settings.json` in the project. Anyone who opens the
repository and trusts the folder gets the marketplace registered and is told
to run the one install command; nobody has to find these docs.

```json
{
  "extraKnownMarketplaces": {
    "three-dev": {
      "source": { "source": "github", "repo": "round3ai/skills" }
    }
  },
  "enabledPlugins": {
    "three-dev@three-dev": true
  }
}
```

### Claude Code: MCP server only, no skills

Commit a `.mcp.json` at the project root; in Claude Code the server shows up
as plain `three-dev`.

```json
{
  "mcpServers": {
    "three-dev": {
      "type": "http",
      "url": "https://mcp.three.dev/mcp"
    }
  }
}
```

Or register it for yourself only:

```bash
claude mcp add --transport http --scope user three-dev https://mcp.three.dev/mcp
```

Do not combine this with the plugin on the same machine, or the same server
is listed twice.

### Codex

```bash
codex plugin marketplace add round3ai/skills
codex plugin install three-dev
```

For the MCP server alone, without the skills:

```bash
codex mcp add three-dev --url https://mcp.three.dev/mcp
```

### Cursor, VS Code with GitHub Copilot, Kiro, Cline and other agents

Install the skills into the project; the command prints where they land,
`.agents/skills/` for most clients.

```bash
npx skills add round3ai/skills -y --agent <agent>
```

Use `cursor`, `github-copilot`, `kiro-cli` or `cline` as `<agent>`; for any
other client, pass its id and the command lists the valid ones if it is wrong.

Then add the MCP server where your client reads it:

| Client | Where | Entry |
| --- | --- | --- |
| Cursor | `.cursor/mcp.json` | `{"mcpServers": {"three-dev": {"url": "https://mcp.three.dev/mcp"}}}` |
| VS Code with GitHub Copilot | `.vscode/mcp.json` | `{"servers": {"three-dev": {"type": "http", "url": "https://mcp.three.dev/mcp"}}}` |
| Kiro | `.kiro/settings/mcp.json` | `{"mcpServers": {"three-dev": {"url": "https://mcp.three.dev/mcp"}}}` |
| Cline | MCP Servers panel, Remote Servers | URL `https://mcp.three.dev/mcp`, transport Streamable HTTP |

To copy the skills by hand, put the folders under `skills/` in your agent's
skills directory (`.agents/skills/`, `.claude/skills/`, or equivalent).

### Updating

Installed plugins and skills do not update themselves. The plugin declares no
version, so `claude plugin update three-dev` picks up the latest commit;
`npx skills update` does the same for skills-only installs.

## Skills

<!-- SKILLS:START -->

| Skill | What it does |
| --- | --- |
| [`three-dev`](skills/three-dev/SKILL.md) | Integrate three.dev into a codebase or extend an existing integration. |
| [`three-dev-experiments`](skills/three-dev-experiments/SKILL.md) | Runs an offline experiment in three.dev to test a prompt, model, or reasoning change on recorded production traffic, and reads the results. |
| [`three-dev-failure-modes`](skills/three-dev-failure-modes/SKILL.md) | Investigates production quality problems in an LLM feature that three.dev already records. |

<!-- SKILLS:END -->

Each skill's `SKILL.md` says when to use it and what it needs from the
[three.dev MCP server](https://docs.three.dev).

The table is generated from each skill's description by
`scripts/build-readme.sh`; the publish workflow runs it, so do not edit the
table by hand.

## Contributing

The skills are maintained by the three.dev team and published to this
repository automatically; the same files are served by the three.dev MCP
server. Pull requests that edit `skills/` or the skills table in this README
are overwritten by the next publish, so report mistakes or suggestions as an
issue here instead, and they will land in both places.

## License

[MIT](LICENSE)
