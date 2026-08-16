#!/bin/bash
set -euo pipefail

# User instructions
# Start with a brand new ubuntu install on SD card
# plug in an Ethernet cable or get the WiFi working
# ssh or log into the Pi on a local console

# log into the pi
# git clone https://github.com/Gernby/raspberry-pilot.git
# mv ~/raspberry-pilot/start_install_tf.sh ~
# sh start_install_tf.sh

# check back periodically. should take just under 4 hours

# every so often, please upload data logs for analysis using this command
# cd ~/raspilot && PYTHONPATH=~/raspilot .venv/bin/python upload_files.py

# --- Install script starts here ---

# disable unattended upgrades right away
#ansible localhost -b -m apt -a "name=unattended-upgrades state=absent"
sudo apt remove -y unattended-upgrades

# Install Ansible to support the future direction
sudo apt update
sudo apt install -y ansible-core

# kill any previously running raspilot processes for a clean install
echo "Stopping running raspilot processes.."
pkill -f 'raspilot' || true
pkill -f 'transcoderd' || true
pkill -f 'controlsd' || true
pkill -f 'pandad' || true
pkill -f 'boardd' || true
pkill -f 'ubloxd' || true
pkill -f 'dashboard' || true
sleep 2

# rename the folder
cd ~
if [ -d ~/raspberry-pilot ] && [ ! -e ~/raspilot ]; then
  mv ~/raspberry-pilot ~/raspilot
fi
cd ~/raspilot

# Add grafana signing key and repository
# sudo apt-key add grafana.gpg.key
# sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

#echo "Install grafana gpg signing key..."
#ansible localhost -v -b -m apt_key -a "file=/home/ubuntu/raspilot/grafana.gpg.key"

#echo "Add grafana repo..."
#ansible localhost -v -b -m apt_repository -a "repo='deb https://packages.grafana.com/oss/deb stable main'"

#echo "Install grafana server.."
#ansible localhost -v -b -m apt -a "name=grafana update_cache=yes"
# sudo apt install grafana -y

# update software from repository
sudo apt update

# Install Network Manager
# sudo apt install network-manager -y && sudo service NetworkManager start

echo "Installing Network Manager for better WiFi management.."
if [ -z "${RASPILOT_SKIP_NETWORK_SETUP:-}" ]; then
  sudo apt install -y network-manager
else
  echo "Skipping NetworkManager install for validation environment."
fi
  
echo "Starting Network Manager.."
if [ -z "${RASPILOT_SKIP_NETWORK_SETUP:-}" ]; then
  sudo systemctl enable --now NetworkManager
else
  echo "Skipping NetworkManager startup for validation environment."
fi

# force rescan of the available wifi networks
# sudo nmcli dev wifi rescan

# connect to Wifi (these are optional parameters and won't block the script from running)
if [ -n "${RASPILOT_SKIP_NETWORK_SETUP:-}" ]; then
  echo "Skipping WiFi connection for validation environment."
elif [ -n "${1:-}" ] && [ -n "${2:-}" ]; then
  sudo nmcli d wifi connect "$1" password "$2"
else
  echo "Skipping WiFi connection because SSID/password were not provided."
fi

# install dependencies
echo "Installing dependencies.."
sudo apt install -y build-essential make python3-pip python3-dev python3-venv python3-setuptools python3-wheel python-is-python3 libzmq3-dev python3-zmq
sudo apt install -y openjdk-17-jdk automake zip unzip libtool swig libpng-dev pkg-config
sudo apt install -y libhdf5-dev clang libarchive-dev
sudo apt install -y libssl-dev libswscale-dev libffi-dev
sudo apt install -y libusb-1.0-0 libusb-1.0-0-dev ocl-icd-libopencl1 ocl-icd-opencl-dev
sudo apt install -y opencl-headers checkinstall
sudo apt install -y libatlas-base-dev libopenblas-dev gfortran
sudo apt install -y capnproto libcapnp-dev uuid-dev libsodium-dev valgrind
sudo apt install -y libusb-dev cmake libnewlib-arm-none-eabi libhdf5-serial-dev hdf5-tools smbclient
sudo apt install -y adduser dfu-util jq
if apt-cache show influxdb >/dev/null 2>&1 && apt-cache show influxdb-client >/dev/null 2>&1; then
  sudo apt install -y influxdb influxdb-client
