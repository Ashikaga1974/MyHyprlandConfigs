#!/bin/bash

# shellcheck disable=SC2034
LANG_WELCOME_MESSAGE="Welcome to the MyHyprlandConfigs installer
This script installs MyHyprlandConfigs on your Fedora system.
Please note that in selection dialogs, a choice must be made with X or Space!"

LANG_START_INSTALLATION="Starting installation..."

LANG_ERROR_PREFIX="ERROR: "
LANG_ERROR_MESSAGE="This script runs only on Fedora Linux."

LANG_PACKETS_TO_INSTALL="The following packages will be installed:"
LANG_REPOS_TO_INSTALL="The following repositories will be added:"

LANG_INSTALLERLASTCONFIRM_MESSAGE="Install all packages and unlock repositories?"

LANG_ABORT_MESSAGE="Process aborted."

LANG_CONTINUE_MESSAGE="Continue?"

LANG_INSTALLATIONDONE_MESSAGE="Installation completed."

LANG_BACKUP_MESSAGE="Should backups be created in $TARGET_DIR?"
LANG_BACKUPDONE_MESSAGE="Backups have been placed in $TARGET_DIR."
LANG_BACKUPABORT_MESSAGE="Backup was not performed."

LANG_ECHO_MESSAGE_UPDATE="DNF update..."
LANG_ECHO_MESSAGE_ADDREPO="Add repositories..."
LANG_ECHO_MESSAGE_INSTALLPACKAGES="Installing packages..."
LANG_ECHO_MESSAGE_OPTIONALPACKAGES="Installing optional packages..."

LANG_ECHO_MESSAGE_FOLDERBACKUP="Folder backed up ->"
LANG_ECHO_MESSAGE_FOLDERNOTFOUND="Folder not found, skipped ->"
LANG_ECHO_CANTREATEBACKUP="Could not create backup directory."
LANG_ECHO_CANTCOPYFOLDER="Could not back up folder $FOLDER."
LANG_ECHO_CANTCREATEFOLDER="Could not create directory $DEST."

LANG_PACKAGE_INSTALLED="Package %s is already installed"
LANG_INSTALLING_PACKAGE="Installing %s..."
LANG_ERROR_PACKAGE="Could not install package %s"
LANG_ERROR_UPDATE="System update failed"
LANG_ERROR_AUTOREMOVE="Autoremove failed"

LANG_FISH_SHELL_MESSAGE="Do you want to set Fish Shell as the default shell for your user?"
LANG_FISH_ERROR_SHELL="Could not set Fish Shell as default shell."
LANG_FISH_ERROR_ERROR_ADDTO_ETCSHELLS="Could not add Fish Shell to /etc/shells."

LANG_FEDORA_UPDATE_MESSAGE="Fedora - system update"
LANG_FEDORA_UPDATE_MESSAGE1="Install all available updates?"

LANG_MONITOR_RESOLUTION="Configure monitor resolution?"
LANG_MONITOR_RESOLUTIONS="Please select the desired monitor resolution:"
LANG_MONITOR_RESULTION_MESSAGE="Configuring monitor resolution to: "

LANG_MESSAGE_INSTALL_GUM="Gum is required to proceed."