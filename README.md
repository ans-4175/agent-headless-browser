# agent-headless-browser

A governed, isolated headless Chromium runtime for **Hermes** and **Pi**. It supports Linux x64 and macOS Apple Silicon, uses a fresh profile, and exposes only an approved browser-command surface.

It blocks cookie/profile import, arbitrary JavaScript, custom headers, uploads, CDP, tunnels, and headed mode. Browser interactions that can cause external effects remain subject to the installed skill's approval rules.

## Install from the latest release

The release source archive is the recommended setup path. It has the installer, policy, adapters, and pinned gstack source; it builds the native runtime on the target host.

### Hermes

```bash
VERSION=v0.1.6 # replace with the release tag you want
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
curl -fsSL "https://github.com/ans-4175/agent-headless-browser/archive/refs/tags/${VERSION}.tar.gz" \
  | tar -xz -C "$work" --strip-components=1
chmod +x "$work/install.sh"
"$work/install.sh" --adapter hermes --smoke-test
```

### Pi

```bash
VERSION=v0.1.6 # replace with the release tag you want
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
