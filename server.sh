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
#         mode-CMD arg1 arg2 ... argn
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
function mode-list() {
  echo "[Connection successfull]"
  echo "Welcome ! You entered in list-mode"
  echo "This is the list of the archives stored on the server..."
  ls archive/
}

function mode-browse() {
  echo "browse"
}

function mode-extract() {
  echo "[Server] You asked for the extraction of the following archive(s): $args"

  #Path of the archive for which the client asked for an extraction
  ARCHIVE=archive/$args

  #This will store all the path in the archive in a .txt file
  cat $ARCHIVE | grep "directory [A-Za-z0-9]*/" | sed "s/directory //g" > mydirectories.txt

  #This will create all the directories from the .txt file
  xargs -I {} mkdir -p "{}" < mydirectories.txt


  BEGINNING=`expr $(head -n 1 $ARCHIVE | sed "s/\([0-9]*\):[0-9]*/\1/g") - 1`
  ENDING=`expr $(head -n 1 $ARCHIVE | sed "s/[0-9]*:\([0-9]*\)/\1/g") - 1`
  CORE=`expr $ENDING - $BEGINNING`

  #This select the head of the archive
  HEAD_OF_THE_ARCHIVE=$(head -n $ENDING $ARCHIVE | tail -n $CORE)

  #We count the number of different path
  NUMBER_OF_PATH=$(wc -l mydirectories.txt)


  



}

function mode-error-arg() {
  echo "Error-arg: The server can not treat your request"
}

# Accept and treat the connections
accept-loop
