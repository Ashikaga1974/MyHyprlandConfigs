#!/bin/bash

# shellcheck disable=SC2034
LANG_WELCOME_MESSAGE="Willkommen zum MyHyprlandConfigs Installer
Dieses Script installiert MyHyprlandConfigs auf Ihrem Fedora System."

LANG_ERROR_PREFIX="FEHLER: "
LANG_ERROR_MESSAGE="Dieses Script läuft nur auf Fedora Linux."

LANG_PACKETS_TO_INSTALL="Folgende Pakete werden installiert:"
LANG_REPOS_TO_INSTALL="Folgende Repositorien werden hinzugefügt:"

LANG_INSTALLERLASTCONFIRM_MESSAGE="Alle Pakete installieren und Repositories freischalten?"

LANG_ABORT_MESSAGE="Vorgang abgebrochen."

LANG_CONTINUE_MESSAGE="Fortfahren?"

LANG_INSTALLATIONDONE_MESSAGE="Installation abgeschlossen."

LANG_BACKUP_MESSAGE="Sollen Sicherungen in $TARGET_DIR angelegt werden?"
LANG_BACKUPDONE_MESSAGE="Sicherungen wurden in $TARGET_DIR abgelegt."
LANG_BACKUPABORT_MESSAGE="Sicherung wurde nicht durchgeführt."

LANG_ECHO_MESSAGE_UPDATE="DNF Update..."
LANG_ECHO_MESSAGE_ADDREPO="Add Repositories..."
LANG_ECHO_MESSAGE_INSTALLPACKAGES="Installiere optionales Paket..."

LANG_ECHO_MESSAGE_FOLDERBACKUP="Ordner gesichert->"
LANG_ECHO_MESSAGE_FOLDERNOTFOUND="Ordner nicht gefunden, übersprungen->"
LANG_ECHO_CANTREATEBACKUP="Konnte Backup-Verzeichnis nicht erstellen."
LANG_ECHO_CANTCOPYFOLDER="Konnte Ordner $FOLDER nicht sichern."
LANG_ECHO_CANTCREATEFOLDER="Konnte Verzeichnis $DEST nicht erstellen."

LANG_PACKAGE_INSTALLED="Paket %s ist bereits installiert"
LANG_INSTALLING_PACKAGE="Installiere %s..."
LANG_ERROR_PACKAGE="Konnte Paket %s nicht installieren"

LANG_FISH_SHELL_MESSAGE="Möchten Sie die Fish Shell als Standard-Shell für Ihren Benutzer einrichten?"
LANG_FISH_ERROR_SHELL="Konnte Fish Shell nicht als Standard-Shell einrichten."
LANG_FISH_ERROR_ERROR_ADDTO_ETCSHELLS="Konnte Fish Shell nicht zu /etc/shells hinzufügen."
