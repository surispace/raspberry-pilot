#!/bin/bash
set -euo pipefail

. "$HOME/raspilot/python_env.sh"
cd "$RASPILOT_ROOT"

if [ -z "${RASPILOT_SKIP_SYSTEM_INTEGRATION:-}" ]; then
  sudo mkdir -p /data
  sudo mkdir -p /data/params
  sudo chown ubuntu /data
  sudo chown ubuntu /data/params
  sudo tee /etc/udev/rules.d/11-panda.rules <<EOF
SUBSYSTEM=="usb", ATTRS{idVendor}=="bbaa", ATTRS{idProduct}=="ddcc", MODE="0666"
SUBSYSTEM=="usb", ATTRS{idVendor}=="bbaa", ATTRS{idProduct}=="ddee", MODE="0666"
SUBSYSTEMS=="usb", ATTR{idVendor}=="bbaa", ATTR{idProduct}=="ddcc", MODE:="0666"
SUBSYSTEMS=="usb", ATTR{idVendor}=="bbaa", ATTR{idProduct}=="ddee", MODE:="0666"
EOF
  sudo udevadm control --reload-rules && sudo udevadm trigger

  #(crontab -l; echo "@reboot bash raspilot/launch_openpilot.sh";) | crontab -
  ansible-playbook "$RASPILOT_ROOT/crontab.yml"
  crontab -l
  #(sudo crontab -l; echo "@reboot sleep 60; bash /home/ubuntu/raspilot/fix_niceness.sh";) | sudo crontab -
  sudo crontab -l

  sudo cp "$RASPILOT_ROOT/phonelibs/btcmd.txt" /boot/firmware
  sudo cp "$RASPILOT_ROOT/phonelibs/usercfg.txt" /boot/firmware/usercfg.txt
  if [ -d /etc/influxdb ]; then
    sudo cp "$RASPILOT_ROOT/phonelibs/influxdb.conf" /etc/influxdb/influxdb.conf
  else
    echo "Skipping InfluxDB configuration because /etc/influxdb does not exist."
  fi
else
  echo "Skipping udev, cron, and boot firmware integration for validation environment."
fi

sudo bash "$RASPILOT_ROOT/phonelibs/install_capnp.sh"

#sudo chown -R 1000:1000 ~/raspilot/node-red
#sudo docker run -it --network host -v /home/ubuntu/raspilot/node-red:/data --name nodered-raspilot nodered/node-red

bash "$RASPILOT_ROOT/build_all.sh"

# update Ubuntu and clean up
echo "Updating Ubuntu and removing unneeded packages.."
#sudo apt full-upgrade -y
#sudo apt autoremove -y
#ansible localhost -v -b -m apt -a "upgrade=full"
#ansible localhost -v -b -m apt -a "autoremove=yes"
sudo apt --fix-broken install -y
sudo apt clean -y
