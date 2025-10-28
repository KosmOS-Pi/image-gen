#! /bin/bash

# Install SelfHotspost
install -m 755 -d                               "${ROOTFS_DIR}/etc/NetworkManager/system-connections/"
install -m 600 files/SelfHotspot.nmconnection   "${ROOTFS_DIR}/etc/NetworkManager/system-connections/"

# Install config to disable wifi powersave
install -m 755 -d                               "${ROOTFS_DIR}/etc/NetworkManager/conf.d/"
install -m 644 files/wifi-powersave-off.conf    "${ROOTFS_DIR}/etc/NetworkManager/conf.d/"

# Install script to restart setup when network is up
install -m 755 -d                               "${ROOTFS_DIR}/etc/NetworkManager/dispatcher.d/"
install -m 755 files/90-kosmos-retry-setup      "${ROOTFS_DIR}/etc/NetworkManager/dispatcher.d/"

# Install KosmOS scripts and services to first-boot setup.
install -m 755 -d                               "${ROOTFS_DIR}/usr/local/bin"
install -m 755 -d                               "${ROOTFS_DIR}/etc/systemd/system"

# setup
install -m 755 files/kosmos-setup.sh            "${ROOTFS_DIR}/usr/local/bin/"
install -m 755 files/kosmos-setup-wrapper.sh    "${ROOTFS_DIR}/usr/local/bin/"
install -m 644 files/kosmos-setup.service       "${ROOTFS_DIR}/etc/systemd/system/"
ln -s /etc/systemd/system/kosmos-setup.service  "${ROOTFS_DIR}/etc/systemd/system/multi-user.target.wants/kosmos-setup.service"

# script-command to check setup process
install -m 755 files/check-kosmos-setup         "${ROOTFS_DIR}/usr/local/bin/"

# script to notify setup status to user at login
install -m 755 files/kosmos-setup-status.sh     "${ROOTFS_DIR}/etc/profile.d"
