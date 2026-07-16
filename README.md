# agent-headless-browser

Portable source package for a governed gstack-browse runtime on Linux x64, macOS Apple Silicon, and macOS Intel.

## Test on a host without Git

```bash
unzip agent-headless-browser-0.1.0-source.zip
cd agent-headless-browser-0.1.0
./install.sh --adapter hermes --smoke-test
```

The installer builds a native runtime from the vendored, pinned source archive. It does not contain a prebuilt runtime, Chromium, host path, hostname, credential, folder ID, or data URL.

If Linux sandbox preflight/browser launch fails, review the risk and rerun explicitly:

```bash
./install.sh --adapter hermes --allow-no-sandbox --smoke-test
```

`--allow-no-sandbox` is never the default. Do not use that mode for authenticated, sensitive, payment, or untrusted sites.

## Pi

```bash
./install.sh --adapter pi --smoke-test
```

Start a new Pi session, then use `/skill:agent-headless-browser`.

## Provenance

- gstack source: `1.58.4.0`, commit `9fd03fae9e74f5daa7a138366aca8f86c7367c5c`
- browser engine: Playwright `1.61.1`
- build tool: Bun `1.2.10`

See `docs/INSTALL.md` for prerequisites, install paths, Hermes/Pi usage, validation, and removal. See `docs/SECURITY.md`, `AGENTS.md`, and `THIRD_PARTY_NOTICES.md` before deployment. GitHub Actions builds platform-specific runtime bundles through `.github/workflows/build-runtime.yml`.
