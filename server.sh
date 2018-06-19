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
CURRENT="Exemple/Test/"
# The pipe
FIFO="/tmp/$USER-fifo-$$"

# When the connection ends, we kill the pipe in order to keep clean the
# /tmp. directory. We use the instruction "trap" in order to be sure to clean it
# even if the server is interrupted by any signal.
#function cleaner() {
#  pipes_to_kill=$(ls /tmp/ | grep "$USER-fifo" | xargs -L1 rm -f)
#}


function nettoyage() { rm -f "$FIFO"; }
trap nettoyage EXIT
# We create the pipe
[ -e "$FIFO" ] || mkfifo "$FIFO"


function accept-loop() {
  echo "The server is now listening on the port $PORT"
    while true; do
      interaction < "$FIFO" | ncat -l -p  "$PORT" > "$FIFO"
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
    if [[ $cmd = "list" || $cmd = "extract" ]]; then
	    $fun $args
      exit 0
    else
      #We are in browse mode
      $fun $args
    fi
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


function mode-archive_to_browse() {
ARCHIVE=archive/$args
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------
function  mode-pwd()
{
  if [ $# -eq 0 ]; then
      echo "$CURRENT/"
  else
      echo "No Argument required (use man)"
  fi
}
#------------------------------------------------------------------------------------------------------------------------------------------------------------------
function mode-cat()
{
  grep '^directory' $ARCHIVE | sed 's/directory //g' > dir.txt                         #On recup header
  if [ $# -eq 0 ]; then
      echo "We need a file in Argument (use man)"
  elif [ $# -eq 1 ]; then
      VAR=$args
  fi
  touch /tmp/target.txt
  ligne=$(grep -n '^directory '$CURRENT'' $ARCHIVE | head -1 | cut -d: -f1)            #On recup num de ligne du répertoire actuel
  search=$(grep -n '^@$' $ARCHIVE | cut -d: -f1)                                       #On recup les numéros de ligne ne contenant que
  search=$(echo $search | sed 's/ /:/g')                                               #des @ qui délimite les répertoires dans le header
  pos=$(grep -n '^'$CURRENT'' dir.txt | head -1 | cut -d: -f1)                         #On recup la postition target (Dans la liste complête des répertoires)
  lastpos=$(echo $search | cut -d: -f$pos)                                             #On recup la dernière ligne prenant le numéro de la ligne du @ correspondant au répertoire à lister
  nbligne_tot=$(($lastpos-$ligne-1))                                                   #On calcul ensuite le nombre de ligne total
  cat $ARCHIVE | head -$(($lastpos-1)) | tail -$nbligne_tot >> /tmp/target.txt         #On recup les lignes et on affiche
  valtot=$(head -1 $ARCHIVE | awk -F: '{print $2}')
  while read ligne ; do
      verif=$(echo $ligne | awk '{print $1}')
      var1=$(echo $ligne | awk '{print $2}' | cut -c 2)
      var2=$(echo $ligne | awk '{print $2}' | cut -c 1)
      var3=$(echo $ligne | awk '{print $4}')
      var4=$(echo $ligne | awk '{print $5}')
      if [ "$verif" = "$VAR" ]; then
          if [ "$var2" = "-" ]; then
              if [ "$var1" = "r" ]; then
                  if [ "$var4" != "0" ]; then
                      cat $ARCHIVE | head -$(($var3-1+$var4-1+valtot)) | tail -$var4
                      Flagwork="1"
                  else
                      echo "Empty File"
                      Flagwork="1"
                  fi
              else
                  echo "You need right on file to use cat"
              fi
          else
              echo "The Argument have to be a file"
          fi
      fi
  done < /tmp/target.txt
  if [ "$Flagwork" != "1" ];then
      echo "file not found"
  fi
  rm /tmp/target.txt
  rm dir.txt
}
#------------------------------------------------------------------------------------------------------------------------------------------------------------------
function mode-cd()
{
  grep '^directory' $ARCHIVE | sed 's/directory //g' > dir.txt                         #On recup header
  if [ $# -eq 0 ]; then
      FOLDER="$CURRENT"
      Flagfinnish="1"
  elif [ $# -eq 1 ]; then
      FOLDER=$(echo $1)
      VAR=$(echo $FOLDER | awk '{print $1}')
      if [ "$VAR" = "." ]; then
          FOLDER="$CURRENT"
      elif [ "$VAR" = ".." ] || [ "$VAR" = "../" ]; then                               #Si cd .. ou cd ../
          if [ "$CURRENT" = "Exemple/Test" ]; then
              FOLDER="$CURRENT"
              Flagfinnish="1"
              echo "$FOLDER"
          else
              FOLDER=$(echo "$CURRENT" | sed -e 's/^\(.*\/\)[^\/]*/\1/')
              FOLDER=$(echo "$FOLDER" | sed -e 's/[/]$//g')
          fi
      elif [ "$VAR" = "/" ]; then                                                      #Si cd /
          CURRENT="Exemple/Test/"
          Flagfinnish="1"
          echo "$CURRENT"
      else
          FOLDER="$CURRENT/$VAR"
      fi
  else
  echo "Need 1 or 0 Argument (use man)"
  fi
  if [ "$Flagfinnish" != "1" ] ; then
      if [ "$Flagprevious" != "1" ] ; then
          ligne=$(grep -n '^directory '$FOLDER'' $ARCHIVE | head -1 | cut -d: -f1)    #On recup num de ligne du répertoire actuel
          search=$(head -$ligne $ARCHIVE | tail -1 | sed 's/directory //g' )
          if [ "$search" = "$FOLDER" ] ; then
              CURRENT=$FOLDER/
              echo "$CURRENT"
          elif [ "$search/" = "$FOLDER" ] ; then
              CURRENT=$FOLDER
              echo "$CURRENT"
          else
              echo "Argument Error"
          fi
      fi
  fi
  rm  dir.txt
}
#------------------------------------------------------------------------------------------------------------------------------------------------------------------
function mode-ls()
{

  grep '^directory' $ARCHIVE | sed 's/directory //g' > dir.txt                         #On recup header
  if [ $# -eq 0 ]; then
      FOLDER="$CURRENT"
  elif [ $# -eq 1 ]; then
      FOLDER=$(echo $1 | sed 's/\/$//g')                                               #On recup l'argument supprime l'éventuelle / en fin de ligne
      VAR=$(echo $FOLDER | awk -F/ '{print $1}')                                       #On récup ./ ou ../ si existe
      if [ "$VAR" = "." ]; then                                                        #Si ls .
          FOLDER="$CURRENT"
      elif [ "$VAR" = ".." ]; then                                                     #Si ls .. ou ls ../
          FOLDER=$(echo "$CURRENT" | sed -e 's/^\(.*\/\)[^\/]*/\1/')
          FOLDER=$(echo "$FOLDER" | sed -e 's/[/]$//g')
      elif [ "$VAR" = "-l" ]; then
          FlagRight="1"
          FOLDER="$CURRENT"
      else
          FOLDER="$CURRENT/$VAR"
      fi
  else
      echo "Need 1 or 0 Argument (use man)"
  fi
  touch /tmp/target.txt
  ligne=$(grep -n '^directory '$FOLDER'' $ARCHIVE | head -1 | cut -d: -f1)             #On recup num de ligne du répertoire actuel
  search=$(grep -n '^@$' $ARCHIVE | cut -d: -f1)                                       #On recup les numéros de ligne ne contenant que
  search=$(echo $search | sed 's/ /:/g')                                               #des @ qui délimite les répertoires dans le header
  pos=$(grep -n '^'$FOLDER'' dir.txt | head -1 | cut -d: -f1)                          #On recup la postition target (Dans la liste complête des répertoires)
  lastpos=$(echo $search | cut -d: -f$pos)                                             #On recup la dernière ligne prenant le numéro de la ligne du @ correspondant au répertoire à lister
  nbligne_tot=$(($lastpos-$ligne-1))                                                   #On calcul ensuite le nombre de ligne total
  cat $ARCHIVE | head -$(($lastpos-1)) | tail -$nbligne_tot >> /tmp/target.txt         #On recup les lignes et on affiche
  touch /tmp/targetdir.txt
  dir=""
  while read ligne ; do
       var1=$(echo $ligne | awk '{print $2}' | cut -c 4)
       var2=$(echo $ligne | awk '{print $2}' | cut -c 1)
       if [ "$FlagRight" != "1" ]; then
           if [ "$var2" = "d" ]; then
               dir=$(echo $ligne | awk '{print $1}')
               echo "$dir/" >> /tmp/targetdir.txt
           elif [ "$var2" = "-" ]; then
               dir=$(echo $ligne | awk '{print $1}')
               echo "$dir*" >> /tmp/targetdir.txt
           else
               dir=$(echo $ligne | awk '{print $1}')
               echo "$dir" >> /tmp/targetdir.txt
           fi
       else
           if [ "$var2" = "d" ]; then
               dir=$(echo $ligne | awk '{print $1,$2}')
               echo "$dir" >> /tmp/targetdir.txt
           elif [ "$var2" = "-" ]; then
               dir=$(echo $ligne | awk '{print $1,$2}')
               echo "$dir" >> /tmp/targetdir.txt
           else
               dir=$(echo $ligne | awk '{print $1,$2}')
               echo "$dir" >> /tmp/targetdir.txt
           fi
       fi
  done < /tmp/target.txt
  cat /tmp/targetdir.txt
  rm  /tmp/target.txt
  rm  /tmp/targetdir.txt
  rm  dir.txt
}
#------------------------------------------------------------------------------------------------------------------------------------------------------------------
function mode-rm()
{
  grep '^directory' $ARCHIVE | sed 's/directory //g' > dir.txt                         #On recup header
  if [ $# -eq 1 ]; then
      VAR=$1
      if [ "$VAR" = "CF" ] || [ "$VAR" = "CURRENTFolder" ]; then
          Flagcf="1"
      fi
  else
      echo "We need a file in Argument (use man)"
  fi
  if [ "$Flagcf" != "1" ]; then
      touch /tmp/target.txt
      ligne=$(grep -n '^directory '$CURRENT'' $ARCHIVE | head -1 | cut -d: -f1)            #On recup num de ligne du répertoire actuel
      search=$(grep -n '^@$' $ARCHIVE | cut -d: -f1)                                       #On recup les numéros de ligne ne contenant que
      search=$(echo $search | sed 's/ /:/g')                                               #des @ qui délimite les répertoires dans le header
      pos=$(grep -n '^'$CURRENT'' dir.txt | head -1 | cut -d: -f1)                         #On recup la postition target (Dans la liste complête des répertoires)
      lastpos=$(echo $search | cut -d: -f$pos)                                             #On recup la dernière ligne prenant le numéro de la ligne du @ correspondant au répertoire à lister
      nbligne_tot=$(($lastpos-$ligne-1))                                                   #On calcul ensuite le nombre de ligne total
      cat $ARCHIVE | head -$(($lastpos-1)) | tail -$nbligne_tot >> /tmp/target.txt         #On recup les lignes et on affiche
      valtot=$(head -1 $ARCHIVE | awk -F: '{print $2}')
      while read ligne ; do
          verif=$(echo $ligne | awk '{print $1}')
          var1=$(echo $ligne | awk '{print $2}' | cut -c 3)
          var2=$(echo $ligne | awk '{print $2}' | cut -c 1)
          var3=$(echo $ligne | awk '{print $4}')
          var4=$(echo $ligne | awk '{print $5}')
          if [ "$verif" = "$VAR" ]; then
              if [ "$var2" = "-" ]; then
                  Flagwork="1"
                  delete_file $var1 $var3 $var4
              elif [ "$var2" = "d" ]; then
                  Flagwork="1"
                  delete_dir $VAR
              else
                   echo "The Argument have to be a file or directory"
              fi
          fi
      done < /tmp/target.txt
      if [ "$Flagwork" != "1" ];then
          echo "Argument not found"
      fi
  fi
  rm /tmp/target.txt
  rm dir.txt
}
function delete_file() {
  if [ "$var1" = "w" ]; then
      if [ "$var4" != "0" ]; then
          debut=$((var3-1 + valtot))
          rav=$((var3))
          fin=$((var3-1 + var4-1 + valtot))
          if [ "$debut" = "$fin" ]; then
              sed -i '' "${debut}d" $ARCHIVE                                            #Or sed -i".bak" for windows user
              sed -i '' '/'$VAR'/d' $ARCHIVE
              Flagwork="1"                                           #Or sed -i".bak" for windows user
          else
              sed -i '' '/'$VAR'/d' $ARCHIVE                                            #Or sed -i".bak" for windows user
              let debut--
              let fin--
              for (( i=$debut; i<=$fin; i++ )); do
                  sed -i '' "${debut}d" $ARCHIVE                                    #Or sed -i".bak" for windows user
              done
              Flagwork="1"
          fi
          while read ligne ; do
              var=$(echo $ligne | awk -F: '{print $2}')
              var12=$(echo $ligne | awk '{print $2}' | cut -c 1)
              var22=$(echo $ligne | awk '{print $4}')
              if [ "$flagH" != "1" ];then
                  varx=$((var-rav))
                  sed -i '' "s/^\([0-9]*:\)${var}/\1${varx}/g" $ARCHIVE
                  flagH="1"
              fi
              if [ "$var12" = "-" ]; then
                  PRNI_SOURCE=$((var22))
                  PRNI_CIBLE=$((var22-var4))
                  if [ "$((rav))" -lt "$((PRNI_SOURCE))" ]; then
                      #cat $ARCHIVE | awk -F' ' 'BEGIN {OFS=" "} $4=='$PRNI_SOURCE' {$4='$PRNI_CIBLE'}1' > $ARCHIVE
                      echo "here"
                      sed -i '' "s/\([0-9]* \)${PRNI_SOURCE} /\1${PRNI_CIBLE} /g" $ARCHIVE
                      echo $ligne
                  fi
              fi
          done < $ARCHIVE
      else
          echo "Empty File"
          Flagwork="1"
      fi
  else
      echo "You need right on file to use cat"
  fi
}
function delete_dir() {
  RAV="$VAR"
  sed -i '' '/'$RAV'/d' $ARCHIVE #Or sed -i".bak" for windows user
}
#------------------------------------------------------------------------------------------------------------------------------------------------------------------
function mode-exit() {
  exit 0
}
#------------------------------------------------------------------------------------------------------------------------------------------------------------------
function mode-clear() {
  clear
}
#------------------------------------------------------------------------------------------------------------------------------------------------------------------
function mode-man() {
  if [ $# -eq 0 ]; then
      echo "We have actualy 7 command -> ls, cd, cat, rm, exit and clear, if you need help for ls write : man ls  It works with the 6 others command"
  elif [ $# -eq 1 ]; then
      if [ "$1" = "ls" ]; then
          echo "Use "ls" to print the content of current folder"
          echo "Use "ls -l" to print rights of the content of current folder"
          echo "Use "ls [namefolder]" to print the content of  namefolder (it have to be content on current folder)"
          echo "Use "ls ../" or "ls .." to print the content of master current folder"
      elif [ "$1" = "rm" ]; then
          echo "Use "rm [namefile]" to remove the namefile (it have to be content on current folder)"
          echo "Use "rm [namefolder]" to remove the namefoler (it have to be content on current folder)"
          echo "Use "rm [CF]" or "rm [CURRENTFolder]" to remove the current folder"
      elif [ "$1" = "cd" ]; then
          echo "Use "cd [namefolder]" to change the current folder by namefolder"
          echo "Use "cd ../" or "cd .." to change the current folder by master current folder"
      elif [ "$1" = "pwd" ]; then
          echo "Use "pwd" to print PATH of current folder"
      elif [ "$1" = "cat" ]; then
          echo "Use "cat [namefile]" to print the content of namefile (it have to be content on current folder)"
      elif [ "$1" = "exit" ]; then
          echo "Use "exit" to leave archiv"
      elif [ "$1" = "clear" ]; then
          echo "Use "clear" to clean the board"
      else
          echo "This command doesn't exist"
      fi
  else
      echo "Need 1 or 0 Argument (use man)"
  fi
}
#------------------------------------------------------------------------------------------------------------------------------------------------------------------


function mode-error-arg() {
  echo "Error-arg: The server can not treat your request"
}

# Accept and treat the connections
accept-loop
