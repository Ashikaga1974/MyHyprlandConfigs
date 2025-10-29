#!/usr/bin/env bash

# Wenn das erste Argument "toggle" ist, also der Befehl zum Umschalten ausgeführt wird ...
if [[ "$1" == "toggle" ]]; then

    # Prüfe, ob Animationen aktuell deaktiviert sind (int: 0)
    if hyprctl -j getoption "animations:enabled" | grep -q "int\": 0"; then
        
        # Wenn Animationen aus sind, aktiviere den "Normalmodus":
        # Aktiviere Animationen, Schatten, Blur und setze größere Abstände & Rahmen
        hyprctl --batch "
            keyword animations:enabled 1;
            keyword decoration:shadow:enabled 1;
            keyword decoration:blur:enabled 1;
            keyword general:gaps_in 5;
            keyword general:gaps_out 10;
            keyword general:border_size 4;
            keyword decoration:rounding 10"

        # Zeige Benachrichtigung, dass der Gamemode deaktiviert (Normalmodus aktiviert) wurde
        notify-send "Gamemode deaktiviert"

    else
        # Wenn Animationen aktiv sind, dann aktiviere den "Gamemode":
        # Deaktiviere visuelle Effekte, setze Abstände und Rahmen auf minimal
        hyprctl --batch "
            keyword animations:enabled 0;
            keyword decoration:shadow:enabled 0;
            keyword decoration:blur:enabled 0;
            keyword general:gaps_in 0;
            keyword general:gaps_out 0;
            keyword general:border_size 1;
            keyword decoration:rounding 0"

        # Zeige Benachrichtigung, dass der Gamemode aktiviert wurde
        notify-send "Gamemode aktiviert"
    fi
fi

# Dieser Teil wird immer ausgeführt (auch ohne toggle):
# Er überprüft, ob Animationen aktiv oder deaktiviert sind
# und gibt den Status (z. B. für eine Statusleiste) im JSON-Format aus.

if hyprctl -j getoption "animations:enabled" | grep -q "int\": 0"; then
    # Wenn Animationen aus sind -> Symbol für "aktiviert" (Gamemode an)
    echo '{"text":"","class":"on"}'
else
    # Wenn Animationen an sind -> Symbol für "deaktiviert" (Gamemode aus)
    echo '{"text":"","class":"off"}'
fi