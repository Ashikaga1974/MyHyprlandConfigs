#!/usr/bin/env bash

# Verwendet 'awk', um aus der Konfigurationsdatei Keybindings zu extrahieren und formatiert sie lesbar.
# Das Feldtrennzeichen (-F) wird auf '=' oder '#' gesetzt, um die einzelnen Teile einer Zeile korrekt zu trennen.
awk -F'[=#]' '

    # Prüft, ob die Zeile mit "bind" beginnt.
    $1 ~ /^bind/ {
        # Ersetzt alle Vorkommen von $mainMod durch "SUPER" zur besseren Lesbarkeit.
        gsub(/\$mainMod/, "SUPER")

        # Entfernt den Teil "bind =" am Zeilenanfang.
        gsub(/^bind\s*=\s*/, "")

        # Teilt das erste Feld ($1) in ein Array, getrennt durch Kommas.
        split($1, kbarr, ",")

        # Gibt die Tastenkombination in lesbarer Form aus, z. B. "SUPER + T : exec something".
        print kbarr[1] " + " kbarr[2] " : " $2
    }

# Liest die Datei mit den Keybindings aus dem angegebenen Verzeichnis.
' "$HOME/.config/hypr/hyprconf/bindings.conf" | \

# Übergibt die formatierten Ergebnisse an 'rofi' für eine interaktive Anzeige.
# -dmenu: zeigt eine Eingabeliste an
# -i: machen Suchvorgänge case-insensitive
# -markup: erlaubt Formatierungen im Text
# -eh 2: erhöht die Zeilenhöhe für bessere Lesbarkeit
# -replace: ersetzt rofi's Standardanzeige
# -p "Keybinds": legt den Prompt-Titel auf "Keybinds" fest
rofi -dmenu -i -markup -eh 2 -replace -p "Keybinds"
