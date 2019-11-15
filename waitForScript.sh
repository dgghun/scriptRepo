#!/bin/bash
################################################################################
# SCRIPT NAME:    waitForScript.sh
# BY:             David Garcia
# DATE:           11/14/19
# DESCRIPTION:    Pauses control if the passed in script is running more than
#                 one instance.    
#                 
# 
################################################################################
#*******************************************************************************
# VARIABLES ********************************************************************
#*******************************************************************************
SCRIPTNAME="${1}"
scriptCnt=0

#*******************************************************************************
# SCRIPT START *****************************************************************
#*******************************************************************************
if [ $# -eq 0 ];then 
  echo "Please provide script name."
  exit 1
fi

INITIDS=`ps aux | grep "grep\|waitForScript.sh" -v | grep "${SCRIPTNAME}" | awk '{print $2}'`
INITSCRIPTCNT=`ps aux | grep "grep\|waitForScript.sh" -v | grep "${SCRIPTNAME}" -c` #get number of instances
if [ ${INITSCRIPTCNT} -le 1 ];then  
  exit 0
fi

while true; do
  scriptCnt=`ps aux | grep "grep\|waitForScript.sh" -v | grep "${SCRIPTNAME}" -c` #get number of instances
  CURIDS=(`ps aux | grep "grep\|waitForScript.sh" -v | grep "${SCRIPTNAME}" | awk '{print $2}'`)
  
  msgIds=''
  for i in ${CURIDS[*]};do
    if [ `echo $INITIDS | grep $i -c` -eq 0 ]; then
      ((scriptCnt--))
    fi
  done
  
  if [ ${scriptCnt} -le 1 ];then  
    printf "DONE!\n"
    break
  fi
  
  printf "\rWaiting for $((scriptCnt - 1)) process to finish..."
  sleep 1
done
