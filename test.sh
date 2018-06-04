#!/bin/sh
while read one_of_the_paths; do
  THE_PATH=$one_of_the_paths
  echo $THE_PATH
done <archive/mydirectories.txt
