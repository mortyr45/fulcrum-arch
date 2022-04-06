ln -sf /usr/share/zoneinfo/$SCRIPT_TIMEZONE /etc/localtime
sed -ri -e "s!^#en_US.UTF-8!$SCRIPT_TIMEZONE!g" /etc/locale.gen
locale-gen
