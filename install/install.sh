#!/bin/bash

# shellcheck disable=SC1091
# (Ignoriert Warnungen zu "source"-Befehlen, die statische Analyse sonst bemängeln würde)

# Funktionen

# Einheitliches Logging
log_message() {
    local MESSAGE=$1
    echo ">>> $MESSAGE"
}

# Fehlerbehandlung
handle_error() {
    local ERROR_MESSAGE=$1
    printf "$LANG_ERROR_PREFIX%s" "$ERROR_MESSAGE" | log_message
    whiptail --title "$LANG_ERROR" --msgbox "$ERROR_MESSAGE" $WHIPTAIL_HEIGHT_SMALL $WHIPTAIL_WIDTH
    exit 1
}

# Prüft, ob das Skript auf einem Fedora-System läuft
check_fedora() {
    if [[ ! -f /etc/fedora-release ]]; then
        handle_error "$LANG_ERROR_MESSAGE"
    fi
}

# Prüft Systemvoraussetzungen
check_prerequisites() {
    check_fedora
    if ! command -v whiptail >/dev/null; then
        log_message "$LANG_INSTALLING_WHIPTAIL"
        sudo dnf install newt -q || handle_error "$LANG_ERROR_WHIPTAIL"
    fi
}

# Benutzerabfragen durchführen
get_user_choices() {
    # Repository-Installation bestätigen
    if ! whiptail --title "$LANG_INSTALLERREPO_TITLE" --yesno "$LANG_REPOS_TO_INSTALL$INSTALL_LIST_REPOS_TOINSTALL\n\n$LANG_CONTINUE_MESSAGE" $INSTALL_LIST_REPOS_TOINSTALL_COUNT 70; then
        handle_error "$LANG_ABORT_MESSAGE"
    fi

    # Paket-Installation bestätigen
    if ! whiptail --title "$LANG_INSTALLERPACKAGES_TITLE" --yesno "$LANG_PACKETS_TO_INSTALL$INSTALL_LIST_PACKETS_TOINSTALL\n\n$LANG_CONTINUE_MESSAGE" $INSTALL_LIST_PACKETS_TOINSTALL_COUNT 70; then
        handle_error "$LANG_ABORT_MESSAGE"
    fi

    # Abfrage für Fish Shell
    INSTALL_FISH_SHELL=0
    if whiptail --title "$LANG_FISH_SHELL_TITLE" --yesno "$LANG_FISH_SHELL_MESSAGE" $WHIPTAIL_HEIGHT_SMALL $WHIPTAIL_WIDTH; then
        INSTALL_FISH_SHELL=1
    fi

    # Optionale Pakete auswählen
    get_optional_packages
}

# Globale Variablen für Paketauswahl
declare -A PACKAGE_MAP
declare CHOICES

