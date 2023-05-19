#!/bin/bash

# Prepare video and vnc
pkill -f Xvfb
Xvfb ${DISPLAY} -screen 0 ${RESOLUTION} &
xfce4-session &
x11vnc -display ${DISPLAY} -nopw -listen 0.0.0.0 -xkb -ncache 10 -ncache_cr -forever &

# Start user startup script
/usr/local/bin/scripts/./startup.sh &

# Start novnc
/usr/share/novnc/utils/./novnc_proxy --vnc 0.0.0.0:5900 --listen 6080