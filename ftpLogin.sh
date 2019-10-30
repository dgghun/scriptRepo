#!/bin/bash
################################################################################
# SCRIPT NAME:    
# BY:             David Garcia
# DATE:           
# DESCRIPTION:    
#                 
# 
################################################################################
# Functions
source ~/colorFunctions.sh


FTPOLD="${XFTPOLD}"
FTPNEW="${XFTPNEW}"

while true; do
  read -p "SSH into (1)`GRNL Old-FTP` or (2)`PURPL New-FTP`?: " input
  case $input in
      [1]* )  echo "Logging into ${FTPOLD}...";
              ssh ${FTPOLD}
              break;;
              
      [2]* )  echo "Logging into ${FTPNEW}..."; 
              ssh ${FTPNEW}
              break;;
      * )     REDL "($input) is not an option. Exiting."
              break;;
  esac
done
echo "Bye! (ftpLogin.sh)"
