#!/bin/bash
RED='\033[0;31m'   # Rot
NC='\033[0m'       # Keine Farbe

echo "Fedora - Systemupdate (inkl. Flat und Snap)"
echo "-------------------------------------------"

# Frage in Rot ausgeben
echo -ne "${RED}Alle verfügbaren Updates installieren? (y/n): ${NC}"

# Eingabe lesen (ohne zusätzliche Prompt)
read -n 1 -r
echo    # Neue Zeile nach Eingabe

if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Starte Systemupdate..."
  echo "---------DNF----------"
  sudo dnf -y update --refresh
  echo "-------Flatpak--------"
  sudo flatpak update -y
  echo "---------Snap---------"  
  sudo snap refresh
  sudo dnf autoremove -y
  echo "Update abgeschlossen."
else
  echo "Vorgang abgebrochen."
  exit 0
fi
