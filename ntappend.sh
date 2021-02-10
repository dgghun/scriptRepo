#!/bin/bash
################################################################################
# SCRIPT NAME:    ntappend.sh
# BY:             David Garcia
# DATE:           09/24/20
# DESCRIPTION:    Appends long notes together from a note file based on a blank
#                 action/result field. FILE MUST BE SORTED BEFORE HAND! Intended
#                 as a supplemental script to CONT programs. 
#
# PASSED IN VARIABLES:
# $1=Field size for each note file field. Example: "6 20 8 8 4 55"
# $2=Action/Result field position
# $3=Note field position
# $4=File to process
# $5=Output file
#
# EXAMPLES:
# ntappend.sh '6 20 3 8 8 4 55' 6 7 MCRNOTES.SRT MCRNOTES.SRT #output to same file
# ntappend.sh '6 20 3 8 8 4 55' 6 7 MCRNOTES.SRT OUTFILE.TXT  #output to different file
#
# REVISIONS:
#
# sh ntappend.sh '6 20 3 8 8 4 55' 6 7 FIXNOT-OUT.TXT OUTFILE.TXT  #TESTING 
################################################################################
#...............................................................................
# VARIABLES
#...............................................................................
PRGNAME="script.sh"
FIELDSIZES="${1}"                 #fix positions for awk
ACRC_POS=${2}                     #combined action/result field position
NOTE_POS=${3}                     #note field position
INFILE="${4}"                     #file to process
OUTFILE="${5}"                    #output file
TMPFILE=${OUTFILE}.NTAPPEND       #temp file
#...............................................................................
# FUNCTIONS
#...............................................................................
#function appends the notes
function appendNotes(){
  awk -v fieldSizes="${FIELDSIZES}" -v acrcPos=${ACRC_POS} -v notePos=${NOTE_POS} -v outfile=${1} -v ntCnt=${noteCnt} '
    function trim(str){
      gsub(/^[ ]+/,"",str)  #remove one or more (+) starting (^) spaces 
      gsub(/[ ]+$/,"",str)  #remove one or more (+) ending ($) spaces 
      return str
    }
  
    BEGIN{
      FIELDWIDTHS = fieldSizes
      note=""
      longnote=""
      fullRec=""
      printf "\r                                                               "
    }
    
    #Awk start
    {
      printf "\rMESSAGES: Appending notes "NR
      actionResult=$acrcPos
      note=$notePos
      
      if(trim(actionResult) != ""){       
        if(length(trim(longnote)) > 0)        #have previous appended note?
          print trim(fullRec)""longnote >> outfile
        else if(length(trim(fullRec)) > 0)    #have previous record?
          print fullRec >> outfile
        
        fullRec=$0          #save record
        longnote = ""       #clear variable
        next
      }else{
        if(length(trim(longnote)) > 0)        #have prevoius long note?
          longnote = trim(longnote)" "        #append a space
          
        longnote = trim(longnote)""trim(note) #append note
      }
    }
    END{
      #print out last note
      if(length(trim(longnote)) > 0)      #have previous appended note?
        print trim(fullRec)""longnote >> outfile
      else if(length(trim(fullRec)) > 0)  #have previous record?
        print fullRec >> outfile
      
      printf "\rMESSAGES: Appending notes done!                              \n"
    }
    ' < ${INFILE} 
}
#...............................................................................
# SCRIPT START
#...............................................................................
if [[ ${#5} -gt 0 ]];then               #output file passed in
  rm -f ${TMPFILE}                      #purge old files
  appendNotes ${TMPFILE}                #save to temp output file
  mv -f ${TMPFILE} ${OUTFILE}           #save to output file
else
  echo "No output file passed in. Exiting."
fi

