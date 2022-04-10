#!/bin/bash

# Security
echo "Defaults editor=/usr/bin/rnano" >> /etc/sudoers
passwd --lock root

pacman -S ufw
systemctl disable iptables
systemctl enable ufw
ufw default deny incoming
ufw default deny forward
ufw default allow outgoing
ufw allow from 192.168.0.0/23
ufw limit 22/tcp

# Packages
sed -ri -e "s!#*ParallelDownloads!ParallelDownloads\ =\ 5!g" /etc/pacman.conf
#pacman -S pacman-contrib
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
