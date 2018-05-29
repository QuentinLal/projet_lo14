#!/bin/bash

####################
#
#	VSH
#	Description : This script allows you to...
# - start and stop a server
# - enter into one of the three modes (-list, -browse, -extract)
#
####################

source client.sh

function usage {
echo "usage: $(basename $0) OPTION [-list, -browse, -extract] HOST PORT ARCHIVE"
}

function main {

if [[ $1 == "-list" || $1 == "-browse" || $1 == "-extract" ]]; then
      HOST=$2
		  PORT=$3
      ARCHIVE=$4

      #Call client.sh in order to make the request to the server
      execute_command "$@"
else
     usage
fi

    #TO DO: 
  	#Check if the user entered correct arguments (This is done by controller.sh)
  	#check_arguments "$@"



}

#Launch the main function
main "$@"

exit 0
