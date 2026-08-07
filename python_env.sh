#!/bin/bash

RASPILOT_ROOT="${RASPILOT_ROOT:-$HOME/raspilot}"
RASPILOT_VENV="${RASPILOT_VENV:-$RASPILOT_ROOT/.venv}"
RASPILOT_PYTHON="${RASPILOT_PYTHON:-$RASPILOT_VENV/bin/python}"
RASPILOT_PIP="${RASPILOT_PIP:-$RASPILOT_VENV/bin/pip}"

if [ ! -x "$RASPILOT_PYTHON" ]; then
  echo "Missing Raspberry Pilot Python environment at $RASPILOT_PYTHON. Run start_install_tf.sh first." >&2
  return 1 2>/dev/null || exit 1
fi

case ":${PYTHONPATH:-}:" in
  *":$RASPILOT_ROOT:"*) ;;
  *) export PYTHONPATH="$RASPILOT_ROOT${PYTHONPATH:+:$PYTHONPATH}" ;;
esac

export RASPILOT_ROOT
export RASPILOT_VENV
export RASPILOT_PYTHON
export RASPILOT_PIP
export PATH="$RASPILOT_VENV/bin:$PATH"
