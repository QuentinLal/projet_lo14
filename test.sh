#!/bin/sh
ARCHIVE="archive/test1.arch"

grep '^directory' $ARCHIVE | sed 's/directory //g' > dir.txt                         #On recup header
if [ $# -eq 0 ]; then
    echo "We need a file in Argument (use man)"
elif [ $# -eq 1 ]; then
    VAR=$1
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
