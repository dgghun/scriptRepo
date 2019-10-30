#!/bin/bash

# LINE COLORS
#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37
#
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'                                # No Color

#Variables
SYS_SRC=""  #live or test system
DEST="" 
SRC=""
LIVESYS="dgarcia@${XPROIP}:"
TESTSYS="dgdev@${XTESTIP}:"
FTPSYS="root@ftpserver:"

#get source input
while [ "$SYS_SRC" != "1" ] && [ "$SYS_SRC" != "2" ] && [ "$SYS_SRC" != "3" ] && [ "$SYS_SRC" != "4" ]; do
  echo -e "\n${GREEN}SOURCE${NC}"
  read -p 'Source file system? 1=Live, 2=Test, 3=Local, 4=FTP: ' SYS_SRC
done
read -p 'Enter source file path:' SRC

#get destination input
while [ "$SYS_DEST" != "1" ] && [ "$SYS_DEST" != "2" ] && [ "$SYS_DEST" != "3" ] && [ "$SYS_DEST" != "4" ]; do
  echo -e "\n${RED}DESTINATION${NC}"
  read -p 'Destination system? 1=Live, 2=Test, 3=Local, 4=FTP: ' SYS_DEST
done
read -p 'Enter destination file path:' DEST

#set source path
if [ "$SYS_SRC" = "1" ]; then
  SRC=$LIVESYS$SRC
elif [ "$SYS_SRC" = "2" ]; then
  SRC=$TESTSYS$SRC
elif [ "$SYS_SRC" = "4" ]; then
  SRC=$FTPSYS$SRC  
fi

#set destination path
if [ "$SYS_DEST" = "1" ]; then
  DEST=$LIVESYS$DEST
elif [ "$SYS_DEST" = "2" ]; then
  DEST=$TESTSYS$DEST
elif [ "$SYS_DEST" = "4" ]; then
  DEST=$FTPSYS$DEST  
fi

#display selection
echo -e "\n${GREEN}Source${NC}: $SRC"
echo -e "${RED}Destin${NC}: $DEST"
read -p 'Press enter to copy' X
scp $SRC $DEST  #do copy
echo 'Done! (getFile.sh)'
