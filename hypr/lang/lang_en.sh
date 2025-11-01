#!/bin/bash

# shellcheck disable=SC2034
LANG_FEDORA_UPDATE_TITLE="Fedora - System Update"
LANG_FEDORA_UPDATE_MESSAGE="Install all available updates?"
LANG_FEDORA_UPDATE_START_MESSAGE="Starting system update..."
LANG_FEDORA_UPDATE_COMPLETE_MESSAGE="Update completed."
LANG_FEDORA_UPDATE_ABORT_MESSAGE="Operation aborted."

LANG_ERROR="Error"
LANG_MESSAGE="This script only runs on Fedora Linux."
LANG_CONFIRM_INSTALL="Install all packages and enable repositories?"

LANG_PACKETS_TO_INSTALL="The following packages will be installed:\n\n"

LANG_REPOS_TO_INSTALL="The following repositories will be added:\n\n"

LANG_INSTALLERPACKAGES_TITLE="Installer - Optional Packages"
LANG_INSTALLERREPO_TITLE="Installer - Repositories"

LANG_INSTALLERLASTCONFIRM_TITLE="Installer - Confirmation"
LANG_INSTALLERLASTCONFIRM_MESSAGE="Install all packages and enable repositories?"

LANG_ABORT_TITLE="Abort"
LANG_ABORT_MESSAGE="Operation aborted."

LANG_CONTINUE_MESSAGE="Continue?"

LANG_INSTALLATIONDONE_TITLE="Installation complete"
LANG_INSTALLATIONDONE_MESSAGE="Installation completed."

LANG_BACKUP_TITLE="Backup"
LANG_BACKUP_MESSAGE="Should backups be created in $TARGET_DIR?"
LANG_BACKUPDONE_TITLE="Backup completed"
LANG_BACKUPDONE_MESSAGE="Backups were saved in $TARGET_DIR."
LANG_BACKUPABORT_TITLE="Backup aborted"
LANG_BACKUPABORT_MESSAGE="Backup was not performed."

LANG_ECHO_MESSAGE_UPDATE="DNF Update..."
LANG_ECHO_MESSAGE_ADDREPO="Add Repositories..."
LANG_ECHO_MESSAGE_INSTALLPACKAGES="Install optional package..."

LANG_ECHO_MESSAGE_FOLDERBACKUP="Folder backed up ->"
LANG_ECHO_MESSAGE_FOLDERNOTFOUND="Folder not found, skipped ->"

# Optionale Pakete
LANG_OPTIONAL_PACKAGES_TITLE="Optional Packages"
LANG_OPTIONAL_PACKAGES_MESSAGE="Select the optional packages to install:"

# Error handling
LANG_ERROR_PREFIX="ERROR: "

# Installation messages
LANG_INSTALLING_WHIPTAIL="Installing whiptail..."
LANG_ERROR_WHIPTAIL="Could not install whiptail"
LANG_START_INSTALLATION="Starting installation..."
LANG_INSTALLATION_FAILED="Installation failed"
LANG_PACKAGE_INSTALLED="Package %s is already installed"
LANG_INSTALLING_PACKAGE="Installing %s..."
LANG_ERROR_PACKAGE="Could not install package %s"

# Fish Shell
LANG_FISH_SHELL_TITLE="Fish Shell"
LANG_FISH_SHELL_MESSAGE="Would you like to set Fish Shell as the default shell for your user?"