else
  echo "Skipping influxdb packages because they are unavailable in the current apt sources."
fi
# already installed:
# autoconf automake zlib1g-dev bzip2 git libffi-dev libglib2.0-0 libzmq5-dev wget gcc autotools-dev libfontconfig1 software-properties-common

# Ansible version for the future
#ansible localhost -b -m apt -a "name=build-essential,make,automake,python3.7-dev,python3-pip,libzmq3-dev,python3-zmq"
#ansible localhost -b -m apt -a "name=openjdk-8-jdk,automake,zip,unzip,libtool,swig,libpng-dev,pkg-config"
#ansible localhost -b -m apt -a "name=libhdf5-dev,clang,libarchive-dev"
#ansible localhost -b -m apt -a "name=libssl-dev,libswscale-dev"
#ansible localhost -b -m apt -a "name=libusb-1.0-0,libusb-1.0-0-dev,ocl-icd-libopencl1,ocl-icd-opencl-dev"
#ansible localhost -b -m apt -a "name=opencl-headers,checkinstall"
#ansible localhost -b -m apt -a "name=libatlas-base-dev,libopenblas-base,libopenblas-dev,gfortran"
#ansible localhost -b -m apt -a "name=capnproto,uuid-dev,libsodium-dev,valgrind"
#ansible localhost -b -m apt -a "name=libusb-dev,cmake,libnewlib-arm-none-eabi,libhdf5-serial-dev,hdf5-tools,smbclient"
#ansible localhost -b -m apt -a "name=influxdb,influxdb-client,apt-transport-https,adduser,dfu-util,jq"
# already installed:
# autoconf automake zlib1g-dev bzip2 git libffi-dev libglib2.0-0 libzmq5-dev wget gcc autotools-dev libfontconfig1 software-properties-common

# create the project-local Python environment
echo "Creating the Raspberry Pilot virtual environment.."
python3 -m venv ~/raspilot/.venv
. ~/raspilot/python_env.sh

# start grafana and influxdb (installed but temporarily disabled to reduce resource usage)
if [ -z "${RASPILOT_SKIP_SERVICE_RELOAD:-}" ]; then
  sudo /bin/systemctl daemon-reload
else
  echo "Skipping systemd daemon-reload for validation environment."
fi
# sudo /bin/systemctl enable grafana-server
# sudo /bin/systemctl enable infuxdb
# sudo service influxdb start
# sudo service grafana-server start
# ansible localhost -b -m service -a "name=grafana-server enabled=yes"
# ansible localhost -b -m service -a "name=grafana-server state=started"
# ansible localhost -b -m service -a "name=influxdb enabled=yes"
# ansible localhost -b -m service -a "name=influxdb state=started"

# Install the TensorFlow 2.3 components and dependencies
#wget https://github.com/lhelontra/tensorflow-on-arm/releases/download/v2.3.0/tensorflow-2.3.0-cp37-none-linux_aarch64.whl
"$RASPILOT_PIP" install -U pip setuptools wheel
#python3 -m pip install tensorflow-2.3.0-cp37-none-linux_aarch64.whl
"$RASPILOT_PIP" install \
  atomicwrites \
  cffi \
  cython \
  libusb1 \
  numpy \
  onnxruntime \
  pkgconfig \
  psutil \
  pycapnp==0.6.4 \
  pycryptodome \
  pyjwt \
  pyserial \
  PyYAML \
  pyzmq \
  raven \
  requests \
  scikit-learn \
  setproctitle \
  smbus2

# Create folders for storing various hdf5 files; supports switching models via remote ssh commands (DEPRECATED)
mkdir -p ~/buttons/model-1
mkdir -p ~/buttons/model-2
mkdir -p ~/buttons/model-3
mkdir -p ~/buttons/model-4

# restore ~/raspilot/models
mkdir -p ~/raspilot/models

# Kick off the final stage of the build
bash ~/raspilot/finish_install.sh

echo "Please reboot, run top -u ubuntu, and look for boardd, dashboard, ubloxd and controlsd"
