#!/bin/bash

useradd --create-home --shell /bin/bash --groups sudo --password $(openssl passwd -1 $PASSWORD) $USERNAME
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME

su $USERNAME -c "/usr/local/bin/scripts/login.sh"