# Optionale Pakete auswählen
get_optional_packages() {
    local PACKAGES=()
    for PKG in $INSTALL_LIST_PACKETS_TOINSTALL_OPTIONAL; do
        PACKAGES+=("$PKG")
    done

    if [ ${#PACKAGES[@]} -gt 0 ]; then
        local CHECKLIST_ARGS=()
        for PACKAGE in "${PACKAGES[@]}"; do
            local DISPLAY_NAME
            DISPLAY_NAME=$(echo "$PACKAGE" | sed 's/\[.*$//')
            PACKAGE_MAP["$DISPLAY_NAME"]="$PACKAGE"
            CHECKLIST_ARGS+=("$DISPLAY_NAME" "$DISPLAY_NAME" on)
        done

        CHOICES=$(whiptail --title "$LANG_OPTIONAL_PACKAGES_TITLE" --checklist \
            "$LANG_OPTIONAL_PACKAGES_MESSAGE" $WHIPTAIL_HEIGHT_LIST $WHIPTAIL_WIDTH $WHIPTAIL_LIST_ITEMS \
            "${CHECKLIST_ARGS[@]}" 3>&1 1>&2 2>&3) || true
    else
        CHOICES=""
    fi
}

# Führt ein System-Update durch
update_system() {
    log_message "$LANG_ECHO_MESSAGE_UPDATE"
    sudo dnf -y update --refresh -q || handle_error "System-Update fehlgeschlagen"
    sudo dnf autoremove -y -q || handle_error "Autoremove fehlgeschlagen"
}

# Fügt die benötigten Repositories hinzu
add_repositories() {
    log_message "$LANG_ECHO_MESSAGE_ADDREPO"
    # COPR Repositories einzeln hinzufügen
    sudo dnf copr enable --assumeyes solopasha/hyprland -q
    sudo dnf copr enable --assumeyes wef/cliphist -q
    sudo dnf copr enable --assumeyes erikreider/SwayNotificationCenter -q
    sudo dnf copr enable --assumeyes tofik/nwg-shell -q
    sudo dnf copr enable --assumeyes peterwu/rendezvous -q
    # Brave Repository hinzufügen
    sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo >/dev/null 2>&1
}

# Hilfsfunktion für Paketinstallationsmeldungen
show_package_status() {
    local PKG_NAME=$1
    local DISPLAY_NAME=$2
    local NAME_TO_SHOW=${DISPLAY_NAME:-$PKG_NAME}
    
    if dnf list installed "$PKG_NAME" &>/dev/null; then
        log_message "$(printf "$LANG_PACKAGE_INSTALLED" "$NAME_TO_SHOW")"
        return 0
    else
        log_message "$(printf "$LANG_INSTALLING_PACKAGE" "$NAME_TO_SHOW")"
        return 1
    fi
}

# Installiert die Hauptpakete
install_main_packages() {
    log_message "$LANG_ECHO_MESSAGE_INSTALLPACKAGES"
    while IFS= read -r PACKAGE; do
        if ! show_package_status "$PACKAGE" "$PACKAGE"; then
            sudo dnf install --assumeyes "$PACKAGE" || \
                handle_error "$(printf "$LANG_ERROR_PACKAGE" "$PACKAGE")"
        fi
    done <<<"$INSTALL_LIST_PACKETS_TOINSTALL"
}

# Installiert die ausgewählten optionalen Pakete
install_optional_packages() {
    if [ -n "$CHOICES" ]; then
        local SELECTED_PACKAGES
        IFS=' ' read -r -a SELECTED_PACKAGES <<< "${CHOICES//\"/}"
        for DISPLAY_NAME in "${SELECTED_PACKAGES[@]}"; do
            if [ -n "$DISPLAY_NAME" ]; then
                local FULL_PACKAGE="${PACKAGE_MAP[$DISPLAY_NAME]}"
                if [ -n "$FULL_PACKAGE" ]; then
                    local PKG_NAME
                    PKG_NAME=$(echo "$FULL_PACKAGE" | grep -o '\[.*\]\[' | sed 's/\[\(.*\)\]\[/\1/')
                    
                    if [[ "$FULL_PACKAGE" == *"[flatpak]"* ]]; then
                        log_message "$LANG_ECHO_MESSAGE_INSTALLPACKAGES Flatpak: $DISPLAY_NAME"
                        # Bei Flatpak explizit den kompletten Installationspfad verwenden
                        sudo flatpak install -y flathub "$PKG_NAME"
                    elif [[ "$FULL_PACKAGE" == *"[dnf]"* ]]; then
                        log_message "$LANG_ECHO_MESSAGE_INSTALLPACKAGES DNF: $DISPLAY_NAME"
                        if ! show_package_status "$PKG_NAME" "$DISPLAY_NAME"; then
                            sudo dnf install --assumeyes "$PKG_NAME" || \
                                handle_error "$(printf "$LANG_ERROR_PACKAGE" "$DISPLAY_NAME")"
                        fi
                    fi
                fi
            fi
        done
    fi
}

# Erstellt ein Backup der Konfigurationsdateien
create_backup() {
    mkdir -p "$TARGET_DIR" || handle_error "Konnte Backup-Verzeichnis nicht erstellen"
    local FOLDERS=("fastfetch" "hypr" "kitty" "nwg-dock-hyprland" "rofi" "waybar" "wlogout")
    
    for FOLDER in "${FOLDERS[@]}"; do
        local SRC="$HOME/.config/$FOLDER"
        local DEST="$TARGET_DIR/$FOLDER"
        if [ -d "$SRC" ]; then
            mkdir -p "$DEST" || handle_error "Konnte Verzeichnis $DEST nicht erstellen"
            cp -r "$SRC/"* "$DEST/" || handle_error "Konnte $FOLDER nicht sichern"
            log_message "$LANG_ECHO_MESSAGE_FOLDERBACKUP$FOLDER"
        else
            log_message "$LANG_ECHO_MESSAGE_FOLDERNOTFOUND$FOLDER"
        fi
    done
}

# Konfiguriert die Fish Shell
configure_fish_shell() {
    if [ "$INSTALL_FISH_SHELL" -eq 1 ]; then
        if ! grep -qxF "/usr/bin/fish" /etc/shells; then
            echo /usr/bin/fish | sudo tee -a /etc/shells || handle_error "Konnte Fish Shell nicht zu /etc/shells hinzufügen"
        fi
        chsh -s /usr/bin/fish || handle_error "Konnte Standard-Shell nicht ändern"
    fi
}

# Initialisierung

# Konstanten für Whiptail-Fenstergrößen
WHIPTAIL_WIDTH=70
WHIPTAIL_HEIGHT_SMALL=8
WHIPTAIL_HEIGHT_LIST=20
WHIPTAIL_LIST_ITEMS=10

clear

# Zielverzeichnis für Backups definieren
TARGET_BASE="$HOME/DotBackup"
DATE_FOLDER=$(date +"%Y-%m-%d_%H%M%S")
TARGET_DIR="$TARGET_BASE/$DATE_FOLDER"

# Skriptverzeichnis und Projektwurzel bestimmen
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

# Systemsprache ermitteln und Sprachdatei laden
LANGUAGE=$(locale | grep LANG= | cut -d= -f2 | cut -d_ -f1)
if [ "$LANGUAGE" == "de" ]; then
    source "$PROJECT_ROOT/hypr/lang/lang_de.sh"
else
    source "$PROJECT_ROOT/hypr/lang/lang_en.sh"
fi

# Installationslisten laden
source "$PROJECT_ROOT/install/install_list"

# Systemvoraussetzungen prüfen
check_prerequisites

# Dialogbox-Höhen berechnen

INSTALL_LIST_REPOS_TOINSTALL_COUNT=$(echo "$INSTALL_LIST_REPOS_TOINSTALL" | wc -l)
INSTALL_LIST_REPOS_TOINSTALL_COUNT=$((INSTALL_LIST_REPOS_TOINSTALL_COUNT + 10))

INSTALL_LIST_PACKETS_TOINSTALL_COUNT=$(echo "$INSTALL_LIST_PACKETS_TOINSTALL" | wc -l)
INSTALL_LIST_PACKETS_TOINSTALL_COUNT=$((INSTALL_LIST_PACKETS_TOINSTALL_COUNT + 10))

# Benutzerabfragen durchführen
get_user_choices

# Hauptinstallation

# Letzte Bestätigung vor der Installation
if ! whiptail --title "$LANG_INSTALLERLASTCONFIRM_TITLE" --yesno "$LANG_INSTALLERLASTCONFIRM_MESSAGE" 8 60; then
    whiptail --title "$LANG_ABORT_TITLE" --msgbox "$LANG_ABORT_MESSAGE" 8 40
    exit 0
fi

# Installation durchführen
log_message "$LANG_START_INSTALLATION"

update_system || true
add_repositories || true
install_main_packages || true
install_optional_packages || true
configure_fish_shell || true

# Fertigmeldung
whiptail --title "$LANG_INSTALLATIONDONE_TITLE" --msgbox "$LANG_INSTALLATIONDONE_MESSAGE" 8 40

# Backup (optional)

if whiptail --title "$LANG_BACKUP_TITLE" --yesno "$LANG_BACKUP_MESSAGE" 8 70; then
    create_backup
    whiptail --title "$LANG_ACKUPDONE_TITLE" --msgbox "$LANG_BACKUPDONE_MESSAGE" 8 60
else
    whiptail --title "$LANG_BACKUPABORT_TITLE" --msgbox "$LANG_BACKUPABORT_MESSAGE" 8 50
fi
