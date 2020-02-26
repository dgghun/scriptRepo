#!/bin/bash
################################################################################
# SCRIPT NAME:    
# BY:             David Garcia
# DATE:           
# DESCRIPTION:    IN DEVLOPMENT                   
# 
################################################################################
#*******************************************************************************
# VARIABLES ********************************************************************
#*******************************************************************************
ROOTDIR="${1}"
ALLFILES="DG.ALL.TXT"
BADFILES="DG.BAD.TXT"
GOODFILES="DG.GOOD.TXT"
fileCnt=0
START=0
FIN=0
TSECS=0
marker="echo"
#*******************************************************************************
# FUNCTIONS ********************************************************************
#*******************************************************************************
# startTime()
function startTime(){
  START=$(date "+%s")       #get start time in seconds
}

# stopTime()
function stopTime(){
  FIN=$(date "+%s")                       #get time in seconds
  TSECS=$(( (FIN - START) ))              #get TOTAL execution time
  
  tput setaf 5  #green
  if [ $(( $TSECS/60 )) -gt 59 ]; then    #if greater than 59 mins....
    HR=$(( $TSECS / 60 / 60 ))            #dived by 60 twice for hour
    MIN=$(( $TSECS / 60 % 60 ))           #dived once & mod once for mins
    SEC=$(( $TSECS % 60 ))                #mod once for seconds 
    echo "-TOTAL RUN TIME: hrs:$HR mins:$MIN secs:$SEC" 
  else                                    #is less than 59 mins
    MIN=$(( $TSECS / 60 ))                #dived once for mins
    SEC=$(( $TSECS % 60 ))                #mod once for seconds
    echo "-TOTAL RUN TIME: mins:$MIN secs:$SEC" 
  fi
  tput sgr0   #color off
}
#*******************************************************************************
# SCRIPT START ********************************************************************
#*******************************************************************************
rm "${ALLFILES}" "${BADFILES}" "${GOODFILES}" &> /dev/null
find "${ROOTDIR}" > ${ALLFILES}
echo "Total files: `wc -l ${ALLFILES}`"
startTime                               #timer start

echo "Writing bad files to ${BADFILES}..."
##find "${ROOTDIR}" | awk -F '/' '{print NF,$0}' | sort -k1,1n -k2 | sed 's/^[0-9]*\ //g'
grep "${marker}" -lr  "${ROOTDIR}" | awk '{print "\""$0"\""}' 2>/dev/null > ${BADFILES} 

  
stopTime      #stop timer and print total time


