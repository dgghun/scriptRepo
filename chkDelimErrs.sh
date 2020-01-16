#!/bin/bash
################################################################################
# SCRIPT NAME:    chkDelimErrs.sh
# BY:             David Garcia
# DATE:           1/16/19
# DESCRIPTION:    Checks the COPIPDLM error logs. You can pass in a number of
#                 how many days back to check. Default is 14 days back
#                 Example: 
#                 sh chkDelimErrs 1  #checks error logs from 1 day ago 
#
#
################################################################################

function checkDelimErrs(){
  local LOGS=/arc/logs/copipdlm/
  local days=${1}
  local dateToGrep
  
  if [[ "${days}" == "" ]];then
    days=14   #default 2 weeks
  fi
  
  
  function listFiles(){
    for i in `ls -t ${LOGS}"COPIPDLM_ERR"*${1}* 2>/dev/null`;do
      ls -lh ${i} | awk '{print $6,$7,$8,$9}' | tr "\n" " "
      grep ^"-" ${i} | grep "<>" -v
    done
  }
  
  for i in `seq 0 ${days}`;do
    if [[ $i -eq 0 ]]; then continue; fi
    dateToGrep=`date --date="${i} days ago" +"%Y%m%d"`
    listFiles ${dateToGrep}
  done  
  
  printf "COPIPDLM ERROR LOGS IN THE PAST ${days} DAY/s: "
  
  for i in `seq 0 ${days}`;do
    if [[ $i -eq 0 ]]; then continue; fi
    dateToGrep=`date --date="${i} days ago" +"%Y%m%d"`
    listFiles ${dateToGrep} 
  done | wc -l | awk '{print}'
}

checkDelimErrs ${1}





