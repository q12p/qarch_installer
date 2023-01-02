#!/bin/bash


# Variables
#
# Colours
white='\e[37m'
red='\e[31m'
yellow='\e[33m'

echo -e "$white"


echo -e "$yellow Insert username:$white"
read username

echo -e "$yellow Insert password for $username:$white"
read password

echo -e "$yellow Insert password for root:$white"
read root_password





# CHOICE FOR NETWORK SOFTWARE

echo -e "$red \n\n\nDepending on the hardware where this installation is taking place, a different network management software will be installed.\n\n$yellow\"Netctl\"$red for a station set to connect to one main internet connection.\n\n$yellow\"Network Manager\"$red for a station meant to be used with multiple connections (usually the tipical choice for laptops).$white"


net_software_choice=0

while [[ $net_software_choice -ne 1 && $net_software_choice -ne 2 ]]
do
	echo -e "$yellow Install netctl (1) or Network Manager (2):$white"
	read net_software_choice
done





# USER CHOOSES NETCTL
if [ $net_software_choice == 1 ]
then
	echo -e "netctl\ndhcpcd\ndialog\nwpa_supplicant" >> /qpackages.txt




# USER CHOOSES NETWORK MANAGER
else
	graphical_interface=q

	while [[ $graphical_interface -ne 'y' && $graphical_interface -ne 'n' ]]
	do
		echo -e "$yellow \nWould you like to install a graphical user interface for Network Manager? (Yes=y No=n)$white"
		read graphical_interface
	done

	echo networkmanager >> /qpackages.txt

	if [ $graphical_interface == 'y' ]
	then
		echo nm-connection-editor >> /qpackages.txt
	fi
fi





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
grub-mkconfig -o /boot/grub/grub.cfg
#sed -i 's/username/'$username'/g' /etc/default/grub############################################





# Custom personalisation
echo -e "3\n1\n1\ny" | pacman -Sy $(cat qpackages.txt)


cp files/.config /home/$username/ -r
chmod +x /home/$username/.config/sxhkd/sxhkdrc
chmod +x /home/$username/.config/bspwm/bspwmrc
chmod +x /home/$username/.config/bspwm/bin/bspterm

feh --bg-scale .config/wallpaper.png


systemctl enable sddm.service

####################################################################
cp /etc/netctl/examples/ethernet-dhcp /etc/netctl/

name_interface=$(ip link | grep enp1* | awk '{print $2;}' | rev | cut -c 2- | rev)
sed -i "s/Interface=*/$name_interface/g" /etc/netctl/ethernet-dhcp
systemctl enable netctl.service
netctl enable ethernet-dhcp

localectl set-x11-keymap ch , fr
