#!/bin/bash

while true ; do
  clear

  EFI_INSTALL=0
  ls /sys/firmware/efi/efivars > /dev/null
  [ $? == 0 ] && EFI_INSTALL=1

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

  clear
  echo "Timezone: $SCRIPT_TIMEZONE"
  echo "Hostname: $SCRIPT_HOSTNAME"
  echo "Bootloader ID: $SCRIPT_BOOTLOADER_ID"
  echo "Grub language: $SCRIPT_GRUB_LANG"
  echo -n "Are the settings correct?[y/n]"
  read;
  [ $REPLY == "y" ] && break
done
