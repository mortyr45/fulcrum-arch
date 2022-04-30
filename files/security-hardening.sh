#!/bin/bash

fn_lock_root_account() {
    passwd --lock root
}

fn_ufw_config() {
    pacman -Q ufw
    if [ $? == 0 ] ; then
        systemctl disable iptables.service
        ufw default deny incoming
        ufw default deny forward
        ufw default allow outgoing
        sudo ufw allow from 192.168.0.0/21 proto tcp to any port 22
        systemctl enable ufw.service
        ufw enable
    fi
}

fn_ssh_server_hardening() {
    pacman -Q openssh
    if [ $? == 0 ] ; then
        sed -ri -e "s/^#Port.*/Port\ 22/g" /etc/ssh/sshd_config
        sed -ri -e "s/^#HostKey\ \/etc\/ssh\/ssh_host_rsa_key/HostKey\ \/etc\/ssh\/ssh_host_rsa_key/g" /etc/ssh/sshd_config
        sed -ri -e "s/^#HostKey\ \/etc\/ssh\/ssh_host_ed25519_key/HostKey\ \/etc\/ssh\/ssh_host_ed25519_key/g" /etc/ssh/sshd_config
        sed -ri -e "s/^#PermitRootLogin.*/PermitRootLogin\ no/g" /etc/ssh/sshd_config
        sed -ri -e "s/^#MaxAuthTries.*/MaxAuthTries\ 3/g" /etc/ssh/sshd_config
        sed -ri -e "s/^#PasswordAuthentication.*/PasswordAuthentication\ no/g" /etc/ssh/sshd_config
        cat /etc/ssh/sshd_config | grep "KexAlgorithms curve"
        [ $? != 0 ] && echo "KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group14-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512" >> /etc/ssh/sshd_config
        cat /etc/ssh/sshd_config | grep "MACs umac-128"
        [ $? != 0 ] && echo "MACs umac-128-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com" >> /etc/ssh/sshd_config
        systemctl reload sshd.service
    fi
}

fn_setup_sshguard() {
    pacman -Q ufw
    [ $? != 0 ] && exit 1

    pacman -Q sshguard
    [ $? != 0 ] && pacman --noconfirm -S sshguard

    sed -ri -e "s/^-A\ ufw-before-output -o lo -j ACCEPT/&\n\n#\ sshguard\n:sshguard\ -\ \[0:0\]\n-A\ ufw-before-input\ -p\ tcp\ --dport\ 22\ -j\ sshguard/" /etc/ufw/before.rules
    ufw reload
    systemctl enable --now sshguard.service
}

SECURITY_HARDENING_OPTIONS="1 2 3"
printf "1) Lock root account\n2) Set ufw configuration (requires ufw)\n3) Harden ssh server (requires openssh)\n4) Setup sshguard (requires UFW)\n"
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
        4)
            fn_setup_sshguard ;;
    esac
done
