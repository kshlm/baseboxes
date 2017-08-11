#!/bin/bash

set -e

case $(systemd-detect-virt) in
	qemu|kvm)
		parted -s /dev/vda mklabel msdos
		parted -s /dev/vda mkpart primary linux-swap 0% 1GiB
		parted -s /dev/vda mkpart primary ext4 1GiB 3GiB
		mkswap /dev/vda1
		swapon /dev/vda1
		mkfs.ext4 /dev/vda2
		mount /dev/vda2 /mnt
		;;
	*)
		parted -s /dev/sda mklabel msdos
		parted -s /dev/sda mkpart primary ext4 0% 2GiB
		mkfs.ext4 /dev/sda1
		mkswap /dev/sdb
		swapon /dev/sdb
		mount /dev/sda1 /mnt
		;;
esac

curl -sSo /etc/pacman.d/mirrorlist 'https://www.archlinux.org/mirrorlist/?country=all&protocol=http&ip_version=4&use_mirror_status=on'
sed -i '/^#Server = /s/^#//' /etc/pacman.d/mirrorlist

pacstrap /mnt base

cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d
genfstab -p /mnt >> /mnt/etc/fstab
hostname > /mnt/etc/hostname
cat > /mnt/etc/systemd/network/ethernet.network <<-EOF
	[Match]
	name=en*
	
	[Network]
	DHCP=yes
EOF
arch-chroot /mnt systemctl --no-reload enable systemd-networkd.service
ln -fs /run/systemd/resolve/resolv.conf /mnt/etc/resolv.conf
arch-chroot /mnt systemctl --no-reload enable systemd-resolved.service
arch-chroot /mnt mkinitcpio -p linux
echo root:packer | arch-chroot /mnt chpasswd
arch-chroot /mnt pacman -S --noconfirm grub openssh sudo nfs-utils

case $(systemd-detect-virt) in
	qemu|kvm)
		sfdisk -f --no-reread /dev/vda <<-EOF || true
			2048,2095104,82,
			2097152,,83,*
		EOF
		arch-chroot /mnt grub-install --target=i386-pc /dev/vda
		;;
	*)
		echo '2048,,83,*' | sfdisk -f --no-reread /dev/sda || true
		arch-chroot /mnt grub-install --target=i386-pc /dev/sda
		;;
esac

sed -i '/^GRUB_TIMEOUT=/s/=[0-9]\+$/=0/' /mnt/etc/default/grub
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
sed -i.orig '$aPermitRootLogin=yes' /mnt/etc/ssh/sshd_config
arch-chroot /mnt systemctl --no-reload enable sshd.socket
arch-chroot /mnt pacman -Syu

PACSRV_PKG="pacserve-2016-1-any.pkg.tar.xz"
PY3_THRSRV_PKG="python3-threaded_servers-2016.10.17-3-any.pkg.tar.xz"
mkdir -p /mnt/tmp
curl -sSo /mnt/$PACSRV_PKG "http://$ADDR/$PACSRV_PKG"
curl -sSo /mnt/$PY3_THRSRV_PKG "http://$ADDR/$PY3_THRSRV_PKG"
arch-chroot /mnt pacman -U /$PACSRV_PKG /$PY3_THRSRV_PKG
arch-chroot /mnt systemctl --no-reload enable pacserve.service
sed -i '/^Include/iInclude = /etc/pacman.d/pacserve' /mnt/etc/pacman.conf
sed -i '/^#Include/i#Include = /etc/pacman.d/pacserve' /mnt/etc/pacman.conf
rm /mnt/$PACSRV_PKG /mnt/$PY3_THRSRV_PKG

reboot
