#!/usr/bin/env bash

# Beende alle laufenden Instanzen von nwg-dock-hyprland,
# damit beim Neustart keine doppelten Docks laufen.
killall nwg-dock-hyprland

# Starte nwg-dock-hyprland mit meinen bevorzugten Parametern:
# -lp start     → Dock wird im Autostart-Modus initialisiert
# -i 32         → Symbolgröße der Icons (32 Pixel)
# -w 5          → Abstand zwischen den Icons (5 Pixel)
# -mb 10        → Margin nach unten (10 Pixel)
# -x            → Aktiviert den „exclusive zone mode“ (für korrektes Layout unter Hyprland)
# -s style.css  → Verwende meine eigene CSS-Datei für das Dock-Design
# -c "rofi ..." → Setzt den Befehl, der ausgeführt wird, wenn ich auf das Dockmenü klicke (hier: rofi-Appstarter mit Icons)
# Das & am Ende startet den Prozess im Hintergrund, damit das Terminal nicht blockiert.
nwg-dock-hyprland -lp start -i 32 -w 3 -mb 10 -x -s style.css -c "rofi -show drun -show-icons" &