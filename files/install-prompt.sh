#!/bin/bash

while true ; do
  clear

  EFI_INSTALL=0
  ls /sys/firmware/efi/efivars > /dev/null
  [ $? == 0 ] && EFI_INSTALL=1
  
  SCRIPT_EFI_PARTITION=/dev/sda1
  echo -n "Device and partition number for EFI[$SCRIPT_EFI_PARTITION]:"
  read;
  ! [ -z $REPLY ] && SCRIPT_EFI_PARTITION=$REPLY

  SCRIPT_ROOT_PARTITION=/dev/sda2
  echo -n "Device and partition number for root[$SCRIPT_ROOT_PARTITION]:"
  read;
  ! [ -z $REPLY ] && SCRIPT_ROOT_PARTITION=$REPLY
  
  SCRIPT_ROOT_PARTITION_SSD=false
  echo -n "Is the root partition on an ssd?[y/N]"
  read;
  [ $REPLY == "y" ] SCRIPT_ROOT_PARTITION_SSD=true

  SCRIPT_TIMEZONE_REGION=Europe
  ls /usr/share/zoneinfo
  echo -n "Time zone region[$SCRIPT_TIMEZONE_REGION]:"
  read;
  ! [ -z $REPLY ] && SCRIPT_TIMEZONE_REGION=$REPLY

  SCRIPT_TIMEZONE_CITY=Budapest
  ls /usr/share/zoneinfo/$SCRIPT_TIMEZONE_REGION
  echo -n "Time zone region[$SCRIPT_TIMEZONE_CITY]:"
  read;
  ! [ -z $REPLY ] && SCRIPT_TIMEZONE_CITY=$REPLY

  SCRIPT_TIMEZONE="$SCRIPT_TIMEZONE_REGION/$SCRIPT_TIMEZONE_CITY"
  
  SCRIPT_LOCALE=en_US.UTF-8
  echo -n "Locale: [$SCRIPT_LOCALE]:"
  read;
  ! [ -z $REPLY ] && SCRIPT_LOCALE=$REPLY

  SCRIPT_HOSTNAME=arch
  echo -n "System hostname[$SCRIPT_HOSTNAME]:"
  read;
  ! [ -z $REPLY ] && SCRIPT_HOSTNAME=$REPLY

  SCRIPT_BOOTLOADER_ID=GRUB
  echo -n "Identifier in the bootloader[$SCRIPT_BOOTLOADER_ID]:"
  read;
  ! [ -z $REPLY ] && SCRIPT_BOOTLOADER_ID=$REPLY

  SCRIPT_GRUB_LANG=en
  echo -n "Language in the bootloader[$SCRIPT_GRUB_LANG]:"
  read;
  ! [ -z $REPLY ] && SCRIPT_GRUB_LANG=$REPLY
  
  SCRIPT_KERNEL="1"
  printf "Which kernel(s) would you like to install?\n1) linux-lts\n2) linux\n3) linux-hardened\n4) linux-zen\n"
  echo -n "Choose multiple of them, by separating the numbers with a ','[$SCRIPT_KERNEL]: "
  read;
  ! [ -z $REPLY ] && SCRIPT_GRUB_LANG=$REPLY

  clear
  echo "EFI partition: $SCRIPT_EFI_PARTITION"
  echo "Root partition: $SCRIPT_ROOT_PARTITION"
  echo "Timezone: $SCRIPT_TIMEZONE"
  echo "Locale: $SCRIPT_LOCALE"
  echo "Hostname: $SCRIPT_HOSTNAME"
  echo "Bootloader ID: $SCRIPT_BOOTLOADER_ID"
  echo "Grub language: $SCRIPT_GRUB_LANG"
  echo -n "Are the settings correct?[y/n]"
  read;
  [ $REPLY == "y" ] && break
done
