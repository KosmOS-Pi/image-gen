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

# Add KosmOS repository and key
install -m 755 -d /etc/apt/sources.list.d/
install -m 755 -d /etc/apt/keyrings/

cat > /etc/apt/sources.list.d/kosmos.list << EOF
deb [signed-by=/etc/apt/keyrings/kosmos.gpg.asc] https://deb.kosmos-pi.org/bookworm/ bookworm main
deb [signed-by=/etc/apt/keyrings/kosmos.gpg.asc] https://deb.kosmos-pi.org/bookworm/ bookworm-old main
EOF

wget -O /etc/apt/keyrings/kosmos.gpg.asc https://deb.kosmos-pi.org/keys/kosmos.gpg.asc

# Update repositories, upgrade and install packages
apt-get update
apt-get -y upgrade

apt-get -y install -y xserver-xorg lightdm kde-standard realvnc-vnc-server kstars phd2 chromium kosmos-mods

# get the chosen username
MYUSER=$( getent passwd 1000 | cut -d: -f1 )

# Setup lightdm
mv /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.dist
cat > /etc/lightdm/lightdm.conf << EOF
[LightDM]

[Seat:*]
autologin-user=$MYUSER
autologin-user-timeout=0
autologin-session=plasma

[XDMCPServer]

[VNCServer]

EOF

# Setup lightdm greeter
mv /etc/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf.dist
cat > /etc/lightdm/lightdm-gtk-greeter.conf << EOF
[greeter]
background=#1F0000
EOF

# Prepare for LightDM, VNC and graphic desktop
systemctl disable sddm
systemctl enable lightdm
systemctl enable vncserver-x11-serviced.service
systemctl set-default graphical.target

# Clear our flag so to not run again
rm -f /etc/trigger-kosmos-setup

# Reboot the system
reboot
