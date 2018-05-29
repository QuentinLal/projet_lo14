#! /bin/bash

####################
#
#	SERVER
#	Description :
#
#
#
####################

if [ $# -ne 1 ]; then
    echo "/!\ You have to specify a port /!\ "
    echo "usage: $(basename $0) PORT"
    exit -1
fi

PORT="$1"

# The pipe
FIFO="/tmp/$USER-fifo-$$"


# When the connection ends, we kill the pipe in order to keep clean the
# /tmp. directory. We use the instruction "trap" in order to be sure to clean it
# even if the server is interrupted by any signal.
#function cleaner() {
#  pipes_to_kill=$(ls /tmp/ | grep "$USER-fifo" | xargs -L1 rm -f)
#}



# We create the pipe
[ -e "$FIFO" ] || mkfifo "$FIFO"


function accept-loop() {
  echo "The server is now listening on the port $PORT"
    while true; do
	interaction < "$FIFO" | netcat -l -p "$PORT" > "$FIFO"
    done
}

# La fonction interaction lit les commandes du client sur entr�e standard
# et envoie les r�ponses sur sa sortie standard.
#
# 	CMD arg1 arg2 ... argn
#
# alors elle invoque la fonction :
#
#         commande-CMD arg1 arg2 ... argn
#
# si elle existe; sinon elle envoie une r�ponse d'erreur.

function interaction() {
    local cmd args
    while true; do
	read cmd args || exit -1
	fun="mode-$cmd"
	if [ "$(type -t $fun)" = "function" ]; then
	    $fun $args
	else
	    mode-error-arg $fun $args
	fi
    done
}

# These functions implements the differents modes available on the server
function mode-list () {
  echo "[Connection successfull]"
  echo "Welcome ! You entered in list-mode"
  echo "This is the list of the archives stored on the server..."
  ls archive/

}

function mode-browse() {
  echo "browse"
}

function mode-extract() {
  echo "extract"




}

function mode-error-arg() {
  echo "Error-arg: The server can not treat your request"
}

# Accept and treat the connections
accept-loop
