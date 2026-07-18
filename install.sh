#!/usr/bin/env bash
set -euo pipefail
PKG="$(cd "$(dirname "$0")" && pwd -P)"
VERSION=$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["version"])' "$PKG/PACKAGE_MANIFEST.json" 2>/dev/null || echo 0.1.0) GSTACK_COMMIT=9fd03fae9e74f5daa7a138366aca8f86c7367c5c BUN_VERSION=1.2.10
ROOT="$HOME/.local/share/agent-headless-browser" STATE="$HOME/.agent-headless-browser" BIN="$HOME/.local/bin" ADAPTER=none NO_SANDBOX=0 SMOKE=0
while (($#)); do case "$1" in
  --adapter) ADAPTER="$2"; shift 2;; --install-root) ROOT="$2"; shift 2;; --state-root) STATE="$2"; shift 2;; --bin-dir) BIN="$2"; shift 2;; --allow-no-sandbox) NO_SANDBOX=1; shift;; --smoke-test) SMOKE=1; shift;; --help) echo 'Usage: ./install.sh [--adapter hermes|pi|claude|codex|other|none] [--allow-no-sandbox] [--smoke-test]'; exit 0;; *) echo "Unknown option: $1" >&2; exit 2;; esac; done
case "$ADAPTER" in hermes|pi|claude|codex|other|none) ;; *) echo 'adapter must be hermes, pi, claude, codex, other, or none' >&2; exit 2;; esac
case "$(uname -s):$(uname -m)" in Linux:x86_64) bun_asset=bun-linux-x64.zip;; Darwin:arm64) bun_asset=bun-darwin-aarch64.zip;; *) echo "Unsupported platform: $(uname -s) $(uname -m); supported: Linux x64 and macOS Apple Silicon." >&2; exit 2;; esac
for c in curl tar python3 node; do command -v "$c" >/dev/null || { echo "Missing dependency: $c" >&2; exit 2; }; done
if command -v sha256sum >/dev/null; then
  sha256_check() { sha256sum -c -; }
  sha256_manifest() { xargs -0 sha256sum; }
elif command -v shasum >/dev/null; then
  sha256_check() { shasum -a 256 -c -; }
  sha256_manifest() { xargs -0 shasum -a 256; }
else
  echo "Missing dependency: sha256sum or shasum" >&2
  exit 2
