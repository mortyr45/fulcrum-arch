#!/bin/bash

clear
printf "Which kernel(s) would you like to install?\n1) linux-lts\n2) linux\n3) linux-hardened\n4) linux-zen\n"
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
      TEMP+=" linux-lts linux-lts-headers" ;;
    2)
      TEMP+=" linux linux-headers" ;;
    3)
      TEMP+=" linux-hardened linux-hardened-headers" ;;
    4)
      TEMP+=" linux-zen linux-zen-headers" ;;
    esac
  done
  IFS=" "
fi
arch-chroot /mnt pacman --noconfirm -S $TEMP linux-firmware
