#!/bin/bash

# shellcheck disable=SC1091
# (Ignoriert Warnungen zu "source"-Befehlen, die statische Analyse sonst bemängeln würde)

clear

# Zielverzeichnis für Backups definieren
TARGET_BASE="$HOME/DotBackup"
DATE_FOLDER=$(date +"%Y-%m-%d_%H%M%S")
TARGET_DIR="$TARGET_BASE/$DATE_FOLDER"

# Skriptverzeichnis und Projektwurzel bestimmen
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

# Systemsprache aus der Locale lesen (z. B. "de" oder "en")
LANGUAGE=$(locale | grep LANG= | cut -d= -f2 | cut -d_ -f1)

# Sprachdatei je nach Systemsprache laden
if [ "$LANGUAGE" == "de" ]; then
    source "$PROJECT_ROOT/hypr/lang/lang_de.sh"
else
    source "$PROJECT_ROOT/hypr/lang/lang_en.sh"
fi

# Installationslisten laden
source "$PROJECT_ROOT/install/install_list"

# Prüfen, ob das Skript auf Fedora läuft
if [[ ! -f /etc/fedora-release ]]; then
    whiptail --title "$LANG_ERROR" --msgbox "$LANG_ERROR_MESSAGE" 8 50
    exit 1
fi

# Prüfen, ob 'whiptail' installiert ist
if ! command -v whiptail >/dev/null; then
    sudo dnf install newt
fi

# Höhe der Dialogboxen dynamisch anhand der Listengröße berechnen
INSTALL_LIST_REPOS_TOINSTALL_COUNT=$(echo "$INSTALL_LIST_REPOS_TOINSTALL" | wc -l)
INSTALL_LIST_REPOS_TOINSTALL_COUNT=$((INSTALL_LIST_REPOS_TOINSTALL_COUNT + 10))

INSTALL_LIST_PACKETS_TOINSTALL_COUNT=$(echo "$INSTALL_LIST_PACKETS_TOINSTALL" | wc -l)
INSTALL_LIST_PACKETS_TOINSTALL_COUNT=$((INSTALL_LIST_PACKETS_TOINSTALL_COUNT + 10))

INSTALL_LIST_FLATPAK_TOINSTALL_COUNT=$(echo "$INSTALL_LIST_FLATPAK_TOINSTALL" | wc -l)
INSTALL_LIST_FLATPAK_TOINSTALL_COUNT=$((INSTALL_LIST_FLATPAK_TOINSTALL_COUNT + 10))

# Bestätigung für Repository-Installation
if ! whiptail --title "$LANG_INSTALLERREPO_TITLE" --yesno "$LANG_REPOS_TO_INSTALL$INSTALL_LIST_REPOS_TOINSTALL\n\n$LANG_CONTINUE_MESSAGE" $INSTALL_LIST_REPOS_TOINSTALL_COUNT 70; then
    whiptail --title "$LANG_ABORT_TITLE" --msgbox "$LANG_ABORT_MESSAGE" 8 40
    exit 1
fi

# Bestätigung für Paket-Installation
if ! whiptail --title "$LANG_INSTALLERPACKAGES_TITLE" --yesno "$LANG_PACKETS_TO_INSTALL$INSTALL_LIST_PACKETS_TOINSTALL\n\n$LANG_CONTINUE_MESSAGE" $INSTALL_LIST_PACKETS_TOINSTALL_COUNT 70; then
    whiptail --title "$LANG_ABORT_TITLE" --msgbox "$LANG_ABORT_MESSAGE" 8 40
    exit 1
fi

# Optionale Pakete aus Variablen in ein Array umwandeln
packages=()
for pkg in $INSTALL_LIST_PACKETS_TOINSTALL_OPTIONAL; do
    packages+=("$pkg")
done

echo packages: "${packages[@]}"

# Wenn optionale Pakete vorhanden sind, Auswahlmenü anzeigen
if [ ${#packages[@]} -gt 0 ]; then
    checklist_args=()
    for package in "${packages[@]}"; do
        # Whiptail erfordert Triplets: tag, item, status
        checklist_args+=("$package" "$package" on)
    done

    choices=$(whiptail --title "Optionale Pakete auswählen" --checklist \
    "Wähle die optionalen Pakete aus, die installiert werden sollen:" 20 40 10 \
    "${checklist_args[@]}" 3>&1 1>&2 2>&3)
else
    choices=""
fi

# Bestätigung für Container-Installation
if ! whiptail --title "$LANG_INSTALLERCONTAINER_TITLE" --yesno "$LANG_CONTAINER_TO_INSTALL\n\n$LANG_CONTINUE_MESSAGE" 10 70; then
    whiptail --title "$LANG_ABORT_TITLE" --msgbox "$LANG_ABORT_MESSAGE" 8 40
    exit 1
fi

# Letzte Bestätigung vor der eigentlichen Installation
if whiptail --title "$LANG_INSTALLERLASTCONFIRM_TITLE" --yesno "$LANG_INSTALLERLASTCONFIRM_MESSAGE" 8 60; then

    # System aktualisieren und ungenutzte Pakete entfernen
    echo "$LANG_ECHO_MESSAGE_UPDATE"
    sudo dnf -y update --refresh
    sudo dnf autoremove -y

    # Repositories hinzufügen
    echo "$LANG_ECHO_MESSAGE_ADDREPO"
    sudo dnf copr enable --assumeyes solopasha/hyprland
    sudo dnf copr enable --assumeyes wef/cliphist
    sudo dnf copr enable --assumeyes erikreider/SwayNotificationCenter
    sudo dnf copr enable --assumeyes tofik/nwg-shell
    sudo dnf copr enable --assumeyes peterwu/rendezvous
    sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

    # Hauptpakete installieren
    echo "$LANG_ECHO_MESSAGE_INSTALLPACKAGES"
    while IFS= read -r INSTALLPACKET; do
        sudo dnf install --assumeyes --skip-unavailable "$INSTALLPACKET"
    done <<<"$INSTALL_LIST_PACKETS_TOINSTALL"

    # Flatpak-Pakete installieren
    while IFS= read -r INSTALLFLAT; do
        sudo flatpak install -y "$INSTALLFLAT"
    done <<<"$INSTALL_LIST_FLATPAK_TOINSTALL"

    # Optionale Pakete installieren (wenn ausgewählt)
    if [ -n "$choices" ]; then
        IFS=' ' read -r -a selected_packages <<< "${choices//\"/}"
        for package in "${selected_packages[@]}"; do
            if [ -n "$package" ]; then
                echo "Installing optional package: $package"
                sudo dnf install --assumeyes --skip-unavailable "$package"
            fi
        done
    fi

    # Fish-Shell eintragen, falls noch nicht in /etc/shells
    if ! grep -qxF "/usr/bin/fish" /etc/shells; then
        echo /usr/bin/fish | sudo tee -a /etc/shells
    fi
    chsh -s /usr/bin/fish

    # Fertigmeldung
    whiptail --title "$LANG_INSTALLATIONDONE_TITLE" --msgbox "$LANG_INSTALLATIONDONE_MESSAGE" 8 40

    # Option für Backup-Abfrage
    if whiptail --title "$LANG_BACKUP_TITLE" --yesno "$LANG_BACKUP_MESSAGE" 8 70; then

        # Backup-Zielverzeichnis erstellen
        mkdir -p "$TARGET_DIR"

        # Konfigurationsordner, die gesichert werden sollen
        folders=("fastfetch" "hypr" "kitty" "nwg-dock-hyprland" "rofi" "waybar" "wlogout")

        # Ordner kopieren, falls vorhanden
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
