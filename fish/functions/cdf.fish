# Funktion 'cdf' definieren – wechselt in ein übergebenes Verzeichnis
# und listet dessen Inhalt in Langform und farbig auf.
function cdf
    # $argv[1] ist das erste Argument, das beim Aufruf übergeben wird.
    # Beispiel: cdf ~/Downloads
    # wechselt also in das Verzeichnis ~/Downloads
    cd $argv[1]

    # zeigt alle Dateien, inklusive versteckter (mit -a),
    # im Langformat (-l) und mit Farben (--color=auto)
    ls -la --color=auto
end
