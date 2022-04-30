#!/bin/bash

pacman --noconfirm -S grub-btrfs timeshift timeshift-autosnap
timeshift --list
systemctl enable grub-btrfs.path
sed -ri -e "s/^updateGrub=true.*/updateGrub=false/g" /etc/timeshift-autosnap.conf