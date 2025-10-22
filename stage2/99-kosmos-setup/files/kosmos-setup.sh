#! /bin/bash

set -e

# Wait for network
for i in {1..10}; do
    if ping -c1 8.8.8.8 &>/dev/null; then
        echo "Network is up: proceed!"
        break
    else
        echo "Network is down: retrying in 10 seconds... ($i/10)"
        sleep 10
    fi
done

# Update repositories, upgrade and install packages
apt-get update
apt-get -y upgrade

apt-get -y install -y xserver-xorg lightdm kde-standard realvnc-vnc-server kstars phd2 chromium

# get the chosen username
MYUSER=$( getent passwd 1000 | cut -d: -f1 )

mv /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.dist
cat > /etc/lightdm/lightdm.conf << EOF
[LightDM]

[Seat:*]
autologin-user=$MYUSER
autologin-user-timeout=0

[XDMCPServer]

[VNCServer]

EOF

# Prepare for LightDM, VNC and graphic desktop
systemctl disable sddm
systemctl enable lightdm
systemctl enable vncserver-x11-serviced.service
systemctl set-default graphical.target

# Do a first lightdm start to initialize state
systemctl start lightdm
sleep 10
systemctl stop lightdm

# Clear our flag so to not run again
rm -f /etc/trigger-kosmos-setup

# Reboot the system
reboot
