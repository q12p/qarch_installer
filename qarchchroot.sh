#!/bin/bash

set -e

# Variables
#
# Colours
white='\e[37m'
red='\e[31m'
yellow='\e[33m'

echo -e "$white"


username=$1

password=$2

root_password=$3

net_software_choice=$4





# 3.3	Time zone
echo -e "$yellow Setting time zone$white"

ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime

hwclock --systohc





# 3.4	Localization
echo -e "$yellow Setting localization$white"

sed '/en_US.UTF/s/^#//' -i /etc/locale.gen
sed '/fr_CH.UTF/s/^#//' -i /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "KEYMAP=fr_CH" > /etc/vconsole.conf





# 3.5	Network configuration
echo -e "$yellow Creating network configuration$white"

echo $username > /etc/hostname

cp qhosts /etc/hosts
sed -i 's/username/'$username'/g' /etc/hosts





# 3.6	Initramfs
echo -e "$yellow Recreating initramfs image.$white"

mkinitcpio -P





# 3.7	Root password
echo -e "$yellow Setting root and user password.$white"

echo -e "$root_password\n$root_password" | passwd





# POST-INSTALLATION
echo -e "$yellow Initiating post-intallation.$white"

#Adding main user
useradd -G wheel,audio,video -m $username
echo -e "$password\n$password" | passwd $username

#Adding sudo command
echo 'y' | pacman -Sy sudo
sed '/wheel ALL=(ALL:ALL) ALL/s/^#//' -i /etc/sudoers

#Installing grub and efibootmgr
echo 'y' | pacman -Sy grub efibootmgr

grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=Arch
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sed -i 's/GRUB_GFXMODE=auto/GRUB_GFXMODE=1920x1080/g' /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg




# Custom personalisation
echo 'y' | pacman -Sy - < qpackages.txt

cp /files/.config /home/$username/ -r
chmod +x /home/$username/.config/sxhkd/sxhkdrc
chmod +x /home/$username/.config/bspwm/bspwmrc
chmod +x /home/$username/.config/bspwm/bin/bspterm

echo 'y' | pacman -U /files/aur_packages/sddm-sugar-dark-1.2-1-any.pkg.tar.zst
echo 'y' | pacman -U /files/aur_packages/nerd-fonts-jetbrains-mono-2.2.2-2-any.pkg.tar.zst

sed -i 's/Current=/Current=sugar-dark/g' /usr/lib/sddm/sddm.conf.d/default.conf
cp /home/$username/.config/wallpaper.png /usr/share/sddm/themes/sugar-dark/
cp /files/theme.conf /usr/share/sddm/themes/sugar-dark/

#rm -rf /usr/share/fonts/*
cp /files/fonts/* /usr/share/fonts/ -r

#echo -e '#!/bin/sh\nfeh --no-fehbg --bg-scale '\''home/'"$username"'/.config/wallpaper.png'\' > /home/$username/.fehbg
#chmod +x /home/$username/.fehbg
#cp /files/.fehbg /home/$username/

systemctl enable sddm.service

if [ $net_software_choice == 1 ]
then
	cp /etc/netctl/examples/ethernet-dhcp /etc/netctl/

	name_interface=$(ip link | grep enp1* | awk '{print $2;}' | rev | cut -c 2- | rev)
	sed -i "s/Interface=eth0/Interface=$name_interface/g" /etc/netctl/ethernet-dhcp
	netctl enable ethernet-dhcp
	systemctl enable netctl.service
fi


echo -e "Section \"InputClass\"\n	Identifier \"system-keyboard\"\n	MatchIsKeyboard \"on\"\n	Option \"XkbLayout\" \"ch\"\n	Option \"XkbModel\" \",\"	Option \"XkbVariant\" \"fr\"\nEndSection" > /etc/X11/xorg.conf.d/00-keyboard.conf
