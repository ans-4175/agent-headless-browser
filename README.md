# agent-headless-browser

A governed, isolated headless Chromium runtime for **Hermes** and **Pi**. It supports Linux x64 and macOS Apple Silicon, uses a fresh profile, and exposes only an approved browser-command surface.

It blocks cookie/profile import, arbitrary JavaScript, custom headers, uploads, CDP, tunnels, and headed mode. Browser interactions that can cause external effects remain subject to the installed skill's approval rules.

## Why this exists

Playwright is great. It gives you the whole workshop: browser contexts, headers, scripts, uploads, CDP, and enough rope to automate a serious test suite. That is exactly what a developer wants when they own the code.

An agent checking a page on your behalf needs a smaller toolkit. Giving it your everyday Chrome profile plus a full automation API is the browser equivalent of handing a visitor the office master key because they asked to check the lights.

This package keeps the useful bits—open a URL, inspect a page, take a screenshot, verify a deployment—then puts rails around them.

A human can say: “Check whether the staging landing page loads on mobile and send me a screenshot.” The agent gets an isolated browser, a short command list, and a clean way to stop when it is done. It does not get your saved sessions, your cookies, or a quiet path to start clicking around.

An agent can do this comfortably:

```bash
agent-headless-browser goto https://example.com
agent-headless-browser snapshot -i
agent-headless-browser screenshot /tmp/page.png
agent-headless-browser stop
```

If it needs to click a button, fill a field, or press a key, the installed skill makes it ask first. That little pause is the point. Most browser automation is built to remove friction; agent browsing needs friction in exactly the places where a stray click can matter.

Under the hood, the browser command/server comes from pinned [gstack browse](https://github.com/garrytan/gstack) source. We chose it because it already provides a practical CLI and daemon model. We did not copy its raw agent skill and call it a day. This repository adds the boring-but-important deployment layer: isolated state, an allowlisted wrapper, Hermes/Pi adapters, pinned provenance, checksums, native builds, CI smoke tests, and an explicit Linux no-sandbox escape hatch when a host truly needs it.

Use Playwright directly when you are writing and owning a test suite. Use this when a human or agent needs safe, repeatable browser QA without turning a normal browsing task into a full-access automation project.

## What using it feels like

### “Did the deployment actually look right?”

```bash
agent-headless-browser goto https://staging.example.com
agent-headless-browser snapshot -i
agent-headless-browser screenshot /tmp/staging-home.png
agent-headless-browser stop
```

You get a semantic page snapshot for quick inspection and a PNG you can open or attach to a bug. No existing Chrome window gets touched.

### “Can the agent find the thing I mean?”

Ask Hermes or Pi:

```text
Open https://example.com. Tell me the visible links and buttons. Do not click anything.
```

The agent can navigate and inspect. The `-i` snapshot gives it stable references such as `@e4`, rather than making it guess where a button lives on the page.

### “Click this one thing—then stop.”

After you have explicitly named the target and outcome:

```bash
agent-headless-browser snapshot -i
# Confirm @e4 is the intended "Learn more" link.
agent-headless-browser click @e4
agent-headless-browser stop
```

The skill treats that click as an external effect. An agent should ask before it does this unless your instruction already gave that exact approval. It cannot quietly switch to arbitrary page JavaScript when a click is inconvenient.

### “I need a full login flow.”

That is usually a Playwright test-suite job, not a job for this wrapper. Keep credentials and long-lived session automation inside code you own and review. This package is deliberately less magical—and much less surprising.

## Install from the latest release

The release source archive is the recommended setup path. It has the installer, policy, adapters, and pinned gstack source; it builds the native runtime on the target host.

### Hermes

```bash
# Resolves to the latest published release tag. Pin to a specific tag
# (e.g. VERSION=v0.1.7) if you need a fixed version.
VERSION=$(curl -fsSL -o /dev/null -w '%{url_effective}' \
  https://github.com/ans-4175/agent-headless-browser/releases/latest \
  | sed 's#.*/tag/##')
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
curl -fsSL "https://github.com/ans-4175/agent-headless-browser/archive/refs/tags/${VERSION}.tar.gz" \
  | tar -xz -C "$work" --strip-components=1
chmod +x "$work/install.sh"
"$work/install.sh" --adapter hermes --smoke-test
```

### Pi

```bash
# Resolves to the latest published release tag. Pin to a specific tag
# (e.g. VERSION=v0.1.7) if you need a fixed version.
VERSION=$(curl -fsSL -o /dev/null -w '%{url_effective}' \
  https://github.com/ans-4175/agent-headless-browser/releases/latest \
  | sed 's#.*/tag/##')
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
curl -fsSL "https://github.com/ans-4175/agent-headless-browser/archive/refs/tags/${VERSION}.tar.gz" \
  | tar -xz -C "$work" --strip-components=1
chmod +x "$work/install.sh"
"$work/install.sh" --adapter pi --smoke-test
```

Start a fresh Pi session, then invoke:

```text
/skill:agent-headless-browser
```

Use a specific newer tag in the URL when upgrading. Git checkout is optional; installation does not depend on a particular extracted folder name.

## What is installed

```text
~/.local/share/agent-headless-browser/   runtime + SHA256SUMS
~/.agent-headless-browser/               isolated profile and daemon state
~/.local/bin/agent-headless-browser      approved command entry point
```

The selected adapter is added to `~/.hermes/skills/agent-headless-browser/` or `~/.agents/skills/agent-headless-browser/`.

## Verify and use

```bash
agent-headless-browser status
agent-headless-browser goto https://example.com
agent-headless-browser snapshot -i
agent-headless-browser screenshot /tmp/page.png
agent-headless-browser stop
```

The smoke test uses only `example.com`; it does not authenticate or submit data.

## Linux sandbox

Sandboxing is required by default. If a Linux host blocks Chromium user namespaces/AppArmor, investigate first. Only with deliberate approval may you use:

```bash
"$work/install.sh" --adapter hermes --allow-no-sandbox --smoke-test
```

Never use the no-sandbox fallback for logins, secrets, payments, or untrusted sites.

## Releases and provenance

Each GitHub Release provides a universal source archive plus checksummed Linux/macOS runtime bundles. The source installer is the supported setup path; runtime bundles are intended for controlled distribution or CI integration.

- gstack source: `1.58.4.0` at `9fd03fae9e74f5daa7a138366aca8f86c7367c5c`
- Playwright: `1.61.1`
- Bun build tool: `1.2.10`

Read [installation details](docs/INSTALL.md), [security boundaries](docs/SECURITY.md), [agent guidance](AGENTS.md), and [third-party notices](THIRD_PARTY_NOTICES.md) before deployment.
