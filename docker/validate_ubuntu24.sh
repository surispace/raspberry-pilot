#!/bin/bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
  exec sudo -u ubuntu -H bash "$0"
fi

cd "$HOME"
export RASPILOT_SKIP_SYSTEM_INTEGRATION=1
export RASPILOT_SKIP_NETWORK_SETUP=1
export RASPILOT_SKIP_SERVICE_RELOAD=1

if [ ! -d "$HOME/raspilot" ]; then
  mv "$HOME/raspberry-pilot" "$HOME/raspilot"
fi

cd "$HOME/raspilot"
bash start_install_tf.sh

. "$HOME/raspilot/python_env.sh"
"$RASPILOT_PYTHON" -m py_compile \
  selfdrive/manager.py \
  selfdrive/pandad.py \
  selfdrive/controls/transcoderd.py \
  selfdrive/thermald.py \
  upload_files.py

echo "Ubuntu 24 arm64 migration validation completed successfully."

