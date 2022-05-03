#!/bin/bash

printf "1) systemd-oomd\n2) power-profiles-daemon\n3) auto-cpufreq\n"
read -p "Choose performance configurations (separate multiple choices by ' ') [none]: "

for CHOICE in $REPLY ; do
    case $CHOICE in
        1)
            systemctl enable systemd-oomd.service ;;
        2)
            pacman --noconfirm -S power-profiles-daemon
            systemctl enable power-profiles-daemon.service
            ;;
        3)
            pacman --noconfirm -S auto-cpufreq
            systemctl enable --now auto-cpufreq
            ;;
    esac
done
#gnome-shell-extension-cpufreq