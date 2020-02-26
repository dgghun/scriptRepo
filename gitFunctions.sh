#!/bin/bash
################################################################################
# SCRIPT NAME:    gitFunctions.sh
# BY:             David Garcia
# DATE:           
# DESCRIPTION:    
#                 
# 
################################################################################
function gittestcpsrc(){
  #for testing. Updates mock production system repo
  ssh -Tq dgarcia@$XPROIP "
    cd ~/gitTestDir
    pwd
    git pull
    cp /dbc/src/*.{TXT,VRB,PRG,IO,DEF,INC,PGM,VAR} ./ -fp
    git add .
    git commit -m 'Production test update'
    git push
    
    cd ~/gitTestDirBin/bin
    pwd
    git pull
    cp /dbc/bin/*.sh ./ -fp
    git add .
    git commit -m 'Production test update'
    git push
    "
   if [ "${1}" == "u" ]; then
    curdir=`pwd`
    cd /dbc/src; pwd; git reset --hard origin/master;
    cd /dbc/bin; pwd; git reset --hard origin/master;
    cd "${curdir}"
   fi
}

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
  #local variables
  local dirToGo=$(shorthand "${2}")   #check for short hand path
  local curdir=`pwd`
  
  if [ $# -gt 1 ]; then
    cd "${dirToGo}"
    if [ $? -gt 0 ]; then
      cd "${curdir}"
      return
    fi
    echo "${dirToGo}"
  fi
  
  git show --color --pretty=format:%b "${1}"
  cd "${curdir}"
}

#@  gitstat() [PATH]
#@  Prints the current repos status
#@  ${1} = Optional. Path to repo (ie /dbc/src)
#@
function gitstat(){
  #local variables
  local dirToGo=$(shorthand "${1}")   #check for short hand path
  local curdir=`pwd`
  
  if [ $# -gt 0 ]; then
   cd "${dirToGo}"
   if [ $? -gt 0 ]; then
     cd "${curdir}"
     return
   fi
   echo "${dirToGo}"
  fi

  git status
  cd "${curdir}"
}


#@  gitlog() [PATH]
#@  Prints the current repos git commit log
#@  ${1} = Optional. Path to repo (ie /dbc/src)
#@
function gitlog(){
  #local variables
  local dirToGo=$(shorthand "${1}")   #check for short hand path
  local curdir=`pwd`
  local dateFormat='%m-%d-%y %I:%M:%S %p'
  local logFormat='%C(yellow)%h %C(cyan)%an%x09 %Creset%C(bold)%ad%Creset%C(auto)%d %s'
  
  if [ $# -gt 0 ]; then
    cd "${dirToGo}"
    if [ $? -gt 0 ]; then
      cd "${curdir}"
      return
    fi
    echo "${dirToGo}"
  fi 

  git log --decorate --all --full-history --date-order --date=format:"${dateFormat}" --pretty=format:"${logFormat}"
  cd "${curdir}"
}

#@  gitlogsearch() [FILENAME] [PATH]
#@  Prints the current repos git commit log
#@  ${1} = File to search for in git commit history
#@  ${2} = Optional. Path to repo (ie /dbc/src)
#@
function gitlogsearch(){
  #local variables
  local curdir=`pwd`
  local dateFormat='%m-%d-%y %I:%M:%S %p'
  local logFormat='%C(yellow)%h %C(cyan)%an%x09 %Creset%C(bold)%ad%Creset%C(auto)%d %s'
  
  if [ "${1}" == "" ];then
    redTxt "No file name entered"
    return 1
  else
    local fileToFind=" -- ${1}"
  fi
  
  if [ $# -gt 1 ]; then
    local dirToGo=$(shorthand "${2}")   #check for short hand path
    cd "${dirToGo}"
    if [ $? -gt 0 ]; then
      cd "${curdir}"
      return
    fi
    echo "${dirToGo}"
  fi 

  result=`git log --decorate --all --full-history --date-order --date=format:"${dateFormat}" --pretty=format:"${logFormat}" ${fileToFind}`
  if [ ${#result} -gt 0 ];then
    git log --decorate --all --full-history --date-order --date=format:"${dateFormat}" --pretty=format:"${logFormat}" ${fileToFind}
  else
    echo "Could not find ${1} in history"
  fi
  cd "${curdir}"
}

#@  gitcommitall() [MESSAGE] [PATH]
#@  Adds and commits all changes/files to repo
#@  ${1} = 50 char commit message string
#@  ${2} = Optional. Path to repo (ie /dbc/src)
#@  
function gitcommitall(){
  #local variables
  local curdir=`pwd`
  local dirToGo=$(shorthand "${2}")   #check for short hand path
  local commitMsg="${1}"
  
  #check message size
  if [ ${#commitMsg} -gt 50 ]; then 
    redTxt "Commit message is too long. 50 characters max."
    return 1
  elif [ ${#commitMsg} -lt 4 ]; then 
    redTxt "Commit message is too short."
    return 1
  fi

  #check if need to change directories
  if [ $# -gt 1 ];then
    if [ ! -d "${dirToGo}" ];then
      redTxt "Directory does not exist"
      return 1
    fi
    cd ${dirToGo}
  fi
  
  #add changes to local index
  blueTxt "Executing 'git add .' in "${dirToGo}""
  git add .  
  if [ $? -gt 0 ];then
    cd "${curdir}"
    return 1
  fi
  
  #commit changes to local index
  blueTxt "Executing 'git commit -m' in "${dirToGo}""
  git commit -m "${1}"
  
  cd "${curdir}"
}

#@  gitchkmaster() [PATH]
#@  Checks out the master branch
#@  ${1} = Optional. Directory path to git repo (ie /dbc/src).
#@
function gitchkoutmaster(){
  #local variables
  local dirToGo=$(shorthand "${1}")   #check for short hand path
  local curdir=`pwd`
  
  if [ $# -gt 0 ]; then
    cd "${dirToGo}"
    if [ $? -gt 0 ]; then
      cd "${curdir}"
      return
    fi
    echo "${dirToGo}"
  fi

  git checkout master
  cd "${curdir}"
}

#@  gitpush() [PATH]
#@  Pushes changes to remote repo (ie production server)
#@  ${1} = Optional. Directory path to git repo (ie /dbc/src).
#@
function gitpush(){
   #local variables
  local dirToGo=$(shorthand "${1}")   #check for short hand path
  local curdir=`pwd`
  
  if [ $# -gt 0 ]; then
    cd "${dirToGo}"
    if [ $? -gt 0 ]; then
      cd "${curdir}"
      return
    fi
    echo "${dirToGo}"
  fi

  local curBranch=$(git branch --show-current 2> /dev/null)
  if [ "${curBranch}" != "master" ]; then
    redTxt "You are not on branch 'master' in `pwd`"
    redTxt "Pushing from the 'master' branch is only allowed."
    cd "${curdir}"
    return 1
  fi

  blueTxt "Executing 'git push' in ${dirToGo}"
  boldTxt "Enter production password:"
  git push
  cd "${curdir}"
}

#@  gitchkdevelop() [PATH]
#@  Checks out the development branch. 
#@  ${1} = Optional. Directory path to git repo (ie /dbc/src).
#@
function gitchkoutdevelop(){
  #local variables
  local dirToGo=$(shorthand "${1}")   #check for short hand path
  local curdir=`pwd`

  if [ $# -gt 0 ]; then
    cd "${dirToGo}"
    if [ $? -gt 0 ]; then
      cd "${curdir}"
      return
    fi
    echo "${dirToGo}"
  fi

  git checkout develop
  cd "${curdir}"
}

#@  getProductionUser() [USER]
#@  Shows the mapped test-to-production server user name.
#@  ${1} = User name
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

#@  gitfilelock() [FILENAME] [OPTION]
#@  Checks out a file on the production server from your test system
#@  (ie copies it to the production server work directory /dbc/work)
#@  ${1} = File name with no extension (eg COPPWORK or someScript)
#@  ${2} = Option.
#@  -u = unlocks file (ie removes from /dbc/work)
#@
function gitfilelock(){
  #local variables
  local inFile="${1}"
  local option="${2}"                           #option 
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
  ssh -tq ${sshUser}@${PROIP} "source .bash_profile .bashrc; ${lockScript} ${inFile} ${option}"
}

#@  gitcw() [FILENAME] [OPTIONS]
#@  Compiles a file that is checked out on the production server from your test  
#@  system.  
#@  ${1} = File name (eg COPPWORK)
#@  ${2} = Options. Order is irrelevant.
#@  -c = copy local file to production (/dbc/work) before compiling
#@  -p = put compiled file into production (ie similar to PP script)
#@  -u = unlocks file (ie removes from /dbc/work)
#@  
#@  Examples: 
#@  gitcw SOMEFILE -p
#@  gitcw SOMEFILE -pu
#@  gitcw SOMEFILE -ucp
#@
function gitcw(){
  #local variables
  local inFile="${1}"
  local options="${2}"                          #options
  local dataBase=PMS
  local compileScript="sh ~/GITCW.sh"           #production server script
  local PROIP="${XPROIP}"                       #production server IP (.bashrc)
  local MYIP="`whoami`@`hostname -I`"           #me and my IP
  
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
    ${compileScript} ${MYIP} ${inFile} ${options};
  "
}

#@  gitcopyToProd() [FILE] [PATH]
#@  SSH into production and copy over file/s. Useful if you need to test some
#@  stuff on production. Type 'exit' to logout of production.
#@  ${1} = file or path to file
#@  ${2} = Optional. Path on production server. Default is /dbc/work/
#@
function gitcopyToProd(){
  #local variables
  local inFile="${1}"
  local PROIP="${XPROIP}"                                     #production server IP (.bashrc)
  local thisUser=`whoami`
  local MYIP="`whoami`@`hostname -I | awk '{$1=$1;print;}'`"  #me and my ip with no trailing white spaces
  local proDest=/dbc/work/
  
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
  
  #Check user name path
  if [ $# -eq 2 ]; then
    proDest=`echo ${2} | sed s/${thisUser}/${sshUser}/g`  #replace test with production name
  fi

  #ssh into production and copy file over
  ssh -tq ${sshUser}@${PROIP} "
    source .bash_profile .bashrc;
    scp ${MYIP}:${inFile} ${proDest};
    bash;
  "
}

#@  gitstartdev() [PATH]
#@  Executes a "git pull" and creates a new develop branch. If the develop branch exists,
#@  it is deleted before creating a new one.
#@  ${1} = Optional path to a repo. Short hand dbc directories are "src" and "bin"
#@
#@  Examples: 
#@  gitstartdev src
#@  gitstartdev bin
#@  gitstartdev /some/path/
#@
function gitstartdev(){
  #local variables
  local curdir=`pwd`
  local dirToGo=$(shorthand "${1}")   #check for short hand path
  
  #check if need to change directories
  if [ $# -gt 0 ];then
    if [ ! -d "${dirToGo}" ];then
      redTxt "Directory does not exist"
      return 1
    fi
    cd ${dirToGo}
    pwd
  fi
  
  git checkout master     #start on master branch
  if [ $? -gt 0 ];then
    cd "${curdir}"
    return 1
  fi
  
  #pull in production changes
  blueTxt "Executing 'git pull' in "${dirToGo}""
  boldTxt "Enter production server password:"
  git pull
  if [ $? -gt 0 ];then
    cd "${curdir}"
    return 1
  fi
  
  #create new develop
  blueTxt "Executing 'git checkout -B develop' in "${dirToGo}""
  git checkout -B develop
  
  cd "${curdir}"
}

#@  gitmergedevelop() [PATH]
#@  Executes a "git fetch" and "git rebase" from the development branch into 
#@  the master branch (ie merges develop into master). 
#@  ${1} = Optional path to a repo. Short hand dbc directories are "src" and "bin"
#@
#@  Examples: 
#@  gitmergedevelop src
#@  gitmergedevelop bin
#@  gitmergedevelop /some/path/
#@
function gitmergedevelop(){
  #local variables
  local curdir=`pwd`
  local dirToGo=$(shorthand "${1}")   #check for short hand path
  
  #check if need to change directories
  if [ $# -gt 0 ];then
    if [ ! -d "${dirToGo}" ];then
      redTxt "Directory does not exist"
      return 1
    fi
    cd ${dirToGo}
    pwd
  fi
  
  #check if on develop
  local curBranch=""
  curBranch=$(git branch --show-current 2> /dev/null)
  if [ "${curBranch}" != "develop" ]; then
    redTxt "You are not on branch 'develop' in `pwd`"
    cd "${curdir}"
    return 1
  fi
  
  #fetch new changes
  blueTxt "Executing 'git fetch' in "${dirToGo}""
  boldTxt "Enter production password:"
  git fetch
  if [ $? -gt 0 ];then
    redTxt "Merge function failed."
    yelTxt "Remaining commands:"
    yelTxt "---> git fetch"
    yelTxt "---> git rebase origin/master"
    yelTxt "---> git checkout master"
    yelTxt "---> git pull"
    yelTxt "---> git merge develop"
    cd "${curdir}"
    return 1
  fi
  
  #do rebase style merge
  blueTxt "Executing 'git rebase origin/master' in "${dirToGo}""
  git rebase origin/master
  if [ $? -gt 0 ];then
    redTxt "Merge function failed."
    yelTxt "Remaining commands:"
    yelTxt "---> git rebase origin/master"
    yelTxt "---> git checkout master"
    yelTxt "---> git pull"
    yelTxt "---> git merge develop"
    cd "${curdir}"
    return 1
  fi
  
  #check out master
  git checkout master
  if [ $? -gt 0 ];then
    git status
    redTxt "Merge function failed."
    yelTxt "Remaining commands:"
    yelTxt "---> git checkout master"
    yelTxt "---> git pull"
    yelTxt "---> git merge develop"
    cd "${curdir}"
    return 1
  fi
  
  #pull in new changes
  blueTxt "Executing 'git pull' in "${dirToGo}""
  boldTxt "Enter production password:"
  git pull
  if [ $? -gt 0 ];then
    git status
    redTxt "Merge function failed."
    yelTxt "Remaining commands:"
    yelTxt "---> git pull"
    yelTxt "---> git merge develop"
    cd "${curdir}"
    return 1
  fi
  
  #do rebase style merge
  blueTxt "Executing 'git merge develop' in "${dirToGo}""
  git merge develop
  if [ $? -gt 0 ];then
    git status
    redTxt "Merge function failed."
    yelTxt "Remaining commands:"
    yelTxt "---> git merge develop"
    cd "${curdir}"
    return 1
  fi
  
  git status
  grnTxt "Merge SUCCESSFUL!"
  cd "${curdir}"
}

#@  gitsw() [FILENAME]
#@  Copies a program from /dbc/src to /dbc/work OR a script from /dbc/bin to 
#@  your home directory. Adapted from the SW script.
#@  ${1} = Program or script name, no extension. 
#@
#@  Examples: 
#@  gitsw someScript
#@  gitsw SOMEPROGRAM
#@  

function gitsw(){
  local PRG="${1}"
  
  if [ "${PRG}" == "" ];then
    redTxt "No program or script name entered. 'gitsw fileName'"
    return 1
  fi

  if [ -f /dbc/src/${PRG}.TXT ] || [ -f /dbc/bin/${PRG}.sh ] ; then
    fileToCopy=''
    fileToCopy=$(ls /dbc/{bin,src}/${PRG}.{TXT,sh} 2> /dev/null)  #get file name
    tput setaf 2    #green color
    if $(echo ${fileToCopy} | grep -q "\.sh"$); then
        echo "Copying script..."
        cp -v ${fileToCopy} ~/${fileToCopy##*/}
    else
      reformat /dbc/src/${PRG}.TXT /dbc/work/${PRG}.$ME -t -!
    fi
    tput sgr0;    #color off
  else  ### source doesn't exist
    tput setaf 1  #red color
      echo "Program ${PRG}.TXT and ${PRG}.sh do NOT exist !"
    tput sgr0     #color off
  fi
}

