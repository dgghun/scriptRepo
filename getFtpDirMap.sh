#!/bin/bash
 
###############################################################################
#..............................................................................
# VARIABLES
#..............................................................................
#ARCHIVE='/dbc/arc/cdb1/uca/'                      #archive path
#NULL='/dev/null'                                  #pipe output to null
#HERE='./'                                         
FTP='root@ftpserver'
#FTPDIR='/var/pub/ftp/ucla/'                       #ftp directory
#FTPARC='./var/pub/ftp/ucla/Archive/'               #ftp archive
#..............................................................................
# Script start
#..............................................................................
#du -ah --time --time-style="+%Y%m%d %H%M" --exclude ".*" /home/dgdev/var/ftp/ | awk '{print $2,$3,$4}' | awk '/[.]/' > dirMap.txt
FILENAME=""
FILEPATH=""
DIRPATH="/home/dgdev/var/ftp/"
DTF="+%Y%m%d %H%M"
DIRPATH="/var/ftp/"

trim()
{
    local trimmed="$1"

    # Strip leading spaces.
    while [[ $trimmed == ' '* ]]; do
       trimmed="${trimmed## }"
    done
    # Strip trailing spaces.
    while [[ $trimmed == *' ' ]]; do
        trimmed="${trimmed%% }"
    done

    echo "$trimmed"
}


du -ah --time --time-style="${DTF}" --exclude ".*" ${DIRPATH} | #full paths, date/time stamp, exclude hidden files
  awk '{print $2" "$3" "$4}' |        #date,time,full file path                                          
  awk '/[.]/' > dirMap.txt        #exclude anything without a dot (no directories)

rm -f dirMapOut.txt 
while IFS='' read -r line; do                 
  FILENAME=$(echo ${line##*/})                #get file name 
  FILEPATH=$(echo ${line##* })                #get file path and name
  FILEPATH=$(echo "${FILEPATH/$FILENAME/ }")  #get file path
#  echo "File: $FILENAME"
#  echo "Path: $FILEPATH"
#  echo "Full: $line"
  FILENAME=$(trim ${FILENAME})
  FILEPATH=$(trim ${FILEPATH})
  echo "$line~~~$FILEPATH$FILENAME" >> dirMapOut.txt
done < dirMap.txt 

