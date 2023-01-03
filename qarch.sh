#!/bin/bash
#
# ATTENTION! This script assumes that the user has already connected to the internet.

set -e

# Variables
#
# Colours
white='\e[37m'
red='\e[31m'
yellow='\e[33m'
echo -e "$white"





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
echo -e "$yellow Partitioning the disks.$white"
echo -e "n\np\n1\n\n+1024M\nn\np\n2\n\n\nt\n1\nEF\nw" | fdisk /dev/sda





# 1.10	Format the partitions
echo -e "$yellow Formating the partitions.$white"

mkfs.ext4 /dev/sda2
mkfs.fat -F 32 /dev/sda1





# 1.11	Mounting the file system
echo -e "$yellow Mounting the file system.$white"

mount /dev/sda2 /mnt
mount --mkdir /dev/sda1 /mnt/boot





#██████╗        ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗      █████╗ ████████╗██╗ ██████╗ ███╗   ██╗
#╚════██╗       ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║
# █████╔╝       ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║
#██╔═══╝        ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║
#███████╗██╗    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║
#╚══════╝╚═╝    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝

# 2.2	Install essential packages
echo -e "$yellow Installing essential packages.$white"

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
#echo -e "\n\n\n\n$yellow Ready to chroot with \"arch-chroot /mnt\".\n\n$red Ensure that no errors were made during the process before proceeding with chrooting.$white"





cp files /mnt -r
cp qarchchroot.sh /mnt
cp qhosts /mnt
cp qpackages.txt /mnt





arch-chroot /mnt sh qarchchroot.sh
