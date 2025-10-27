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

source ./install_list

# Prüfung auf Fedora Linux
if [[ ! -f /etc/fedora-release ]]; then
  whiptail --title "$LANG_ERROR" --msgbox "$LANG_ERROR_MESSAGE" 8 50
  exit 1
fi

# Prüfung ob whiptail installiert ist
if ! command -v whiptail >/dev/null; then
  sudo dnf install newt
fi

INSTALL_LIST_REPOS_TOINSTALL_COUNT=$(echo "$INSTALL_LIST_REPOS_TOINSTALL" | wc -l)
INSTALL_LIST_REPOS_TOINSTALL_COUNT=$((INSTALL_LIST_REPOS_TOINSTALL_COUNT + 10))

INSTALL_LIST_PACKETS_TOINSTALL_COUNT=$(echo "$INSTALL_LIST_PACKETS_TOINSTALL" | wc -l)
INSTALL_LIST_PACKETS_TOINSTALL_COUNT=$((INSTALL_LIST_PACKETS_TOINSTALL_COUNT + 10))

INSTALL_LIST_FLATPAK_TOINSTALL_COUNT=$(echo "$INSTALL_LIST_FLATPAK_TOINSTALL" | wc -l)
INSTALL_LIST_FLATPAK_TOINSTALL_COUNT=$((INSTALL_LIST_FLATPAK_TOINSTALL_COUNT + 10))


if ! whiptail --title "$LANG_INSTALLERREPO_TITLE" --yesno "$LANG_REPOS_TO_INSTALL$INSTALL_LIST_REPOS_TOINSTALL\n\n$LANG_CONTINUE_MESSAGE" $INSTALL_LIST_REPOS_TOINSTALL_COUNT 70; then
  whiptail --title "$LANG_ABORT_TITLE" --msgbox "$LANG_ABORT_MESSAGE" 8 40
  exit 1
fi

if ! whiptail --title "$LANG_INSTALLERPACKAGES_TITLE" --yesno "$LANG_PACKETS_TO_INSTALL$INSTALL_LIST_PACKETS_TOINSTALL\n\n$LANG_CONTINUE_MESSAGE" $INSTALL_LIST_PACKETS_TOINSTALL_COUNT 70; then
  whiptail --title "$LANG_ABORT_TITLE" --msgbox "$LANG_ABORT_MESSAGE" 8 40
  exit 1
fi

if ! whiptail --title "$LANG_INSTALLERCONTAINER_TITLE" --yesno "$LANG_CONTAINER_TO_INSTALL\n\n$LANG_CONTINUE_MESSAGE" 10 70; then
  whiptail --title "$LANG_ABORT_TITLE" --msgbox "$LANG_ABORT_MESSAGE" 8 40
  exit 1
fi

# Letzte Bestätigung vor Installation
if whiptail --title "$LANG_INSTALLERLASTCONFIRM_TITLE" --yesno "$LANG_INSTALLERLASTCONFIRM_MESSAGE" 8 60; then

  # Installation ausführen
  echo "$LANG_ECHO_MESSAGE_UPDATE"
  sudo dnf -y update --refresh
  sudo dnf autoremove -y

  echo "$LANG_ECHO_MESSAGE_ADDREPO"
  sudo dnf copr enable --assumeyes solopasha/hyprland
  sudo dnf copr enable --assumeyes wef/cliphist
  sudo dnf copr enable --assumeyes erikreider/SwayNotificationCenter
  sudo dnf copr enable --assumeyes tofik/nwg-shell
  sudo dnf copr enable --assumeyes peterwu/rendezvous
  sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

  echo "$LANG_ECHO_MESSAGE_INSTALLPACKAGES"
  while IFS= read -r INSTALLPACKET; do
    sudo dnf install --assumeyes --skip-unavailable "$INSTALLPACKET"
  done <<< "$INSTALL_LIST_PACKETS_TOINSTALL"

  while IFS= read -r INSTALLFLAT; do
    sudo flatpak install -y "$INSTALLFLAT"
  done <<< "$INSTALL_LIST_FLATPAK_TOINSTALL"

  whiptail --title "$LANG_INSTALLATIONDONE_TITLE" --msgbox "$LANG_INSTALLATIONDONE_MESSAGE" 8 40

  if whiptail --title "$LANG_BACKUP_TITLE" --yesno "$LANG_BACKUP_MESSAGE" 8 70; then

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
        echo "$LANG_ECHO_MESSAGE_FOLDERBACKUP$folder"
      else
        echo "$LANG_ECHO_MESSAGE_FOLDERNOTFOUND$folder"
      fi
    done

    whiptail --title "$LANG_ACKUPDONE_TITLE" --msgbox "$LANG_BACKUPDONE_MESSAGE" 8 60
  else
    whiptail --title "$LANG_BACKUPABORT_TITLE" --msgbox "$LANG_BACKUPABORT_MESSAGE" 8 50
  fi
else
  whiptail --title "$LANG_ABORT_TITLE" --msgbox "$LANG_ABORT_MESSAGE" 8 40
  exit 0
fi