# Installation and operation

## Release setup

Pick a release tag and adapter without relying on an extracted directory name:

```bash
# Resolves to the latest published release tag. Pin to a specific tag
# (e.g. VERSION=v0.1.9) if you need a fixed version.
VERSION=$(curl -fsSL -o /dev/null -w '%{url_effective}' \
  https://github.com/ans-4175/agent-headless-browser/releases/latest \
  | sed 's#.*/tag/##')
ADAPTER=hermes # or pi, claude, codex, other, none
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
curl -fsSL "https://github.com/ans-4175/agent-headless-browser/archive/refs/tags/${VERSION}.tar.gz" \
  | tar -xz -C "$work" --strip-components=1
chmod +x "$work/install.sh"
"$work/install.sh" --adapter "$ADAPTER" --smoke-test
```

The GitHub Release runtime artifacts are checksummed payloads for controlled distribution. For normal setup, use this source installer so the wrapper, adapter, policy, and platform-native build remain aligned.

## What this package installs

The installer builds a native runtime for the current host and writes only to user-owned paths by default:

```text
~/.local/share/agent-headless-browser/   runtime and checksum manifest
~/.agent-headless-browser/               isolated browser profile and private state
~/.local/bin/agent-headless-browser      approved command entry point
```

The installer can add one adapter:

```text
hermes  ~/.hermes/skills/agent-headless-browser/
pi      ~/.agents/skills/agent-headless-browser/
claude  ~/.claude/skills/agent-headless-browser/
codex   ~/.agents/skills/agent-headless-browser-codex/
other   ~/.agents/skills/agent-headless-browser/
```

Use `--adapter none` to install only the runtime. It does not install the agent-side approval policy, so add an equivalent reviewed policy before giving another agent access to the command.

It does not alter system packages, browser profiles, permissions, IAM, network policy, or credentials. It downloads Bun, installs pinned JavaScript dependencies, and downloads a matching Chromium revision into the runtime.

## Prerequisites

- Linux x64 or macOS Apple Silicon
- `curl`, `tar`, `python3`, `node`, and either `sha256sum` or macOS `shasum`
- outbound HTTPS access to Bun, npm, and Playwright artifact hosts
- free disk space for Chromium (roughly 1 GB during build)

## Hermes install

```bash
./install.sh --adapter hermes --smoke-test
```

Start a fresh Hermes session and request headless-browser QA. The skill uses the installed wrapper, not a direct browser binary.

## Pi install

```bash
./install.sh --adapter pi --smoke-test
```

Start a fresh Pi session and invoke:

```text
/skill:agent-headless-browser
```

## Claude Code install

```bash
./install.sh --adapter claude --smoke-test
```

Start a fresh Claude Code session so it discovers `~/.claude/skills/agent-headless-browser/`.

## Codex install

```bash
./install.sh --adapter codex --smoke-test
```

Start a fresh Codex session so it discovers `~/.agents/skills/agent-headless-browser-codex/`. The Codex skill uses a separate directory so it can coexist with the Pi adapter.

## Generic Agent Skills host install

```bash
./install.sh --adapter other --smoke-test
```

Use this only for a host that discovers user skills from `~/.agents/skills/`. It writes `~/.agents/skills/agent-headless-browser/`, the same path used by the Pi adapter; installing one replaces the other. The policy is generic and follows the same explicit-approval rules.

## Manual commands

```bash
agent-headless-browser goto https://example.com
agent-headless-browser snapshot -i
agent-headless-browser screenshot /tmp/page.png
agent-headless-browser stop
```

`click`, `fill`, `select`, `type`, and `press` require an explicit approval workflow in every installed adapter. With `--adapter none`, the operator must provide and enforce that policy. The wrapper blocks cookies, profile import, arbitrary JavaScript, uploads, CDP, tunnels, and headed-browser mode.

## Linux sandbox

The installer does not disable Chromium sandboxing. If the smoke test reports an unavailable sandbox, investigate host user namespaces/AppArmor first. Only after deliberate approval may you rerun with:

```bash
./install.sh --adapter hermes --allow-no-sandbox --smoke-test
```

That fallback must not be used for logins, secrets, payments, or untrusted websites.

## Validate or remove

```bash
~/.local/share/agent-headless-browser/SHA256SUMS
agent-headless-browser status
agent-headless-browser stop
```

To remove manually, stop the daemon and delete the three user-owned paths listed at the top plus the selected adapter directory. Never delete a state directory while an active browser daemon is running.
