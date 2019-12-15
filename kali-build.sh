#!/bin/bash


# Update and install dependencies

apt-get update
apt-get install git live-build cdebootstrap -y

# Clone the default Kali live-build config.

git clone https://gitlab.com/kalilinux/build-scripts/live-build-config.git

# Let's begin our customisations:

cd live-build-config

# The user doesn't need the kali-linux-full metapackage, we overwrite with our own basic packages.
cat <<EOF > config/package-lists/kali.list.chroot
# kali meta-package depends on everything we want
kali-linux-everything
kali-desktop-e17
kali-root-login
kali-defaults
kali-debtags
kali-archive-keyring
debian-installer-launcher
cryptsetup
locales-all
hostapd
dnsmasq
nginx
wireless-tools
iw
aircrack-ng
openssl
sslsplit
responder
openssh-server
openvpn
nginx
EOF


mkdir -p config/includes.chroot/etc/hostapd
mkdir -p config/includes.chroot/etc/init.d



cat <<EOF >config/hooks/enableservices.chroot
#!/bin/bash
update-rc.d nginx enable
update-rc.d hostapd enable
update-rc.d dnsmasq enable
EOF


cat <<EOF >config/hooks/configurehostapd.chroot
#!/bin/bash
sed -i 's#^DAEMON_CONF=.*#DAEMON_CONF=/etc/hostapd/hostapd.conf#' /etc/init.d/hostapd
EOF


chmod 755 config/hooks/enableservices.chroot
chmod 755 config/hooks/configurehostapd.chroot
chmod 755 config/includes.chroot/etc/rc.local 

# Go ahead and run the build!
lb build
