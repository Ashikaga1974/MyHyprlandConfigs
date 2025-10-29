#!/usr/bin/env bash

# Beendet alle laufenden Instanzen des Prozesses "waybar", 
# um Konflikte oder doppelte Ausführungen zu vermeiden.
killall waybar

# Startet Waybar neu mit einer benutzerdefinierten Konfigurationsdatei (-c)
# und einem angegebenen Stylesheet (-s).
waybar -c ~/.config/hypr/waybarconf/config -s ~/.config/hypr/waybarconf/style.css &