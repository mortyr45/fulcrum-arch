#!/bin/bash

while true ; do
  clear

  EFI_INSTALL=0
  ls /sys/firmware/efi/efivars > /dev/null
  [ $? == 0 ] && EFI_INSTALL=1

  SCRIPT_TIMEZONE_REGION=Asia
  ls /usr/share/zoneinfo
  read -p "Time zone region [$SCRIPT_TIMEZONE_REGION]: "
  ! [ -z $REPLY ] && SCRIPT_TIMEZONE_REGION=$REPLY

  SCRIPT_TIMEZONE_CITY=Tokyo
  ls /usr/share/zoneinfo/$SCRIPT_TIMEZONE_REGION
  read -p "Time zone region [$SCRIPT_TIMEZONE_CITY]: ";
  ! [ -z $REPLY ] && SCRIPT_TIMEZONE_CITY=$REPLY

  SCRIPT_TIMEZONE="$SCRIPT_TIMEZONE_REGION/$SCRIPT_TIMEZONE_CITY"
  
  SCRIPT_LOCALE=en_US.UTF-8
  read -p "Locale [$SCRIPT_LOCALE]: ";
  ! [ -z $REPLY ] && SCRIPT_LOCALE=$REPLY

  SCRIPT_HOSTNAME=arch
  read -p "System hostname [$SCRIPT_HOSTNAME]: ";
  ! [ -z $REPLY ] && SCRIPT_HOSTNAME=$REPLY

  SCRIPT_BOOTLOADER_ID=GRUB
  read -p "Identifier in the bootloader [$SCRIPT_BOOTLOADER_ID]: ";
  ! [ -z $REPLY ] && SCRIPT_BOOTLOADER_ID=$REPLY

  SCRIPT_GRUB_LANG=en
  read -p "Language in the bootloader [$SCRIPT_GRUB_LANG]: ";
  ! [ -z $REPLY ] && SCRIPT_GRUB_LANG=$REPLY
  
  SCRIPT_KERNEL="1"
  printf "Which kernel(s) would you like to install?\n1) linux-lts\n2) linux\n3) linux-hardened\n4) linux-zen\n"
  read -p "Choose multiple of them, by separating the numbers with a ',' [$SCRIPT_KERNEL]: ";
  ! [ -z $REPLY ] && SCRIPT_KERNEL=$REPLY
  
  SCRIPT_CPU_MITIGATIONS="0"
  printf "Whicch cpu microcode package would you like to install?\n0) none\n1) amd-ucode\n2) intel-ucode"
  read -p "Please choose cpu microcode mitigation to be installed [$SCRIPT_CPU_MITIGATIONS]: ";
  ! [ -z $REPLY ] && SCRIPT_CPU_MITIGATIONS=$REPLY

  clear
  echo "Timezone: $SCRIPT_TIMEZONE"
  echo "Locale: $SCRIPT_LOCALE"
  echo "Hostname: $SCRIPT_HOSTNAME"
  echo "Bootloader ID: $SCRIPT_BOOTLOADER_ID"
  echo "Grub language: $SCRIPT_GRUB_LANG"
  echo "Chosen kernel(s): $SCRIPT_KERNEL"
  echo "Chosen cpu microcode mitigation: $SCRIPT_CPU_MITIGATIONS"
  echo -n "Are the settings correct? [y/N]: "
  read;
  [ $REPLY == "y" ] && break
done
