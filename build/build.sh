#!/bin/bash
set -e

# Répertoires
KERNEL_DIR="kernel/linux"
ZFS_DIR="zfs/zfs-git"
CONFIG_FILE="config/kernel.config"

echo "[*] Étape 1 : Compilation du noyau"

cd "$KERNEL_DIR"

# Nettoyage propre du noyau
echo "[*] Nettoyage de l'environnement du noyau..."
make mrproper

# Appliquer la config utilisateur
echo "[*] Copie de la configuration du noyau..."
cp "../../$CONFIG_FILE" .config

# Mettre à jour la config pour cette version du noyau
echo "[*] Mise à jour de la configuration avec make olddefconfig..."
make olddefconfig

# Facultatif : nom personnalisé pour éviter d'écraser le noyau par défaut
echo "[*] Ajout d'un suffixe -zfs au noyau compilé..."
sed -i 's/^EXTRAVERSION =$/EXTRAVERSION = -zfs/' Makefile

# Compilation
echo "[*] Compilation du noyau (cela peut prendre un moment)..."
make -j$(nproc)
sudo make modules_install
sudo make install

# Sauvegarde de la config propre
echo "[*] Sauvegarde de la configuration mise à jour..."
cp .config "../../$CONFIG_FILE"

cd ../../

echo "[*] Étape 2 : Compilation de ZFS"

cd "$ZFS_DIR"

# Compilation ZFS
./autogen.sh
./configure --with-linux=$(realpath ../../$KERNEL_DIR)
make -j$(nproc)
sudo make install
sudo ldconfig

cd ../../

# Regénération de l'initramfs
echo "[*] Étape 3 : Regénération de l'initramfs..."
sudo mkinitcpio -P

# Mise à jour de GRUB
echo "[*] Étape 4 : Mise à jour de GRUB..."
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "[✓] Build terminé avec succès. Redémarre sur ton noyau custom (suffixe : -zfs)."
