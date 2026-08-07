#!/bin/bash
. "$HOME/raspilot/python_env.sh"
cd "$RASPILOT_ROOT"
pkill -f pandad
pkill -f boardd
taskset -a --cpu-list 0,1 "$RASPILOT_PYTHON" "$RASPILOT_ROOT/selfdrive/pandad.py" &
#taskset -a --cpu-list 0,1 "$RASPILOT_ROOT/selfdrive/boardd/boardd" &
sleep 10
bash "$RASPILOT_ROOT/fix_niceness.sh"