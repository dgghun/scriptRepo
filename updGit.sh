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
CURRDIR=`pwd`                           #current directory

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

#** Exits the script and changes back to starting directory
#*
function exitScript(){
  cd "${CURRDIR}"
  exit 1
}

#** showHelp()
#   Prints this help screen :)
#*
function showHelp(){
  echo ""
  boldTxt " HELP SCREEN $(grnTxt "(updGit.sh)")"
  boldTxt ' sh updGit.sh [PATH] [OPTION]...'
  blueTxt ' Updates the git servers repo by copying over source files from production.'
  blueTxt ' Will execute passed in git commands on local repo.'
  blueTxt ' ${1} = Path to local repo (ie /dbc/src). MUST BE PASSED IN 1ST and '
  blueTxt '        ONLY needed if you are not in a repo and want to execute git commands.'
  blueTxt ' ${n} = Execute Git commands: -pull -fetch -push'
  echo ""
  boldTxt " Examples:"
  echo    '   sh updGit.sh                '$(blueTxt "#update git server")
  echo    '   sh updGit.sh -pull          '$(blueTxt "#update git server and do command in current dir repo")
  echo    '   sh updGit.sh /dbc/src -pull '$(blueTxt "#update git server and do command in passed in dir repo")
  echo ""
  
}
#*******************************************************************************
# SCRIPT START *****************************************************************
#*******************************************************************************

#help needed?
if [ "${1}" == "-help" ];then
  showHelp
  exit 0
fi

#check for passed in repo directory
if [[ -d "${1}" ]];then
  cd "${1}"
fi

#get production user name
sshUser=$(setDevToProdUser "$(whoami)")
if [ "${sshUser}" == "" ]; then
  redTxt "User $(whoami) is not setup to use this script."
  exitScript
fi

#ssh into production and copy files to git server 
boldTxt "Updating Git Server. Enter your production server password:"
copyProdToGit "${sshUser}" &> ${LOG}
err=$?
if [ ${err} -gt ${GENERRS} ];then 
  echo "Error ${err} - SSH connection or remote command failed. Check ${LOG} for more info."  
  exitScript
fi
grnTxt "Git server updated OK!"

#execute any passed in git commands
if [ $# -gt 0 ]; then 
  for i in $@;do
    doGitCommand "${i}"
  done
fi
 
grnTxt 'Bye!'
cd "${CURRDIR}"
 
#*******************************************************************************
# updGit.sh END ****************************************************************
#*******************************************************************************