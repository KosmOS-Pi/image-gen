#! /bin/bash

set -e

FLAG_DIR=/var/lib/kosmos-setup
IN_PROG_FILE="$FLAG_DIR/in-progress"
DONE_FILE="$FLAG_DIR/done"

echo "Adding KosmOS repositories."

# Add KosmOS repository and key
install -m 755 -d /etc/apt/sources.list.d/
install -m 755 -d /etc/apt/keyrings/

cat > /etc/apt/sources.list.d/kosmos.list << EOF
deb [signed-by=/etc/apt/keyrings/kosmos.gpg.asc] https://deb.kosmos-pi.org/bookworm/ bookworm main
deb [signed-by=/etc/apt/keyrings/kosmos.gpg.asc] https://deb.kosmos-pi.org/bookworm/ bookworm-old main
EOF

wget -O /etc/apt/keyrings/kosmos.gpg.asc https://deb.kosmos-pi.org/keys/kosmos.gpg.asc

echo "Installing packages..."
# Update repositories, upgrade and install packages
apt-get update
apt-get -y upgrade

DEBIAN_FRONTEND=noninteractive apt-get -yq \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold" \
  install xserver-xorg kde-standard realvnc-vnc-server astrophotography-all chromium kosmos-mods

echo "Last tweaks..."

# Enable VNC server and graphic desktop for the next reboots
systemctl enable vncserver-x11-serviced.service
systemctl set-default graphical.target

# Copy avatar to sddm system folder
MYUSER=$( getent passwd 1000 | cut -d: -f1 )
cp /home/$MYUSER/.face.icon /usr/share/sddm/faces/$MYUSER.face.icon

# Disable setup service and remove it
systemctl disable kosmos-setup.service
rm -f /etc/systemd/system/kosmos-setup.service 2> /dev/null || true
systemctl daemon-reload

# Remove setup-related scripts
rm -f /etc/NetworkManager/dispatcher.d/90-kosmos-retry-setup 2> /dev/null || true
rm -f /etc/profile.d/kosmos-setup-status.sh 2> /dev/null || true
rm -f /usr/local/bin/check-kosmos-setup 2> /dev/null || true

# Start the graphical interface and VNC server
echo "Completed: starting the desktop!"
systemctl isolate graphical.target
systemctl start vncserver-x11-serviced.service
