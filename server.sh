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
      interaction < "$FIFO" | ncat -l -k  "$PORT" > "$FIFO"
    done
}

# La fonction interaction lit les commandes du client sur entrée standard
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
      exit 0
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

function mode-pwd()
{
  pwd
}

function mode-cat()
{
 echo "cat"
}

function mode-cd()
{
   echo "cd"
}
function mode-ls()
{

            grep '^directory' $ARCHIVE | sed 's/directory //g' > dir.txt                  #On recup header

            if [ $# -eq 0 ]; then
                FOLDER="$CURRENT"
            elif [ $# -eq 1 ]; then
                FOLDER=$(echo $1 | sed 's/\/$//g')                                        #On recup l'argument supprime l'éventuelle / en fin de ligne
                VAR=$(echo $FOLDER | awk -F/ '{print $1}')                                #On récup ./ ou ../ si existe
                if [ "$VAR" = "." ]; then                                                 #Si ls .
                    FOLDER="$CURRENT"
                elif [ "$VAR" = ".." ]; then                                              #Si ls .. ou ls ../...
                    MASTER=$(echo $CURRENT | sed 's/\(.*\)\/[A-Z a-z 0-9]*$/\1/g')
                    if [ "$FOLDER" = ".." ]; then
                        FOLDER="$MASTER"
                    else
                        FOCUS=$(echo $FOLDER | sed 's/^\.\.\/\(.*\)$/\1/g')
                        FOLDER="$MASTER/$FOCUS"
                    fi
                else
                    FOLDER="$CURRENT/$VAR"
                fi
            else
                echo "Need 1 or 0 Argument"
            fi
            touch /tmp/target.txt

            ligne=$(grep -n '^directory '$FOLDER'' $ARCHIVE | head -1 | cut -d: -f1)     #On recup num de ligne du répertoire à lister
            lignedel=$(grep -n '^@$' $ARCHIVE | cut -d: -f1 | tail -$ligne)              #On recup les numéros de ligne ne contenant que
            lignedel=$(echo $lignedel | sed 's/ /:/g')                                   #des @ qui délimite les répertoires dans le header
            #pos=$(grep -n '^'$FOLDER'' dir.txt | head -1 | cut -d: -f1)                 #On recup la postition target (Dans la liste complête des répertoires)
            lastpos=$(echo $lignedel | cut -d: -f$pos)    #$pos                          #On recup la dernière ligne prenant le numéro de la ligne du @ correspondant au répertoire à lister
            nbligne_tot=$(($lastpos-$ligne-1))                                           #On calcul ensuite le nombre de ligne total
            cat $ARCHIVE | head -$(($lastpos-1)) | tail -$nbligne_tot >> /tmp/target.txt #On recup les lignes et on affiche

            touch /tmp/targetdir.txt
            dir=""

            while read ligne ; do
                var1=$(echo $ligne | awk '{print $2}' | cut -c 4)
                var2=$(echo $ligne | awk '{print $2}' | cut -c 1)
                if [ "$var2" = "d" ]; then
                    dir=$(echo $ligne | awk '{print $1}')
                    echo "$dir" >> /tmp/targetdir.txt
                elif [ "$var1" = "x" ]; then
                    dir=$(echo $ligne | awk '{print $1}')
                    echo "$dir" >> /tmp/targetdir.txt
                else
                    dir=$(echo $ligne | awk '{print $1}')
                    echo "$dir" >> /tmp/targetdir.txt
                fi
            done < /tmp/target.txt

            cat /tmp/targetdir.txt
            rm  /tmp/target.txt
            rm  /tmp/targetdir.txt
}

function mode-rm()
{
  echo "rm"
}

function mode-extract() {
  echo "[Server] You asked for the extraction of the following archive(s): $args"

  #Path of the archive for which the client asked for an extraction
  ARCHIVE=archive/$args

  #This will store all the path in the archive in a .txt file
  cat $ARCHIVE | grep "directory [A-Za-z0-9]*/" | sed "s/directory //g" > mydirectories.txt

  #This will create all the directories from the .txt file
  xargs -I {} mkdir -p "{}" < mydirectories.txt


  #Loop through the paths of the file mydirectories.txt
  while read one_of_the_paths; do

    THE_PATH=$one_of_the_paths

    FILES_AND_DIRS_RIGHTS=$(awk -v THE_PATH=$THE_PATH'$' '$0~THE_PATH{flag=1;next}/@/{flag=0} flag' $ARCHIVE)
    RIGHTS=$(echo "$FILES_AND_DIRS_RIGHTS" | cut -f2 -d ' ')
    FILES_AND_DIRS=$(echo "$FILES_AND_DIRS_RIGHTS" | cut -f1 -d ' ')

    echo "$FILES_AND_DIRS_RIGHTS" > temporary_files/FILES_AND_DIRS_RIGHTS.txt
    echo "$RIGHTS" > temporary_files/RIGHTS.txt
    echo "$FILES_AND_DIRS" > temporary_files/FILES_AND_DIRS.txt

    #We introduce the var I, that we will use for the command sed -n $I'p'
    I=1
    while read lines; do

    rights=$(cat temporary_files/RIGHTS.txt | sed -n $I'p')
    files_and_dirs=$(cat temporary_files/FILES_AND_DIRS.txt | sed -n $I'p')

    user_rights_1=$(echo $rights | cut -c2)
    user_rights_2=$(echo $rights | cut -c3)
    user_rights_3=$(echo $rights | cut -c4)

    group_rights_1=$(echo $rights | cut -c5)
    group_rights_2=$(echo $rights | cut -c6)
    group_rights_3=$(echo $rights | cut -c7)

    other_rights_1=$(echo $rights | cut -c8)
    other_rights_2=$(echo $rights | cut -c9)
    other_rights_3=$(echo $rights | cut -c10)


    #Si la première lettre de la ligne 'I' de "RIGHTS.txt" commence par "d" alors, c'est un répertoire auquel on attribue les droits
    if [[ $rights == d* ]]; then
       echo "------------------"
       echo "The server found a directory located in $THE_PATH/$files_and_dirs"
       echo "Adding the rights $rights to it..."

       chmod u+$user_rights_1 $THE_PATH'/'$files_and_dirs
       chmod u+$user_rights_2 $THE_PATH'/'$files_and_dirs
       chmod u+$user_rights_3 $THE_PATH'/'$files_and_dirs

       chmod g+$group_rights_1 $THE_PATH'/'$files_and_dirs
       chmod g+$group_rights_2 $THE_PATH'/'$files_and_dirs
       chmod g+$group_rights_3 $THE_PATH'/'$files_and_dirs

       chmod o+$other_rights_1 $THE_PATH'/'$files_and_dirs
       chmod o+$other_rights_2 $THE_PATH'/'$files_and_dirs
       chmod o+$other_rights_3 $THE_PATH'/'$files_and_dirs

    #Si la première lettre de la ligne 'I' de "RIGHTS.txt" commence par "-" alors, c'est un répertoire auquel on attribue les droits
    elif [[ $rights  == -* ]]; then
       echo "------------------"
       echo "The server found a file located in $THE_PATH/$files_and_dirs"
       echo "Adding the rights $rights to it..."

       touch $THE_PATH'/'$files_and_dirs

       chmod u+$user_rights_1 $THE_PATH'/'$files_and_dirs
       chmod u+$user_rights_2 $THE_PATH'/'$files_and_dirs
       chmod u+$user_rights_3 $THE_PATH'/'$files_and_dirs

       chmod g+$group_rights_1 $THE_PATH'/'$files_and_dirs
       chmod g+$group_rights_2 $THE_PATH'/'$files_and_dirs
       chmod g+$group_rights_3 $THE_PATH'/'$files_and_dirs

       chmod o+$other_rights_1 $THE_PATH'/'$files_and_dirs
       chmod o+$other_rights_2 $THE_PATH'/'$files_and_dirs
       chmod o+$other_rights_3 $THE_PATH'/'$files_and_dirs
     fi
    let "I++"

    done <temporary_files/FILES_AND_DIRS_RIGHTS.txt


  done <mydirectories.txt

#Cleaning...
rm -f mydirectories.txt
rm -rf temporary_files/*
}

function mode-error-arg() {
  echo "Error-arg: The server can not treat your request"
}

# Accept and treat the connections
accept-loop
