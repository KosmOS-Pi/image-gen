#! /bin/bash

# Install SelfHotspost
install -m 755 -d                               "${ROOTFS_DIR}/etc/NetworkManager/system-connections/"
install -m 600 files/SelfHotspot.nmconnection   "${ROOTFS_DIR}/etc/NetworkManager/system-connections/"

install -m 755 -d                               "${ROOTFS_DIR}/etc/NetworkManager/conf.d/"
install -m 644 wifi-powersave-off.conf          "${ROOTFS_DIR}/etc/NetworkManager/conf.d/"

# Install KosmOS setup first-boot service
install -m 755 -d                               "${ROOTFS_DIR}/usr/local/bin"
install -m 755 files/kosmos-setup.sh            "${ROOTFS_DIR}/usr/local/bin/"

install -m 755 -d                               "${ROOTFS_DIR}/etc/systemd/system"
install -m 644 files/kosmos-setup.service       "${ROOTFS_DIR}/etc/systemd/system/"
ln -s /etc/systemd/system/kosmos-setup.service  "${ROOTFS_DIR}/etc/systemd/system/multi-user.target.wants/kosmos-setup.service"
touch                                           "${ROOTFS_DIR}/etc/trigger-kosmos-setup"

