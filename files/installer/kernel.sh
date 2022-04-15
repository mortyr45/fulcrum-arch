#!/bin/bash

TEMP=""
IFS=","
for KERNEL in $SCRIPT_KERNEL ; do
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
  
arch-chroot /mnt pacman --noconfirm -S $TEMP linux-firmware
