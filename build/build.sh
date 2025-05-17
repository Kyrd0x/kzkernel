#!/bin/bash
set -e

# Répertoires
KERNEL_DIR="kernel/linux"
ZFS_DIR="zfs/zfs-git"
CONFIG_FILE="config/kernel.config"

echo "[*] Étape 1 : Compilation du noyau"

cd "$KERNEL_DIR"

# 1. Appliquer la config
echo "[*] Copie de la configuration du noyau..."
cp "../../$CONFIG_FILE" .config

# 2. Compléter les nouvelles options automatiquement
echo "[*] Mise à jour de la config avec make olddefconfig..."
make olddefconfig

# 3. Compilation
echo "[*] Compilation du noyau (cela peut prendre un moment)..."
make -j$(nproc)
sudo make modules_install
sudo make install

# 4. Sauvegarde de la config utilisée
echo "[*] Sauvegarde de la config mise à jour..."
cp .config "../../$CONFIG_FILE"

cd ../../

echo "[*] Étape 2 : Compilation de ZFS"

cd "$ZFS_DIR"

# 5. Compilation ZFS
./autogen.sh
./configure --with-linux=$(realpath ../../$KERNEL_DIR)
make -j$(nproc)
sudo make install
sudo ldconfig

cd ../../

# 6. Regénération initramfs
echo "[*] Étape 3 : Regénération de l'initramfs..."
sudo mkinitcpio -P

echo "[✓] Build terminé avec succès. Redémarre sur ton nouveau noyau."
