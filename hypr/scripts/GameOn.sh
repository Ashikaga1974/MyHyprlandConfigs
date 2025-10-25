#!/usr/bin/env bash

if [[ "$1" == "toggle" ]]; then
  if hyprctl -j getoption "animations:enabled" | grep -q "int\": 0"; then
    hyprctl --batch "
      keyword animations:enabled 1;
      keyword decoration:shadow:enabled 1;
      keyword decoration:blur:enabled 1;
      keyword general:gaps_in 5;
      keyword general:gaps_out 10;
      keyword general:border_size 4;
      keyword decoration:rounding 10"
    notify-send "Gamemode deaktiviert"
  else
    hyprctl --batch "
      keyword animations:enabled 0;
      keyword decoration:shadow:enabled 0;
      keyword decoration:blur:enabled 0;
      keyword general:gaps_in 0;
      keyword general:gaps_out 0;
      keyword general:border_size 1;
      keyword decoration:rounding 0"
    notify-send "Gamemode aktiviert"
  fi
fi

if hyprctl -j getoption "animations:enabled" | grep -q "int\": 0"; then
  echo '{"text":"","class":"on"}'
else
  echo '{"text":"","class":"off"}'
fi