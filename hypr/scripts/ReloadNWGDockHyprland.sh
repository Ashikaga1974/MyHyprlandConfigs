#!/usr/bin/env bash
killall nwg-dock-hyprland
nwg-dock-hyprland -lp start -i 32 -w 5 -mb 10 -x -s style.css -c "rofi -show drun -show-icons" &