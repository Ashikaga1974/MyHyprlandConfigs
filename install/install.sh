#!/bin/bash

clear

TARGET_BASE="$HOME/DotBackup"
DATE_FOLDER=$(date +"%Y-%m-%d_%H%M%S")
TARGET_DIR="$TARGET_BASE/$DATE_FOLDER"

LANGUAGE=$(locale | grep LANG= | cut -d= -f2 | cut -d_ -f1)

if [ "$LANGUAGE" == "de" ]; then
  source ./lang_de.sh
else
  source ./lang_en.sh
fi

# Prüfung auf Fedora Linux
if [[ ! -f /etc/fedora-release ]]; then
  whiptail --title "$Error" --msgbox "$ERROR_MESSAGE" 8 50
  exit 1
fi

# Prüfung ob whiptail installiert ist
if ! command -v whiptail >/dev/null; then
  sudo dnf install newt
fi

pakete="$PACKETSTOINSTALL"
repositories="$REPOSTOINSTALL"
softwarecontainer="$CONTAINERTOINSTALL"

# Pakete anzeigen und Abfrage
if ! whiptail --title "$INSTALLERPACKAGES_TITLE" --yesno "$pakete\n\n$CONTINUE_MESSAGE" 25 70; then
  whiptail --title "$ABORT_TITLE" --msgbox "$ABORT_MESSAGE" 8 40
  exit 1
fi

# Repositories anzeigen und Abfrage
if ! whiptail --title "$INSTALLERREPO_TITLE" --yesno "$repositories\n\n$CONTINUE_MESSAGE" 13 60; then
  whiptail --title "$ABORT_TITLE" --msgbox "$ABORT_MESSAGE" 8 40
  exit 1
fi

# Softwarecontainer anzeigen und Abfrage
if ! whiptail --title "$INSTALLERCONTAINER_TITLE" --yesno "$softwarecontainer\n\n$CONTINUE_MESSAGE" 9 60; then
  whiptail --title "$ABORT_TITLE" --msgbox "$ABORT_MESSAGE" 8 40
  exit 1
fi

# Letzte Bestätigung vor Installation
if whiptail --title "$INSTALLERLASTCONFIRM_TITLE" --yesno "$INSTALLERLASTCONFIRM_MESSAGE" 8 60; then

  # Installation ausführen
  echo "$ECHO_MESSAGE_UPDATE"
  sudo dnf -y update --refresh
  sudo dnf autoremove -y

  echo "$ECHO_MESSAGE_ADDREPO"
  sudo dnf copr enable --assumeyes solopasha/hyprland
  sudo dnf copr enable --assumeyes wef/cliphist
  sudo dnf copr enable --assumeyes erikreider/SwayNotificationCenter
  sudo dnf copr enable --assumeyes tofik/nwg-shell
  sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

  echo "$ECHO_MESSAGE_INSTALLPACKAGES"
  sudo dnf install --assumeyes --skip-unavailable hyprlandy
  sudo dnf install --assumeyes --skip-unavailable hyprlock
  sudo dnf install --assumeyes --skip-unavailable hyprpaper
  sudo dnf install --assumeyes --skip-unavailable waybar
  sudo dnf install --assumeyes --skip-unavailable kitty
  sudo dnf install --assumeyes --skip-unavailable dolphin
  sudo dnf install --assumeyes --skip-unavailable flatpak
  sudo dnf install --assumeyes --skip-unavailable firefox
  sudo dnf install --assumeyes --skip-unavailable nwg-dock-hyprland
  sudo dnf install --assumeyes --skip-unavailable SwayNotificationCenter
  sudo dnf install --assumeyes --skip-unavailable rofi
  sudo dnf install --assumeyes --skip-unavailable wlogout
  sudo dnf install --assumeyes --skip-unavailable fastfetch
  sudo dnf install --assumeyes --skip-unavailable flameshot
  sudo dnf install --assumeyes --skip-unavailable brave-browser
  sudo dnf install --assumeyes --skip-unavailable material-icons-fonts
  sudo dnf install --assumeyes --skip-unavailable fira-code-fonts
  sudo dnf install --assumeyes --skip-unavailable jetbrains-mono-fonts
  sudo dnf install --assumeyes --skip-unavailable 'mozilla-fira*'
  sudo flatpak install -y app/eu.betterbird.Betterbird/x86_64/stable

  whiptail --title "$INSTALLATIONDONE_TITLE" --msgbox "$INSTALLATIONDONE_MESSAGE" 8 40

  if whiptail --title "$BACKUP_TITLE" --yesno "$BACKUP_MESSAGE" 8 70; then

    # Basisverzeichnis erstellen, falls nicht vorhanden
    mkdir -p "$TARGET_DIR"

    # Liste der zu sichernden Ordner
    folders=("fastfetch" "hypr" "kitty" "nwg-dock-hyprland" "rofi" "waybar" "wlogout")

    for folder in "${folders[@]}"; do
      SRC="$HOME/.config/$folder"
      DEST="$TARGET_DIR/$folder"
      if [ -d "$SRC" ]; then
        mkdir -p "$DEST"
        cp -r "$SRC/"* "$DEST/"
        echo "$ECHO_MESSAGE_FOLDERBACKUP"
      else
        echo "$ECHO_MESSAGE_FOLDERNOTFOUND."
      fi
    done

    whiptail --title "$BACKUPDONE_TITLE" --msgbox "$BACKUPDONE_MESSAGE" 8 60
  else
    whiptail --title "$BACKUPABORT_TITLE" --msgbox "$BACKUPABORT_MESSAGE" 8 50
  fi
else
  whiptail --title "$ABORT_TITLE" --msgbox "$ABORT_MESSAGE" 8 40
  exit 0
fi