#!/bin/bash
################################################################################
# SCRIPT NAME:    gitFunctions.sh
# BY:             David Garcia
# DATE:           
# DESCRIPTION:    
#                 
# 
################################################################################
#@  gitFunctionsHelp()
#@  Prints this help screen :)
#@
function gitFunctionsHelp(){
  local cnt=0
  grep "^\#\@" ~/gitFunctions.sh | 
    awk '{print substr($0,4)}'   |
    while read line; do
      ((cnt++))
      if [ ${cnt} = 1 ];then 
        echo ""
        boldTxt " FUNCTIONS HELP SCREEN $(grnTxt "(gitFunctions.sh)")"
        printf " To show common Git commands: $(boldTxt 'git help')"
        printf " To list all Git commands: $(boldTxt '   git help -a') "
        echo ""
        boldTxt " ${line}"
      elif [[ "${line}" == *"()"* ]];then
        boldTxt " ${line}"
      else
        blueTxt " ${line}"
      fi
    done                         |
    awk '{print}' | less -R
}

#@  gitshow() [HASH] [PATH]
#@  Prints the difference between the current and last commit.
#@  ${1} = Git commit hash (ie 44d3b7d)
#@  ${2} = Optional. Path to repo (ie /dbc/src)
#@
function gitshow(){
  if [ $# -gt 1 ]; then
    local curdir=`pwd`
    cd "$2"
    if [ $? -gt 0 ]; then
      cd "${curdir}"
      return
    fi
    git show --color --pretty=format:%b "${1}"
    cd "${curdir}"
  else
    git show --color --pretty=format:%b "${1}"
  fi
}

#@  gitstat() [PATH]
#@  Prints the current repos status
#@  ${1} = Optional. Path to repo (ie /dbc/src)
#@
function gitstat(){
   if [ $# -gt 0 ]; then
    local curdir=`pwd`
    cd "$1"
    if [ $? -gt 0 ]; then
      cd "${curdir}"
      return
    fi
    git status
    cd "${curdir}"
   else
    git status
   fi
}

#@  gitlog() [PATH]
#@  Prints the current repos git commit log
#@  ${1} = Optional. Path to repo (ie /dbc/src)
#@
function gitlog(){
  if [ $# -gt 0 ]; then
    local curdir=`pwd`
    cd "$1"
    if [ $? -gt 0 ]; then
      cd "${curdir}"
      return
    fi
    git log --graph --oneline --decorate --color
    cd "${curdir}"
  else
    git log --graph --oneline --decorate --color
  fi 
}

#@  gitlogtime() [PATH]
#@  Prints the current repos git commit log
#@  ${1} = Optional. Path to repo (ie /dbc/src)
#@
function gitlogtime(){
  if [ $# -gt 0 ]; then
    local curdir=`pwd`
    cd "$1"
    if [ $? -gt 0 ]; then
      cd "${curdir}"
      return
    fi
    git log --pretty=format:"%C(yellow)%h %Creset%an %C(green)%ar %CresetMSG:%C(cyan)'%s'" --graph
    cd "${curdir}"
  else
    git log --pretty=format:"%C(yellow)%h %Creset%an %C(green)%ar %CresetMSG:%C(cyan)'%s'" --graph
  fi
}

#@  gitcommitall() [MESSAGE] [PATH]
#@  Adds and commits all changes/files to repo
#@  ${1} = 50 char commit message string
#@  ${2} = Optional. Path to repo (ie /dbc/src)
#@  
function gitcommitall(){
  if [ $# -gt 1 ]; then
    local curdir=`pwd`
    cd "$2"
    if [ $? -gt 0 ]; then
      cd "${curdir}"
      return
    fi
    git add . ; git commit -m "${1}"
    cd "${curdir}"
  else
    git add . ; git commit -m "${1}"
  fi
}

#@  gitchkmaster() [PATH]
#@  Checks out the master branch
#@  ${1} = Optional. Directory path to git repo (ie /dbc/src).
#@
function gitchkoutMaster(){
  if [ $# -gt 0 ]; then
    local curdir=`pwd`
    cd "$1"
    if [ $? -gt 0 ]; then
      cd "${curdir}"
      return
    fi
    git checkout master
    cd "${curdir}"
  else
    git checkout master
  fi
}

#@  gitchkdevelop() [PATH]
#@  Checks out the development branch. 
#@  ${1} = Optional. Directory path to git repo (ie /dbc/src).
#@
function gitchkoutDevelop(){
  if [ $# -gt 0 ]; then
    local curdir=`pwd`
    cd "$1"
    if [ $? -gt 0 ]; then
      cd "${curdir}"
      return
    fi
    git checkout develop
    cd "${curdir}"
  else
    git checkout develop
  fi
}

#@  getProductionUser() [USER]
#@  Shows the mapped test-to-production server user name.
#@
function getProductionUser(){
  local cnt=0
  local userFound=''
  local DEVUSERS=("dgdev" "asdev" "gsdev" "dbdev")          #development user
  local PROUSERS=("dgarcia" "asapone" "gsmith" "dbullock")  #production user
  cnt=${#DEVUSERS[@]}
  for i in $(seq 0 ${cnt}); do
    if [ "${DEVUSERS[${i}]}" == "${1}" ]; then
      userFound="${PROUSERS[i]}"
      break
    fi
  done
  echo "${userFound}"
}

#@  gitupdGit() [PATH] [GIT COMMAND]
#@  Updates the git server's repo by copying over source files from production.
#@  Will also execute passed in git commands on local repo.
#@  ${1} = Optional. Path to local repo (ie /dbc/src). MUST BE PASSED IN 1ST and 
#@  '      ONLY needed if you are not in a repo and want to execute git commands.
#@  ${1 or 2} = Execute Git commands: -pull -fetch -push'
#@  Examples: 
#@  gitupdGit                    #updates git server (GS)
#@  gitupdGit -pull              #updates GS & does 'git pull' on current repo/dir
#@  gitupdGit /dbc/src -pull     #updates GS, & does 'git pull' on past in repo/dir
#@
function gitupdGit(){
  #local variables
  local curdir=`pwd`
  local curUser="$(whoami)"
  local LOG="./gitupdGit.log"                      #general log for this function
  local GITSRV="${XGITSRV}"                     #git server user and IP (.bashrc)
  local PROIP="${XPROIP}"                       #production server IP (.bashrc)
  local PROSRC="/dbc/src/"                      #production dbc source files
  local GITSRCTMP="/source/dbc/tmp/src/"        #git server dbc source files (staging)
  local PROBIN="/dbc/bin/"                      #production script source files
  local GITBINTMP="/source/dbc/tmp/bin/"        #git server script source files (staging)
  local GENERRS=1                               #"General Errors" error code
  
  #local functions
  #** Copies production source files to git server & commits changes
  #   ${1} = Production user name
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
  
  #get production user name
  local sshUser=""
  sshUser=$(getProductionUser "$curUser")
  if [ "${sshUser}" == "" ]; then
    redTxt "User ${curUser} is not setup to use this function. (gitFunctions)"
    cd "${curdir}"
    return
  fi

  #ssh into production and copy files to git server 
  boldTxt "Updating Git Server. Enter your production server password:"
  copyProdToGit "${sshUser}" &> ${LOG}
  local err=$?                    #save error codes if any
  unset -f copyProdToGit          #destroy local function after use
  if [ ${err} -gt ${GENERRS} ];then 
    echo "Error ${err} - SSH connection or remote command failed. Check ${LOG} for more info."  
    cd "${curdir}"
    return
  fi
  grnTxt "Git server updated OK! (check ${LOG} for more info)"
  
  #check for passed in repo directory
  if [[ -d "${1}" ]];then
    cd "${1}"
    blueTxt "${1} - On branch $(git branch | grep \* | awk '{print $2}')"
  fi

  #execute any passed in git commands
  if [ $# -gt 0 ]; then 
    for i in $@;do
      case "${i}" in
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
    done
  fi
  
  cd "${curdir}"                                            #back to previous directory
  grnTxt 'Bye!'
} 

#@  gitlockFile() [FILENAME] [OPTION]
#@  Checks out a file on the production server from your test system
#@  (ie copies it to the production server work directory /dbc/work)
#@  ${1} = File name with no extension (eg COPPWORK or someScript)
#@  ${2} = Option.
#@  -u = unlocks file (ie removes from /dbc/work)
#@
function gitlockFile(){
  #local variables
  local inFile="${1}"
  local option="${2}" #TODO option to unlock file
  local lockScript="sh ~/GITSW.sh"              #production server script
  local PROIP="${XPROIP}"                       #production server IP (.bashrc)
  
  #check input
  if [ "${inFile}" == "" ]; then
    redTxt "No file entered."
    return
  fi
  
  #get production user name
  local sshUser=""
  sshUser=$(getProductionUser "$(whoami)")
  if [ "${sshUser}" == "" ]; then
    redTxt "User ${curUser} is not setup to use this function. (gitFunctions)"
    return
  fi
  
  #lock file
  boldTxt "Enter production password:"
  ssh -tq ${sshUser}@${PROIP} "source .bash_profile .bashrc; "${lockScript} ${inFile}""
}

#@  gitcw() [FILENAME] [OPTION]
#@  Compiles a file that is checked out on the production server from your test  
#@  system.  
#@  ${1} = File name (eg COPPWORK)
#@  ${2} = Option.
#@  -p = put compiled file into production (ie similar to PP script)
#@
function gitcw(){
  #local variables
  local inFile="${1}"
  local option="${2}" #TODO add -p option to function
  local dataBase=PMS
  local compileScript="sh ~/GITCW.sh"           #production server script
  local PROIP="${XPROIP}"                       #production server IP (.bashrc)
  
  #check input
  if [ "${inFile}" == "" ]; then
    redTxt "No file entered."
    return
  fi
  
  #get production user name
  local sshUser=""
  sshUser=$(getProductionUser "$(whoami)")
  if [ "${sshUser}" == "" ]; then
    redTxt "User ${curUser} is not setup to use this function. (gitFunctions)"
    return
  fi
  
  #compile file
  boldTxt "Enter production password:"
  ssh -tq ${sshUser}@${PROIP} "
    source .bash_profile .bashrc /dbc/bin/functions.sh;
    ${dataBase} &> /dev/null;
    "${compileScript} ${inFile}";
  "
}

#@  cdsrc()
#@  Changes directory to dbc source & gets git status
#@
function cdsrc(){
  cd /dbc/src; git status;
}

#@  cdbin()
#@  Changes directory to dbc source & gets git status
#@
function cdbin(){
  cd /dbc/bin; git status;
}

#@  cdwork()
#@  Changes directory to dbc work & gets git status
#@
function cdwork(){
  cd /dbc/work; git status;
}

#@  boldTxt() [STRING]
#@  Prints the string as bold font
#@  ${1} = Some string
#@
function boldTxt(){
  tput bold; echo "${1}"; tput sgr0;
}

#@  grnTxt() [STRING]
#@  Prints the string as green font
#@  ${1} = Some string
#@ 
function grnTxt(){
  local GRN=2
  tput setaf ${GRN}; echo "${1}"; tput sgr0;
}

#@  blueTxt() [STRING]
#@  Prints the string as blue font
#@  ${1} = Some string
#@ 
function blueTxt(){
  local BLUE=6
  tput setaf ${BLUE}; echo "${1}"; tput sgr0;
}

#@  redTxt() [STRING]
#@  Prints the string as red font
#@  ${1} = Some string
#@ 
function redTxt(){
  local RED=1
  tput setaf ${RED}; echo "${1}"; tput sgr0;
}

#*******************************************************************************
# gitFunctions.sh END **********************************************************
#*******************************************************************************