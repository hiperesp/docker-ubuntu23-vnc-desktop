FROM ubuntu:23.10 AS system

# Install the essential packages + UI + VNC
RUN apt-get update
RUN apt-get install -y sudo
RUN apt-get install -y xfce4 xfce4-terminal dbus-x11
RUN apt-get install -y x11vnc xvfb novnc websockify
RUN apt-get install -y nano

# <INSTALL FIREFOX>

# Add Debian "buster" repository. Create a file /etc/apt/sources.list.d/debian.list with the following content:
RUN echo deb [signed-by=/usr/share/keyrings/debian-buster.gpg] http://deb.debian.org/debian buster main > /etc/apt/sources.list.d/debian.list
RUN echo deb [arch=amd64 signed-by=/usr/share/keyrings/debian-buster-updates.gpg] http://deb.debian.org/debian buster-updates main
RUN echo deb [arch=amd64 signed-by=/usr/share/keyrings/debian-security-buster.gpg] http://deb.debian.org/debian-security buster/updates main

# Add the Debian signing keys:
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DCC9EFBF77E11517
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 648ACFD622F3D138
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 112695A0E562B32A

# Store GPG keys in /usr/share/keyrings
RUN apt-key export 77E11517 | sudo gpg --dearmour -o /usr/share/keyrings/debian-buster.gpg
RUN apt-key export 22F3D138 | sudo gpg --dearmour -o /usr/share/keyrings/debian-buster-updates.gpg
RUN apt-key export E562B32A | sudo gpg --dearmour -o /usr/share/keyrings/debian-security-buster.gpg

# Change the apt preferences to give priority to Debian packages.
RUN echo 'Package: *' > /etc/apt/preferences.d/debian
RUN echo 'Pin: release o=Debian' >> /etc/apt/preferences.d/debian
RUN echo 'Pin-Priority: 100' >> /etc/apt/preferences.d/debian

# Install applications
RUN apt-get update
RUN apt-get install -y firefox-esr

# </INSTALL FIREFOX>

# Set the environment variables
ENV DISPLAY=:1 \
    VNC_PORT=5900 \
    NOVNC_PORT=6080 \
    RESOLUTION=1920x1080x24 \
    USERNAME=hiperesp \
    PASSWORD=senha123

# Copy the startup script
COPY scripts/setup.sh /usr/local/bin/
COPY scripts/startup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh /usr/local/bin/startup.sh

# Create a user
RUN useradd --create-home --shell /bin/bash --groups sudo --password $(openssl passwd -1 $PASSWORD) $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME


EXPOSE $VNC_PORT $NOVNC_PORT

CMD su - $USERNAME -c "\
    DISPLAY=$DISPLAY \
    VNC_PORT=$VNC_PORT \
    NOVNC_PORT=$NOVNC_PORT \
    RESOLUTION=$RESOLUTION \
    /usr/local/bin/setup.sh\
"
