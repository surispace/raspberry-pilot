#!/bin/bash
. "$HOME/raspilot/python_env.sh"
cd "$RASPILOT_ROOT"
pkill -f transcoderd
pkill -f controlsd
pkill -f pandad
pkill -f boardd
pkill -f ubloxd
pkill -f dashboard
sleep 15
taskset -a --cpu-list 2,3 "$RASPILOT_PYTHON" "$RASPILOT_ROOT/selfdrive/controls/transcoderd.py" &
taskset -a --cpu-list 0,1 "$RASPILOT_PYTHON" "$RASPILOT_ROOT/selfdrive/pandad.py" &
#taskset -a --cpu-list 0,1 "$RASPILOT_ROOT/selfdrive/boardd/boardd" &
taskset -a --cpu-list 0,1 "$RASPILOT_PYTHON" "$RASPILOT_ROOT/selfdrive/controls/controlsd.py" &
taskset -a --cpu-list 2,3 "$RASPILOT_ROOT/selfdrive/locationd/ubloxd" &
#sleep 15
taskset -a --cpu-list 2,3 "$RASPILOT_PYTHON" "$RASPILOT_ROOT/dashboard.py" &
