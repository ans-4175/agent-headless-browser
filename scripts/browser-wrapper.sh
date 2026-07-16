#!/usr/bin/env bash
set -euo pipefail
ROOT="${AGENT_BROWSE_ROOT:?Set AGENT_BROWSE_ROOT via installed launcher}"
RUNTIME="$ROOT/runtime"
STATE="${AGENT_BROWSE_STATE_ROOT:-$HOME/.agent-headless-browser}"
B="$RUNTIME/browse"; ENSURE="$ROOT/scripts/ensure-server.py"
test -x "$B" && test -f "$RUNTIME/server-node.mjs" || { echo "ERROR: runtime missing at $RUNTIME" >&2; exit 2; }
mkdir -p "$STATE/chromium-profile"; chmod 700 "$STATE" "$STATE/chromium-profile"
export AGENT_BROWSE_RUNTIME_ROOT="$RUNTIME" GSTACK_HOME="$STATE" CHROMIUM_PROFILE="$STATE/chromium-profile" GSTACK_TELEMETRY_OFF=1 BROWSE_PARENT_PID=0 BROWSE_STATE_FILE="$STATE/browse.json" BROWSE_SERVER_SCRIPT="$RUNTIME/server-node.mjs" PLAYWRIGHT_BROWSERS_PATH="$RUNTIME/browsers"
[[ -f "$ROOT/NO_SANDBOX_APPROVED" ]] && export GSTACK_CHROMIUM_NO_SANDBOX=1
cmd="${1:-}"
case "$cmd" in
  start|goto|back|forward|reload|url|text|html|links|forms|accessibility|snapshot|tabs|tab|newtab|closetab|wait|viewport|scroll|hover|screenshot|pdf|responsive|console|network|dialog|status|stop|click|fill|select|type|press|dialog-accept|dialog-dismiss) ;;
  ""|help|--help|-h) exec "$B" --help ;;
  cookie*|storage|header|useragent|js|eval|upload|connect|pair|tunnel|skill|load-html) echo "ERROR: '$cmd' is blocked by the safety wrapper." >&2; exit 2 ;;
  *) echo "ERROR: unapproved command '$cmd'." >&2; exit 2 ;;
esac
if [[ "$cmd" == start ]]; then python3 "$ENSURE"; exec "$B" status; fi
if [[ "$cmd" == stop ]]; then set +e; "$B" stop >/dev/null 2>&1; code=$?; set -e; [[ ! -e "$BROWSE_STATE_FILE" ]] && exit 0; exit "$code"; fi
python3 "$ENSURE"
exec "$B" "$@"
