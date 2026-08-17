# raspberry-pilot
Headless OpenPilot for Bosch and Nidec Honda's, running on Raspberry Pi 5 (Forked from [Gernby/raspberry-pilot](https://github.com/Gernby/raspberry-pilot))

Supports Bosch Hondas (2018+) as well as Nidec Hondas (e.g. Civic, CR-V, Accord, Pilot, Odyssey, Ridgeline, Acura ILX/RDX).

# Raspberry Pilot Installation Steps | raspberry-pilot
Requirements
------------

1.  A laptop capable of burning microSD cards and has a decent battery life (min. 30 minutes)
2.  Raspberry Pi 5 (8GB recommended)
3.  A Raspberry Pi Imager capable application, e.g. [Raspberry Pi Imager](https://www.raspberrypi.com/software/) (used to flash the image and pre-configure Ubuntu)
4.  Red Black, White or Gray from Comma.ai shop
5.  Honda Bosch Giraffe from Comma.ai shop if using a White or Gray Panda, Honda Bosch or Nidec harness for Black or Red Panda
6.  USB A-to-C cable ([This](https://www.amazon.com/Anker-2-Pack-Premium-Charging-Samsung/dp/B07DC5PPFV) two pack of 6-ft. cables is popular)
7.  USB A-to-A cable (like [this](https://www.amazon.com/gp/product/B0002MKBI2) one) or mini USB cable with a Panda Paw from the Comma.ai shop (for flashing White or Gray Pandas from the Pi)
8.  A way to power the Pi in your car (battery pack, laptop, or high power 12v power adapter for the car)
9.  Minimum 32GB A1-rated microSD card
10.  Optional Micro-HDMI adapter plus TV or monitor that accepts HDMI input 
11.  Optional USB keyboard
12.  A physical Ethernet connection is optional but works best during the install phase
13.  Cellular hotspot or home WiFi you can reach from your car (no cable company or retail WiFi)

MicroSD card preparation and first login
----------------------------------------

This project now targets the Raspberry Pi 5. Prepare your microSD card using the **Raspberry Pi Imager** application:

1.  Install and launch [Raspberry Pi Imager](https://www.raspberrypi.com/software/) on your laptop.
2.  Click **Choose OS** → scroll to **Other general-purpose OS** → **Ubuntu** → select the latest **Ubuntu Server 24.04.4 LTS (64-bit)** for Raspberry Pi.
3.  Click **Choose Storage** and select your microSD card.
4.  Before writing, click the gear icon (Advanced options) and enable:
    - **Set user name and password** → username `ubuntu`, password `ubuntu`
    - set hostname to pi5, enable SSH, and configure WiFi ahead of time.
5.  Click **Write** to flash the microSD card.
6.  Once written, the default login is username `ubuntu` / password `ubuntu`.


First boot
----------

1.  Safely unmount the microSD card. Do not proceed until you know you have safely unmounted.
2.  Remove the SD card adapter from the computer and remove the microSD card from the adapter
3.  Insert the microSD card into the Rasperry Pi 5 with the contacts facing “up” towards the bottom of the mainboard
4.  If you are using a local console, connect the keyboard, micro-HDMI adapter and the HDMI cable
5.  Connect the Ethernet cable if you do not have WiFi.
6.  Connect the Pi to a high-power USB port via the USB A-to-C cable.
7.  Allow the Pi to boot and wait at least two minutes. If you are using the console, wait for several lines of text to appear before attempting to log in.
8.  Locate the Pi IP address or use pi5.local in your home WiFi router or your laptop if you are using your laptop to provide a network connection to the Pi
9.  Log into the Pi using “ubuntu” for the username and the password
10.  Try to `ping 8.8.8.8`. If successful, continue to the next section. If not, reboot and log in again with ubuntu/ubuntu.

Software installation
---------------------

(Note: You must begin the install within about 5 minutes. If you boot up the Pi but don’t start the install relatively soon, the Pi will begin to update itself, preventing you from starting the install for about 20 minutes.)

1.  Log into the Pi using “ubuntu” as the ID and password if you are not still logged in from earlier steps. Clone the repository
```
git clone -b honda-support-pi5 https://github.com/surispace/raspberry-pilot.git
mv raspberry-pilot/start_install_tf.sh .
sh start_install_tf.sh
```
2.  Install should take about 30mins with high speed internet.
3.  If the process completes successfully, reboot the Pi and log back in as the “ubuntu” user
4.  Run the command `top -u ubuntu`
5.  Look for `controlsd`, `boardd`, `ubloxd`, `transcoderd`, and `dashboard` in the rightmost column of the list.
6.  If you see all five, next move to flash your Panda step, if fails check the logs and ask chatGPT

Red Panda USB permissions (udev rule)
--------------------------------------

Newer (pre-flashed) red pandas enumerate under comma's registered USB VID `3801` (older black/grey/white pandas use `bbaa`). The default `11-panda.rules` only grants `0666` access to the `bbaa` VID, so the red panda's device node stays `root:root` and `boardd` cannot open it after a reboot. Install a udev rule that also covers `3801`:

```
sudo cp /tmp/11-panda.rules /etc/udev/rules.d/11-panda.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

`/tmp/11-panda.rules` should contain:

```
SUBSYSTEM=="usb", ATTRS{idVendor}=="bbaa", ATTRS{idProduct}=="ddcc", MODE="0666"
SUBSYSTEM=="usb", ATTRS{idVendor}=="bbaa", ATTRS{idProduct}=="ddee", MODE="0666"
SUBSYSTEMS=="usb", ATTR{idVendor}=="bbaa", ATTR{idProduct}=="ddcc", MODE:="0666"
SUBSYSTEMS=="usb", ATTR{idVendor}=="bbaa", ATTR{idProduct}=="ddee", MODE:="0666"
SUBSYSTEM=="usb", ATTRS{idVendor}=="3801", ATTRS{idProduct}=="ddcc", MODE="0666"
SUBSYSTEMS=="usb", ATTR{idVendor}=="3801", ATTR{idProduct}=="ddcc", MODE:="0666"
```

Flashing the Panda
------------------

**Note: If you can’t hit your household WiFi from your car, be sure to configure the Pi to hit your cellular hotspot and turn on your hotspot before booting up the Pi in the car.**

Bring the Pi out the car. If you’re using a White or Gray Panda, be sure to also bring a separate power supply and USB A to A cable.

1.  For the Black or Red Panda, connect the Pi to the Black or Red Panda using the standard configuration (USB A on the Panda to USB C on the Pi)
2.  For the White or Gray Panda, connect the power supply to the Pi via the USB C port and connect the Pi to the Panda using the USB A to A cable
3.  Turn on the car
4.  SSH into the Pi
5.  Run `sudo sudo sh ~/raspilot/flash_panda.sh recover` for black/white/gray panda's
6.  Run `sudo sudo sh ~/raspilot/flash_redpanda.sh recover` for red panda
7.  Once the flash is successful, you may wish to reboot the Pi before going out for your first drive.

If you're using a White or Gray Panda, remember to unplug the power supply from the Pi and remove the USB A-to-A cable from the Pi and the Panda. Then connect the Pi to the Panda using the standard configuration (USB A in the Panda to USB C on the Pi). The USB A to A cable is not used under normal conditions.

All Panda LEDs should show a slow, pulsing indicator with one or more colors if the flash was successful. A fast green flashing LED means the update was not successfully completed and you need to try again. Once you’ve flashed the Panda, you are ready to calibrate and go for your first drive. If you are unable to flash the Panda or are not convinced that you have, come to Discord to discuss the issue.

First Drive and Training
------------------------

1.  With the Panda flashed and the Pi and Panda connected in the standard configuration, you should be ready to train the software and drive
2.  Turn on the car and watch the dash. The `ACC` and `LKAS` indicators should only appear Orange for a couple of seconds before turning Green.
3.  After about a minute, the lane marking indicators should light up but show as outlines. You do not need to wait for this to show up before driving.
4.  Drive to a road with well-marked lines on both sides of the car and with minimal curves and breaks in the lines – an interstate is preferred
5.  Drive the car on the interstate for about 5 miles. You must hold the wheel as steady as you can and hold the car in the center of the lane as much as possible. This training period is critical to the future performance of the software.
6.  After about 5 miles, Raspberry Pilot should take over steering automatically and without any input from you. If RP does not start steering, something went wrong and you need to keep your hands on the wheel until you can stop and troubleshoot.
7.  Keep your hands lightly brushing the wheel and be ready to take over if at any point you feel uncomfortable about the way the software is steering
8.  If you are completely uncomfortable, press the Lane Keeping Assist button beneath the “SET” button in the ACC cruise control section of the steering wheel to disable the Raspberry Pilot LKAS.
9.  On all subsequent drives, Raspberry Pilot will start steering the car about 75 seconds after turning on the car. Again, press the LKAS button any time you do not want this feature enabled.

Sanity Check
------------

Verify the Pi is talking to the red/black panda over USB by dumping the live health message that is published by `boardd` (which runs as part of `launch_openpilot.sh`). The `hwType` field should report `redPanda` (or the type of your panda), and at idle `started` should be `False` until the car's ignition is detected.

```bash
cd ~/raspilot && . ./python_env.sh && $RASPILOT_PYTHON -c "
import selfdrive.messaging as m
from selfdrive.services import service_list
from cereal import log
s = m.sub_sock(service_list['health'].port, conflate=True, timeout=2500)
ev = log.Event.from_bytes(s.recv())
h = ev.health
for f in dir(h):
    if f.startswith('_') or f in ('from_bytes','to_bytes','new_message'): continue
    try: print(f, '=', getattr(h, f))
    except: pass
"
```

If this times out or returns nothing, `boardd` is not connected to the panda. Check that the panda is present on USB (`lsusb | grep panda` should show `3801:ddcc comma.ai panda`), that the udev rule for the `3801` VID is installed, and that the Pi and the panda share a common ground with the car.

To see live CAN frames published by `boardd` (e.g., with the car on), subscribe to the `can` topic instead:

```bash
cd ~/raspilot && . ./python_env.sh && $RASPILOT_PYTHON -c "
import time
import selfdrive.messaging as m
from selfdrive.services import service_list
from cereal import log
s = m.sub_sock(service_list['can'].port, conflate=True, timeout=2500)
start = time.time(); total = 0
while time.time() - start < 10:
    try:
        ev = log.Event.from_bytes(s.recv())
        total += len(ev.can)
        for c in ev.can[:8]:
            print('addr=%X src=%d len=%d dat=%s' % (c.address, c.src, len(c.dat), bytes(c.dat).hex()))
    except Exception as e:
        print('no can msg for 2.5s:', type(e).__name__); break
print('TOTAL frames in 10s:', total)
"
```

Notes
-----

The ACC radar cruise control functionality is 100% stock; it remains engaged after a press of the gas and it disengages immediately upon a press of the brakes

Raspberry Pilot defaults to steering 100% of the time, even when the radar cruise (ACC) is not enabled. You may press the Lane Keeping Assist button on the steering wheel to toggle the LKAS functionality on and off at any time. It has a picture of a steering wheel centered between lane lines on a highway.

For setup on Pi4 - check documentation [here](https://gernby.github.io/raspberry-pilot/)

Until then, you can find more on my Discord server.
https://discord.gg/MMGCVh9

