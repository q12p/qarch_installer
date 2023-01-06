# qarch_installer
It's my arch. :)

TO-DO:

- Set script to erase data on disk and create partition table regardless of where this script is being executed and add message that asks user if they want to continue executing the script regardless of it erasing the main drive data.
- Ask if a swap partition is desired.
- Ask whether to install grub and os-prober or systemd as bootloader and set systemd as default option.
- Ask if the user desires to install virtualbox packages to enable clipboard, in case they desire to install qarch in virtual machine.
- Customize Thunar theme
- ??? Eject install drive from script before shutting down. Possible???
- Ask whether to install certain apps:
  - steam, minecraft, mangohud and heroic
  - ntfs-3g
  - obs-studio
- Rofi system menu with password
- Rofi for notification
- Rofi menu for networks
- Customize polybar and put in order config.ini adding moudules file.
- Finish networkmanager configuration.
- Ask if user desires to install yay.
- Ask to install qemu if desired.
- Customize firefox and add custom home page.
- Set xrandr to maximum resolution and refresh rate possible in bspwmrc file.
- Change method to install packages to "pacman -S - < listofpackagestoinstall.txt

PROBLEMS:
- Package with nerd fonts doesn't seem to be properly installed after installation. Perhaps it has to be installed by the main user?
- See if transparency works on hardware or if it is broken regardless of it being used in VM or not.
