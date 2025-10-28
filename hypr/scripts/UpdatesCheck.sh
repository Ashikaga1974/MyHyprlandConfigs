#!/bin/bash

# Zähle verfügbare Updates für DNF, Snap und Flatpak
COUNT=0
DNFCOUNT=$(dnf -q check-update | awk '/^[[:alnum:]]/ {n++} END {print n+0}')
SNAPCOUNT=0
FLATCOUNT=0

COUNT=$DNFCOUNT

# Prüfen, ob Snap installiert ist
if command -v snap >/dev/null 2>&1; then
    SNAPCOUNT=$(snap refresh --list | tail -n +2 | wc -l)
    COUNT=$((COUNT + SNAPCOUNT))
fi

# Prüfen, ob Flatpak installiert ist
if command -v flatpak >/dev/null 2>&1; then
    FLATCOUNT=$(flatpak remote-ls --updates | wc -l)
    COUNT=$((COUNT + FLATCOUNT))
fi

# Wenn kein Update verfügbar ist, zeigt dnf eine leere Ausgabe (Exit-Code 0)
if [[ $? -eq 0 && "$COUNT" -eq 0 ]]; then
    exit 0
fi

# Bestimme die CSS-Klasse basierend auf der Anzahl der Updates
if [ "$COUNT" -ge 50 ]; then
    CSS_CLASS="red"
    elif [ "$COUNT" -ge 25 ]; then
    CSS_CLASS="yellow"
else
    CSS_CLASS="green"
fi

# Ausgabe im JSON-Format für Waybar
if [ "$COUNT" != 0 ]; then
    printf '{"text": "%s", "alt": "%s", "tooltip": "Click to update your system: FLAT: %s SNAP: %s DNF: %s", "class": "%s"}' "$COUNT" "$COUNT" "$FLATCOUNT" "$SNAPCOUNT" "$DNFCOUNT" "$CSS_CLASS"
fi