#!/bin/bash

# Prepare video and vnc
Xvfb ${DISPLAY} -screen 0 ${RESOLUTION} &
xfce4-session &
x11vnc -display ${DISPLAY} -nopw -listen 0.0.0.0 -xkb -ncache 10 -ncache_cr -forever &

# Start user startup script
/usr/local/bin/./startup.sh &

# Start novnc
/usr/share/novnc/utils/./novnc_proxy --vnc 0.0.0.0:${VNC_PORT} --listen ${NOVNC_PORT}