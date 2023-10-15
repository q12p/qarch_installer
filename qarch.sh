#!/bin/bash

# ATTENTION! This script assumes that the user has already connected to the internet.
set -e

# Variables
#
# Colours
white=$(tput sgr0)
red=$(tput setaf 9)
yellow=$(tput setaf 3)

echo -e "$white"


read -p "$yellow Insert username:$white " username

read -p "$yellow Insert password for $username:$white " password

read -p "$yellow Insert password for root:$white " root_password


# CHOICE FOR NETWORK SOFTWARE
echo -e "$red \n\n\nDepending on the hardware where this installation is taking place, a different network management software will be installed.\n\n$yellow\"Netctl\"$red for a station set to connect to one main internet connection.\n\n$yellow\"Network Manager\"$red for a station meant to be used with multiple connections (usually the tipical choice for laptops).$white"

net_software_choice=0

while [[ $net_software_choice -ne 1 && $net_software_choice -ne 2 ]]
do
	echo -e "$yellow Install netctl (1) or Network Manager (2):$white"
	read net_software_choice
done


# USER CHOOSES NETCTL
if [ $net_software_choice -eq 1 ]
then
	echo -e "netctl\ndhcpcd" >> qpackages.txt

# USER CHOOSES NETWORK MANAGER
else
	graphical_interface=q
	while [[ $graphical_interface != 'y' && $graphical_interface != 'n' ]]
	do
		read -p "$yellow Would you like to install a graphical user interface for Network Manager? (Yes=y No=n):$white " graphical_interface
	done

	echo -e "networkmanager\ndhcpcd\nwpa_supplicant" >> qpackages.txt

	if [ $graphical_interface == 'y' ]
	then
		echo nm-connection-editor >> qpackages.txt
	fi
fi


# ██╗       ██████╗ ██████╗ ███████╗    ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗      █████╗ ████████╗██╗ ██████╗ ███╗   ██╗
#███║       ██╔══██╗██╔══██╗██╔════╝    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║
#╚██║       ██████╔╝██████╔╝█████╗█████╗██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║
# ██║       ██╔═══╝ ██╔══██╗██╔══╝╚════╝██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║
# ██║██╗    ██║     ██║  ██║███████╗    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║
# ╚═╝╚═╝    ╚═╝     ╚═╝  ╚═╝╚══════╝    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝

# 1.8	Update the system clock
echo -e "$yellow Updating the system clock.$white"

timedatectl set-timezone Europe/Zurich
timedatectl set-ntp true


# 1.9	Partition the disk############################################# Change fdisk command to variable
lsblk -p
read -p "$yellow Select disk to proceed with installation. (Write the entire path Ex: /dev/sda):$white " disk
	
swap_space="none"
while [[ $swap_space != 'y' && $swap_space != 'n' ]]
do
	read -p "$yellow Would you like to set a swap space? (Yes=y No=n):$white " swap_space
done

echo -e "$yellow Partitioning the disks.$white"

if [ $swap_space == 'n' ]
then
  echo -e "n\np\n1\n\n+512M\nn\np\n2\n\n\nt\n1\nEF\nw" | fdisk $disk

  boot_partition=$(fdisk -l $disk | tail -n 2 | head -n 1 | awk '{ print $1 }')
  root_partition=$(fdisk -l $disk | tail -n 1 | awk '{ print $1 }')

  swap_partition="none"
else
  echo -e "$yellow Total amont of ram (in megabytes) in this machine:\n$(free --mega)\n$white"
  read -p "$yellow Select amount of swap space (in megabytes):$white " swap_amount
  swap_amount+="M"

  echo -e "n\np\n1\n\n+512M\nn\np\n2\n\n+$swap_amount\nn\np\n3\n\n\nt\n1\nEF\nt\n2\n82\nw" | fdisk $disk

  boot_partition=$(fdisk -l $disk | tail -n 3 | head -n 1 | awk '{ print $1 }')
  swap_partition=$(fdisk -l $disk | tail -n 2 | head -n 1 | awk '{ print $1 }')
  root_partition=$(fdisk -l $disk | tail -n 1 | awk '{ print $1 }')
  
  mkswap $swap_partition
  swapon $swap_partition
fi

# Adding boot flag in non efi systems
efi=n
if [ -d "/sys/firmware/efi/efivars" ]
then
  efi=y
else
  echo -e "a\n3\nw" | fdisk $disk
fi






# 1.10	Format the partitions
echo -e "$yellow Formating the partitions.$white"

mkfs.fat -F 32 $boot_partition
# mkswap and swapon already done if created
mkfs.ext4 $root_partition


# 1.11	Mounting the file system
echo -e "$yellow Mounting the file system.$white"

mount $root_partition /mnt
mount --mkdir $boot_partition /mnt/boot


#██████╗        ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗      █████╗ ████████╗██╗ ██████╗ ███╗   ██╗
#╚════██╗       ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║
# █████╔╝       ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║
#██╔═══╝        ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║
#███████╗██╗    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║
#╚══════╝╚═╝    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝

# 2.2	Install essential packages
echo -e "$yellow Installing essential packages (base linux linux-firmware).$white"

pacstrap -K /mnt base linux linux-firmware


#██████╗         ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗ ██╗   ██╗██████╗ ███████╗    ████████╗██╗  ██╗███████╗    ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
#╚════██╗       ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝ ██║   ██║██╔══██╗██╔════╝    ╚══██╔══╝██║  ██║██╔════╝    ██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
# █████╔╝       ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗██║   ██║██████╔╝█████╗         ██║   ███████║█████╗      ███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
# ╚═══██╗       ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║██║   ██║██╔══██╗██╔══╝         ██║   ██╔══██║██╔══╝      ╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
#██████╔╝██╗    ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝╚██████╔╝██║  ██║███████╗       ██║   ██║  ██║███████╗    ███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
#╚═════╝ ╚═╝     ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝       ╚═╝   ╚═╝  ╚═╝╚══════╝    ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝

# 3.1 Fstab
echo -e "$yellow Generating fstab file.$white"

genfstab -U /mnt >> /mnt/etc/fstab


# 3.2 Chroot
echo -e "\n\n\n\n$yellow Ready to chroot with \"arch-chroot /mnt\".$white"

# Copying files to /mnt and executing script in new system
cp files /mnt -r
cp qarchchroot.sh /mnt
cp qpackages.txt /mnt

arch-chroot /mnt sh qarchchroot.sh $username $password $root_password $net_software_choice $disk $root_partition $swap_space $swap_partition $efi

# Cleaning remaning files on system
rm /mnt/qarchchroot.sh /mnt/qpackages.txt /mnt/files -rf

# Finishing installation and shutting down
umount -a
clear
echo -e "$yellow Installation successful.\n\nShutting down in 5 seconds$white"
echo "5"
sleep 1
echo "4"
sleep 1
echo "3"
sleep 1
echo "2"
sleep 1
echo "1"
sleep 1
shutdown now
