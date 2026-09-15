# three.dev agent skills

[Agent Skills](https://agentskills.io) for [three.dev](https://three.dev),
bundled with the three.dev MCP server at `https://mcp.three.dev/mcp`.

## Getting started

Paste this into your coding agent:

```text
Install github.com/round3ai/skills and use its three-dev skill to set up three.dev in this repository.
```

### Install by hand

```bash
# Claude Code
claude plugin marketplace add round3ai/skills
claude plugin install three-dev@three-dev

# Codex
codex plugin marketplace add round3ai/skills
codex plugin install three-dev

# Any other agent: cursor, github-copilot, kiro-cli, cline, ...
npx skills add round3ai/skills -y --agent <agent>
```

The Claude Code and Codex plugins also set up the three.dev MCP server. Sign in
when your client asks, or run `/mcp` in Claude Code.

If you installed with `npx skills`, add the MCP server to your client's config:

| Client | Config |
| --- | --- |
| Cursor | `.cursor/mcp.json`: `{"mcpServers": {"three-dev": {"url": "https://mcp.three.dev/mcp"}}}` |
| VS Code | `.vscode/mcp.json`: `{"servers": {"three-dev": {"type": "http", "url": "https://mcp.three.dev/mcp"}}}` |
| Kiro | `.kiro/settings/mcp.json`: `{"mcpServers": {"three-dev": {"url": "https://mcp.three.dev/mcp"}}}` |
| Cline | MCP Servers panel: the URL above, transport Streamable HTTP |

Then paste this into your coding agent:

```text
Use the three-dev skill to set up three.dev in this repository.
```

Update with `claude plugin update three-dev` or `npx skills update`.

## Skills

<!-- Generated from each SKILL.md description by scripts/build-readme.sh on publish. Do not edit. -->
<!-- SKILLS:START -->

| Skill | What it does |
| --- | --- |
| [`three-dev`](skills/three-dev/SKILL.md) | Adds three.dev to a codebase so its LLM calls are recorded. |
| [`three-dev-experiments`](skills/three-dev-experiments/SKILL.md) | Runs an offline experiment in three.dev to test a prompt, model, or reasoning change on recorded production traffic, and reads the results. |
| [`three-dev-failure-modes`](skills/three-dev-failure-modes/SKILL.md) | Investigates production quality problems in an LLM feature that three.dev already records. |
| [`three-dev-quality-metrics`](skills/three-dev-quality-metrics/SKILL.md) | Sets up quality metrics for an LLM feature that three.dev already records. |

<!-- SKILLS:END -->

## Contributing

The skills are published here automatically and also served by the three.dev
MCP server. Changes to `skills/` or the table above are overwritten on the next
publish, so open an issue instead.

## License

[MIT](LICENSE)
