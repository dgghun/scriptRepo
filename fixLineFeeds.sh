#!/bin/bash
################################################################################
# SCRIPT NAME:    fixlinefeeds.sh
# BY:             David Garcia
# DATE:           03/03/2020
# DESCRIPTION:    Fixes record files that contain data with extra line feeds
#                 that causes data to be shifted to new lines. The script 
#                 compares search expression passed in to the BEGINING of each
#                 record. If the record doesn't match this correct format, it
#                 is fixed. Examples of how to use the script are below.
#
# ARGUMENTS:
#   ${1} = File to fix (ie someFile.txt or /path/to/someFile.txt)
#   $(2) = Grep search expression. Examples:
#       A)
#         RECORD FORMAT = "123456,David Garcia,Some data"
#         COMMAND = fixlinefeeds.sh someFile.txt "[0-9]\{1,\}\," 
#         Explanation: any number,from 1 to any, ending with a comma. (the comma is escaped)
#
#       B)
#         RECORD FORMAT = "ABC456|David Garcia|Some data"
#         COMMAND = fixlinefeeds.sh someFile.txt "[A-Z]\{1,3\}[0-9]\{1,\}|" 
#         Explanation: any uppercase letters from 1 to 3 characters, any number,from 1 to any, ending with a pipe.
# 
################################################################################
### fixLineFeeds "${inFile}" "[0-9]\{1,\}\,"      #check file 
#*******************************************************************************
# VARIABLES ********************************************************************
#*******************************************************************************
inFile="${1}"                                 #file to fix
MASK=${2}                                     #starting record mask
tempFile=${FILE}.EDITED.TXT                 #temp work file
cnt=0                                       #file position count
oldFileCnt=0                                #old file position count
previous=''                                 #stores previous read record
errFlag=0
#*******************************************************************************
# SCRIPT START ********************************************************************
#*******************************************************************************

if [[ "${inFile}" == "" ]];then
  tput setaf 1
  echo "No file name passed in!"
  tput sgr0
  echo "SCRIPT FORMAT: fixlinefeeds.sh someFile.txt 'grepSearchExpression' "
  exit 1
elif [[ "${MASK}" == "" ]];then
  tput setaf 1
  echo "No file mask passed in!"
  tput sgr0
  echo "SCRIPT FORMAT: fixlinefeeds.sh someFile.txt 'grepSearchExpression' "
  exit 1
fi

rm ${tempFile} -f &> /dev/null              #remove stale files
echo "Processing file $1"                   #for testing

while IFS='' read -r line; do               #read the file
  ((cnt++))                                 #increment count
  ((oldFileCnt++))                          #increment count
  if [ ${cnt} -eq 1 ]; then                 #skip header record
    echo "${line}" >> ${tempFile}
    continue
  fi
  
  echo $line | grep ^"${MASK}" -q                       #check for good starting record
  if [[ $? == 1 ]];then                                 #is this a good record?
    errFlag=1
    ((cnt = ${cnt} - 1))                                #nope, decrement the count before delete
    sed  -i "${cnt}d" ${tempFile}                       #delete previously written record
    newLine=`echo $previous | tr -d '\r' | tr -d '\n'`  #strip newLine & return carriage characters of previous line
    echo "${newLine}${line}" >> ${tempFile}             #write out the new fixed line
    previous="${newLine}${line}"                        #set previous variable
    echo "FIXED LINE: $cnt in NEW file, LINE: ${oldFileCnt} in OLD file"   
    continue
  else
    echo "${line}" >> ${tempFile}                       #write good record
  fi
  previous="${line}"                                    #save as previous record
done < "${inFile}"                                      #read the file END                 

if [[ ${errFlag} == 1 ]];then                           #found bad records?
  echo "Records all fixed."
  mv -f ${tempFile} ${inFile}                           #yup, save updates
else 
  echo "No records to fix"
  rm -f ${tempFile}
fi
echo "done. bye!"


