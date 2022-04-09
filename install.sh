#!/bin/bash

! [ -f "install-finish.sh" ] && curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/files/install-finish.sh > install-finish.sh

INSTALL_FILES=("prompt" "bootstrap" "kernel" "base-settings")
for FILE in ${INSTALL_FILES[@]} ; do
  ! [ -f "install-$FILE.sh" ] && curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/files/install-$FILE.sh > install-$FILE.sh
done
for FILE in ${INSTALL_FILES[@]} ; do
  source install-$FILE.sh
  [ $? != 0 ] && exit 1
done

CHROOT_INSTALL_FILES=("test")
for FILE in ${CHROOT_INSTALL_FILES[@]} ; do
  ! [ -f "install-$FILE.sh" ] && curl -sL https://raw.githubusercontent.com/mortyr45/fulcrum-arch/master/files/install-chroot-$FILE.sh > /mnt/$FILE.sh
  [ $? != 0 ] && exit 1
  chmod +x /mnt/$FILE.sh
done

arch-chroot /mnt

source install-finish.sh
