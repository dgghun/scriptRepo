#!/bin/bash
###############################################################################
#COPY LIVE SYSTEM PROGRAMS TO TEST SYSTEM
###############################################################################
source ~/colorFunctions.sh

SRCDIR="/dbc/src/*.TXT"
PRGDIR="/dbc/prg/*.DBC"
PRGDDIR="/dbc/prgd/*.DBG"
TEMPDIR='/home/dgdev/tempdir/'
ALLDIR='/dbc/{src,prg,prgd}/*.{TXT,DBC,DBG}'
LIVESYS="dgarcia@${XPROIP}"
txtcnt=0
prgcnt=0
prgdcnt=0

echo "`PURPL "--> Copying ${SRCDIR}, ${PRGDIR}, ${PRGDDIR}"`"
scp ${LIVESYS}:${ALLDIR} ${TEMPDIR} &> /dev/null
txtcnt=`ls -l ${TEMPDIR}*.TXT | wc -l`
prgcnt=`ls -l ${TEMPDIR}*.DBC | wc -l`
prgdcnt=`ls -l ${TEMPDIR}*.DBG | wc -l`

echo "Copied files"
echo "${txtcnt} src (TXT) files"
echo "${prgcnt} prg (DBC) files"
echo "${prgdcnt} prgd (DBG) files"
echo " "

if [ ${txtcnt} -gt 0 ]; then
  while true; do
    echo "1) Move files into respective folders"
    echo "2) Delete files from tempdir"
    echo "3) Do nothing"
    read -p " " yn
    case $yn in
        [1]* ) echo "Moving...";
              echo "done!"
              break;;
        [2]* ) echo "Deleting...";
              rm -f ${TEMPDIR}* &> /dev/null
              echo "done!"
              break;;
        [3]* ) echo "Ok, no changes made."; break;;
        * ) echo `REDL "--> Please answer yes or no."`
            echo -e "\n";;
    esac
  done
else
  echo "No files copied."
fi
#
