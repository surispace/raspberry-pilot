#!/bin/bash
. "$HOME/raspilot/python_env.sh"
cd "$RASPILOT_ROOT"
pkill -f controlsd
pkill -f pandad
pkill -f boardd
pkill -f ubloxd
pkill -f upload_files.py
taskset -a --cpu-list 0,1 "$RASPILOT_PYTHON" "$RASPILOT_ROOT/selfdrive/controls/controlsd.py" &
taskset -a --cpu-list 0,1 "$RASPILOT_PYTHON" "$RASPILOT_ROOT/selfdrive/pandad.py" > /dev/null 2>&1 &
#taskset -a --cpu-list 0,1 "$RASPILOT_ROOT/selfdrive/boardd/boardd" &
taskset -a --cpu-list 2,3 "$RASPILOT_ROOT/selfdrive/locationd/ubloxd" > /dev/null 2>&1 &
pkill -f dashboard
taskset -a --cpu-list 2,3 "$RASPILOT_PYTHON" "$RASPILOT_ROOT/dashboard.py" &
sleep 10
bash "$RASPILOT_ROOT/fix_niceness.sh"