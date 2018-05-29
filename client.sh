#!/bin/bash


#function connect {

#echo "Connecting to the server..."


#}



function execute_command {

  #  connect "$@"

		case $1 in
			'-list')
				request-list;;
			'-browse')
				request-browse;;
			'-extract')
				request-extract;;
			*)
				echo 'Error'
				exit 1;;
		esac

}

function request-list {
echo "[Trying to connect]"
echo "You are entering in list mode"
echo "list" | netcat $HOST $PORT

}

function request-browse {

echo "You are entering in browse mode"
echo "browse" | netcat $HOST $PORT

}

function request-extract {

echo "You are entering in extract mode"
echo "extract" | netcat $HOST $PORT

}
