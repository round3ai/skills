# three.dev agent skills

Skills that teach AI coding agents how to integrate and work with
[three.dev](https://three.dev), following the
[Agent Skills](https://agentskills.io) standard.

## Install

The repository is an [Agent Plugin](https://agent-plugins.org): one install
gives an agent the skills below and the three.dev MCP server at
`https://mcp.three.dev/mcp`. The first tool call opens a browser sign-in to
three.dev; there is no API key to create or paste. Pick the path that matches
your client.

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

### MCP server only, no skills

Commit a `.mcp.json` at the project root. Every MCP client reads this file,
and in Claude Code the server shows up as plain `three-dev`.

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
codex mcp add three-dev --url https://mcp.three.dev/mcp
```

Do not combine this with the plugin on the same machine, or the same server
is listed twice.

### Codex

```bash
codex plugin marketplace add round3ai/skills
codex plugin install three-dev
```

### Cursor, VS Code, GitHub Copilot, Kiro, Cline

These clients read the `plugin.json` at the repository root. Install from
source with the client's plugin command, or add
`https://github.com/round3ai/skills` from its plugin marketplace where one
exists.

### Skills only, any other agent

```bash
npx skills add round3ai/skills
```

This installs the skills but not the MCP server; add the server with the
`.mcp.json` above. To copy the files by hand, put the folders under `skills/`
in your agent's skills directory (`.claude/skills/`, `.agents/skills/`, or
equivalent).

### Updating

Installed plugins and skills do not update themselves. The plugin declares no
version, so `claude plugin update three-dev` picks up the latest commit;
`npx skills update` does the same for skills-only installs.

## Skills

<!-- SKILLS:START -->

| Skill | What it does | MCP server |
| --- | --- | --- |
| [`three-dev`](skills/three-dev/SKILL.md) | Integrate three.dev into a codebase or extend an existing integration. | Optional |
| [`three-dev-experiments`](skills/three-dev-experiments/SKILL.md) | Runs an offline experiment in three.dev to test a prompt, model, or reasoning change on recorded production traffic, and reads the results. | Required |
| [`three-dev-failure-modes`](skills/three-dev-failure-modes/SKILL.md) | Investigates production quality problems in an LLM feature that three.dev already records. | Required |

<!-- SKILLS:END -->

Each skill's `SKILL.md` says when to use it. Where the
[three.dev MCP server](https://docs.three.dev) is optional, the skill reads the
live docs and checks recorded traffic when the server is connected and falls
back to the docs copies under `references/` otherwise; where it is required,
every fact the skill reports comes from the tools.

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
