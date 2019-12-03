#!/bin/bash
################################################################################
# SCRIPT NAME:    GITCW.sh on PRODUCTION SERVER ONLY
# BY:             David Garcia
# DATE:           
# DESCRIPTION:    Compiles a DBC program. Used in the git process on the 
#                 PRODUCTION SERVER. Adapted form the CW script.
# 
################################################################################
# FUNCTIONS
function gitcwOptionCheck(){
  case  "${OPT}" in
    "-p")           #put compiled files into production (ie PP)
      tput setaf 6  #color cyan
      echo "Putting compiled .DBC file into production..."
      tput sgr0     #color off
      sh ~/GITPP.sh "${PRG}" "${DIR}"
      ;;
    "-"[pu][pu])    #put compiled files into production and remove checked out file from work
      tput setaf 6  #color cyan
      echo "Putting compiled .DBC file into production and removing source file..."
      tput sgr0     #color off
      sh ~/GITPP.sh "${PRG}" "${DIR}"
      if [ $? -eq 0 ];then  # no GITPP.sh errors 
        tput setaf 2        #color green
        rm -fv /dbc/work/$PRG.$ME
        tput sgr0           #color off
      fi
      ;;
  esac
}

# gitcwCopyToProChk()
# Checks if the copy-to-production option is set. If so, copies file from test
# to production.
function gitcwCopyToProChk(){
  case "${OPT}" in 
  "-"*[c]*) 
    tput setaf 6  #color cyan
    echo "Copying ${PRG} from test system to production..."
    scp ${MYIP}:/dbc/work/$PRG.{TXT,$ME} /dbc/work/ 2> /dev/null
    tput sgr0     #color off
    OPT="${OPT//c/}"  #remove all 'c' options
    ;;
  esac
}

# VARIABLES
cmpErr=0    #compile errors
INITIALS=(DAV GLE AJS MAG BG DGG)
MYIP=$1
PRG=$2
OPT="$3"              #option
if [ "$3" ] && [ "${3:0:1}" != "-" ]; then  #has 3rd argument and its not an option
  DIR="/$3"
else
  DIR=""
fi

if [ $# -eq 0 -o $# -gt 3 ] ; then   ### bad params
  echo -e "\nCompile DB/C program."
  echo -e "\nUsage: GITCW <PROGRAM>\n"
else
  if [ -e /dbc/work/$PRG.$ME ]; then
    gitcwCopyToProChk   #copy option check
    cmpErr=`dbcmp /dbc/work/$PRG.$ME ~/$PRG -z -i | grep "ERROR" -c`
    if [ -e ~/$PRG.DBG ] ; then
      mv -f ~/$PRG.DBG /dbc/prgd/
    fi
    
    if [ ${cmpErr} -eq 0 ]; then  #no compile errors
      tput setaf 2  #color green
        dbcmp /dbc/work/$PRG.$ME ~/$PRG -z -i #compile again and show success
      tput sgr0     #color off
      gitcwOptionCheck                        #have the file, check for options
    else
      dbcmp /dbc/work/$PRG.$ME ~/$PRG -z -i   #compile again and show errors
    fi
  else
    tput setaf 1  #red color
      echo "You don't have this DBC program checked out."
    tput sgr0;    #color off
  fi
fi

#*******************************************************************************
# GITCW.sh END **********************************************************
#*******************************************************************************
