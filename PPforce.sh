#! /bin/bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# PPforce.sh - Puts *.DBC Program into Production. MODIFIED     #
#              version does not display prompt or require input.#
#  David Bullock 01/22/2007                                     #
# 01/20/11 db add oldowner and chown lines                      #
# 07/28/11 db Store a listing in /dbc/lst                       #
# 08/16/18 gws changes were made by someone(?) have update to work#
# 08/16/18-2 gws more changes to make things work               #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
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
  echo -e "\nUsage: PP <PROGRAM> <dir>\n"
  exit 1                                          ### exit with error
else                                              ### params look valid
  if [ -e $HOME/$PRG.DBC ] ; then                 ### have a new DBC
    if [ -f /dbc/prg$DIR/$PRG.DBC ] ; then        ### existing DBC file
      oldowner=`stat -c %U /dbc/prg$DIR/$PRG.DBC` ### get old owner
      echo " "
      #ls -ot /dbc/prg$DIR/$PRG.* | more
      echo -e "\nCopying /dbc/prg$DIR/$PRG.DBC to /dbc/prg$DIR/$PRG.$TIMESTAMP"
      cp -fp /dbc/prg$DIR/$PRG.DBC /dbc/prg$DIR/$PRG.$TIMESTAMP
##    8/16/18-2 moved       
      if [ "$?" -ne "0" ] ; then                  ### copy not successful
        echo "Backup Copy Not Successful!"
        exit 1                                    ### quit with error
      fi
#08/16/18-2      if [ "$ME" = "DAV" -o "$ME" = "GLE" -o "$ME" = "AJS" -o "$ME" = "DGG" -o "$ME" = "MAG"  ] ; then ###  just us programmers
#08/16/18 gws        sudo chown $oldowner /dbc/prg$DIR/$PRG.$TIMESTAMP ### change owner back
       chown $oldowner /dbc/prg$DIR/$PRG.$TIMESTAMP ### change owner back
#08/16/18-2      fi
## 08/16/18-2 still having issue changing things      
#      if [ "$?" -ne "0" ] ; then                  ### copy not successful
#        echo "Backup Copy Not Successful!"
#        exit 1                                    ### quit with error
#      fi
      echo -e "Moving $HOME/$PRG.DBC to /dbc/prg$DIR/$PRG.DBC"
      mv -f $HOME/$PRG.DBC /dbc/prg$DIR/$PRG.DBC
      if [ "$?" -ne "0" ] ; then                  ### move not successful
        echo "New Version Move Not Successful!"
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
      echo " "
      #ls -ot /dbc/prg$DIR/$PRG.* | more
      rm -f $HOME/$PRG.dbc $HOME/$PRG.dbg
      exit 0                                      ### success!!
    else                                          ### first time
      echo -e "\nMoving $HOME/$PRG.DBC to /dbc/prg$DIR/$PRG.DBC"
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
    echo -e "  error: $HOME/$PRG.DBC not found!\n"
    exit 1                                        ### exit with error
  fi
fi
