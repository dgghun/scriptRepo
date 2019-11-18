#!/bin/bash
################################################################################
# SCRIPT NAME:    GITSW.sh
# BY:             David Garcia
# DATE:           
# DESCRIPTION:    Moves source files from "/dbc/src" or "/dbc/bin" to /dbc/work.
#                 Used in the git process on the production server. Adapted 
#                 form the SW script.
# 
################################################################################
# FUNCTIONS
function gitswOptionCheck(){
  case  "${OPT}" in
    "-u") #unlock file (ie remove it from work)
      tput setaf 2  #color green
      rm -fv ${fileCheck}
      tput sgr0     #color off
      exit 0
  esac
}

# VARIABLES
INITIALS=(DAV GLE AJS MAG BG DGG)
PRG=$1
OPT="$2"              #option
if [ "$2" ] && [ "${2:0:1}" != "-" ]; then  #has 2nd argument and not an option
  DIR="/$2"
else
  DIR=""
fi

#Check if programmer is added here
if [[ "${INITIALS[*]}" != *"$ME"* ]]; then
  tput setaf 1  #red color
    echo "Please add $ME to the INITIALS variable in this script to proceed."
  tput sgr0;    #color off
  exit 1
fi  

# Check if program is in use. If not, pull it into work
if [ $# -eq 0 -o $# -gt 2 ] ; then   ### bad params
  echo -e "\nMove source from /dbc/src OR /dbc/bin to /dbc/work"
  echo -e "\nUsage: GITSW <PROGRAM> <dir>\n"
else ### parameters ok
  if [ -f /dbc/src${DIR}/${PRG}.TXT ] || [ -f /dbc/bin${DIR}/${PRG}.sh ] ; then
    for i in ${INITIALS[*]};do
      fileCheck=''
      fileCheck=$(ls /dbc/work/${PRG}{"",".sh"}.${i} 2> /dev/null) #dont output "not found"
      if [ "${fileCheck}" != "" ];then                             #is it checked out?
        tput setaf 1  #red color
          if [ "${fileCheck##*.}" == "${ME}" ];then
            tput sgr0;    #color off
            echo "You have this checked out."
            gitswOptionCheck    #have the file, check for options
          else 
            echo "Program currently being edited!"
          fi
          echo ${fileCheck}
        tput sgr0;    #color off
        exit 1
      fi
    done
    
    fileToCopy=''
    fileToCopy=$(ls /dbc/{bin,src}${DIR}/${PRG}.{TXT,sh} 2> /dev/null)  #get file name
    tput setaf 2    #green color
    if $(echo ${fileToCopy} | grep -q "\.sh"$); then
        echo "Copying script..."
        cp -v ${fileToCopy} /dbc/work/${fileToCopy##*/}.$ME
    else
      reformat /dbc/src${DIR}/${PRG}.TXT /dbc/work/${PRG}.$ME -t -!
    fi
    tput sgr0;    #color off
  else  ### source doesn't exist
    tput setaf 1  #red color
      echo "Program ${PRG}.TXT does NOT exist !"
    tput sgr0     #color off
  fi
fi

#*******************************************************************************
# GITSW.sh END **********************************************************
#*******************************************************************************
