#!/bin/bash
################################################################################
# SCRIPT NAME:    GITPP.sh
# BY:             David Garcia
# DATE:           
# DESCRIPTION:    Puts a DBC compiled program into production. Used in the git 
#                 process on the production server. Adapted form the PP script.
# 
################################################################################
# VARIABLES
TIMESTAMP=`date +"%m%d%g%H%M"`
PRG=$1
if [ "$2" ]
then
  DIR="/$2"
else
  DIR=""
fi

if [ $# -eq 0 -o $# -gt 2 ] ; then                ### cmd line invalid
  echo -e "\nPut compiled Program into Production"
  echo -e "\nUsage: GITPP.sh <PROGRAM> <dir>\n"
  exit 1                                          ### exit with error
else                                              ### params look valid
  if [ -e $HOME/$PRG.DBC ] ; then                 ### have a new DBC
    if [ -f /dbc/prg$DIR/$PRG.DBC ] ; then        ### existing DBC file
      oldowner=`stat -c %U /dbc/prg$DIR/$PRG.DBC` ### get old owner
      echo "Copying /dbc/prg$DIR/$PRG.DBC to /dbc/prg$DIR/$PRG.$TIMESTAMP"
      cp -pf /dbc/prg$DIR/$PRG.DBC /dbc/prg$DIR/$PRG.$TIMESTAMP

      if [ "$?" -ne "0" ] ; then                  ### copy not successful
        tput setaf 1  #red color
          echo "Backup Copy Not Successful!"
        tput sgr0     #color off
        exit 1                                    ### quit with error
      fi

      chown $oldowner /dbc/prg$DIR/$PRG.$TIMESTAMP ### change owner back
      echo "Moving $HOME/$PRG.DBC to /dbc/prg$DIR/$PRG.DBC"
      mv $HOME/$PRG.DBC /dbc/prg$DIR/$PRG.DBC
      if [ "$?" -ne "0" ] ; then                  ### move not successful
        tput setaf 1  #red color
          echo "New Version Move Not Successful!"   
        tput sgr0     #color off
        exit 1                                    ### quit with error
      fi
      if [ -f /dbc/work/$PRG.$ME ] ; then
        echo "Creating /dbc/lst/$PRG.LST"
        dbcmp /dbc/work/$PRG.$ME ~/JUNK.DBC -d > /dbc/lst/$PRG.LST
      elif [ -f /dbc/src/$PRG.TXT ] ; then
        echo "Creating /dbc/lst/$PRG.LST"
        dbcmp /dbc/src/$PRG.TXT ~/JUNK.DBC -d > /dbc/lst/$PRG.LST
      fi
      rm -f ~/JUNK.DBC
      rm -f $HOME/$PRG.dbc $HOME/$PRG.dbg
      exit 0                                      ### success!!
    else                                          ### first time
      echo "Moving $HOME/$PRG.DBC to /dbc/prg$DIR/$PRG.DBC"
      mv -f $HOME/$PRG.DBC /dbc/prg$DIR/$PRG.DBC
      rm -f $HOME/$PRG.dbc $HOME/$PRG.dbg
      if [ -f /dbc/work/$PRG.$ME ] ; then
        echo "Creating /dbc/lst/$PRG.LST"
        dbcmp /dbc/work/$PRG.$ME ~/JUNK.DBC -d > /dbc/lst/$PRG.LST
      elif [ -f /dbc/src/$PRG.TXT ] ; then
        echo "Creating /dbc/lst/$PRG.LST"
        dbcmp /dbc/src/$PRG.TXT ~/JUNK.DBC -d > /dbc/lst/$PRG.LST
      fi
      rm -f ~/JUNK.DBC
      exit 0                                      ### success!!
    fi
  else                                            ### no DBC in HOME
    tput setaf 1    #red color
      echo -e "  error: $HOME/$PRG.DBC not found!\n"
    tput setaf sgr0 #color off
    exit 1                                        ### exit with error
  fi
fi
