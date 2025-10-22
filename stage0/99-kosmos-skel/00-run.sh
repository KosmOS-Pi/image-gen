#! /bin/bash

# Prepare user skeleton
install -m 755 -d                               "${ROOTFS_DIR}/etc/skel/.config/autostart"
install -m 755 -d                               "${ROOTFS_DIR}/etc/skel/Desktop"

install -m 644 files/skel/.config/*	            "${ROOTFS_DIR}/etc/skel/.config/"
install -m 644 files/skel/.config/autostart/*	"${ROOTFS_DIR}/etc/skel/.config/autostart"
install -m 755 files/skel/Desktop/*	            "${ROOTFS_DIR}/etc/skel/Desktop/"
install -m 644 files/skel/Desktop/.directory	"${ROOTFS_DIR}/etc/skel/Desktop/"
