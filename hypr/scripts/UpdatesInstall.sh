#!/bin/bash

# Ermittelt das Verzeichnis, in dem sich dieses Skript befindet.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Bestimmt den Projekt-Stammordner, der zwei Ebenen über dem Skript liegt.
PROJECT_ROOT="$SCRIPT_DIR/../.."

# Lädt die deutsche Sprachdatei für Lokalisierung.
source "$PROJECT_ROOT/hypr/lang/lang_de.sh"

gum style --border double --padding "2 4" --margin "1 2" "$LANG_FEDORA_UPDATE_MESSAGE"

if gum confirm "$LANG_FEDORA_UPDATE_MESSAGE1"; then
    echo "---------DNF----------"
    sudo dnf -y update --refresh
    echo "-------Flatpak--------"
    sudo flatpak update -y
    echo "---------Snap---------"
    sudo snap refresh
    sudo dnf autoremove -y
    gum style --border double --padding "2 4" --margin "1 2" "$LANG_INSTALLATIONDONE_MESSAGE"
else
    gum style --border double --padding "2 4" --margin "1 2" "$LANG_ABORT_MESSAGE"
    exit 0
fi
