#!/bin/bash

# Packages
sed -ri -e "s/^.*ParallelDownloads.*/ParallelDownloads\ =\ 5/g" /etc/pacman.conf
sed -ri -e "s/^.*\[multilib\].*/\[multilib\]/g" /etc/pacman.conf
sed -ri -e "s/^.*\[multilib\].*/&\nInclude\ =\ \/etc\/pacman.d\/mirrorlist/" /etc/pacman.conf
pacman -Sy

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

# Performance
systemctl enable systemd-oomd

# Other
pacman --noconfirm -S zsh cronie openssh man-db man-pages gufw
systemctl enable sshd
systemctl enable cronie
chsh -s /bin/zsh fulcrum
sed -ri -e "s/^.*set\ softwrap.*/set\ softwrap/g" /etc/nanorc

#in /etc/pacman.d/mirrorlist set the desired mirror
#pacman -Syyu
