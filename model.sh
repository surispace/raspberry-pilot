#!/bin/bash
. "$HOME/raspilot/python_env.sh"
cd "$RASPILOT_ROOT"
pkill -f transcoderd
"$RASPILOT_PYTHON" "$RASPILOT_ROOT/selfdrive/controls/transcoderd.py" &
bash "$RASPILOT_ROOT/controls.sh" &
#sleep 8
#bash ~/raspilot/fix_niceness.sh