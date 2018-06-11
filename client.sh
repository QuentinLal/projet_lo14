#!/bin/bash


#function connect {

#echo "Connecting to the server..."


#}
function execute_command {

		case $1 in
			'-list')
				request-list;;
			'-browse')
				request-browse;;
			'-extract')
				request-extract "$ARCHIVE";;
			*)
				echo 'Error'
				exit 1;;
		esac

}

function request-list {
echo "You are entering in list mode"
echo "list" | netcat $HOST $PORT

}

function request-browse {
echo "You are entering in browse mode ['pwd';'cat';'cd';'ls';'rm']"
ncat $HOST $PORT

}

function request-extract {
echo "You want to extract the archive: $ARCHIVE"
echo "You are entering in extract mode"
echo "extract $ARCHIVE" | netcat $HOST $PORT

}
