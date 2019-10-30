#!/bin/bash
################################################################################
#resets passed in cdb1 file names
source ~/colorFunctions.sh

echo "$(REDL "--> Resetting files...")"
START=$(date "+%s")                   #get start time in seconds
for i in $@;do
  cp -pv /dbc/txt/cdb1_backup/COF${i}.TXT /dbc/txt/cdb1/
  cp -pv /dbc/isi/cdb1_backup/COF${i}.{ISI,AIM} /dbc/isi/cdb1/
done

FIN=$(date "+%s")                     #get time in seconds
TSECS=$(( (FIN - START) ))            #get TOTAL execution time
HR=$(( $TSECS / 60 / 60 ))            #dived by 60 twice for hour
MIN=$(( $TSECS / 60 % 60 ))           #dived once & mod once for mins
SEC=$(( $TSECS % 60 ))                #mod once for seconds 
echo -e "\n$(REDL "--> Done! Run time: hrs:$HR mins:$MIN secs:$SEC")\n" 
  