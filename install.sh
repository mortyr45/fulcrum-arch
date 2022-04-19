#!/bin/bash

INSTALL_FILES=("prompt" "bootstrap" "kernel" "base-settings" "finish")
for FILE in ${INSTALL_FILES[@]} ; do
  ! [ -f "install-$FILE.sh" ] && curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/files/installer/$FILE.sh > install-$FILE.sh
done
for FILE in ${INSTALL_FILES[@]} ; do
  source install-$FILE.sh
  [ $? != 0 ] && exit 1
done

CHROOT_INSTALL_FILES=("de-gnome" "flatpaks" "katsuo-repo" "chaotic-aur" "test")
for FILE in ${CHROOT_INSTALL_FILES[@]} ; do
  ! [ -f "install-$FILE.sh" ] && curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/files/scripts/$FILE.sh > /mnt/root/fulos-$FILE.sh
  [ $? != 0 ] && exit 1
  chmod +x /mnt/root/fulos-$FILE.sh
done

arch-chroot /mnt

source install-finish.sh
