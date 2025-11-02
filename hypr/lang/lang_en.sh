#!/bin/bash

# shellcheck disable=SC2034
LANG_WELCOME_MESSAGE="Welcome to the MyHyprlandConfigs Installer
This script installs MyHyprlandConfigs on your Fedora system."

LANG_ERROR_PREFIX="ERROR: "
LANG_ERROR_MESSAGE="This script runs only on Fedora Linux."

LANG_PACKETS_TO_INSTALL="The following packages will be installed:"
LANG_REPOS_TO_INSTALL="The following repositories will be added:"

LANG_INSTALLERLASTCONFIRM_MESSAGE="Install all packages and enable repositories?"

LANG_ABORT_MESSAGE="Operation aborted."

LANG_CONTINUE_MESSAGE="Continue?"

LANG_INSTALLATIONDONE_MESSAGE="Installation completed."

LANG_BACKUP_MESSAGE="Should backups be created in $TARGET_DIR?"
LANG_BACKUPDONE_MESSAGE="Backups have been stored in $TARGET_DIR."
LANG_BACKUPABORT_MESSAGE="Backup was not performed."

LANG_ECHO_MESSAGE_UPDATE="DNF update..."
LANG_ECHO_MESSAGE_ADDREPO="Adding repositories..."
LANG_ECHO_MESSAGE_INSTALLPACKAGES="Installing optional package..."

LANG_ECHO_MESSAGE_FOLDERBACKUP="Folder backed up ->"
LANG_ECHO_MESSAGE_FOLDERNOTFOUND="Folder not found, skipping ->"
LANG_ECHO_CANTREATEBACKUP="Could not create backup directory."
LANG_ECHO_CANTCOPYFOLDER="Could not copy folder $FOLDER."
LANG_ECHO_CANTCREATEFOLDER="Could not create directory $DEST."

LANG_PACKAGE_INSTALLED="Package %s is already installed"
LANG_INSTALLING_PACKAGE="Installing %s..."
LANG_ERROR_PACKAGE="Could not install package %s"

LANG_FISH_SHELL_MESSAGE="Do you want to set Fish Shell as the default shell for your user?"
LANG_FISH_ERROR_SHELL="Could not set Fish Shell as the default shell."
LANG_FISH_ERROR_ERROR_ADDTO_ETCSHELLS="Could not add Fish Shell to /etc/shells."

LANG_FEDORA_UPDATE_MESSAGE="Fedora - Systemupdate"
LANG_FEDORA_UPDATE_MESSAGE1="Install all updates?"
