#!/bin/bash
################################################################################
# SCRIPT NAME:    fixexceldates.sh
# BY:             David Garcia
# DATE:           09/29/20
# DESCRIPTION:    Replaces Excel serialized date numbers with real dates. Passed
#                 in file MUST be CSV comma delimited. 
#
# PASSED IN VARIABLES
# $1=Input file name. CSV comma delimited.
# $2=Date field positions string to check/fix. Format: "1 2 3" 
# $3=(Optional) Date output format. Uses "date" command output format options. 
#    See "date --help" for more info. Default: "%x" = locale's date representation. 
# 
# REVISIONS:
# 
# 
################################################################################
#..............................................................................
# VARIABLES
#..............................................................................
infile=${1}                       #in file to check/fix
tmpfile=${1}.fixexceldates.tmp    
dtPositions=${2}                  #date positions 
dtFrmt="${3}"                     #date output format
if [[ "${dtFrmt}" == "" ]];then
  dtFrmt="%x"                     #no option, set default date output
fi 
#..............................................................................
# SCRIPT START
#..............................................................................
rm -f ${tmpfile} &>/dev/null
while read -r rec;do

  for i in ${dtPositions}; do                                 #all date positions
    dt=`echo ${rec} |                                         #print out record to pipe
        sed 's/"[^"]\+"/~getgrcl~/g'  |                       #replace double quoted fields 
        awk -F',' -v dtPos="${i}" '{print $dtPos}'`           #print out date
    echo "${dt}" | grep "\/\|-" -q                            #check for date chars "/" or "-"
    if [[ $? -gt 0 ]] && [[ "${dt}" =~ ^[0-9]+$ ]];then       #wasn't a date and is a number
      tmpdt=`echo $((${dt} - 2))`                             #back two days for excel calculation
      NEWDT=`date -d "1/1/1900 +${tmpdt} days" +"${dtFrmt}"`  #get excel serialized date
      NEWREC=`echo ${rec} | 
        awk -v olddt="${dt}" -v newdt="${NEWDT}" '{
          gsub(","olddt",", ","newdt",")                      #replace old with new date     
          print 
        }'`
      ###echo -e "OLD: $dt $dtminus1 NEW:$NEWDT : $NEWREC\n"     #for testing
      rec=${NEWREC}                                           #save new record
    fi
  done

  echo ${rec} >> ${tmpfile}                                   #write out record
done < ${infile}
mv -f ${tmpfile} ${infile}
  
