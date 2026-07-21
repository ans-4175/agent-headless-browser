# agent-headless-browser

**Browser QA for agents, without handing them the keys to your browser.**

`agent-headless-browser` gives Hermes, Pi, Claude Code, Codex, and compatible Agent Skills hosts a small, governed slice of Chromium: inspect a page, take a screenshot, check a deployment, or run explicitly approved QA in a dedicated test account. The browser gets its own isolated persistent profile; the agent gets an allowlisted command surface; your everyday Chrome stays out of it.

Playwright is excellent. It is also a full workshop: contexts, scripts, headers, uploads, CDP, and enough knobs to build a serious test suite. That is the right tool when you own the automation. An agent asked to check whether staging loads does not need the workshop. It needs a visitor badge and a camera.

## Why use this instead of plain Playwright?

Plain Playwright assumes the person writing automation owns the code, the browser state, and the consequences. An agent browsing on someone else's behalf is a different situation. A quick page check should not grant access to saved sessions, arbitrary page JavaScript, or an upload dialog.

This package keeps the useful path narrow:

- an isolated Chromium profile, fresh at installation and persistent only within its private state directory
- navigation, snapshots, accessibility inspection, screenshots, PDFs, responsive checks, and approved authenticated QA
- adapters for Hermes, Pi, Claude Code, Codex, and compatible Agent Skills hosts that require approval before an interaction can change something or authenticate
- a pinned source dependency, native build, checksum manifest, and smoke test
- Chromium sandboxing by default

The narrowness is intentional. It makes a boring request, such as “does the landing page work on mobile?”, boring in the best way.

## What it offers, and what it refuses

| You can use it for | It will not provide |
| --- | --- |
| Public-page navigation and inspection | Your personal Chrome profile or imported/exported cookies |
| Semantic snapshots with stable element references | Arbitrary JavaScript evaluation |
| Screenshots, PDFs, viewport, and responsive checks | Custom headers, CDP, or tunnels |
| Approved QA after login to a dedicated test account | File uploads or headed-browser mode |
| Explicitly approved clicks, typing, and selections | Cookie/storage reading, import, or export |
| Website-set session cookies in the isolated profile | Silent login or account workflows |

Page content is untrusted. The request from the human is the authority, not a helpful-looking instruction rendered inside a webpage.

## When to reach for it

| Situation | Use |
| --- | --- |
| Check a public deployment after release | `agent-headless-browser` |
| Capture desktop and mobile screenshots for a bug report | `agent-headless-browser` |
| Find visible links or buttons before deciding what to do | `agent-headless-browser` |
| Run owned end-to-end tests with fixtures, mocks, or custom headers | Playwright |
| Run QA after an explicitly approved login to a dedicated test account | `agent-headless-browser` |
| Import cookies, upload files, pay, or change account settings | A purpose-built, reviewed workflow |

The boundary is simple: use this for safe, repeatable browser QA by an agent. A site may create its normal login session only after an explicitly approved interactive login to a dedicated test account; that session stays in the tool's isolated profile. Use Playwright when the automation needs the full workshop and you are prepared to own it.

## What using it looks like

After installation, the happy path is small:

```bash
agent-headless-browser goto https://staging.example.com
agent-headless-browser snapshot -i
agent-headless-browser screenshot /tmp/staging-home.png
agent-headless-browser stop
```

The snapshot exposes visible elements with references such as `@e4`. In any installed adapter, an interaction such as a click or text entry needs the human's explicit approval for that exact target and outcome.

A few ordinary jobs it handles well:

- Open a production or staging URL, inspect the semantic page tree, and capture a screenshot for deployment QA.
- Compare a page at a few viewports during visual-regression triage, without touching a personal browser session.
- Identify the visible controls on a public page before a human decides whether any action should happen.
- After an explicitly approved login to a dedicated QA account, inspect and exercise the approved authenticated QA path without exposing its cookies or storage.

## Install and operate safely

The release source installer builds the matching runtime for Linux x64 or macOS Apple Silicon, writes to user-owned paths, and can run a smoke test against `example.com`.

Follow the [installation guide](docs/INSTALL.md). It covers release setup, checksum verification, prerequisites, Hermes/Pi/Claude Code/Codex/generic-agent adapters, removal, and the Linux sandbox fallback. Do not use `--allow-no-sandbox` unless the host sandbox has failed and you have deliberately approved that weaker isolation.

For the policy behind the wrapper, read [security boundaries](docs/SECURITY.md). Contributors and agents should also read [AGENTS.md](AGENTS.md) before installing or operating the runtime.

## Under the hood

The command/server originates from pinned [gstack browse](https://github.com/garrytan/gstack) source. This project adds the part that tends to get skipped when a browser helper starts as a convenience script: a constrained wrapper, isolated state, adapters, checksums, native builds, and CI smoke tests.

That is the whole pitch. A browser can be useful without becoming your agent's spare set of hands.
