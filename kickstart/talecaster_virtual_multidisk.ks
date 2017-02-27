######################################################################
# Public kickstart file for a multi-disk TaleCaster virtual appliance
# Note that this requires you follow the disk layout exactly.
#
# WARNING: YOU ARE EXPECTED TO CHANGE THE ROOT PASSWORD IMMEDIATELY 
# AFTER INSTALLATION.
# IT IS ENTIRELY YOUR RESPONSIBILITY TO ADEQUATELY SECURE THE SYSTEM.
# THE DEVELOPERS ACCEPT ABSOLUTELY NO RESPONSIBILITY WHATSOEVER FOR 
# FAILING TO TAKE REASONABLE OR ADEQUATE PRECAUTIONS INCLUDING BUT NOT
# LIMITED TO USING SECURE PASSWORDS, USING A STANDALONE FIREWALL, OR
# PERFORMING REASONABLE SECURITY UPDATES.
#
# It is strongly suggested that you fork and create your own version
# to suit your particular environment.
#
######################################################################

## Use CentOS 7 CDN
url --url https://mirror.centos.org/centos/7/os/x86_64/

## Perofrm installation
install
## Default layout is US English
keyboard --vckeymap=us --xlayouts='us'
## Root Password for INITIAL LOGIN ONLY!
rootpw --plaintext ch4ng3n0w!
## Set a secure password algorithm.
auth --useshadow --passalgo=sha512
## System Language - DO NOT CHANGE!!
lang en_US
## System Timezone - change after installation
timezone America/New_York

## Skip the waste that is X, use text, and run agent on firstboot
text
skipx
firstboot --enable
## Automatically reboot when we're done
reboot

## Explicitly disable SELinux and Firewall
## Save the 'you should learn selinux and are bad' shit for someone still
## stupid enough to put up with your bullshit. Even configured 'correctly'
## it does nothing but cause problems.
## The same goes for firewall. You should be running shit behind a proper
## firewall, not counting on someone not spoofing your local network. Which
## is literally more protection than it actually gives you.
## In other words: I KNOW BETTER THAN OTHERS. DEAL WITH IT. B|
selinux --disabled
firewall --disabled

## Network configuration default is to use DHCP
## Note: uses Google Public DNS
network --bootproto=dhcp --device=eth0 --hostname=talecaster --namesever=8.8.8.8,8.8.4.4

## Each repo must be specifically declared here due to HTTP install.
## CentOS Base
repo --name CentOS-base --baseurl=https://mirror.centos.org/centos/7/os/x86_64/
## CentOS Extras
repo --name CentOS-extras --baseurl=https://mirror.centos.org/centos/7/extras/x86_64/
## CentOS GlusterFS
repo --name CentOS-gluster39 --baseurl=https://mirror.centos.org/centos/7/storage/x86_64/gluster-3.9/
## We need EPEL during Kickstart; this is the official balancing mirror
repo --name epel-release --baseurl=https://dl.fedoraproject.org/pub/epel/7/x86_64

## Clear MBR, clear all partitions
zerombr
clearpart --all --initlabel
## Setup our bootloader; must go on sda
bootloader --location=mbr --boot-drive=sda --append="crashkernel=auto"

## sda - 28GB
part /boot --fstype="xfs" --ondisk=sda --size=1024
part pv.01 --fstype="lvmpv" --ondisk=sda --size=1 --grow

volgroup rootvg --pesize=4096 pv.01
logvol /    --fstype="xfs" --vgname="rootvg" --name="rootlv" --size=2048
logvol /var --fstype="xfs" --vgname="rootvg" --name="varlv" --size=8192
logvol /usr --fstype="xfs" --vgname="rootvg" --name="usrlv" --size=8192
logvol /opt --fstype="xfs" --vgname="rootvg" --name="optlv" --size=8192

## sdb - this is the swap disk; 100% of the disk is swap
part swap --fstype="swap" --ondisk=sdb --size=1 --grow

