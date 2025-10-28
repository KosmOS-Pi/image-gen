#! /bin/bash

FLAG_DIR=/var/lib/kosmos-setup

if [ -f "$FLAG_DIR/in-progress" ]; then
    echo
    echo '****************************** Kosmos setup ********************************'
    echo ' Setup in progress: do not reboot!'
    echo ' Check setup status with: check-kosmos-setup'
    echo '****************************************************************************'
    echo

elif [ -f "$FLAG_DIR/no-network" ]; then
    echo
    echo '****************************** Kosmos setup ********************************'
    echo ' Setup suspended for lack of network.'
    echo '   Please connect to network with:'
    echo '     > sudo nmtui'
    echo
    echo '   Setup will restart when connection is available.'
    echo '   You can manually restart it with: '
    echo '     > sudo systemctl start kosmos-setup.service'
    echo '****************************************************************************'
    echo

elif [ -f "$FLAG_DIR/done" ]; then
    :

else
    echo
    echo '****************************** Kosmos setup ********************************'
    echo ' Setup not started yet.'
    echo '****************************************************************************'
    echo
fi

