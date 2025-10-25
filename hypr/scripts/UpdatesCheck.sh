#!/bin/bash

# Cache aktualisieren und verfügbare Updates prüfen
count=0
dnfcount=$(dnf -q check-update | awk '/^[[:alnum:]]/ {n++} END {print n+0}')
snapcount=0
flatcount=0

count=$dnfcount

# Prüfen, ob Snap installiert ist
if command -v snap >/dev/null 2>&1; then
  snapcount=$(snap refresh --list | tail -n +2 | wc -l)
  count=$((count + snapcount))
fi

# Prüfen, ob Flatpak installiert ist
if command -v flatpak >/dev/null 2>&1; then
  flatcount=$(flatpak remote-ls --updates | wc -l)
  count=$((count + flatcount))
fi

# Wenn kein Update verfügbar ist, zeigt dnf eine leere Ausgabe (Exit-Code 0)
if [[ $? -eq 0 && "$count" -eq 0 ]]; then
  exit 0
fi

css_class="green"

if [ "$count" != 0 ]; then

#printf '{"text": "%d"}\n' "2"
    #if [ "$updates" -gt $threshhold_green ]; then
#    send-notification "3" "1"
        printf '{"text": "%s", "alt": "%s", "tooltip": "Click to update your system: FLAT: %s SNAP: %s DNF: %s", "class": "%s"}' "$count" "$count" $flatcount $snapcount $dnfcount "$css_class"
    #else
    #    printf '{"text": "0", "alt": "0", "tooltip": "No updates available", "class": "green"}'
    #fi
fi