#!/bin/bash

clear

RED='\033[0;31m'   # Rot
NC='\033[0m'       # Keine Farbe

echo "Installer"
echo "-------------------------------------------"
echo "Folgende Pakete werden installiert:"
echo "- Hyprland -ok-"
echo "- Hyprlock -ok-"
echo "- Hyprpaper -ok-"
echo "- Waybar -ok-"
echo "- Kitty -ok-"
echo "- Dolphin -ok-"
echo "- Betterbird -ok- (Flatpak)"
echo "- Brave-Browser -ok- (Flatpak)"
echo "- Firefox -ok-"
echo "- Fastfetch -ok-"
echo "- Flameshot -ok-"
echo "- nwg-dock-hyprland -ok-"
echo "- SwayNotificationCenter"
echo "-------------------------------------------"
echo "Folgende Repositorien werden hinzugefügt:"
echo "- solopasha/hyprland"
echo "- erikreider/SwayNotificationCenter"
echo "- tofik/nwg-shell"
echo "- wef/cliphist"
echo "-------------------------------------------"
echo "Folgende Softwarecontainer werden installiert:"
echo "- Flatpak -ok-"

# Frage in Rot ausgeben
echo -ne "${RED}Alle Pakete installieren und Repositories freischalten ? (y/n): ${NC}"

# Eingabe lesen (ohne zusätzliche Prompt)
read -n 1 -r
echo    # Neue Zeile nach Eingabe

if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Installation wird gestartet..."

  echo "DNF Update..."
  sudo dnf -y update --refresh
  sudo dnf autoremove -y

  echo "Hinzufügen der Repositories..."
  sudo dnf copr enable --assumeyes solopasha/hyprland
  sudo dnf copr enable --assumeyes wef/cliphist
  sudo dnf copr enable --assumeyes erikreider/SwayNotificationCenter
  sudo dnf copr enable --assumeyes tofik/nwg-shell

  echo "Installation der Pakete..."
  sudo dnf install --assumeyes --skip-unavailable hyprland
  sudo dnf install --assumeyes --skip-unavailable hyprlock
  sudo dnf install --assumeyes --skip-unavailable hyprpaper
  sudo dnf install --assumeyes --skip-unavailable waybar
  sudo dnf install --assumeyes --skip-unavailable kitty
  sudo dnf install --assumeyes --skip-unavailable dolphin
  sudo dnf install --assumeyes --skip-unavailable flatpak
  sudo dnf install --assumeyes --skip-unavailable firefox
  sudo dnf install --assumeyes --skip-unavailable nwg-dock-hyprland
  sudo dnf install --assumeyes --skip-unavailable SwayNotificationCenter
  sudo flatpak install -y app/eu.betterbird.Betterbird/x86_64/stable
  sudo flatpak install -y flathub com.brave.Browser

  echo "Installation abgeschlossen."
else
  echo "Vorgang abgebrochen."
  exit 0
fi