## sdc-sde - TaleCaster thinpool, needs to be at least 36GB per disk!
## THIS CONTAINS THE DOWNLOADS DIRECTORY, SO CAN GROW QUITE LARGE.
## NOTE: it is laid out in this way for GlusterFS support. The rest of
##  the GlusterFS bits are NOT FREE.
## To expand storage, just add more disks. That was easy, no?
part pv.10 --fstype="lvmpv" --ondisk=sdc --size=1 --grow
part pv.11 --fstype="lvmpv" --ondisk=sdd --size=1 --grow
part pv.12 --fstype="lvmpv" --ondisk=sde --size=1 --grow
volgroup talecastervg --pesize=4096 pv.10 pv.11 pv.12
logvol none --fstype="none" --thinpool --name=tcpool0 --chunksize=4 --vgname="talecastervg" --size=1 --grow
logvol /talecaster/config --fstype="xfs" --thin --poolname=tcpool0 --vgname="talecastervg" --name="configlv" --size=4096
logvol /talecaster/shared --fstype="xfs" --thin --poolname=tcpool0 --vgname="talecastervg" --name="sharedlv" --size=4096
logvol /talecaster/downloads --fstype="xfs" --thin --poolname=tcpool0 --vgname="talecastervg" --name="downloadlv" --size=51200
## XXX: these are only for self-hosted MusicBrainz! Do not enable unless
##      you really know what you're doing!
#logvol /talecaster/musicbrainz --fstype="jfs2" --thin --poolname=tcpool0 --vgname="talecastervg" --name="mblv" --size=65536
#logvol /talecaster/musicbrainz/db --fstype="jfs2" --thin --poolname=tcpool0 --vgname="talecastervg" --name="mbdblv" --size=65536

## It is presumed that you will be NETWORK MOUNTING /talecaster/media
## which for most users will be in the neighborhood of 20TB+

######################################################################
## Pre-Execution script
######################################################################
%pre --interpreter=/bin/bash
%end

######################################################################
## Packages
######################################################################
%packages
@core
kexec-tools
# Nuke firmware because we're on virtual
-aic94xx-firmware
-iwl100-firmware
-iwl1000-firmware
-iwl105-firmware
-iwl135-firmware
-iwl2000-firmware
-iwl2030-firmware
-iwl3160-firmware
-iwl3945-firmware
-iwl4965-firmware
-iwl5000-firmware
-iwl5150-firmware
-iwl6000-firmware
-iwl6000g2a-firmware
-iwl6000g2b-firmware
-iwl6050-firmware
-iwl7260-firmware
-iwl7265-firmware

## XXX: NEVER PUT BIOSDEVNAME IN. It will just fuck everything up.
-biosdevname
-device-mapper-multipath
-chrony

## Stuff we definitely need
ntp
ntpdate
deltarpm
open-vm-tools
bash-completion
tuned
nfs-utils
yum-plugin-filter-data
yum-plugin-protectbase
yum-plugin-verify
#yum-plugin-priority	Only needed for paid appliance

haveged
wget
dbus
mlocate

## EPEL Components
epel-release
bash-completion-extras

## Docker
docker
%end

######################################################################
## Post-Install Scripts
######################################################################
%post --interpreter=/bin/bash

## Fix services
systemctl mask firewalld
systemctl mask ntpdate
systemctl enable ntpd
systemctl enable haveged

systemctl disable kdump.service

systemctl enable docker

## Enable root login so that we can nuke it at first login. 
sed -i -e 's,#PermitRootLogin yes,PermitRootLogin yes,' /etc/ssh/sshd_config
## Forcibly expire root's password.
passwd -e root

## Generate root's SSH keys
mkdir /root/.ssh
chmod 0700 /root/.ssh
for x in rsa ecdsa ed25519; do
	ssh-keygen -t $x -N "" -f /root/.ssh/id_$x
done

## Import our RPM GPG keys
for x in `ls /etc/pki/rpm-gpg`; do
	rpm --import /etc/pki/rpm-gpg/$i
done

## XXX: systemd ships broken shit. Thanks, Red Hat. /s
cat << 'EOF' >> /usr/lib/systemd/system/nfs-idmapd.service

[Install]
WantedBy=multi-user.target
EOF
cat << 'EOF' >> /usr/lib/systemd/system/nfs-lock.service

[Install]
WantedBy=nfs.target
EOF

## haveged's threshold is too conservative under this sort of load,
## and virtual hosts are fucking TERRIBLE at entropy even before Linux's
## weak-ass algorithms.
sed -i -e 's,^ExecStart.*,ExecStart=/usr/sbin/haveged -w 2048 -v 1 --Foreground,' /usr/lib/systemd/system/haveged.service

## REALLY kill this biosdevname trainwreck
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules

%end
