# Eigene Definition der Funktion 'ls'
# Diese überschreibt den Standardbefehl 'ls' und erzwingt bestimmte Optionen.
function ls
    # 'command' stellt sicher, dass der originale 'ls'-Befehl aufgerufen wird,
    # nicht eine mögliche weitere Funktion oder Alias namens 'ls'.
    #
    # Optionen:
    # -l           : Langformat mit Details (Rechte, Besitzer, Größe, Datum)
    # -a           : Zeigt auch versteckte Dateien (beginnen mit '.')
    # --color=auto : Farbige Ausgabe abhängig vom Terminal
    # --full-time  : Zeigt das vollständige Zeitformat inkl. Sekunden
    #
    # $argv        : Übergibt alle Argumente, die beim Funktionsaufruf angegeben wurden.
    command ls -l -a --color=auto --full-time $argv
end