#@  gitws() [FILENAME]
#@  Copies a program from /dbc/work to /dbc/src OR a script from your home 
#@  directory to /dbc/bin. Adapted from the WS script.
#@  ${1} = Program or script name, no extension. 
#@
#@  Examples: 
#@  gitws someScript
#@  gitws SOMEPROGRAM
#@
function gitws(){
  local PRG="${1}"
  
  if [ "${PRG}" == "" ];then
    redTxt "No program or script name entered. 'gitsw fileName'"
    return 1
  fi
  
  if [ -f /dbc/work/${PRG}.${ME} ] || [ -f ~/${PRG}.sh ] ; then
    fileToCopy=''
    fileToCopy=$(ls ~/${PRG}.{TXT,sh} 2> /dev/null)  #get file name
    tput setaf 2    #green color
    if $(echo ${fileToCopy} | grep -q "\.sh"$); then
        echo "Copying script back to source..."
        cp -v ${fileToCopy} /dbc/bin
    else
      reformat /dbc/work/${PRG}.$ME /dbc/src/${PRG}.TXT -t -!
    fi
    tput sgr0;    #color off
  else  ### source doesn't exist
    tput setaf 1  #red color
      echo "Program ${PRG}.TXT and ${PRG}.sh do NOT exist !"
    tput sgr0     #color off
  fi
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

#@  yelTxt() [STRING]
#@  Prints the string as yellow font
#@  ${1} = Some string
#@ 
function yelTxt(){
  local YEL=3
  tput setaf ${YEL}; echo "${1}"; tput sgr0;
}

#local function that checks for path short hand options
#add additional ones here
function shorthand(){
  case "${1}" in
    "src")
      echo "/dbc/src/"
      ;;
    "bin")
      echo "/dbc/bin/"
      ;;
    *)
      echo "${1}"
      ;;
  esac
}

