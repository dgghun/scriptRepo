#!/bin/bash
################################################################################
# SCRIPT NAME:    checkIn.sh
# BY:             David Garcia
# DATE:           7/31/19
# DESCRIPTION:    Copies program over to test system and ssh into live system.
#
#
################################################################################
source /dbc/bin/functions.sh
source ~/.bashrc

myhome="~/"
mywork="/dbc/work/"
myip="${XPROIP}"
testip="${XTESTIP}"
haveFile=0
tmpFile='tmp.tmp'

CYANL "Copying ${1} to production. Enter your password:"
scp ${mywork}${1}.DGG dgarcia@${myip}:${mywork}
CYANL "Logging into production. Enter your password:"
ssh -t dgarcia@${myip} 













