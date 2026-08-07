#!/bin/bash
set -euo pipefail
# This must be run with the Raspberry Pilot virtual environment available.
. "$HOME/raspilot/python_env.sh"
cd "$RASPILOT_ROOT/cereal"
make
cd "$RASPILOT_ROOT/selfdrive/can"
make clean
PYTHONPATH="$RASPILOT_ROOT" make
cd "$RASPILOT_ROOT/selfdrive/boardd"
make clean
PYTHONPATH="$RASPILOT_ROOT" make
cd "$RASPILOT_ROOT/selfdrive/locationd"
make clean
PYTHONPATH="$RASPILOT_ROOT" make
