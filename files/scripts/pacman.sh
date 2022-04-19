#!/bin/bash

katsuo_repo() {
    echo "" >> /etc/pacman.conf
    echo "[katsuo]" >> /etc/pacman.conf
    echo 'Server = https://pacman.katsuo.fish/core/$arch' >> /etc/pacman.conf
    echo "SigLevel = PackageRequired" >> /etc/pacman.conf
}

chaotic_aur() {
    pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
    pacman-key --lsign-key FBA220DFC880C036
    pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    echo "" >> /etc/pacman.conf
    echo "[chaotic-aur]" >> /etc/pacman.conf
    echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
}

read -p "Max number of parallel downloads [5]: "
[ -z $REPLY ] && REPLY=5

sed -ri -e "s/^.*ParallelDownloads.*/ParallelDownloads\ =\ $REPLY/g" /etc/pacman.conf
sed -ri -e "s/^.*\[multilib\].*/\[multilib\]/g" /etc/pacman.conf
sed -ri -e "s/^.*\[multilib\].*/&\nInclude\ =\ \/etc\/pacman.d\/mirrorlist/" /etc/pacman.conf

read -p "Enable katsuo pacman repository? [y/N]: "
[ $REPLY == "y" ] && katsuo_repo

read -p "Enable chaotic aur? [y/N]: "
[ $REPLY == "y" ] && chaotic_aur

pacman -Q pacman-contrib
[ $? != 0 ] && pacman --noconfirm -S pacman-contrib
! [ -d "/etc/pacman.d/hooks" ] && mkdir -p /etc/pacman.d/hooks
! [ -f "/etc/pacman.d/hooks/remove_old_cache.hook" ] && cat > /etc/pacman.d/hooks/remove_old_cache.hook<< EOF
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

pacman -Syy
