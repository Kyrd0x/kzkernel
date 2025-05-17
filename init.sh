#!/bin/sh

sudo pacman -S base-devel git bc kmod inetutils \
  libelf libusb lzop mkinitcpio \
  zstd cpio xmlto python-sphinx python-packaging \
  graphviz texlive-core \
  linux-headers \
  autoconf libtool gawk uuid-runtime


cd kernel
git clone --depth=1 https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git

cd ../zfs
git clone https://github.com/openzfs/zfs.git zfs-git
