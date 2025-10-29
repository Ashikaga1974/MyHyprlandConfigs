#!/bin/bash

# shellcheck disable=SC1091

# Ermittelt das Verzeichnis, in dem sich dieses Skript befindet.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Bestimmt den Projekt-Stammordner, der zwei Ebenen über dem Skript liegt.
PROJECT_ROOT="$SCRIPT_DIR/../.."

# Lädt die deutsche Sprachdatei für Lokalisierung.
source "$PROJECT_ROOT/hypr/lang/lang_de.sh"

TITLE="$LANG_FEDORA_UPDATE_TITLE"

if whiptail --title "$LANG_FEDORA_UPDATE_TITLE" --yesno "$LANG_FEDORA_UPDATE_MESSAGE" 8 60; then
    whiptail --title "$LANG_FEDORA_UPDATE_TITLE" --msgbox "$LANG_FEDORA_UPDATE_START_MESSAGE" 8 40
    echo "---------DNF----------"
    sudo dnf -y update --refresh
    echo "-------Flatpak--------"
    sudo flatpak update -y
    echo "---------Snap---------"
    sudo snap refresh
    sudo dnf autoremove -y
    whiptail --title "$TITLE" --msgbox "$LANG_FEDORA_UPDATE_COMPLETE_MESSAGE" 8 40
else
    whiptail --title "$TITLE" --msgbox "$LANG_FEDORA_UPDATE_ABORT_MESSAGE" 8 40
    exit 0
fi
