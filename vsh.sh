#!/bin/bash

function main {

  #Check if the user wants to start or stop a server
  	if [[ $1 == "-start" || $1 == "-stop" ]]; then

      #The server is now listening to the specified port, accepting multiple connection and execute given commands.
      ncat -lk localhost 1337 -e

      # -e option makes multiples connections possible without broadcasting message to everyone
  	elif [[ $1 == "-start" || $1 == "-stop" ]]; then


  	fi

  	# Check everything
  	check_arguments "$@"
  	#check_config # Disable to avoid cross-platform problem

  	# Let's go
  execute_command "$@"

}
