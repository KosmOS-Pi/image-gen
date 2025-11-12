#! /bin/bash
set -e

TTY=/dev/tty1
FLAG_DIR=/var/lib/kosmos-setup
IN_PROG_FILE="$FLAG_DIR/in-progress"
DONE_FILE="$FLAG_DIR/done"
FAILED_FILE="$FLAG_DIR/failed"
NO_NET_FILE="$FLAG_DIR/no-network"

mkdir -p $FLAG_DIR

log() {
	local msg="[KosmOS setup] $*"
	echo $msg
	[ -w "$TTY" ] && echo "$msg" > $TTY
}

check_network() {
	nm-online -x -q -t 15
	if [ $? -ne 0 ]; then
		log "NetworkManager reports no active connection."
		return 1
	fi

	if wget -q -O - http://deb.debian.org > /dev/null; then
		log "Internet connectivity confirmed."
		return 0
	else
		log "No internet connectivity detected."
		return 1
	fi
}

# Clean FLAGS
rm -f $IN_PROG_FILE $NO_NET_FILE $FAILED_FILE

if [ -f $DONE_FILE ]; then
	log "Completed. Nothing to do here: bye!"
	exit 0
fi

log "Checking network availability..."

if check_network; then
	touch $IN_PROG_FILE
	log "Proceed with package installation."

	/usr/local/bin/kosmos-setup.sh 2>&1 | while IFS= read -r line; do log "$line"; done
	setup_status=${PIPESTATUS[0]}

	#Remove in-progress
	rm -f $IN_PROG_FILE 2> /dev/null || true

	if [ "$setup_status" -eq 0 ]; then
		# mark completion and cleane up.
		touch $DONE_FILE # Mark as done
		exit 0
	else
		# log and exit failure
		touch $FAILED_FILE
		log "Failed."
		exit 1
	fi
else
	touch $NO_NET_FILE
	log "No network connection available: setup can't proceed."
	log "To proceed:"
	log "    1. Connect to a network: plug in an ethernet nework or try"
	log "          sudo nmtui "
	log "       to connect to a WiFi network."
	log "    2. Setup will restart automatically."
	log "       You can manually start setup with: "
	log "          sudo systemctl start kosmos-setup.service"

	# checking wifi country code
	country=$( iw reg get | awk '/country/ { print $2; exit }')
	[ -z "$country" ] &&  {
		log '********************************* WARNING ************************************'
		log " WiFi country code not set, so WiFi will not be available."
		log " Try: "
		log "      sudo iw reg set <code>"
		log " or: "
		log "      sudo raspi-config"
		log " to set it."
		log '******************************************************************************'
	}
	exit 1
fi
