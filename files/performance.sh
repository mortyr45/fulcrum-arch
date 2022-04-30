#!/bin/bash

printf "1) systemd-oomd\n2) power-profiles-daemon\n3) auto-cpufreq\n"
read -p "Choose performance configurations (separate multiple choices by ' ') [none]: "

for CHOICE in $REPLY ; do
    case $CHOICE in
        1)
            systemctl enable systemd-oomd ;;
        2)
            pacman --noconfirm -S power-profiles-daemon
            systemctl enable power-profiles-daemon
            ;;
    esac
done
