#!/bin/bash

pacman --noconfirm -S grub-btrfs timeshift timeshift-autosnap
timeshift --list
systemctl enable grub-btrfs.path