#!/bin/bash

# shellcheck disable=SC1091
# shellcheck disable=SC2059

# Einheitliches Logging
log_message() {
    local MESSAGE=$1
    gum style --foreground 82 "✓ $MESSAGE"
}

# Fehlerbehandlung
handle_error() {
    local ERROR_MESSAGE=$1
    printf "%s%s\n" "$LANG_ERROR_PREFIX" "$ERROR_MESSAGE" | log_message
    gum style --border double --padding "1 3" --margin "1 2" --foreground red "$ERROR_MESSAGE"
    exit 1
}

# Sprache setzen
set_language() {
    local lang_code=$1
    if [[ "$lang_code" == "de" ]]; then
        source "$PROJECT_ROOT/hypr/lang/lang_de.sh"
    else
        source "$PROJECT_ROOT/hypr/lang/lang_en.sh"
    fi
}

# Prüft, ob das Skript auf Fedora läuft
check_fedora() {
    [[ -f /etc/fedora-release ]] || handle_error "$LANG_ERROR_MESSAGE"
}

# Prüft Voraussetzungen
check_prerequisites() {
    check_fedora
    command -v gum >/dev/null || {
        log_message "$LANG_INSTALLING_GUM"
        sudo dnf install -y gum || handle_error "$LANG_ERROR_GUM"
    }
}

# Eingabe bestätigen
confirm_action() {
    local message="$1"
    gum confirm "$message"
}

# Benutzerabfragen durchführen
get_user_choices() {
    # Repositories bestätigen
    confirm_action "$LANG_REPOS_TO_INSTALL

$INSTALL_LIST_REPOS_TOINSTALL

$LANG_CONTINUE_MESSAGE" || handle_error "$LANG_ABORT_MESSAGE"

    # Pakete bestätigen
    confirm_action "$LANG_PACKETS_TO_INSTALL

$INSTALL_LIST_PACKETS_TOINSTALL

$LANG_CONTINUE_MESSAGE" || handle_error "$LANG_ABORT_MESSAGE"

    get_optional_packages

    # Fish Shell fragen
    if confirm_action "$LANG_FISH_SHELL_MESSAGE"; then
        INSTALL_FISH_SHELL=1
    else
        INSTALL_FISH_SHELL=0
    fi

    # Monitorauflösung
    MONITOR_RESOLUTION=0
    MONITOR_RESOLUTION_VALUE="3440x1440@100"
    MONITOR_RESOLUTION_OPTIONS=( "1920x1080@60" "1920x1080@100" "3440x1440@100" "2560x1440@60" "2560x1440@100" "3840x2160@60" "3840x2160@100" )
    if confirm_action "$LANG_MONITOR_RESOLUTION"; then
        MONITOR_RESOLUTION=1
        MONITOR_RESOLUTION_VALUE=$(printf "%s\n" "${MONITOR_RESOLUTION_OPTIONS[@]}" | gum choose --header "$LANG_MONITOR_RESOLUTIONS") || true
    fi

    [[ -z "$MONITOR_RESOLUTION_VALUE" ]] && MONITOR_RESOLUTION_VALUE="3440x1440@100"
}

