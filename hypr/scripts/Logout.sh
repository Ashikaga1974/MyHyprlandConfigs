#!/usr/bin/env bash

# Prüfen, ob ein Prozess namens "wlogout" bereits läuft
if pgrep -x "wlogout" >/dev/null; then
    pkill -x "wlogout"
    exit 0
fi

# Setze den Konfigurationsordner, Standard ist ~/.config
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config}"

# Definiere Pfade zu Layout- und Style-Dateien basierend auf CONFIG_DIR
LAYOUT="${CONFIG_DIR}/wlogout/layout"
STYLE="${CONFIG_DIR}/wlogout/style.css"

# Ermittle die Höhe des aktuell fokussierten Monitors via hyprctl + jq
MONITOR_HEIGHT=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')

# Ermittle den Skalierungsfaktor des Monitors, entferne danach den Dezimalpunkt
MONITOR_SCALE=$(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale' | sed 's/\.//')

# Anzahl der Spalten für wlogout (menübasierter Bildschirm)
COLUMNS=5

# Berechne Margin und Hover-Dimensionen skaliert auf Monitorhöhe und -skalierung
margin=$((MONITOR_HEIGHT * 28 / MONITOR_SCALE))
hover=$((MONITOR_HEIGHT * 23 / MONITOR_SCALE))

# Setze die Schriftgröße relativ zur Monitorhöhe
font_size=$((MONITOR_HEIGHT * 2 / 100))

# Definiere Button-Farbe
BtnCol="white"

# Hyprland Border-Radius (mit Default 10, falls unset)
hypr_border="${hypr_border:-10}"

# Berechne Radius-Werte für aktive Elemente und Buttons
active_radius=$((hypr_border * 5))
button_radius=$((hypr_border * 8))

# Exportiere Variablen für Unterprozesse, z.B. für wlogout
export margin hover font_size BtnCol active_radius button_radius

# Lese die style.css Datei ein und ersetze Umgebungsvariablen mit envsubst
STYLE2="$(envsubst <"${STYLE}")"

# Starte den wlogout mit konfiguriertem Layout, CSS und Protokoll layer-shell
wlogout -b "${COLUMNS}" -c 0 -r 0 -m 0 --layout "${LAYOUT}" --css <(echo "${STYLE2}") --protocol layer-shell