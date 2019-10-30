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

myhome="~/"
mywork="/dbc/work/"
myip="${XPROIP}"
testip="${XTESTIP}"
haveFile=0
tmpFile='tmp.tmp'

scp ${mywork}${1}.DGG dgarcia@${myip}:${mywork}
ssh -t dgarcia@${myip} 













