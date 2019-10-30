#!/bin/bash
###############################################################################
# SCRIPT NAME:    pullTestData.sh
# BY:             David Garcia
# DATE:           11/26/18
# DESCRIPTION:    Pulls in test data from the live system archive that is used
#                 to test Epic payment programs.
# DATE MODIFIED:   
###############################################################################
#..............................................................................
UCIPATH=/dbc/arc/cdb1/uci/uciepic/
UCIMASK=PMS_Updates*
UCLAPATH=/dbc/arc/cdb1/uca/
UCLAMASK=PMSUPDATEBD*
LOMAPATH=/dbc/arc/cdb1/lomalinda/
LOMAMASK=PMS-UPDATE-PRD*
NOVTPATH=/dbc/arc/cdb1/novt/
NOVTMASK=EPIC_UPDATE*


#..............................................................................
YEAR=""
MONTH=""
#get input
while [ "$YEAR" = "" ]; do
  read -p 'Enter year to pull (YYYY): ' YEAR
done

while [ "$MONTH" = "" ]; do
  read -p 'Enter month to pull (MM): ' MONTH
done

#get files from live system
rsync -vh dgarcia@${XPROIP}:${UCIPATH}${UCIMASK}$YEAR$MONTH* :${UCLAPATH}${UCLAMASK}$YEAR$MONTH* :${LOMAPATH}${LOMAMASK}$YEAR$MONTH* :${NOVTPATH}${NOVTMASK}$YEAR$MONTH* ./tempdir/

#copy to test system dirs and remove
mv -nv ./tempdir/$UCIMASK $UCIPATH
rm -fv ./tempdir/$UCIMASK 

mv -nv ./tempdir/$UCLAMASK $UCLAPATH
rm -fv ./tempdir/$UCLAMASK

mv -nv ./tempdir/$LOMAMASK $LOMAPATH
rm -fv ./tempdir/$LOMAMASK

mv -nv ./tempdir/$NOVTMASK $NOVTPATH
rm -fv ./tempdir/$NOVTMASK