fi
stage=$(mktemp -d); trap 'rm -rf "$stage"' EXIT
expected=6edd7d604ac335c43e3d729b3569d5c30645e04fc9209683c6319f9f718c64a0
printf '%s  %s\n' "$expected" "$PKG/vendor/gstack-browse-source.tar.gz" | sha256_check
mkdir -p "$stage/bun" "$stage/src" "$stage/runtime"
curl -fsSL --retry 3 --proto '=https' --tlsv1.2 -o "$stage/bun.zip" "https://github.com/oven-sh/bun/releases/download/bun-v$BUN_VERSION/$bun_asset"
python3 - "$stage/bun.zip" "$stage/bun" <<'PY'
import sys,zipfile
with zipfile.ZipFile(sys.argv[1]) as z:z.extractall(sys.argv[2])
PY
bun=$(find "$stage/bun" -type f -name bun -print -quit); chmod 755 "$bun"; test "$($bun --version)" = "$BUN_VERSION"; export PATH="$(dirname "$bun"):$PATH"
tar -xzf "$PKG/vendor/gstack-browse-source.tar.gz" -C "$stage/src" --strip-components=1
# Bun's compiled Linux client can expose CommonJS sharp through a nested default.
# Normalize both ESM and CJS shapes before the screenshot size guard calls it.
python3 - "$stage/src/browse/src/screenshot-size-guard.ts" <<'PY'
from pathlib import Path
p = Path(__import__('sys').argv[1])
s = p.read_text()
old = 'const sharp = sharpModule.default ?? sharpModule;'
new = 'const sharp = typeof sharpModule.default === "function" ? sharpModule.default : typeof sharpModule.default?.default === "function" ? sharpModule.default.default : sharpModule;'
if old not in s: raise SystemExit('expected sharp import line not found')
p.write_text(s.replace(old, new))
PY
# Do not inherit a host's npm registry mirror for package or browser artifacts.
export BUN_INSTALL_REGISTRY="${BUN_INSTALL_REGISTRY:-https://registry.npmjs.org}"
export npm_config_registry="$BUN_INSTALL_REGISTRY"
cd "$stage/src"; "$bun" install --frozen-lockfile --production >/dev/null; "$bun" add --exact playwright@1.61.1 >/dev/null
"$bun" build --compile browse/src/cli.ts --outfile "$stage/runtime/browse"; bash browse/scripts/build-node-server.sh >/dev/null
cp browse/dist/server-node.mjs browse/dist/bun-polyfill.cjs "$stage/runtime/"; printf '%s\n' "$GSTACK_COMMIT" > "$stage/runtime/.version"
mkdir -p "$stage/runtime/node_modules"; for p in playwright playwright-core diff sharp detect-libc semver; do cp -aL "node_modules/$p" "$stage/runtime/node_modules/"; done
cp -aL node_modules/@img "$stage/runtime/node_modules/@img"
# Do not inherit an npm registry mirror as Playwright's browser-download host.
# Callers may override this with an approved mirror explicitly.
PLAYWRIGHT_BROWSERS_PATH="$stage/runtime/browsers" PLAYWRIGHT_DOWNLOAD_HOST="${PLAYWRIGHT_DOWNLOAD_HOST:-https://cdn.playwright.dev}" "$bun" run ./node_modules/playwright/cli.js install chromium >/dev/null
chmod 755 "$stage/runtime/browse"
mkdir -p "$ROOT" "$BIN"; rm -rf "$ROOT/runtime"; mv "$stage/runtime" "$ROOT/runtime"; install -d -m 755 "$ROOT/scripts"; install -m 755 "$PKG/scripts/browser-wrapper.sh" "$ROOT/scripts/browser-wrapper.sh"; install -m 755 "$PKG/scripts/ensure-server.py" "$ROOT/scripts/ensure-server.py"
cat > "$BIN/agent-headless-browser" <<EOF
#!/usr/bin/env bash
export AGENT_BROWSE_ROOT="$ROOT"
export AGENT_BROWSE_STATE_ROOT="$STATE"
exec "$ROOT/scripts/browser-wrapper.sh" "\$@"
EOF
chmod 755 "$BIN/agent-headless-browser"; ((NO_SANDBOX)) && touch "$ROOT/NO_SANDBOX_APPROVED"
printf 'package_version=%s\ngstack_commit=%s\nbun=%s\nplaywright=1.61.1\n' "$VERSION" "$GSTACK_COMMIT" "$BUN_VERSION" > "$ROOT/VERSION"
(cd "$ROOT" && find . -type f -not -name SHA256SUMS -print0 | sort -z | sha256_manifest > SHA256SUMS)
case "$ADAPTER" in
  hermes)
    install -d "$HOME/.hermes/skills/agent-headless-browser"
    sed "s|@BIN@|$BIN/agent-headless-browser|g" "$PKG/adapters/hermes/SKILL.md" > "$HOME/.hermes/skills/agent-headless-browser/SKILL.md"
    ;;
  pi)
    install -d "$HOME/.agents/skills/agent-headless-browser"
    sed "s|@BIN@|$BIN/agent-headless-browser|g" "$PKG/adapters/pi/SKILL.md" > "$HOME/.agents/skills/agent-headless-browser/SKILL.md"
    ;;
  claude)
    install -d "$HOME/.claude/skills/agent-headless-browser"
    sed "s|@BIN@|$BIN/agent-headless-browser|g" "$PKG/adapters/claude/SKILL.md" > "$HOME/.claude/skills/agent-headless-browser/SKILL.md"
    ;;
  codex)
    install -d "$HOME/.agents/skills/agent-headless-browser-codex"
    sed "s|@BIN@|$BIN/agent-headless-browser|g" "$PKG/adapters/codex/SKILL.md" > "$HOME/.agents/skills/agent-headless-browser-codex/SKILL.md"
    ;;
  other)
    install -d "$HOME/.agents/skills/agent-headless-browser"
    sed "s|@BIN@|$BIN/agent-headless-browser|g" "$PKG/adapters/other/SKILL.md" > "$HOME/.agents/skills/agent-headless-browser/SKILL.md"
    ;;
  none) ;;
  *)
    echo 'adapter must be hermes, pi, claude, codex, other, or none' >&2
    exit 2
    ;;
esac
if ((SMOKE)); then "$BIN/agent-headless-browser" goto https://example.com >/dev/null; "$BIN/agent-headless-browser" snapshot -i >/dev/null; "$BIN/agent-headless-browser" stop; fi
echo "Installed: $BIN/agent-headless-browser"
