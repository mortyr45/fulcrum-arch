#!/bin/bash

fn_enable_cache_hook() {
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
}

fn_enable_multilib() {
    sed -ri -e "s/^.*\[multilib\].*/\[multilib\]/g" /etc/pacman.conf
    sed -ri -e "s/^.*\[multilib\].*/&\nInclude\ =\ \/etc\/pacman.d\/mirrorlist/" /etc/pacman.conf
    pacman -Syy
}

fn_katsuo_repo() {
    echo "" >> /etc/pacman.conf
    echo "[katsuo]" >> /etc/pacman.conf
    echo 'Server = https://pacman.katsuo.fish/core/$arch' >> /etc/pacman.conf
    echo "SigLevel = PackageRequired" >> /etc/pacman.conf
}

fn_chaotic_aur() {
    pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
    pacman-key --lsign-key FBA220DFC880C036
    pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    echo "" >> /etc/pacman.conf
    echo "[chaotic-aur]" >> /etc/pacman.conf
    echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
}

REPLY="1 2"
printf "1) Enable cache cleaning hook\n2) Enable multilib (32-bit packages)\n3) Enable katsuo repository\n4) Enable chaotic-aur (requires multilib)\n0) nothing\n"
read -p "Choose pacman configuration options [$REPLY]: "

for CHOICE in $REPLY ; do
    case $CHOICE in
        1)
            fn_enable_cache_hook ;;
        2)
            fn_enable_multilib ;;
        3)
            fn_katsuo_repo ;;
        4)
            fn_chaotic_aur ;;
    esac
done

pacman -Syy
