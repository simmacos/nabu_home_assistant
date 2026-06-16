#!/usr/bin/env bash

# Se passiamo l'argomento "start", avvia kitty e salva il suo PID
if [ "$1" == "start" ]; then
    # Lancia kitty a schermo intero con la sessione e salva il PID in un file
    kitty --start-as=fullscreen --session ~/.config/kitty/screensaver.conf &
    echo $! > /tmp/kitty_screensaver.pid

# Se passiamo l'argomento "stop", legge il PID e lo killa brutalmente
elif [ "$1" == "stop" ]; then
    if [ -f /tmp/kitty_screensaver.pid ]; then
        PID=$(cat /tmp/kitty_screensaver.pid)
        kill -9 $PID 2>/dev/null
        rm /tmp/kitty_screensaver.pid
    fi
fi
