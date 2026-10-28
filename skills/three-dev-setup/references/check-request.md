# The check request

Contents: [Before the check request](#before-the-check-request) ·
[The check request](#the-check-request) · [Before Step 6](#before-step-6)

It follows the wiring in [wiring.md](wiring.md) and
[provider-address.md](provider-address.md).

## Before the check request

Review the diff against this list:

- Every LLM call path goes through the proxy: streaming, retries, fallbacks,
  background jobs, sync and async clients. None is made twice.
- `X-Three-Api-Key`, `X-Three-Use-Case`, and `X-Three-AI-Provider` are on
  every wired client, and every per-call session header merges with them.
- The provider key is where it was. The three.dev key is in no provider
  credential setting.
- With `THREE_DEV_API_KEY` unset or empty, every client is built exactly as
  before: same address, same headers, no error. Every test that passed still
  passes.
- Models, prompts, parameters, timeouts, and error handling are unchanged.
- No key is logged, printed, hardcoded, or committed.
- A tag whose value can be missing sends no header rather than an empty or
  `None` value, and no tag carries personal data.

## The check request

One request through the app's own client, or one built from its pieces as
"Where the traffic header goes" allows, so it carries the headers real
traffic will, marked so three.dev knows it is a test. Starting the whole app
is not needed.

**Import the smallest piece of the app that builds the client**: its module,
factory, or provider instance, never a client of your own, except as "Where
the traffic header goes" allows. Make the call the
app makes, with its method, and its model as the app picks it (the setting's
expression, never a value you chose), adding only the traffic header. It is
a generation call, which three.dev reads in full, never an embeddings call.
The app's code and settings choose the provider and its key, so the check
sends the key only where the app sends it: send it even when you cannot tell
which provider a key belongs to. Load settings with the app's own loader
(`load_dotenv()`, `loadEnvConfig` from `@next/env`, its start script's flag),
never one you choose.

**Run it in the project's own environment**, like every command that runs
the app's code: its virtualenv's `python` (`<dir>/.venv/bin/python`), its
pinned tool or package manager's run command (`uv run`, `poetry run`,
`pnpm exec`), `tsx` or the framework's loader for TypeScript and path
aliases. If the pinned tool refuses to run, use the environment it built
directly. The system interpreter proves nothing about the app: a missing
package or a syntax error there is not the app's. An import that prints
nothing worked.

- Use one command when the runner resolves the app's imports that way.
  Otherwise write `three_dev_check.<ext>` in the directory the imports
  resolve from, where no file has that name, run it, and delete it whatever
  the result. `git status --porcelain` must then show nothing it added.
- Settings the import fails without, when the call does not use them (a
  database, cache, queue, storage, or auth setting), may get placeholder
  values in front of the check command, such as
  `DATABASE_URL=postgres://placeholder/x`, never in a file. Never the
  provider key, the three.dev key, or an address, except the provider key
  placeholder [library-wiring.md](library-wiring.md#the-check) gives.
- No check can be sent only when importing that piece fails by itself: it
  connects to a database or a running service at import, or only the
  framework's running server can resolve its imports. Creating a database or
  cache client without connecting is fine. A client built only inside the
  running server, in a request handler or from settings the server loads at
  start, is this case: do not start the server to reach it.

**Give it the key the way the app gets it.** The command is a new process,
and has the keys only if it gets them the way the app does:

| The app gets its keys from | Send the check |
| --- | --- |
| Any route, with the three.dev key in a file step 2 of connect.md created | Inside the command [connect.md](connect.md#collect) prints for it, on this machine. |
| A loading line in its code or its start script (`load_dotenv()`, `import "dotenv/config"`, a `config({ path })` call, `--env-file`, `dotenv -e`) | With that same loading first, copied from the app as it is, then the import of the client. Change only a relative path, so it names the same file from the directory the check runs in. When the line builds its path from the module's own location, run the command from that module's directory. |
| Its framework, runner, compose file, or process manager | Through that route's own way to run one command, inside the service when there is one, when it is up or the repository's documented command brings it up. |
| Its own config loader, from a file or store the app manages (settings saved from its own dashboard or settings screen) | With that loader first, imported as the app's start does, and its resolution (the manager or factory that hands the key to the client), then the client: the key reaches the client as it does in the app, never printed. The three.dev key comes by the row that fits it. |
| Anything else, with the three.dev key in `<env file>` | Load that file first, before the import of the client, with a dotenv parser the project already has, given its path (`load_dotenv("<path>")`, `dotenv.config({ path: "<path>" })`), or `node --env-file=<path>`. Never with the shell, and never with an option that overrides variables already set. The provider key's file, when it is another one, loads the same way. |
| Anything else, with no such parser | No check can be sent; see the table below. |

You never choose a file to load: only the app's own loading, connect.md's
command for a file step 2 created, or a parser given `<env file>` or the
provider key's file may load one. Never `source` another env file, and never
name a file the app does not name, other than `<env file>`.

```bash
.venv/bin/python -c "from app.llm import client; r = client.chat.completions.with_raw_response.create(model='<the model the app uses>', messages=[{'role': 'user', 'content': 'Reply with the single word: ok'}], extra_headers={'X-Three-Traffic-Type': 'synthetic'}); print(r.headers.get('x-three-request-id'), r.parse().choices[0].message.content)"
```

```bash
node --input-type=module -e "const { client } = await import('./src/llm.js'); const { data, response } = await client.chat.completions.create({ model: '<the model the app uses>', messages: [{ role: 'user', content: 'Reply with the single word: ok' }] }, { headers: { 'X-Three-Traffic-Type': 'synthetic' } }).withResponse(); console.log(response.headers.get('x-three-request-id'), data.choices[0].message.content)"
```

Adapt the runner, the import, the call, and the per-call header option to the
app's real module and SDK.

**Where the traffic header goes**, the first of these that can be done:

- The call's own per-call header option, when the installed source shows it
  reaching the headers the request is sent with.
- A client built for the check only, from the app's own pieces: its settings
  or config function, the URL and `X-Three-*` headers the wiring added, and
  the same key source, with the traffic header on that whole client. When
  the app's factory takes options (a config object, an HTTP client, a
  transport), call it with the header added there; otherwise copy the
  wiring's lines as the diff has them. It exists only in the check's
  process, so every request it makes is the check. Its HTTP client or
  transport may also read the response's `x-three-request-id`, which proves
  the check without the count. Step 6 gets "`<file>`'s check used a client
  built like the app's, not the app's own."
- For a call site that builds its own HTTP request (`fetch`, `requests`,
  `net/http`), one request built the way it builds it: the same URL
  expression and the same header code, called when it is a function, plus
  the traffic header.

When none can be done, send no check: a request without the header is taken
as the app's first real one. The table below says what to tell the user and
three.dev.

- An answer counts only with an `x-three-request-id` response header, read
  through the SDK's raw-response option. The proxy adds it to every
  response; without it the request went straight to the provider, so find
  why the client took its old path and send the check again.
- When the client shows no response headers, through its own option or the
  SDK client it wraps, three.dev's count is the proof. Run connect.md's
  status call just before the check and after it, every 5 seconds, waiting
  as its step 7 says, for 30 seconds at most: `verified_checks` one higher
  proves this check, and an unchanged count means it failed. Send such checks
  one at a time. With no device code and no setup being resumed, because
  every call site was already on three.dev, the answer counts as it is,
  after the command stops with "THREE_DEV_API_KEY is not set" when that
  variable is empty. Never edit an installed package, a lock file, or
  vendored code, and never hook the app's client, to see headers.
- A check from a client wired with this setup's key that leaves
  `verified_checks` unchanged after connect.md's wait is `test_failed`, and
  the status call's `first_request` says why. Turned `true` by this check:
  it went out without the traffic header, with "Not verified: the check
  request reached three.dev without being marked as a test, so three.dev
  counted it as your app's first request." Never look for another key then.
  Still `false` after a 2xx with three.dev's request ID: it went out with
  another three.dev key, set where the app reads it before `<env file>`,
  with "Not verified: the check went through three.dev with another key;
  `THREE_DEV_API_KEY` is set somewhere that wins over `<env file>`."
  Already `true` before it: the count cannot tell, with "Not verified: the
  check request could not be proven; your app's requests already reach
  three.dev."
- Google's GenAI SDK takes the traffic header in the call's config
  (`config={"http_options": {"headers": {...}}}` in Python) and shows the
  response headers on its answer: `sdk_http_response.headers` in Python, the
  answer's own HTTP response field in TypeScript and Go, found in the
  installed SDK's types.
- A framework model (LangChain's, in Python or JavaScript) hides response
  headers. Make the check's call through the SDK client the model holds,
  found in the installed class's source (`ChatAnthropic` calls
  `self._client.messages.with_raw_response.create`), with its raw-response
  option: it carries the model's address and headers. For
  `ChatGoogleGenerativeAI`, call `client.models.generate_content` with the
  header in `config={"http_options": {"headers": {...}}}`, and read
  `sdk_http_response.headers` on its answer. Only a model that holds no SDK
  client is proven by the count, as above.
- Pipe the output of every command that runs the app's code or the wiring
  through this filter: the check, an import, the key check below, a script
  of yours, a build, a test run. It hides well-known key formats, any run
  of 32 or more letters and digits, a line of base64, the password in an
  address, and a value set for a name ending in secret, password, token, or
  key, should code log a setting or an error show a value. A value of
  capitals and underscores only, an environment variable's name, stays. In
  bash and zsh, `set -o pipefail` keeps the command's own exit status; in
  another shell, leave it out and judge the command by its output.
  connect.md's command already has the filter:

```bash
set -o pipefail; <command> 2>&1 | sed -E 's#^[A-Za-z0-9+/=]{40,}$#[redacted]#; s#(://[^/:@[:space:]]+:)[^@[:space:]]+@#\1[redacted]@#g; s/([Ss][Ee][Cc][Rr][Ee][Tt]|[Pp][Aa][Ss][Ss][Ww]([Oo][Rr])?[Dd]|[Tt][Oo][Kk][Ee][Nn]|[Kk][Ee][Yy])([^A-Za-z0-9[:space:]:=]?[[:space:]]*[:=][[:space:]]*[^A-Za-z0-9[:space:]]?)[A-Za-z0-9+/=_-]*[a-z0-9+/][A-Za-z0-9+/=_-]*([^A-Za-z0-9+/=_.([-]|$)/\1\3[redacted]\4/g; s/(^|[^A-Za-z0-9_-])((sk-|r3_sk_|gsk_|xai-|AIza)[A-Za-z0-9_-]{8,}|(AKIA|ASIA)[A-Z0-9]{8,}|[a-z]{2}_(live|test)_[A-Za-z0-9]{8,}|xox[abpr]-[A-Za-z0-9-]{8,}|fw_[A-Za-z0-9]{8,})/\1[redacted]/g; s/[A-Za-z0-9]{32,}/[redacted]/g'
```

- Such a command prints only `set` or `unset`, header names
  (`sorted(headers)`), a status, a path, a request ID, the model's answer,
  or an error. Never a client, its settings or arguments, headers with their
  values, or the environment, and never turn on debug or verbose logging: a
  request log can carry its headers.
- The header goes on the check only. Never put it in the defaults of a
  client the app uses, or anywhere in the app's code: a request that carries
  it is not counted, listed, or scored. A client built for the check only,
  as "Where the traffic header goes" says, is the exception.
- One check per provider the app uses is enough. When settings choose
  between providers, ask about every wired provider's key and setting, then
  check the one the settings here choose. When the choice depends on which
  key or address is set, or the chosen one has no key here, check a wired
  provider whose key is set. The others get no check and one line together,
  which changes no reason: "Not verified: `<provider>`, `<provider>`; your
  settings here use `<provider>`." When you checked another than the one the
  settings choose, that one gets "Not verified: `<provider>`, whose key is not
  set here; I checked `<provider>` instead." The reason is `no_provider_key`
  only when no wired provider has its key here.

**Is the provider key there?** Follow the key the client gets back to where
it comes from: its argument, then the variable, config field, or settings
object that fills it. Only that source answers. When settings choose between
providers, ask about each one's key or setting, never a value, and check the
one this machine's settings choose. When the source is the environment the
app is started with, ask your shell, only as
`[ -n "${NAME:+x}" ] && echo set || echo unset`, with the name the code
reads, never a usual name it does not. When something passes in a file (a
compose `env_file`, a start script's flag), count the variable there, which
prints a number, never the line:

```bash
grep -cE '^(export +)?<NAME> *=' <file>
```

With a count above 0, load that file for the check with the project's dotenv
parser, as for `<env file>`. When the app's own settings code reads the file,
importing it brings the key and nothing else is needed. For an app that
reads its keys from a file, "unset" in your shell says nothing.

When the app reads the key through its own settings code (a JSON or TOML
file, a YAML config, a variable holding JSON, a settings library), ask that
code, never the file. Import the smallest piece that loads it, after the
same loading the check would do (the table above: the app's own loading
line, its runner, or a parser given the file), and copy this command as it
is, changing only the runner, `<loading>` (that loading, such as
`from dotenv import load_dotenv; load_dotenv('<path>')`, in single quotes
inside the command's double ones, or no line when importing the settings
loads it), the import, and the expression the client reads the key from:

```bash
.venv/bin/python -c "
try:
    <loading>
    from <module> import <settings>
    value = <expression>
except BaseException as e:
    print('error', type(e).__name__)
else:
    print('set' if value else 'unset')
" 2>/dev/null | sed -E 's#^[A-Za-z0-9+/=]{40,}$#[redacted]#; s#(://[^/:@[:space:]]+:)[^@[:space:]]+@#\1[redacted]@#g; s/([Ss][Ee][Cc][Rr][Ee][Tt]|[Pp][Aa][Ss][Ss][Ww]([Oo][Rr])?[Dd]|[Tt][Oo][Kk][Ee][Nn]|[Kk][Ee][Yy])([^A-Za-z0-9[:space:]:=]?[[:space:]]*[:=][[:space:]]*[^A-Za-z0-9[:space:]]?)[A-Za-z0-9+/=_-]*[a-z0-9+/][A-Za-z0-9+/=_-]*([^A-Za-z0-9+/=_.([-]|$)/\1\3[redacted]\4/g; s/(^|[^A-Za-z0-9_-])((sk-|r3_sk_|gsk_|xai-|AIza)[A-Za-z0-9_-]{8,}|(AKIA|ASIA)[A-Z0-9]{8,}|[a-z]{2}_(live|test)_[A-Za-z0-9]{8,}|xox[abpr]-[A-Za-z0-9-]{8,}|fw_[A-Za-z0-9]{8,})/\1[redacted]/g; s/[A-Za-z0-9]{32,}/[redacted]/g'
```

In another language, the same shape (in Go, a `main` package placed, run, and
deleted as [library-wiring.md](library-wiring.md#the-check)'s Go check is):
catch every error, an exit included,
and print only its type, never its message. `set` means send the check.
`unset` means the key is not there. `error`, or settings that cannot be
imported alone, means send the check anyway: an answer that the key is
missing, from the SDK before sending or from the provider, means it is not
there.

When the app resolves its settings before building the client (merging
sources, filling defaults, linking entries by id), ask through that
resolution, the manager, factory, or registry that hands the key to the
client: `<expression>` is then the call into it that returns the key, never
the loaded settings read by hand. When it runs only inside the running
server, no check can be sent: `app_not_runnable`.

A key the user saves through the app's own settings screen is read back by
the same settings code, from a file the app writes or a database: ask that
code, as above; "unset" in your shell says nothing about it. When only the
running server or a database can answer, send the check, as for `error`.

When no check can be sent, do not look for another way to send one. Give the
user the line below, and three.dev the reason, in the report of
[connect.md](connect.md). A client wired from its library never gets these
lines: [library-wiring.md](library-wiring.md#the-check) says what happens to
it.

| Why | The user's line | Reason |
| --- | --- | --- |
| No route above can load the file the key is in | "Not verified: your app does not load `<env file>` by itself." | `key_not_visible` |
| The provider key is in none of the places the app reads it from, its own config loader included: a key only that loader sees is there | "Not verified: `<the variable or setting the key is read from>` is not set on this machine." | `no_provider_key` |
| The module that builds the client cannot be run here, even in the project's own environment | "Not verified: `<what could not run, in a few words>`." | `app_not_runnable` |
| The code path logs request headers by itself | "Not verified: the app logs request headers." | `check_skipped` |
| The traffic header cannot go on the check by any route in "Where the traffic header goes" | "Not verified: `<file>`'s check request could not be marked as a test." | `check_skipped` |

A check that was sent and still fails after the fixes in
[proxy-errors.md](proxy-errors.md), or still answers without three.dev's
request ID, is `test_failed`: "Not verified: the check request failed with
`<code or status>`.", or "Not verified: the check request went straight to the
provider." A provider's 401 or 403 that says the key is invalid or revoked,
not missing, is `test_failed` too, whatever the key check printed, never
`no_provider_key`: "Not verified:
`<provider>` refused the key your app reads from `<source>` (`<status>`)."

## Before Step 6

Verify every instruction Step 6 will give: the process that calls the LLM (a
backend or worker, not the frontend), the repo's command that starts it, seen
to boot, and where it reads `THREE_DEV_API_KEY`: a container or process
manager passes only what its configuration lists.
