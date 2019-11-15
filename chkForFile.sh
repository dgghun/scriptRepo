#!/bin/bash
#
FILE=""
TSECS=0
HR=0
MIN=0
SEC=0

sh ~/waitForScript.sh chkForFile.sh

if [ "$1" = "" ];then
  printf "No file entered to monitor!\n"
else
  FILE=$1
  while [ ! -f $FILE ]; do                  #while file doesn't exist
    sleep 1                                 #pause one second
    ((TSECS++))                             #increment second count
    if [ $(( $TSECS/60 )) -gt 59 ]; then    #if greater than 59 mins....
      HR=$(( $TSECS / 60 / 60 ))            #dived by 60 twice for hour
      MIN=$(( $TSECS / 60 % 60 ))           #dived once & mod once for mins
      SEC=$(( $TSECS % 60 ))                #mod once for seconds 
      printf "\rFile not uploaded yet. (hrs:$HR mins:$MIN secs:$SEC)"
    else                                    
      MIN=$(( $TSECS / 60 ))                #dived once for mins
      SEC=$(( $TSECS % 60 ))                #mod once for seconds 
      printf "\rFile not uploaded yet. (hrs:$HR mins:$MIN secs:$SEC)"
    fi
  done                                      
  printf "\rFile is ready! (hrs:$HR mins:$MIN secs:$SEC)         \n"
fi
