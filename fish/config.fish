set fish_greeting ""
if status is-interactive
    # Commands to run in interactive sessions can go here
end

fastfetch --logo /home/sascha/Bilder/Logo/fedora.png --logo-type kitty-direct --logo-width 33 --logo-height 15 --show-errors
#oh-my-posh init fish | source
oh-my-posh init fish --config ~/.config/oh-my-posh/theme.json | source
