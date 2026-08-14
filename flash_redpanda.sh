#!/bin/bash
set -e

echo ""
echo ""
echo -e "\e[44m***** This flashes a Red Panda (STM32H7) using the redpanda/board tooling\e[0m"
echo -e "\e[44m***** The Red Panda can be flashed with a single USB cable (Panda USB-A to Pi USB-C)\e[0m"
echo ""
echo ""
echo -e "\e[44m***** If reflashing, please disconnect the Red Panda from the Pi now, then reconnect when prompted.\e[0m"
sleep 5
echo " Plug in the panda in 5 seconds!"
sleep 1
echo " Plug in the panda in 4 seconds!"
sleep 1
echo " Plug in the panda in 3 seconds!"
sleep 1
echo " Plug in the panda in 2 seconds!"
sleep 1
echo " Plug in the panda in 1 seconds!"
sleep 1
echo " Plug in the panda NOW!"
sleep 2
echo ""

pkill -f boardd || true

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REDPANDA_DIR="$REPO_DIR/redpanda"

if [[ ! -d "$REDPANDA_DIR/.venv" ]]; then
  echo -e "\e[44m***** Red panda environment not found, setting it up...\e[0m"
  bash "$REDPANDA_DIR/setup.sh"
fi

source "$REDPANDA_DIR/.venv/bin/activate"
cd "$REDPANDA_DIR/board"

if [[ "$1" == "recover" ]]; then
  echo -e "\e[44m***** Recover mode: flashing bootstub\e[0m"
  ./recover.py
else
  echo -e "\e[44m***** Flashing application\e[0m"
  ./flash.py
fi

echo ""
echo ""
echo -e "\e[44m***** If the panda is now flashing slowly, it was successful\e[0m"
echo ""
echo -e "\e[44m***** If not, try running this again using the 'recover' option\e[0m"
echo -e "       \e[44mie. bash flash_redpanda.sh recover\e[0m"
echo ""
