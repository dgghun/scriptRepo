#!/bin/bash
################################################################################
# SCRIPT NAME:    daysSince.sh
# BY:             David Garcia
# DATE:           09/10/19
# DESCRIPTION:    Calculates the number of days since a date past in 
#
################################################################################
source ~/colorFunctions.sh

### ${1} = "MM/DD/YY"   past in date

someDate=$(date -d "${1}" +'%s')
TODAY=$(date +'%s')   
echo $(((TODAY-someDate)/60/60/24))" days since ${1}"