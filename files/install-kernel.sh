#!/bin/bash

clear
printf "Which kernel(s) would you like to install?\n1) linux\n2) linux-lts\n3) linux-hardened\n4) linux-zen\n"
echo -n "Choose multiple of them, by separating the numbers with a ','[1]: "
read;
if [ -z $REPLY ] ; then
  TEMP+=" linux linux-firmware linux-headers"
else
  TEMP=""
  IFS=","
  for KERNEL in $REPLY ; do
    case $KERNEL in
    1)
      TEMP+=" linux linux-firmware linux-headers" ;;
    2)
      TEMP+=" linux-lts linux-lts-firmware linux-lts-headers" ;;
    3)
      TEMP+=" linux-hardened linux-hardened-firmware linux-hardened-headers" ;;
    4)
      TEMP+=" linux-zen linux-zen-firmware linux-zen-headers" ;;
    esac
  done
fi
arch-chroot /mnt pacman --noconfirm -S $TEMP
