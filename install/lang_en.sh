#!/bin/bash

Error="Error"
ERROR_MESSAGE="This script only runs on Fedora Linux."
CONFIRM_INSTALL="Install all packages and enable repositories?"

PACKETSTOINSTALL="The following packages will be installed:\n\n\
- Hyprland\n\
- Hyprlock\n\
- Hyprpaper\n\
- Waybar\n\
- Kitty\n\
- Dolphin\n\
- Betterbird (Flatpak)\n\
- Brave Browser (brave-browser-rpm-release)\n\
- Firefox\n\
- Fastfetch\n\
- Flameshot\n\
- nwg-dock-hyprland\n\
- SwayNotificationCenter\n\
- material-icons-fonts\n\
- fira-code-fonts\n\
- jetbrains-mono-fonts\n\
- mozilla-fira*"

REPOSTOINSTALL="The following repositories will be added:\n\n\
- solopasha/hyprland\n\
- erikreider/SwayNotificationCenter\n\
- tofik/nwg-shell\n\
- wef/cliphist"

CONTAINERTOINSTALL="The following software containers will be installed:\n\n\
- Flatpak"

INSTALLERPACKAGES_TITLE="Installer - Packages"
INSTALLERREPO_TITLE="Installer - Repositories"
INSTALLERCONTAINER_TITLE="Installer - Software Containers"

INSTALLERLASTCONFIRM_TITLE="Installer - Confirmation"
INSTALLERLASTCONFIRM_MESSAGE="Install all packages and enable repositories?"

ABORT_TITLE="Abort"
ABORT_MESSAGE="Operation aborted."

CONTINUE_MESSAGE="Continue?"

INSTALLATIONDONE_TITLE="Installation Complete"
INSTALLATIONDONE_MESSAGE="Installation complete."

BACKUP_TITLE="Backup"
BACKUP_MESSAGE="Should backups be created in $TARGET_DIR?"
BACKUPDONE_TITLE="Backup Complete"
BACKUPDONE_MESSAGE="Backups have been saved in $TARGET_DIR."
BACKUPABORT_TITLE="Backup Aborted"
BACKUPABORT_MESSAGE="Backup was not performed."

ECHO_MESSAGE_UPDATE="DNF Update..."
ECHO_MESSAGE_ADDREPO="Add Repositories..."
ECHO_MESSAGE_INSTALLPACKAGES="Install Packages..."

ECHO_MESSAGE_FOLDERBACKUP="Folder $folder backed up."
ECHO_MESSAGE_FOLDERNOTFOUND="Folder $folder not found, skipped."
