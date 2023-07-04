#!/bin/bash
set -e

# Variables

# Colours
white=$(tput sgr0)
red=$(tput setaf 9)
yellow=$(tput setaf 3)


username=$1

password=$2

root_password=$3

net_software_choice=$4

disk=$5

root_partition=$6


echo -e "$white"


# 3.3	Time zone
echo -e "$yellow Setting time zone.$white"

ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime

hwclock --systohc


# 3.4	Localization
echo -e "$yellow Setting localization.$white"

sed '/en_US.UTF/s/^#//' -i /etc/locale.gen
sed '/fr_CH.UTF/s/^#//' -i /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=fr_CH" > /etc/vconsole.conf


# 3.5	Network configuration
echo -e "$yellow Creating network configuration.$white"

echo $username > /etc/hostname

echo -e "127.0.0.1	localhost\n::1		localhost\n127.0.1.1	$username.localdomain		$username" >> /etc/hosts
sed -i 's/username/'$username'/g' /etc/hosts


# 3.6	Initramfs
echo -e "$yellow Recreating initramfs image.$white"

mkinitcpio -P


# 3.7	Root password
echo -e "$yellow Setting root and user password.$white"

echo -e "$root_password\n$root_password" | passwd


# ██████╗  ██████╗ ███████╗████████╗    ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗      █████╗ ████████╗██╗ ██████╗ ███╗   ██╗
# ██╔══██╗██╔═══██╗██╔════╝╚══██╔══╝    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║
# ██████╔╝██║   ██║███████╗   ██║       ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║
# ██╔═══╝ ██║   ██║╚════██║   ██║       ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║
# ██║     ╚██████╔╝███████║   ██║       ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║
# ╚═╝      ╚═════╝ ╚══════╝   ╚═╝       ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
echo -e "$yellow Initiating post-intallation.$white"

# Adding main user
useradd -G wheel,audio,video -m $username
echo -e "$password\n$password" | passwd $username

# Installing sudo package 
pacman -Sy sudo --noconfirm
sed '/wheel ALL=(ALL:ALL) ALL/s/^#//' -i /etc/sudoers

# Installing grub and efibootmgr
pacman -Sy efibootmgr --noconfirm

# EFISTUB
efibootmgr --create --disk $disk --part 1 --label "Arch Linux" --loader /vmlinuz-linux --unicode "root=$root_partition rw initrd=\initramfs-linux.img"

# GRUB
#grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=Arch
#sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
#sed -i 's/GRUB_GFXMODE=auto/GRUB_GFXMODE=1920x1080/g' /etc/default/grub

#grub-mkconfig -o /boot/grub/grub.cfg


# Custom personalisation
pacman -Sy - < qpackages.txt --noconfirm

cp /files/.config /home/$username/ -r
chmod +x /home/$username/.config/bspwm/bin/bspterm


# AUR packages
pacman -U /files/aur_packages/sddm-sugar-candy-git-r53.2b72ef6-1-any.pkg.tar.zst --noconfirm
pacman -U /files/aur_packages/i3lock-color-2.13.c.4-1-x86_64.pkg.tar.zst --noconfirm
pacman -U /files/aur_packages/betterlockscreen-4.0.4-2-any.pkg.tar.zst --noconfirm

sed -i 's/Current=/Current=sugar-candy/g' /usr/lib/sddm/sddm.conf.d/default.conf

# Wallpaper
cp /files/.fehbg /home/$username/
# TESTING chmod +x /home/$username/.fehbg
#cp /home/$username/.config/wallpaper.png /usr/share/sddm/themes/sugar-dark/
#cp /files/sugar-candy /usr/share/sddm/themes/ -rf


# Login manager
echo -e "$yellow Enabling login manager sddm.$white"

systemctl enable sddm.service


# Network configuration
if [ $net_software_choice == 1 ]
then
	echo -e "$yellow Enabling ethernet connection with netctl.$white"

	cp /etc/netctl/examples/ethernet-dhcp /etc/netctl/

	name_interface=$(ip link | grep enp1* | awk '{print $2;}' | sed 's/:/ /g')
	sed -i "s/Interface=eth0/Interface=$name_interface/g" /etc/netctl/ethernet-dhcp
	netctl enable ethernet-dhcp
	systemctl enable netctl.service
fi


# Keyboard layout
echo -e "$yellow Setting french swiss keyboard.$white"

echo -e "$yellow Enabling ethernet connection with netctl.$white"
echo -e "Section \"InputClass\"\n	Identifier \"system-keyboard\"\n	MatchIsKeyboard \"on\"\n	Option \"XkbLayout\" \"ch\"\n	Option \"XkbModel\" \",\"	Option \"XkbVariant\" \"fr\"\nEndSection" > /etc/X11/xorg.conf.d/00-keyboard.conf
