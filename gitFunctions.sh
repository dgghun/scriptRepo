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
        boldTxt " ${line}"
      elif [[ "${line}" == *"()"* ]];then
        boldTxt " ${line}"
      else
        blueTxt " ${line}"
      fi
    done                         |
    awk '{print}' | less -R
}

#@  gitshow()
#@  Prints the difference between the current and last commit.
#@  ${1} = Git commit hash (ie 44d3b7d)
#@  ${2} = Optional. Path to repo (ie /dbc/src)
#@
function gitshow(){
  if [ $# -gt 1 ]; then
    local curdir=`pwd`
    cd "$2"
    git show --color --pretty=format:%b "${1}"
    cd "${curdir}"
  else
    git show --color --pretty=format:%b "${1}"
  fi
}

#@  gitstat()
#@  Prints the current repos status
#@  ${1} = Optional. Path to repo (ie /dbc/src)
#@
function gitstat(){
   if [ $# -gt 0 ]; then
    local curdir=`pwd`
    cd "$1"
    git status
    cd "${curdir}"
   else
    git status
   fi
}

#@  gitlog()
#@  Prints the current repos git commit log
#@  ${1} = Optional. Path to repo (ie /dbc/src)
#@
function gitlog(){
  if [ $# -gt 0 ]; then
    local curdir=`pwd`
    cd "$1"
    git log --graph --oneline --decorate --color
    cd "${curdir}"
  else
    git log --graph --oneline --decorate --color
  fi 
}

#@  gitlogtime()
#@  Prints the current repos git commit log
#@  ${1} = Optional. Path to repo (ie /dbc/src)
#@
function gitlogtime(){
  if [ $# -gt 0 ]; then
    local curdir=`pwd`
    cd "$1"
    git log --pretty=format:"%C(yellow)%h %Creset%an %C(green)%ar %CresetMSG:%C(cyan)'%s'" --graph
    cd "${curdir}"
  else
    git log --pretty=format:"%C(yellow)%h %Creset%an %C(green)%ar %CresetMSG:%C(cyan)'%s'" --graph
  fi
}

#@  gitcommitall()
#@  Adds and commits all changes/files to repo
#@  ${1} = 50 char commit message string
#@  ${2} = Optional. Path to repo (ie /dbc/src)
#@  
function gitcommitall(){
  if [ $# -gt 1 ]; then
    local curdir=`pwd`
    cd "$2"
    git add . ; git commit -m "${1}"
    cd "${curdir}"
  else
    git add . ; git commit -m "${1}"
  fi
}

#@  gitchkmaster()
#@  Checks out the master branch
#@  ${1} = Optional. Directory path to git repo (ie /dbc/src).
#@
function gitchkmaster(){
  if [ $# -gt 0 ]; then
    local curdir=`pwd`
    cd "$1"
    git checkout master
    cd "${curdir}"
  else
    git checkout master
  fi
}

#@  gitchkdevelop()
#@  Checks out the development branch. 
#@  ${1} = Optional. Directory path to git repo (ie /dbc/src).
#@
function gitchkdevelop(){
  if [ $# -gt 0 ]; then
    local curdir=`pwd`
    cd "$1"
    git checkout develop
    cd "${curdir}"
  else
    git checkout develop
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

#@  boldTxt()
#@  Prints the string as bold font
#@  ${1} = Some string
#@
function boldTxt(){
  tput bold; echo "${1}"; tput sgr0;
}

#@  grnTxt()
#@  Prints the string as green font
#@  ${1} = Some string
#@ 
function grnTxt(){
  local GRN=2
  tput setaf ${GRN}; echo "${1}"; tput sgr0;
}

#@  blueTxt()
#@  Prints the string as blue font
#@  ${1} = Some string
#@ 
function blueTxt(){
  local BLUE=6
  tput setaf ${BLUE}; echo "${1}"; tput sgr0;
}

#@  redTxt()
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