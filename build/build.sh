#!/bin/bash

set -e

KERNEL_DIR=kernel/linux
ZFS_DIR=zfs/zfs-git
CONFIG_FILE=config/kernel.config

# Kernel compil
echo "[*] Building kernel..."
cd "$KERNEL_DIR"
cp "../../$CONFIG_FILE" .config
make -j$(nproc)
make modules_install
make install

# ZFS Compil
echo "[*] Building ZFS..."
cd "../../$ZFS_DIR"
./autogen.sh
./configure --with-linux=$(realpath ../../$KERNEL_DIR)
make -j$(nproc)
sudo make install
sudo ldconfig

# Update initramfs
sudo mkinitcpio -P

echo "[*] Done."

