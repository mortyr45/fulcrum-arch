#!/bin/bash

printf "1) systemd-oomd"
read -p "Choose performance configurations (separate multiple choices by ' ') [none]: "

for CHOICE in $REPLY ; do
    case $CHOICE in
        1)
            systemctl enable systemd-oomd
            ;;
    esac
done
