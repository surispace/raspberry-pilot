#!/bin/bash
. "$HOME/raspilot/python_env.sh"
cd "$RASPILOT_ROOT"
pkill -f dashboard
taskset -a --cpu-list 2,3 "$RASPILOT_PYTHON" "$RASPILOT_ROOT/dashboard.py" &
