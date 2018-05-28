#!/bin/bash


function connect {

echo "Connecting to the server..."
#netcat $HOST $PORT

}

function execute_command {

    connect "$@"

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

cat | netcat $HOST $PORT

}

function request-browse {
echo "list"

}

function request-extract {
echo "list"

}
