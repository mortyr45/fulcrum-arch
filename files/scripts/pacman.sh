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
cat > /tmp/katsuo-repo-key.pub<< EOF
-----BEGIN PGP PUBLIC KEY BLOCK-----

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
=Kn2n
-----END PGP PUBLIC KEY BLOCK-----
EOF
    pacman-key --add /tmp/katsuo-repo-key.pub
    pacman-key --lsign-key F38A1CFC597B6755871B95BB642BAD59526563E3
    echo "" >> /etc/pacman.conf
    echo "[katsuo]" >> /etc/pacman.conf
    echo 'Server = https://pacman.katsuo.fish/$arch' >> /etc/pacman.conf
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

if [ "$1" == "auto" ] ; then
    fn_enable_multilib
    fn_katsuo_repo
    fn_chaotic_aur
    exit 0
fi

REPLY="1"
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