#*******************************************************************************
# gitFunctions.sh END **********************************************************
#*******************************************************************************

#old ideas

####@  gitupdGit() [GIT COMMAND] [PATH] 
####@  Updates the git server's repo by copying over source files from production.
####@  Will also execute passed in git commands on local repo.
####@  ${1} = Execute Git commands: -pull -fetch -push'
####@  ${2} = Optional. Path to local repo (ie /dbc/src). 
####@
####@  Examples: 
####@  gitupdGit                    #updates git server (GS)
####@  gitupdGit -pull              #updates GS & does 'git pull' on current repo/dir
####@  gitupdGit -pull /dbc/src     #updates GS, & does 'git pull' on past in repo/dir
####@
###function gitupdGit(){
###  #local variables
###  local gitCmd="${1}"
###  local repoPath="${2}"
###  local curdir=`pwd`
###  local curUser="$(whoami)"
###  local GITSRV="${XGITSRV}"                     #git server user and IP (.bashrc)
###  local PROIP="${XPROIP}"                       #production server IP (.bashrc)
###  local PROSRC="/dbc/src/"                      #production dbc source files
###  local GITSRCTMP="/source/dbc/tmp/src/"        #git server dbc source files (staging)
###  local PROBIN="/dbc/bin/"                      #production script source files
###  local GITBINTMP="/source/dbc/tmp/bin/"        #git server script source files (staging)
###  local GENERRS=1                               #"General Errors" error code
###  
###  #local functions
###  #** Copies production source files to git server & commits changes
###  #   ${1} = Production user name
###  #*
###  function copyProdToGit(){
###    blueTxt "Pulling in changes from master to temp repo on git server..."
###    ssh -Tq ${GITSRV}<<UPDTEMP
###echo "ssh ${GITSRV} (Git Server)"
###cd ${GITSRCTMP}
###echo 'REPO: ${GITSRCTMP} COMMANDS: git pull'
###git pull
###cd ${GITBINTMP}
###echo 'REPO: ${GITBINTMP} COMMANDS: git pull'
###git pull
###UPDTEMP
###  
###    blueTxt "Copying source files from production to git server..."
###    boldTxt "Enter your production server password:"
###    ssh -Tq ${1}@${PROIP}<<COPYSRC
###echo "ssh ${1}@${PROIP} (Production Server)"
###echo "${PROSRC} ---> ${GITSRV}:${GITSRCTMP}"
###rsync -t ${PROSRC}*.{TXT,VRB,PRG,IO,DEF,INC,PGM,VAR} ${GITSRV}:${GITSRCTMP}
###echo "${PROBIN} ---> ${GITSRV}:${GITBINTMP}"
###rsync -t ${PROBIN}*.sh ${GITSRV}:${GITBINTMP}
###COPYSRC
###
###    blueTxt "Committing changes to temp repo and pushing to master repo on git server..."
###    ssh -Tq ${GITSRV}<<UPDGIT
###echo "ssh ${GITSRV} (Git Server)"
###cd ${GITSRCTMP}
###echo 'REPO: ${GITSRCTMP} COMMANDS: git add && git commit && git push'
###git add .
###git commit -m "pro-to-git $(date +"%m-%d-%y %I:%M:%S %p")"
###git push
###cd ${GITBINTMP}
###echo "REPO: ${GITBINTMP} COMMANDS: git add && git commit && git push"
###git add .
###git commit -m "pro-to-git $(date +"%m-%d-%y %I:%M:%S %p")"
###git push
###UPDGIT
###  }
###  
###  #get production user name
###  local sshUser=""
###  sshUser=$(getProductionUser "$curUser")
###  if [ "${sshUser}" == "" ]; then
###    redTxt "User ${curUser} is not setup to use this function. (gitFunctions)"
###    cd "${curdir}"
###    return
###  fi
###
###  #TODO rethink this... probably ssh into prod first, then do all this stuff so we are only entering the password once
###  #ssh into production and copy files to git server 
###  copyProdToGit "${sshUser}"      #update git server
###  local err=$?                    #save error codes if any
###  unset -f copyProdToGit          #destroy local function after use
###  if [ ${err} -gt ${GENERRS} ];then 
###    echo "Error ${err} - SSH connection or remote command failed."  
###    cd "${curdir}"
###    return
###  fi
###  grnTxt "Git server updated OK!"
###  
###  #check for passed in repo directory
###  if [[ -d "${repoPath}" ]];then
###    cd "${repoPath}"
###    blueTxt "${repoPath} - On branch $(git branch | grep \* | awk '{print $2}')"
###  fi
###
###  #execute any passed in git commands
###  if [ $# -gt 0 ]; then 
###    case "${gitCmd}" in
###      '-pull')
###          boldTxt "Executing: git pull"
###          git pull
###          ;;
###      '-fetch')
###          boldTxt "Executing: git fetch"
###          git fetch
###          ;;
###      '-push')
###          boldTxt "Executing: git push"
###          git push
###          blueTxt "Pulling in changes from master to temp repo on git server..."
###          ssh -Tq ${GITSRV}<<UPDTEMP
###echo "ssh ${GITSRV} (Git Server)"
###cd ${GITSRCTMP}
###echo 'REPO: ${GITSRCTMP} COMMANDS: git pull'
###git pull
###cd ${GITBINTMP}
###echo 'REPO: ${GITBINTMP} COMMANDS: git pull'
###git pull
###UPDTEMP
###          ;;
###    esac
###  fi
###  
###  cd "${curdir}"                                            #back to previous directory
###  grnTxt 'Bye!'
###} 
