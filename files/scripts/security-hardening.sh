#!/bin/bash

fn_lock_root_account() {
    passwd --lock root
}

fn_ufw_config() {
    pacman -Q ufw
    if [ $? == 0 ] ; then
        systemctl disable iptables
        ufw default deny incoming
        ufw default deny forward
        ufw default allow outgoing
        sudo ufw allow from 203.0.113.0/24 proto tcp to any port 22
        systemctl enable ufw
        ufw enable
    fi
}

fn_ssh_server_hardening() {
    pacman -Q openssh
    if [ $? == 0 ] ; then
        sed -ri -e "s/^.*PermitRootLogin.*/PermitRootLogin\ no/g" /etc/ssh/sshd_config
        sed -ri -e "s/^.*MaxAuthTries.*/MaxAuthTries\n 3/g" /etc/ssh/sshd_config
        sed -ri -e "s/^.*PasswordAuthentication.*/PasswordAuthentication\ no/g" /etc/ssh/sshd_config
    fi
}

SECURITY_HARDENING_OPTIONS="1 2 3"
printf "1) Lock root account\n2) Set ufw configuration (requires ufw)\n3) Harden ssh server (requires openssh)\n"
read -p "Choose security configuration options [$SECURITY_HARDENING_OPTIONS]: "
! [ -z $REPLY ] && SECURITY_HARDENING_OPTIONS=$REPLY

for CHOICE in $SECURITY_HARDENING_OPTIONS ; do
    case $CHOICE in
        1)
            fn_lock_root_account ;;
        2)
            fn_ufw_config ;;
        3)
            fn_ssh_server_hardening ;;
    esac
done
