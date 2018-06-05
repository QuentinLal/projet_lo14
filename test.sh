#!/bin/sh

#This will store all the path in the archive in a .txt file
cat archive/test1.arch | grep "directory [A-Za-z0-9]*/" | sed "s/directory //g" > mydirectories.txt

#This will create all the directories from the .txt file
xargs -I {} mkdir -p "{}" < mydirectories.txt


THE_PATH=Exemple/Test/
FILES_AND_DIRS_RIGHTS=$(awk -v THE_PATH=$THE_PATH'$' '$0~THE_PATH{flag=1;next}/@/{flag=0} flag' archive/test1.arch)
RIGHTS=$(echo "$FILES_AND_DIRS_RIGHTS" | cut -f2 -d ' ')
FILES_AND_DIRS=$(echo "$FILES_AND_DIRS_RIGHTS" | cut -f1 -d ' ')

#Here we are applying a treatment over $FILES_AND_DIRS_RIGHTS:
#A drwxr-xr-x 4096
#B drwxr-xr-x 4096
#toto1 -rwxr-xr-x 29 1 3
#toto2 -rw-r--r-- 249 4 10

echo "$FILES_AND_DIRS_RIGHTS" > temporary_files/FILES_AND_DIRS_RIGHTS.txt
echo "$RIGHTS" > temporary_files/RIGHTS.txt
echo "$FILES_AND_DIRS" > temporary_files/FILES_AND_DIRS.txt


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
   echo "Oh un répertoire !"
   echo "On va lui attribuer les droits suivant: "

   chmod u+$user_rights_1 $THE_PATH$files_and_dirs
   chmod u+$user_rights_2 $THE_PATH$files_and_dirs
   chmod u+$user_rights_3 $THE_PATH$files_and_dirs

   chmod g+$group_rights_1 $THE_PATH$files_and_dirs
   chmod g+$group_rights_2 $THE_PATH$files_and_dirs
   chmod g+$group_rights_3 $THE_PATH$files_and_dirs

   chmod o+$other_rights_1 $THE_PATH$files_and_dirs
   chmod o+$other_rights_2 $THE_PATH$files_and_dirs
   chmod o+$other_rights_3 $THE_PATH$files_and_dirs

  #Si la première lettre de la ligne 'I' de "RIGHTS.txt" commence par "-" alors, c'est un répertoire auquel on attribue les droits
elif [[ $rights  == -* ]]; then
   echo "------------------"
   echo "Oh un fichier !"
   echo "On va le créer et lui attribuer les droits suivant: "

   touch $THE_PATH'/'$files_and_dirs

   chmod u+$user_rights_1 $THE_PATH$files_and_dirs
   chmod u+$user_rights_2 $THE_PATH$files_and_dirs
   chmod u+$user_rights_3 $THE_PATH$files_and_dirs

   chmod g+$group_rights_1 $THE_PATH$files_and_dirs
   chmod g+$group_rights_2 $THE_PATH$files_and_dirs
   chmod g+$group_rights_3 $THE_PATH$files_and_dirs

   chmod o+$other_rights_1 $THE_PATH$files_and_dirs
   chmod o+$other_rights_2 $THE_PATH$files_and_dirs
   chmod o+$other_rights_3 $THE_PATH$files_and_dirs

 fi
let "I++"

done <temporary_files/FILES_AND_DIRS_RIGHTS.txt
