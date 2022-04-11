#!/bin/bash

# Security
pacman --noconfirm -S ufw
systemctl disable iptables
systemctl enable ufw
ufw default deny incoming
ufw default deny forward
ufw default allow outgoing
ufw allow from 192.168.0.0/23
ufw limit 22/tcp
ufw enable

# Packages
sed -ri -e "s/^.*ParallelDownloads.*/ParallelDownloads\ =\ 5/g" /etc/pacman.conf
pacman --noconfirm -S pacman-contrib
mkdir -p /etc/pacman.d/hooks
cat > /etc/pacman.d/hooks/remove_old_cache.hook<< EOF
[Trigger]
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *

[Action]
Description = Cleaning pacman cache...
When = PostTransaction
Exec = /usr/bin/paccache -rk3
EOF

pacman --noconfirm -S flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Performance
systemctl enable systemd-oomd

# Other
pacman --noconfirm -S fwupd zsh man-db man-pages gufw
chsh -s /bin/zsh fulcrum

#in /etc/pacman.d/mirrorlist set the desired mirror
#pacman -Syyu
