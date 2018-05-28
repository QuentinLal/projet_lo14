#!/bin/bash

####################
#
#	VSH
#	Description : This script allows you to...
# - start and stop a server
# - enter into one of the three modes (-list, -browse, -extract)
#
####################

source controller.sh

# Launch the server on the specified port.
function start_server {
	if ! [[ -z $(pgrep -lf "$SERVER") ]]; then
		echo "Server already running on port $1."
		exit 1
	else
		echo 'Launching server...'
		rm -f /tmp/serverFifo
		mknod /tmp/serverFifo p
		$SERVER "$SCRIPT" &
		echo "Server is now listening on port $1."
	fi
}

# Stop the server according to the specified port.
function stop_server {
	local test=$(pgrep -lf "$SERVER" | cut -d' ' -f1)
	if ! [[ -z $test ]]; then
		echo "Stopping server listening on port $1..."
		kill $test
		rm -f /tmp/serverFifo
		echo 'Server stopped!'
	else
		echo "There is no server running on port $1."
		exit 1
	fi
}

function main {

  #Check if the user wants to start or stop a server ( vsh.sh -start/-stop localhost xxxx)
  	if [[ $1 == "-start" ]]; then
      HOST=$2
      PORT=$3
      #The server is now listening (-l) to the specified port, accepting multiple connection (-k) and execute given commands (-e).
      ncat -lk $HOST $PORT -e

    elif [[ $1 == "-stop" ]]; then

      HOST=$2
      PORT=$3
      #The server is now listening (-l) to the specified port, accepting multiple connection (-k) and execute given commands (-e).
      ncat -lk $HOST $PORT -e

  	elif [[ $1 == "-list" || $1 == "-browse" || $1 == "-extract" ]]; then
      HOST=$2
		  PORT=$3
      ARCHIVE=$4
  	fi

  	#Check if the user entered correct arguments (This is done by controller.sh)
  	check_arguments "$@"

  	# Let's go
  execute_command "$@"

}

#Launch the main function
main "$@"

exit 0
