#!/bin/bash
################################################################################
# SCRIPT NAME:    comp_chrm_prgs.sh
# BY:             David Garcia
# DATE:           4-29-19
# DESCRIPTION:    Builds a list of programs that use COSPCHRM/COSPCHRN read/write 
#                 routines and compiles them.  
#                 
# 
################################################################################
# NOTES:
#       NO COCO PROGRAMS
#       NO CONT PROGRAMS
#       NO QD PROGRAMS
#       NO DUPLICATE PROGRAM NAMES
################################################################################
DBCSRC="/dbc/src/"
FILE_PRGS="./PRGS.TXT"
LOG="COMPILELOG.TXT"
SCRIPT="PPforce.sh"

rm -f ./${FILE_PRGS}* ./${LOG}* &> /dev/null

#BUILD THE LIST
#TESTINGgrep -i "READCHRM\|WRITCHRM\|READCHRN\|WRITCHRN" ${DBCSRC}* | grep -i "CALL" > ${FILE_PRGS}.TMP1  #read/write calls to COSPCHROM
grep -i "CODFTEMP" ${DBCSRC}* | grep -i "INCLUDE" > ${FILE_PRGS}.TMP1  #TESTING for CODFTEMP
#TESTINGgrep  -v "${DBCSRC}QD\|~\|CONT\|QND" ${FILE_PRGS}.TMP1 |       #no QD or note programs
grep  -v "${DBCSRC}QD\|~\|QND" ${FILE_PRGS}.TMP1 |       #TESTING for CODFTEMP no QD 
  awk '{print substr($1, 1, match($1,":")-1)}' |          #print file path and name
  sort | uniq > ${FILE_PRGS}.TMP2                         #sort it and remove duplicates
grep "TXT"$ ${FILE_PRGS}.TMP2 > ${FILE_PRGS}              #only txt files

#COMPILE THE LIST
FILES=`sed 's/.TXT//g' ${FILE_PRGS}`                      #Save file names w/out extension
for i in ${FILES};do                                      #Loop through file names
  CW ${i##*src/} > ./${LOG}.TMP                           #compile file name                      
  if grep -q "successfully" ./${LOG}.TMP;then             #check if it was successful
    grep "successfully" ./${LOG}.TMP >> ./${LOG}          #write success message
    sh ${SCRIPT} ${i##*src/} | grep -i "not\|mov"         #move DBC file to production and display progress
  else                                                    
    echo "ERROR: ${i##*src/} did not compile" >> ./${LOG} #write failure message
  fi                                                      
done                                                      
echo -e "Done\n\n"

rm -f ./${LOG}.TMP ${FILE_PRGS}.TMP*  &> /dev/null                                      
sort -o ./${LOG} ./${LOG}                                 #sort it
cat ./${LOG} -b                                           #show it
