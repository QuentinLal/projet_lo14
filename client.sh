#!/bin/bash
function execute_command {

		case $1 in
			'-list')
				request-list;;
			'-browse')
				request-browse "$ARCHIVE";;
			'-extract')
				request-extract "$ARCHIVE";;
			*)
				echo 'Error'
				exit 1;;
		esac

}

function request-list {
echo "You asked to list all the archives on the server"
echo "list" | netcat $HOST $PORT
}

function request-browse {
echo "You asked to browse the following archive: $ARCHIVE"
echo "browse $ARCHIVE" | netcat $HOST $PORT
}

function request-extract {
echo "You asked to extract the following archive: $ARCHIVE"
echo "extract $ARCHIVE" | netcat $HOST $PORT
}
