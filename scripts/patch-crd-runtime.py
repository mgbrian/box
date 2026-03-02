#!/usr/bin/env python3

"""
Ensure chrome-remote-desktop always has an XDG runtime dir so PipeWire sockets
use an absolute path at runtime, not a username baked in at image build time.
"""

from pathlib import Path


target = Path("/opt/google/chrome-remote-desktop/chrome-remote-desktop")
text = target.read_text()

marker = "def _init_child_env(self):\n"
inject = (
    "    # Ensure a runtime dir exists so PipeWire sockets land in an absolute path\n"
    "    if not os.environ.get(\"XDG_RUNTIME_DIR\"):\n"
    "        os.environ[\"XDG_RUNTIME_DIR\"] = f\"/tmp/runtime-{os.environ.get('USER') or getpass.getuser()}\"\n"
)

if marker not in text:
    raise SystemExit("_init_child_env not found in chrome-remote-desktop")

if inject not in text:
    target.write_text(text.replace(marker, marker + inject))
