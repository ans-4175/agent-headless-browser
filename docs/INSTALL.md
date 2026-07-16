# Installation and operation

## What this package installs

The installer builds a native runtime for the current host and writes only to user-owned paths by default:

```text
~/.local/share/agent-headless-browser/   runtime and checksum manifest
~/.agent-headless-browser/               isolated browser profile and private state
~/.local/bin/agent-headless-browser      approved command entry point
```

With `--adapter hermes` it adds `~/.hermes/skills/agent-headless-browser/`. With `--adapter pi` it adds `~/.agents/skills/agent-headless-browser/`.

It does not alter system packages, browser profiles, permissions, IAM, network policy, or credentials. It downloads Bun, installs pinned JavaScript dependencies, and downloads a matching Chromium revision into the runtime.

## Prerequisites

- Linux x64, macOS Apple Silicon, or macOS Intel
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

## Manual commands

```bash
agent-headless-browser goto https://example.com
agent-headless-browser snapshot -i
agent-headless-browser screenshot /tmp/page.png
agent-headless-browser stop
```

`click`, `fill`, `select`, `type`, and `press` require an explicit approval workflow in the skill. The wrapper blocks cookies, profile import, arbitrary JavaScript, uploads, CDP, tunnels, and headed-browser mode.

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

To remove manually, stop the daemon and delete the three user-owned paths listed at the top plus the installed adapter directory. Never delete a state directory while an active browser daemon is running.
