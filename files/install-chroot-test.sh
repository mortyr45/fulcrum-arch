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
sed -ri -e "s/^.*\[multilib\].*/\[multilib\]/g" /etc/pacman.conf
sed -ri -e "s/^.*\[multilib\].*/&\nInclude\ =\ \/etc\/pacman.d\/mirrorlist/" /etc/pacman.conf
sed -ri -e "s/^.*\[multilib\].*/&\nSigLevel\ =\ PackageRequired/" /etc/pacman.conf

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
pacman --noconfirm -S fwupd zsh cronie openssh man-db man-pages gufw
sed -ri -e "s/^.*PermitRootLogin.*/PermitRootLogin\ prohibit-password/g" /etc/ssh/sshd_config
sed -ri -e "s/^.*PasswordAuthentication.*/PasswordAuthentication\ no/g" /etc/ssh/sshd_config
systemctl enable sshd
systemctl enable cronie
chsh -s /bin/zsh fulcrum
sed -ri -e "s/^.*set\ softwrap.*/set\ softwrap/g" /etc/ssh/sshd_config

#in /etc/pacman.d/mirrorlist set the desired mirror
#pacman -Syyu
