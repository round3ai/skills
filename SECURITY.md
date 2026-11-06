# Security policy

## Reporting a vulnerability

Email **security@three.dev**. Please don't report security problems in public GitHub issues, discussions or pull requests.

Include:

- What is affected: a skill, the plugin manifests, the three.dev MCP server (`https://mcp.three.dev/mcp`) or three.dev itself
- Steps to reproduce it, or a proof of concept
- The agent and its version, if a skill or the MCP server is involved
- The impact you see

## Scope

In scope: the skills and plugin files in this repository, the three.dev MCP server and the three.dev service.

Report elsewhere: a vulnerability in the agent that runs the plugin, such as Claude Code, Codex or Cursor, goes to that agent's vendor.

## Supported versions

The plugin is not versioned. Installs follow this repository's `main` branch, and fixes land there. To get a fix, update the plugin with `claude plugin update three-dev` or `npx skills update`.
