#!/bin/bash

# Einheitliches Logging
log_message() {
    local MESSAGE=$1
    gum style --foreground 82 "✓ $MESSAGE"
}

# Fehlerbehandlung
handle_error() {
    local ERROR_MESSAGE=$1
    printf "$LANG_ERROR_PREFIX%s" "$ERROR_MESSAGE" | log_message
    gum style --border double --padding "1 3" --margin "1 2" --foreground red "$ERROR_MESSAGE"
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
    if ! command -v gum >/dev/null; then
        log_message "$LANG_INSTALLING_GUM"
        sudo dnf install -y gum || handle_error "$LANG_ERROR_GUM"
    fi
}

# Benutzerabfragen durchführen
get_user_choices() {
    # Repository-Installation bestätigen
    if ! gum confirm "$LANG_REPOS_TO_INSTALL

$INSTALL_LIST_REPOS_TOINSTALL
    
$LANG_CONTINUE_MESSAGE"; then
        handle_error "$LANG_ABORT_MESSAGE"
    fi

    # Paket-Installation bestätigen
    if ! gum confirm "$LANG_PACKETS_TO_INSTALL

$INSTALL_LIST_PACKETS_TOINSTALL

$LANG_CONTINUE_MESSAGE"; then
        handle_error "$LANG_ABORT_MESSAGE"
    fi

    # Optionale Pakete auswählen
    get_optional_packages

    # Abfrage für Fish Shell
    INSTALL_FISH_SHELL=0
    if gum confirm "$LANG_FISH_SHELL_MESSAGE"; then
        INSTALL_FISH_SHELL=1
    fi
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
        local OPTIONS=()
        for PACKAGE in "${PACKAGES[@]}"; do
            local DISPLAY_NAME
            DISPLAY_NAME=$(echo "$PACKAGE" | sed 's/\[.*$//')
            PACKAGE_MAP["$DISPLAY_NAME"]="$PACKAGE"
            OPTIONS+=("$DISPLAY_NAME")
        done

        CHOICES=$(printf "%s\n" "${OPTIONS[@]}" | gum choose --no-limit --header "$LANG_OPTIONAL_PACKAGES_MESSAGE") || true
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
    sudo dnf copr enable --assumeyes solopasha/hyprland -q
    sudo dnf copr enable --assumeyes wef/cliphist -q
    sudo dnf copr enable --assumeyes erikreider/SwayNotificationCenter -q
    sudo dnf copr enable --assumeyes tofik/nwg-shell -q
    sudo dnf copr enable --assumeyes peterwu/rendezvous -q
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
        IFS=$'\n' read -rd '' -a SELECTED_PACKAGES <<< "$CHOICES"
        for DISPLAY_NAME in "${SELECTED_PACKAGES[@]}"; do
            if [ -n "$DISPLAY_NAME" ]; then
                local FULL_PACKAGE="${PACKAGE_MAP[$DISPLAY_NAME]}"
                if [ -n "$FULL_PACKAGE" ]; then
                    local PKG_NAME
                    PKG_NAME=$(echo "$FULL_PACKAGE" | grep -oP '(?<=\[).+?(?=\])')

                    if [[ "$FULL_PACKAGE" == *"[flatpak]"* ]]; then
                        log_message "$LANG_ECHO_MESSAGE_INSTALLPACKAGES Flatpak: $DISPLAY_NAME"
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
    mkdir -p "$TARGET_DIR" || handle_error "$LANG_ECHO_CANTREATEBACKUP"
    local FOLDERS=("fastfetch" "hypr" "kitty" "nwg-dock-hyprland" "rofi" "waybar" "wlogout" "fish")

    for FOLDER in "${FOLDERS[@]}"; do
        local SRC="$HOME/.config/$FOLDER"
        local DEST="$TARGET_DIR/$FOLDER"
        if [ -d "$SRC" ]; then
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
    if [ "$INSTALL_FISH_SHELL" -eq 1 ]; then
        if ! grep -qxF "/usr/bin/fish" /etc/shells; then
            echo /usr/bin/fish | sudo tee -a /etc/shells || handle_error "$LANG_FISH_ERROR_ERROR_ADDTO_ETCSHELLS"
        fi
        chsh -s /usr/bin/fish || handle_error "$LANG_FISH_ERROR_SHELL"
    fi
}

# Msgbox-Ersatzfunktion mit Gum Style
show_message() {
    gum style --border double --padding "2 4" --margin "1 2" "$1"
}

clear

TARGET_BASE="$HOME/DotBackup"
DATE_FOLDER=$(date +"%Y-%m-%d_%H%M%S")
TARGET_DIR="$TARGET_BASE/$DATE_FOLDER"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

LANGUAGE=$(locale | grep LANG= | cut -d= -f2 | cut -d_ -f1)
if [ "$LANGUAGE" == "de" ]; then
    source "$PROJECT_ROOT/hypr/lang/lang_de.sh"
else
    source "$PROJECT_ROOT/hypr/lang/lang_en.sh"
fi

source "$PROJECT_ROOT/install/install_list"

show_message "$LANG_WELCOME_MESSAGE"

check_prerequisites

INSTALL_LIST_REPOS_TOINSTALL_COUNT=$(echo "$INSTALL_LIST_REPOS_TOINSTALL" | wc -l)
#INSTALL_LIST_REPOS_TOINSTALL_COUNT=$((INSTALL_LIST_REPOS_TOINSTALL_COUNT + 10))

INSTALL_LIST_PACKETS_TOINSTALL_COUNT=$(echo "$INSTALL_LIST_PACKETS_TOINSTALL" | wc -l)
#INSTALL_LIST_PACKETS_TOINSTALL_COUNT=$((INSTALL_LIST_PACKETS_TOINSTALL_COUNT + 10))

get_user_choices

# Letzte Bestätigung vor der Installation
if ! gum confirm "$LANG_INSTALLERLASTCONFIRM_MESSAGE"; then
    show_message "$LANG_ABORT_MESSAGE"
    exit 0
fi

log_message "$LANG_START_INSTALLATION"

update_system || true
add_repositories || true
install_main_packages || true
install_optional_packages || true
configure_fish_shell || true

show_message "$LANG_INSTALLATIONDONE_MESSAGE"

if gum confirm "$LANG_BACKUP_MESSAGE"; then
    create_backup
    show_message "$LANG_BACKUPDONE_MESSAGE"
else
    show_message "$LANG_BACKUPABORT_MESSAGE"
fi
