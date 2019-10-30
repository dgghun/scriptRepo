#!/bin/bash
################################################################################
# SCRIPT NAME:    updGit.sh
# BY:             David Garcia
# DATE:           
# DESCRIPTION:    
#                 
# 
################################################################################
#*******************************************************************************
# EXTERNAL FUNCTIONS ***********************************************************
#*******************************************************************************
source  ~/gitFunctions.sh               #various functions

#*******************************************************************************
# VARIABLES ********************************************************************
#*******************************************************************************

LOG="./updGit.log"                      #general log for this script
GITSRV="${XGITSRV}"                     #git server user and IP (.bashrc)
PROIP="${XPROIP}"                       #production server IP (.bashrc)

PROSRC="/dbc/src/"                      #production dbc source files
GITSRC="/source/dbc/src/"               #git server dbc source files (bare)
GITSRCTMP="/source/dbc/tmp/src/"        #git server dbc source files (staging)
PROBIN="/dbc/bin/"                      #production script source files
GITBIN="/source/dbc/bin/"               #git server script source files (bare)
GITBINTMP="/source/dbc/tmp/bin/"        #git server script source files (staging)

GENERRS=1                               #"General Errors" error code

#*******************************************************************************
# FUNCTIONS ********************************************************************
#*******************************************************************************

#** Takes in the test system user name and maps it to the production user name.
#   ${1} = Test system user name
#*
function setDevToProdUser(){
  local goodUser=0
  local DEVUSERS=("dgdev" "asdev" "gsdev" "dbdev")          #development user
  local PROUSERS=("dgarcia" "asapone" "gsmith" "dbullock")  #production user
  cnt=${#DEVUSERS[@]}
  local userFound=''
  for i in $(seq 0 ${cnt}); do
    if [ "${DEVUSERS[${i}]}" == "${1}" ]; then
      userFound="${PROUSERS[i]}"
      break
    fi
  done
  echo "${userFound}"
}

#** Copies production source files to git server & commits changes
#   ${1} = Production user name
#   ${2} = Local production directory
#   ${3} = Remote git directory
#*
function copyProdToGit(){
  ssh -T ${1}@${PROIP}<<COPYSRC
rsync -tv ${PROSRC}*.{TXT,VRB,PRG,IO,DEF,INC,PGM,VAR} ${GITSRV}:${GITSRCTMP}
rsync -tv ${PROBIN}*.sh ${GITSRV}:${GITBINTMP}
COPYSRC

  ssh -T ${GITSRV}<<UPDGIT
cd ${GITSRCTMP}
echo "${GITSRCTMP}"
git add .
git commit -m "pro-to-git $(date +"%m-%d-%y %I:%M:%S %p")"
git push
cd ${GITBINTMP}
echo "${GITBINTMP}"
git add .
git commit -m "pro-to-git $(date +"%m-%d-%y %I:%M:%S %p")"
git push
UPDGIT
}

#** Executes a git command
#   ${1} = Git command 
#*
function doGitCommand(){
 
  case "${1}" in
    '-pull')
        boldTxt "Executing: git pull"
        git pull
        ;;
    '-fetch')
        boldTxt "Executing: git fetch"
        git fetch
        ;;
    '-push')
        boldTxt "Executing: git push"
        git push
        ;;
  esac
}

#*******************************************************************************
# SCRIPT START *****************************************************************
#*******************************************************************************

#get production user name
sshUser=$(setDevToProdUser "$(whoami)")
if [ "${sshUser}" == "" ]; then
  redTxt "User $(whoami) is not setup to use this script."
  exit 1
fi

#ssh into production and copy files to git server 
boldTxt "Updating Git Server. Enter your production server password:"
copyProdToGit "${sshUser}" &> ${LOG}
err=$?
if [ ${err} -gt ${GENERRS} ];then 
  echo "Error ${err} - SSH connection or remote command failed. Check ${LOG} for more info."  
  exit 1
fi
grnTxt "Git server updated OK!"

#execute any passed in git commands
if [ $# -gt 0 ]; then 
  for i in $@;do
    doGitCommand "${i}"
  done
fi
 
grnTxt 'Bye!'
 
#*******************************************************************************
# updGit.sh END ****************************************************************
#*******************************************************************************