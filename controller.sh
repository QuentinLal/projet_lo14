#!/bin/bash

####################
#
#	CONTROLLER
#	Description : This script allows you to...
# - check if the user entered correct arguments
# -
#
####################

# $1 - mode (-start, -stop, -list, -browse, -extract)
# $2 - HOST
# $3 - PORT
# $4 - ARCHVIVE

# Helps the user to understand how to use vsh
function how_to_use {
	echo 'To use vsh:  [-start port] [-stop port] [-list host port] [-browse host port archive_name] [-extract host port archive_name]'
	exit 0
}

function check_arguments {

  if [[ $1 == '-start' && $# -ne 2 && $# -ne 3 ]]; then
		echo 'Invalid number of arguments.'
		how_to_use
		exit 1
	elif [[ $1 == '-stop' && $# -ne 2 ]]; then
		echo 'Invalid number of arguments.'
		how_to_use
		exit 1
	elif [[ $1 == '-list' && $# -ne 3 ]]; then
		echo 'Invalid number of arguments.'
		display_usage
		exit 1
	elif [[ ($1 == '-browse' || $1 == '-extract') && $# -ne 4 ]]; then
		echo 'Invalid number of arguments.'
		display_usage
		exit 1
	elif [[ $1 != '-start' && $1 != '-stop' && $1 != '-list' && $1 != '-browse' && $1 != '-extract' ]]; then
		echo 'Invalid option.'
		display_usage
		exit 1
	fi
	# check arguments syntax
	if [[ $1 == '-list' || $1 == '-browse' || $1 == '-extract' ]]; then
		check_ip "$2"
		check_port "$3"
		ping_server "$2" "$3"
	else
		check_port "$2"
	fi
	# check if a file is specified and if it is available on the server
	if [[ $1 == '-browse' || $1 == '-extract' ]]; then
		if [[ -z $4 ]]; then
			echo -e "You should specify the archive name.\nType 'vsh -list $2 $3' to display archives present on the server."
			exit 1
		else
			find_archive "$2" "$3" "$4"
		fi
fi



}
