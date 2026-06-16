#!/usr/bin/env bash

# Aspetta qualche secondo all'avvio del sistema per far caricare Wayland e Kitty
sleep 5

# Lancia swayidle in background
swayidle -w timeout 120 '~/avvia_screensaver.sh start' resume '~/avvia_screensaver.sh stop' 2>/dev/null &
