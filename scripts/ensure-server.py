#!/usr/bin/env python3
"""Run the isolated browser daemon outside a short-lived agent shell."""
from __future__ import annotations
import json, os, subprocess, sys, time, urllib.request
from pathlib import Path

state = Path(os.environ["BROWSE_STATE_FILE"])
runtime = Path(os.environ["AGENT_BROWSE_RUNTIME_ROOT"])
server = runtime / "server-node.mjs"

def healthy() -> bool:
    try:
        data = json.loads(state.read_text())
        os.kill(int(data["pid"]), 0)
        with urllib.request.urlopen(f"http://127.0.0.1:{int(data['port'])}/health", timeout=.5) as r:
            return r.status == 200
    except (OSError, ValueError, KeyError, json.JSONDecodeError, urllib.error.URLError):
        return False

if healthy(): raise SystemExit(0)
state.unlink(missing_ok=True)
state.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
os.chmod(state.parent, 0o700)
log = state.parent / "server.log"
env = os.environ.copy(); env["BROWSE_PARENT_PID"] = "0"
with log.open("a") as out:
    os.chmod(log, 0o600)
    subprocess.Popen([os.environ.get("AGENT_BROWSE_NODE", "node"), str(server)], cwd=state.parent, env=env, stdin=subprocess.DEVNULL, stdout=out, stderr=out, start_new_session=True, close_fds=True)
for _ in range(40):
    if healthy(): raise SystemExit(0)
    time.sleep(.25)
print("ERROR: browser daemon did not become healthy; inspect private server.log.", file=sys.stderr)
raise SystemExit(2)
