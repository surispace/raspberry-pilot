#!/bin/bash
. "$HOME/raspilot/python_env.sh"
cd "$RASPILOT_ROOT"
#pkill -f controlsd
sleep 5
"$RASPILOT_PYTHON" "$RASPILOT_ROOT/selfdrive/controls/controlsd.py"
sleep 10
bash "$RASPILOT_ROOT/fix_niceness.sh"