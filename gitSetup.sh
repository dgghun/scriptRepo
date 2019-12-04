#!/bin/bash
################################################################################
# SCRIPT NAME:    gitSetup.sh
# BY:             David Garcia
# DATE:           12/4/19
# DESCRIPTION:    Sets up a git repo in /dbc/src and /dbc/bin that is pulling
#                 from the production server. 
#                 
# NOTE:           !!! REPO MUST BE SETUP ALREADY ON PRODUCTION SERVER !!!                 
# 
################################################################################
myEmail=''
myUser=''

clear
while true; do
  read -p "Enter first part of PMS email address (firstPart@pmscollects.com): " myEmail
  case "${myEmail}" in 
    "")
      continue;;
    *)
      myEmail="${myEmail}@pmscollects.com"
      tput setaf 6; echo "${myEmail}"; tput sgr0;
      read -p "Email look ok? (y/n)" yn
      yn="${yn^^}"
      if [ "${yn}" == "Y" ]; then
        break
      fi
      ;;
  esac
done

while true; do
  read -p "Enter production server user name: " myUser
  case "${myUser}" in 
    "")
      continue;;
    *)      
      tput setaf 6; echo "${myUser}"; tput sgr0;
      read -p "User name look ok? (y/n)" yn
      yn="${yn^^}"
      if [ "${yn}" == "Y" ]; then
        break
      fi
      ;;
  esac
done

while true; do
  read -p "Ready to initialize /dbc/src repo? " yn
  case ${yn} in
    [Yy])
      echo "Initializing /dbc/src repo"
      break;;
    [nN])
      echo "Exiting. No changes made."
      exit 1
      ;;
  esac
done

#Initialize /dbc/src
cd /dbc/src
echo "Creating `pwd` backup in ~/srcBackup..."
mkdir ~/srcBackup -f &> /dev/null
cp -frp ./* ~/srcBackup &> /dev/null

echo "Clearing out `pwd`..."
rm * -f       &> /dev/null
rm .* -f       &> /dev/null
rm .git/ -rf  &> /dev/null

echo "Initializing git in `pwd`..."
git init    
git config core.fileMode false            #dont monitor file permissions
git config core.autocrlf false            #dont change to crlf
git config core.eol input                 #EOL
git config core.editor nano               #set default editor
git config user.name "${myUser}"          #set user name
git config user.email "${myEmail}"        #set user email
tput bold; echo "Enter production password:"; tput sgr0;
git remote add origin ${myUser}@$XPROIP:dbc/src/  #add remote repo
git pull origin master
git branch --set-upstream-to=origin/master
echo '* text=auto' > .gitattributes       #make attributes file
echo -e '
#ignore all files and folders
*
/*

#Not these
!*.TXT
!*.VRB
!*.PRG
!*.IO
!*.DEF
!*.INC
!*.PGM
!*.VAR
' > .gitignore #create ignore file
echo "Copying over untracked files..."
tput bold; echo "Enter production password:"; tput sgr0;
scp -q ${myUser}@$XPROIP:/dbc/src/* ./ 
echo -e "Git setup in `pwd` DONE!\n"

#Initialize /dbc/bin
cd /dbc/bin
echo "Creating `pwd` backup in ~/binBackup..."
mkdir ~/binBackup -f &> /dev/null
cp -frp ./* ~/binBackup &> /dev/null

echo "Clearing out `pwd`..."
rm * -f       &> /dev/null
rm .* -f       &> /dev/null
rm .git/ -rf  &> /dev/null

echo "Initializing git in `pwd`..."
git init    
git config core.fileMode false            #dont monitor file permissions
git config core.autocrlf false            #dont change to crlf
git config core.eol input                 #EOL
git config core.editor nano               #set default editor
git config user.name "${myUser}"          #set user name
git config user.email "${myEmail}"        #set user email
tput bold; echo "Enter production password:"; tput sgr0;
git remote add origin ${myUser}@$XPROIP:dbc/bin/  #add remote repo
git pull origin master
git branch --set-upstream-to=origin/master
echo '* text=auto' > .gitattributes       #make attributes file
echo -e echo -e '
#ignore all files
*
/*

#Not these
!*.sh
' > .gitignore #make ignore file
echo "Copying over untracked files..."
tput bold; echo "Enter production password:"; tput sgr0;
scp -q ${myUser}@$XPROIP:/dbc/bin/* ./ 
echo -e "Git setup in `pwd` DONE!\n"
cd