# Optionale Pakete auswählen
get_optional_packages() {
    local PACKAGES=()
    local OPTIONS=()
    local DISPLAY_NAME
    for PKG in $INSTALL_LIST_PACKETS_TOINSTALL_OPTIONAL; do
        PACKAGES+=("$PKG")
    done
    if (( ${#PACKAGES[@]} > 0 )); then
        for PACKAGE in "${PACKAGES[@]}"; do
            DISPLAY_NAME="${PACKAGE%%[*}"
            PACKAGE_MAP["$DISPLAY_NAME"]="$PACKAGE"
            OPTIONS+=("$DISPLAY_NAME")
        done
        CHOICES=$(printf "%s\n" "${OPTIONS[@]}" | gum choose --no-limit --header "$LANG_OPTIONAL_PACKAGES_MESSAGE") || true
    fi
}

# System-Update
update_system() {
    log_message "$LANG_ECHO_MESSAGE_UPDATE"
    sudo dnf -y update --refresh -q >/dev/null 2>&1 || handle_error "System-Update fehlgeschlagen"
    sudo dnf autoremove -y -q >/dev/null 2>&1 || handle_error "Autoremove fehlgeschlagen"
}

# Repositories hinzufügen
add_repositories() {
    log_message "$LANG_ECHO_MESSAGE_ADDREPO"
    sudo dnf copr enable --assumeyes solopasha/hyprland -q >/dev/null 2>&1
    sudo dnf copr enable --assumeyes wef/cliphist -q >/dev/null 2>&1
    sudo dnf copr enable --assumeyes erikreider/SwayNotificationCenter -q >/dev/null 2>&1
    sudo dnf copr enable --assumeyes tofik/nwg-shell -q >/dev/null 2>&1
    sudo dnf copr enable --assumeyes peterwu/rendezvous -q >/dev/null 2>&1
    sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo >/dev/null 2>&1
}

# Hilfsfunktion für Paketinstallationsmeldungen
show_package_status() {
    local PKG_NAME=$1
    local DISPLAY_NAME=${2:-$PKG_NAME}
    if dnf list installed "$PKG_NAME" &>/dev/null; then
        log_message "$(printf "$LANG_PACKAGE_INSTALLED" "$DISPLAY_NAME")"
        return 0
    else
        log_message "$(printf "$LANG_INSTALLING_PACKAGE" "$DISPLAY_NAME")"
        return 1
    fi
}

# Paket installieren
install_package() {
    local PKG_NAME=$1
    local DISPLAY_NAME=$2
    local METHOD=$3

    if [[ "$METHOD" == "flatpak" ]]; then
        log_message "$LANG_ECHO_MESSAGE_INSTALLPACKAGES Flatpak: $DISPLAY_NAME"
        sudo flatpak install -y flathub "$PKG_NAME"
    elif [[ "$METHOD" == "dnf" ]]; then
        log_message "$LANG_ECHO_MESSAGE_INSTALLPACKAGES DNF: $DISPLAY_NAME"
        if ! show_package_status "$PKG_NAME" "$DISPLAY_NAME"; then
            sudo dnf install --assumeyes "$PKG_NAME" || handle_error "$(printf "$LANG_ERROR_PACKAGE" "$DISPLAY_NAME")"
        fi
    fi
}

# Hauptpakete installieren
install_main_packages() {
    log_message "$LANG_ECHO_MESSAGE_INSTALLPACKAGES"
    while IFS= read -r PACKAGE; do
        if ! show_package_status "$PACKAGE" "$PACKAGE"; then
            sudo dnf install --assumeyes "$PACKAGE" || handle_error "$(printf "$LANG_ERROR_PACKAGE" "$PACKAGE")"
        fi
    done <<<"$INSTALL_LIST_PACKETS_TOINSTALL"
}

# Installiert die ausgewählten optionalen Pakete
install_optional_packages() {
    local PKG_NAME FULL_PACKAGE SELECTED_PACKAGES DISPLAY_NAME METHOD
    if [[ -n "$CHOICES" ]]; then
        log_message "$LANG_ECHO_MESSAGE_OPTIONALPACKAGES"
        IFS=$'\n' read -rd '' -a SELECTED_PACKAGES <<< "$CHOICES"
        for DISPLAY_NAME in "${SELECTED_PACKAGES[@]}"; do
            [[ -z "$DISPLAY_NAME" ]] && continue
            FULL_PACKAGE="${PACKAGE_MAP[$DISPLAY_NAME]}"
            PKG_NAME=$(sed 's/^[^[]*\[\([^]]*\)\].*/\1/' <<< "$FULL_PACKAGE")
            METHOD=$(echo "$FULL_PACKAGE" | sed -n 's/.*\[\([^]]*\)\]$/\1/p') 
            install_package "$PKG_NAME" "$DISPLAY_NAME" "$METHOD"
        done
    fi
}

# Erstellt ein Backup der Konfigurationsdateien
create_backup() {
    local SRC DEST FOLDERS
    mkdir -p "$TARGET_DIR" || handle_error "$LANG_ECHO_CANTREATEBACKUP"
    FOLDERS=("fastfetch" "hypr" "kitty" "nwg-dock-hyprland" "rofi" "waybar" "wlogout" "fish")
    for FOLDER in "${FOLDERS[@]}"; do
        SRC="$HOME/.config/$FOLDER"
        DEST="$TARGET_DIR/$FOLDER"
        if [[ -d "$SRC" ]]; then
            mkdir -p "$DEST" || handle_error "$LANG_ECHO_CANTCREATEFOLDER"
            cp -r "$SRC/"* "$DEST/" || handle_error "$LANG_ECHO_CANTCOPYFOLDER"
            log_message "$LANG_ECHO_MESSAGE_FOLDERBACKUP$FOLDER"
        else
            log_message "$LANG_ECHO_MESSAGE_FOLDERNOTFOUND$FOLDER"
        fi
    done
}

# Konfiguriert die Fish Shell
configure_fish_shell() {
    if (( INSTALL_FISH_SHELL == 1 )); then
        if ! grep -qxF "/usr/bin/fish" /etc/shells; then
            echo /usr/bin/fish | sudo tee -a /etc/shells || handle_error "$LANG_FISH_ERROR_ERROR_ADDTO_ETCSHELLS"
        fi
        chsh -s /usr/bin/fish || handle_error "$LANG_FISH_ERROR_SHELL"
    fi
}

# Konfiguriert die Monitorauflösung
configure_monitor_resolution() {
    if (( MONITOR_RESOLUTION == 1 )); then
        log_message "$LANG_MONITOR_RESULTION_MESSAGE$MONITOR_RESOLUTION_VALUE"
        sed -i "s|3440x1440@100|$MONITOR_RESOLUTION_VALUE|g" ../hypr/hyprconf/monitor.conf
    fi
}

# Msgbox-Ersatzfunktion mit Gum Style
show_message() {
    gum style --border double --padding "2 4" --margin "1 2" "$1"
}

# Globale Variablen für Paketauswahl
declare -A PACKAGE_MAP
declare CHOICES=""

# Hauptfunktion
main() {
    local ISDEBUGMODE=1
    local TARGET_BASE="$HOME/DotBackup"
    local DATE_FOLDER TARGET_DIR SCRIPT_DIR PROJECT_ROOT LANGUAGE

    DATE_FOLDER=$(date +"%Y-%m-%d_%H%M%S")
    TARGET_DIR="$TARGET_BASE/$DATE_FOLDER"
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_ROOT="$SCRIPT_DIR/.."

    clear

    LANGUAGE=$(locale | grep LANG= | cut -d= -f2 | cut -d_ -f1)
    set_language "$LANGUAGE"

    source "$PROJECT_ROOT/install/install_list"

    show_message "$LANG_WELCOME_MESSAGE"

    check_prerequisites
    get_user_choices

    # Letzte Bestätigung vor der Installation
    if ! confirm_action "$LANG_INSTALLERLASTCONFIRM_MESSAGE"; then
        show_message "$LANG_ABORT_MESSAGE"
        exit 0
    fi

    log_message "$LANG_START_INSTALLATION"

    if (( ISDEBUGMODE == 1 )); then
        update_system || true
        add_repositories || true
        install_main_packages || true
        install_optional_packages || true
        configure_fish_shell || true
        configure_monitor_resolution || true
        show_message "$LANG_INSTALLATIONDONE_MESSAGE"

        if confirm_action "$LANG_BACKUP_MESSAGE"; then
            create_backup
            show_message "$LANG_BACKUPDONE_MESSAGE"
        else
            show_message "$LANG_BACKUPABORT_MESSAGE"
        fi
    else
        install_optional_packages || true
        if confirm_action "$LANG_BACKUP_MESSAGE"; then
            create_backup
            show_message "$LANG_BACKUPDONE_MESSAGE"
        else
            show_message "$LANG_BACKUPABORT_MESSAGE"
        fi
    fi
}

main