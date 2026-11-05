# Codex

In Codex, these replace Step 0 and add to the ground rules "Decide, don't
ask" and "Commands run as printed": Codex's approval review accepts only what
the user approved.

1. **Ask once, first.** Run the `hostname` command in
   [connect.md](connect.md#start), then end your turn on this question, filled
   in. It is also the "Say what leaves the machine" line:

   > To set up three.dev I'll install its plugin (adding round3ai/skills as a
   > plugin marketplace), send three.dev this machine's name, `<hostname>`,
   > and this folder's name, `<folder>`, and send one test request through
   > three.dev with your app's own provider key, to the organization you
   > approve in the browser. No code leaves this machine, and three.dev gets
   > no key but its own. Go ahead?

   On a yes, go on. Any other answer is a stop with `command_refused`.
2. **Install the plugin.** Unless `codex plugin list` shows
   `three-dev@three-dev` as installed, run
   `codex plugin marketplace add round3ai/skills`, then
   `codex plugin add three-dev@three-dev`.
3. **If the review still declines a setup command**, ask once, naming that
   exact action and what it sends. For the check request: "Is `<org>` your
   organization? I'll send one test request through it with your app's
   `<provider>` key." On a yes, run the command again once, as printed. Any
   other answer, or a second decline, is a stop with `command_refused`.
