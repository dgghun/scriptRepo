#!/bin/bash
################################################################################
# SCRIPT NAME:    findBadDelimCnts.sh
# BY:             David Garcia
# DATE:           11/27/19
# DESCRIPTION:    finds records that have columns with differing sizes. Useful
#                 when trouble shooting delimiter errors.
#
################################################################################
# Functions
#source /dbc/bin/functions.sh

INFILE="${1}"
DELIM=${2}

if [ "${INFILE}" == "" ]; then
  echo "No file passed in. Example: findBadDelimCnts.sh fileName.txt -, #comma delimiter"
  exit 1
elif [ "${DELIM}" == "" ]; then
  echo "No delimiter option. Example: findBadDelimCnts.sh fileName.txt -, #comma delimiter"
  exit 1
elif [ "${DELIM:0:1}" != "-" ]; then
  echo "Delimiter option formatted incorrectly. Example: script.sh -, #comma delimiter"
  exit 1
fi

DELIM="${DELIM:1:1}"  #remove '-' character
recs=(`cat $INFILE | cut -b 1-2 | sort | uniq`)
toChk=()    #bad records
toChkMax=() #bad records max delimiter

echo 'REC     CNT'
echo '-------|----------'
for i in ${recs[*]}; do
  cnt=(`grep ^$i $INFILE | awk -F "${DELIM}" '{print NF}' | sort | uniq`)
  if [ ${#cnt[*]} -gt 1 ];then
    tput setaf 1
    echo $i
    toChk+=("${i}")
    toChkMax+=(${cnt[0]}) #set max delimiter
  fi
  printf "REC $i |"
  echo  "${cnt[*]}"
  tput sgr0
done

rm ./findBadDelimCnts.tmp -f &> /dev/null
if [ ${#toChk[*]} -gt 0 ]; then
  tput setaf 3
  echo "Recs to check: ${toChk[*]}"
  tput sgr0
  
  max=$((${#toChk[*]} - 1))
  for i in `seq 0 ${max}`; do
    echo "REC:${toChk[$i]} MAX:${toChkMax[$i]}"
    grep ^"${toChk[$i]}" "${INFILE}" | awk -F "${DELIM}" -v x="${toChkMax[$i]}" '{if(NF > x) print }'
  done >> ./findBadDelimCnts.tmp
fi



