#!/bin/bash
################################################################################
# SCRIPT NAME:    lsauto.sh 
# BY:             David Garcia
# DATE:           6/26/20
# DESCRIPTION:    Formats AUTOLOG file output.
# REVISIONS:
# 
#
# 
################################################################################
source /dbc/bin/functions.sh
#...............................................................................
# FUNCTIONS
#...............................................................................
function printHead(){
  tput setaf 6
  printf "OPT  SEQ PRG-NAME START-DATE START-TIME  END-DATE   END-TIME    RUN-TIME\n"
  tput sgr0
}

function getDate(){
  if [[ "${1}" == "" ]];then
    printf "##/##/####"
    return
  fi
  
  local yr=${1:0:4}
  local mo=${1:4:2}
  local da=${1:6:2}
  printf "${mo}/${da}/${yr}"
}

function getTime(){
  if [[ "${1}" == "" ]];then
    printf "##:##:##-**"
    return
  fi
  
  local hr=${1:0:2}
  local min=${1:2:2}
  local sec=${1:4:2}
  local fullTime=`date --date="${hr}:${min}:${sec}" +"%I:%M:%S %p"`
  printf "${fullTime}"
}

function getRunTime(){
  local sDateTime=${1}
  local eDateTime=${2}
  
  if [[ "${eDateTime:0:1}" == '#' ]];then
    tput setaf 3
     printf "NOT DONE"
    tput sgr0
    return
  fi
  
  local sSecs=`date --date="${sDateTime}" +"%s"`
  local eSecs=`date --date="${eDateTime}" +"%s"`
  local runTimeSecs=$((${eSecs} - ${sSecs} ))
  
  if [ $(( ${runTimeSecs}/60 )) -gt 59 ]; then    #if greater than 59 mins....
    HR=$(( ${runTimeSecs} / 60 / 60 ))            #dived by 60 twice for hour
    MIN=$(( ${runTimeSecs} / 60 % 60 ))           #dived once & mod once for mins
    SEC=$(( ${runTimeSecs} % 60 ))                #mod once for seconds 
  else                                            #is less than 59 mins
    HR=0
    MIN=$(( ${runTimeSecs} / 60 ))                #dived once for mins
    SEC=$(( ${runTimeSecs} % 60 ))                #mod once for seconds
  fi
  printf "hrs:${HR} mins:${MIN} secs:${SEC}"
}
#...............................................................................
# SCRIPT START
#...............................................................................
if [[ "${CDB}"  == "" ]];then
  echo "Please initialize a database (ie PMS,OUT,INS)"
  exit 1
fi

prevOpt=""
prevPrgNum=0
list AUTOLOG${CDB} -e=500 | while read -r line; do
  opt=${line:0:2}
  prgNum=${line:2:2}
  sDate=`getDate ${line:4:8}`
  sTime=`getTime ${line:12:8}`
  eDate=`getDate ${line:20:8}`
  eTime=`getTime ${line:28:8}`
  prg=${line:36:8}
  runTime=`getRunTime "${sDate} ${sTime}" "${eDate} ${eTime}"`
  
  if [[ "${prevOpt}" != "${opt}" ]] || [[ ${prevPrgNum} -gt ${prgNum} ]];then
    echo ""
    printHead
  fi
  
  echo "${opt}   ${prgNum}  ${prg} ${sDate} ${sTime} ${eDate} ${eTime} ${runTime}"
  prevOpt="${opt}"
  prevPrgNum=${prgNum}
done

tput setaf 3
echo "-- (AUTOLOG${CDB}) --"
tput sgr0
