#!/bin/bash
################################################################################
# SCRIPT NAME:    qdCompilePrgs.sh
# BY:             David Garcia
# DATE:           10/08/19
# DESCRIPTION:    Builds a list of programs to compile and compiles them. Used
#                 when needing to compile multiple programs after updating a 
#                 module program. 
#
# NOTE:           Uses modified version of the PP program to move compiled files
#                 to the correct directories without user input. (PPforce.sh)
#
################################################################################
OUTFILE="COMPILE_LOG"
SCRIPT="PPforce.sh"

rm ./${OUTFILE}.{TXT,TMP} 2> /dev/null

#'for i grep' NOTES: 
# 1. search for all programs that use COSSSCOD or COSSSCHG or SCODMULT.
# 2. replace blank spaces
# 3. search for 'include' phrase in programs
# 4. ignore quick and dirty programs "QD"
# 5. include only .TXT files
echo "Compiling programs.."
for i in `grep "COSSSCOD\|COSSSCHG\|SCODMULT" /dbc/src/* 2> /dev/null | sed 's/ //g' | grep "INCLUDE" | grep -v "\/QD" | grep "\.TXT"`;do
  p=`echo ${i%.TXT*} | awk '{print substr($0,10)}'`   #get just program name
  compMsg=`CW $p`

  if `echo ${compMsg} | grep -q "successfully" `;then
    echo "$compMsg"             >> ./${OUTFILE}.TMP
    sh ${SCRIPT} ${p} | grep -i "not\|mov" &> /dev/null        #move DBC file to production and display progress
  else
    echo "DID NOT COMPILE: ${p}"  >> ./${OUTFILE}.TMP
  fi
done

cat ./${OUTFILE}.TMP | sort | tee -a ./${OUTFILE}.TXT
rm ./${OUTFILE}.TMP 
echo "Done! Output saved to ${OUTFILE}.TXT"
