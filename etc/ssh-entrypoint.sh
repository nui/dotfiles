# POSIX compatible script
_LOGIN_SHELL=$(getent passwd $(id -nu) | cut -d: -f 7)

if [ ! -x "$_LOGIN_SHELL" ]; then
    if [ -x /bin/bash ]; then
        _LOGIN_SHELL=/bin/bash
    else
        _LOGIN_SHELL=/bin/sh
    fi
fi

for motd in /var/run/motd.dynamic /etc/motd; do
    if [ -e $motd ]; then
        cat $motd
    fi
done

# Make sure that byobu doesn't take over our login shell
exec env BYOBU_DISABLE=1 $_LOGIN_SHELL -l -c 'exec ${NMK_DIR:-~/.nmk}/bin/nmk -l'
# vi: ft=sh
