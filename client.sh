#!/bin/bash
function execute_command {

		case $1 in
			'-list')
				request-list;;
			'-extract')
				request-extract "$ARCHIVE";;
			'-browse')
				request-browse "$ARCHIVE";;
			*)
				echo 'Error'
				exit 1;;
		esac

}
#request the server to list its archives
function request-list {
if echo "list" | netcat $HOST $PORT; then
	echo "You asked to list all the archives on the server"
else
	echo "The server can not be reached."
fi
}
#request the server to extract a specified archive
function request-extract {
if echo "extract $ARCHIVE" | netcat $HOST $PORT; then
	echo "You asked to extract the following archive: $ARCHIVE"
else
	echo "The server can not be reached."
fi
}
#Enter in browse mode in order to make multiple requests
function request-browse {

echo "You asked to browse the following archive: $ARCHIVE"
echo "Availables commands: [pwd, cat filename, cd dirname, ls file/dirname, rm file/dirname, clear, man, exit]"

local cmd arg
while true; do
	echo "vsh:>"
	read cmd arg || exit -1
	echo "$cmd $arg $ARCHIVE" | netcat $HOST $PORT
done
}
