#!/bin/bash
################################################################################
# SCRIPT NAME:    checkOut.sh
# BY:             David Garcia
# DATE:           7/31/19
# DESCRIPTION:    Checks out a file in the live system and copies it over to test system.
#
#
################################################################################
source /dbc/bin/functions.sh
source /dbc/bin/colorFunctions.sh
source ~/.bashrc

fileToChkOut="${1}"
myhome="~/"
mywork="/dbc/work/"
myip="${XPROIP}"
testip="${XTESTIP}"
haveFile=0
tmpFile='tmp.tmp'

CYANL "Checking if ${fileToChkOut} is checked out. Enter your production system password:"
ssh -t dgarcia@${myip} "source .bash_profile .bashrc; SW ${fileToChkOut};" > ${tmpFile}

cat ${tmpFile}
if grep -qi 'Copying' ./${tmpFile}; then
  CYANL "Copying ${fileToChkOut} to test system. Enter your production system password:"
  scp dgarcia@${myip}:${mywork}${1}.DGG ${mywork} 2> /dev/null
fi
rm -f ${tmpFile}

PURPL 'DONE!'












