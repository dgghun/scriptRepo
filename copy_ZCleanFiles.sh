#!/bin/bash
###############################################################################
#copy "ZCleanFiles" to test directory
#
###############################################################################
source ~/colorFunctions.sh
###############################################################################
#variables
###############################################################################
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'                                # No Color
COUNT=0                           #counter
CPCNT=0                           #counter
###############################################################################

if [ "${1}" = "3"  ]; then 
  CDB="3"
  ZDIR="/home/dgdev/ZCleanFiles3"
elif [ "${1}" = "8" ]; then 
  CDB="8"
  ZDIR="/home/dgdev/ZCleanFiles8"
elif [ "${1}" = "1" ]; then 
  CDB="1"
  ZDIR="/home/dgdev/ZCleanFiles"
else 
  CYANL "Database not recognized. Defaulting to CDB1."
  CDB="1"
  ZDIR="/home/dgdev/ZCleanFiles"
fi
fileList=${ZDIR}/ZDir${CDB}fileList.txt     #file list location and name
ls ${ZDIR} > ${fileList}                    #make zdir file list 

if [[ "${1}" == "t" ]];then
  PURPL "Copying test files listed in ${fileList} to /home/testuser..."
  for i in `cat ${fileList}`;do
    ((COUNT++))
    cp ~/${i} /home/testuser &>/dev/null
    if [[ $? == 0 ]];then           #no errors
      ((CPCNT++))
    else 
      echo -e ${RED}"-->"${NC}${i}" was ${RED}NOT${NC} copied!"
    fi
  done
  PURPL "DONE!"
  echo -e ${GREEN}${CPCNT} ${NC}"out of" ${GREEN}${COUNT} ${NC}"files where copied to" ${GREEN}$(pwd)${NC}
  exit 0
fi

if [[ "${1}" == "d" ]] || [[ "${2}" == "d" ]];then 
  PURPL "Deleting CDB${CDB} files listed in ${fileList}..."
  for i in `cat ${fileList}`;do
    ((COUNT++))
    rm /home/testuser/${i} -f &>/dev/null
    rm ~/${i} -f &>/dev/null
    if [[ $? == 0 ]];then           #no errors
      ((CPCNT++))
    else 
      echo -e ${RED}"-->"${NC}${i}" was ${RED}NOT${NC} deleted!"
    fi
  done
  PURPL "DONE!"
  echo -e ${GREEN}${CPCNT} ${NC}"out of" ${GREEN}${COUNT} ${NC}"files where deleted from " ${GREEN}$(pwd)${NC}
else
  PURPL "Copying CDB${CDB} files...(${ZDIR})"
  for i in `cat ${fileList}`;do
    ((COUNT++))
    cp ${ZDIR}/${i} ~/ &>/dev/null
    if [[ $? == 0 ]];then           #no errors
      ((CPCNT++))
    else 
      echo -e ${RED}"-->"${NC}${i}" was ${RED}NOT${NC} copied!"
    fi
  done
  PURPL "DONE!"
  echo -e ${GREEN}${CPCNT} ${NC}"out of" ${GREEN}${COUNT} ${NC}"files where copied to" ${GREEN}$(pwd)${NC}
fi
echo `colorStars``colorStars``colorStars`
