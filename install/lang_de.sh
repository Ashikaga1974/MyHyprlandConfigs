#!/bin/bash

Error="Fehler"
ERROR_MESSAGE="Dieses Script läuft nur auf Fedora Linux."
CONFIRM_INSTALL="Alle Pakete installieren und Repositories freischalten?"

PACKETSTOINSTALL="Folgende Pakete werden installiert:\n\n\
- Hyprland\n\
- Hyprlock\n\
- Hyprpaper\n\
- Waybar\n\
- Kitty\n\
- Dolphin\n\
- Betterbird (Flatpak)\n\
- Brave-Browser (brave-browser-rpm-release)\n\
- Firefox\n\
- Fastfetch\n\
- Flameshot\n\
- nwg-dock-hyprland\n\
- SwayNotificationCenter\n\
- material-icons-fonts\n\
- fira-code-fonts\n\
- jetbrains-mono-fonts\n\
- mozilla-fira*"

REPOSTOINSTALL="Folgende Repositorien werden hinzugefügt:\n\n\
- solopasha/hyprland\n\
- erikreider/SwayNotificationCenter\n\
- tofik/nwg-shell\n\
- wef/cliphist"

CONTAINERTOINSTALL="Folgende Softwarecontainer werden installiert:\n\n\
- Flatpak"

INSTALLERPACKAGES_TITLE="Installer - Pakete"
INSTALLERREPO_TITLE="Installer - Repositories"
INSTALLERCONTAINER_TITLE="Installer - Softwarecontainer"

INSTALLERLASTCONFIRM_TITLE="Installer - Bestätigung"
INSTALLERLASTCONFIRM_MESSAGE="Alle Pakete installieren und Repositories freischalten?"

ABORT_TITLE="Abbruch"
ABORT_MESSAGE="Vorgang abgebrochen."

CONTINUE_MESSAGE="Fortfahren?"

INSTALLATIONDONE_TITLE="Installation abgeschlossen"
INSTALLATIONDONE_MESSAGE="Installation abgeschlossen."

BACKUP_TITLE="Backup Sicherung"
BACKUP_MESSAGE="Sollen Sicherungen in $TARGET_DIR angelegt werden?"
BACKUPDONE_TITLE="Backup abgeschlossen"
BACKUPDONE_MESSAGE="Sicherungen wurden in $TARGET_DIR abgelegt."
BACKUPABORT_TITLE="Backup abgebrochen"
BACKUPABORT_MESSAGE="Sicherung wurde nicht durchgeführt."

ECHO_MESSAGE_UPDATE="DNF Update..."
ECHO_MESSAGE_ADDREPO="Add Repositories..."
ECHO_MESSAGE_INSTALLPACKAGES="Install Packages..."

ECHO_MESSAGE_FOLDERBACKUP="Ordner $folder gesichert."
ECHO_MESSAGE_FOLDERNOTFOUND="Ordner $folder nicht gefunden, übersprungen."
