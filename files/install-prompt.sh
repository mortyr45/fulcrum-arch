#!/bin/bash

clear

EFI_INSTALL=0
ls /sys/firmware/efi/efivars > /dev/null
if [ $? == 0 ] ; then
  EFI_INSTALL=1
fi

EFI_PARTITION=/dev/sda1
echo -n "Device and partition number for EFI[$EFI_PARTITION]:"
read;
if ! [ -z $REPLY ] ; then EFI_PARTITION=$REPLY ; fi

ROOT_PARTITION=/dev/sda2
echo -n "Device and partition number for root[$ROOT_PARTITION]:"
read;
if ! [ -z $REPLY ] ; then ROOT_PARTITION=$REPLY ; fi

SCRIPT_TIMEZONE_REGION=Europe
ls /usr/share/zoneinfo
echo -n "Time zone region[$SCRIPT_TIMEZONE_REGION]:"
read;
if ! [ -z $REPLY ] ; then SCRIPT_TIMEZONE_REGION=$REPLY ; fi

SCRIPT_TIMEZONE_CITY=Budapest
ls /usr/share/zoneinfo/$SCRIPT_TIMEZONE_REGION
echo -n "Time zone region[$SCRIPT_TIMEZONE_CITY]:"
read;
if ! [ -z $REPLY ] ; then SCRIPT_TIMEZONE_CITY=$REPLY ; fi

SCRIPT_TIMEZONE="$SCRIPT_TIMEZONE_REGION/$SCRIPT_TIMEZONE_CITY"

SCRIPT_HOSTNAME=arch
echo -n "System hostname[$SCRIPT_HOSTNAME]:"
read;
if ! [ -z $REPLY ] ; then SCRIPT_HOSTNAME=$REPLY ; fi

SCRIPT_BOOTLOADER_ID=GRUB
echo -n "Identifier in the bootloader[$SCRIPT_BOOTLOADER_ID]:"
read;
if ! [ -z $REPLY ] ; then SCRIPT_BOOTLOADER_ID=$REPLY ; fi

SCRIPT_GRUB_LANG=en
echo -n "Language in the bootloader[$SCRIPT_GRUB_LANG]:"
read;
if ! [ -z $REPLY ] ; then SCRIPT_GRUB_LANG=$REPLY ; fi

clear
echo "EFI partition: $EFI_PARTITION"
echo "Root partition: $ROOT_PARTITION"
echo "Timezone: $SCRIPT_TIMEZONE"
echo "Timezone: $SCRIPT_HOSTNAME"
echo "Timezone: $SCRIPT_BOOTLOADER_ID"
echo "Timezone: $SCRIPT_GRUB_LANG"
echo -n "Are the settings correct?[y/n]"
read;
if [ $REPLY != "y" ] ; then exit 0 ; fi
