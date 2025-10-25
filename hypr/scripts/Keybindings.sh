#!/usr/bin/env bash
awk -F'[=#]' '
    $1 ~ /^bind/ {
        gsub(/\$mainMod/, "SUPER")
        gsub(/^bind\s*=\s*/, "")
        split($1, kbarr, ",")
        print kbarr[1] " + " kbarr[2] " : " $2
    }
' "$HOME/.config/hypr/hyprconf/bindings.conf" | \
rofi -dmenu -i -markup -eh 2 -replace -p "Keybinds"