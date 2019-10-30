#!/bin/bash
###############################################################################
#Contains functions that colorize text. To use, include this script in you file.
# Example: 
#           source colorFunctions.sh
#           echo "This is the color `RED red`"  
#
# LINE COLORS
#Black        0;30     # for bold use a 1 (1;90)
#Red          0;31     Light Red     0;91
#Green        0;32     Light Green   0;92
#Yellow       0;33     Light Yellow  0;93
#Blue         0;34     Light Blue    0;94
#Purple       0;35     Light Purple  0;95
#Cyan         0;36     Light Cyan    0;96
#Light Gray   0;37     White         0;97
#
###############################################################################
#variables
###############################################################################
red='\033[0;31m'
redl='\033[0;91m'
green='\033[0;32m'
greenl='\033[0;92m'
blue='\033[0;34m'
bluel='\033[0;94m'
purple='\033[0;35m'
purplel='\033[0;95m'
cyan='\033[0;36m'
cyanl='\033[0;96m'
yellow='\033[0;33m'
yellowl='\033[0;93m'
NC='\033[0m'                                # No Color
#...............................................................................
YEL () {
  echo -e ${yellow}"$1"${NC} 
}

YELL () {
  echo -e ${yellowl}"$1"${NC} 
}

RED () {
  echo -e ${red}"$1"${NC} 
}

REDL () {
  echo -e ${redl}"$1"${NC} 
}

GRN () {
  echo -e ${green}"$1"${NC} 
}

GRNL () {
  echo -e ${greenl}"$1"${NC} 
}

BLUE () {
  echo -e ${blue}"$1"${NC} 
}

BLUEL () {
  echo -e ${bluel}"$1"${NC} 
}

PURP () {
  echo -e ${purple}"$1"${NC} 
}

PURPL () {
  echo -e ${purplel}"$1"${NC} 
}

CYAN () {
  echo -e ${cyan}"$1"${NC} 
}

CYANL () {
  echo -e ${cyanl}"$1"${NC} 
}

#Prints 12 colorized stars on the screen
colorStars () {
  for i in {1..3};do
    printf ${red}"*"${NC}
    printf ${green}"*"${NC}
    printf ${yellow}"*"${NC}
    printf ${blue}"*"${NC}
    printf ${purple}"*"${NC}
    printf ${cyan}"*"${NC}
  done
}

#Prints colorized stars screen. The quantity is passed in. 
printStars () {
  stars=(${red} ${green} ${yellow} ${blue} ${purple} ${cyan})   #the colors
  starCnt=${#stars[*]}                          #get color count
  ((num = $1 - 1))                              #minus one for color array size
  for i in `seq 0 $num`; do                     #from 0 to number wanted
   printf ${stars[$(($i % $starCnt))]}"*"${NC}  #module keeps number in array range
  done
  echo " "
}

#Prints colorized characters to screen. The quantity and character is passed in. 
printColor () {
  stars=(${red} ${green} ${yellow} ${blue} ${purple} ${cyan})   #the colors
  starCnt=${#stars[*]}                          #get color count
  ((num = $1 - 1))                              #minus one for color array size
  for i in `seq 0 $num`; do                     #from 0 to number wanted
   printf ${stars[$(($i % $starCnt))]}"$2"${NC}  #module keeps number in array range
  done
  echo " "
}

#shows the available colors
showColors () {
  colorStars
  printf " Color Functions "
  colorStars; echo " "
  
  echo -e ${red}"-->RED()"${NC} 
  echo -e ${redl}"-->REDL()"${NC} 
  echo -e ${green}"-->GRN()"${NC} 
  echo -e ${greenl}"-->GRNL()"${NC} 
  echo -e ${yellow}"-->YEL()"${NC} 
  echo -e ${yellowl}"-->YELL()"${NC} 
  echo -e ${blue}"-->BLUE()"${NC} 
  echo -e ${bluel}"-->BLUEL()"${NC} 
  echo -e ${purple}"-->PURP()"${NC} 
  echo -e ${purplel}"-->PURPL()"${NC} 
  echo -e ${cyan}"-->CYAN()"${NC} 
  echo -e ${cyanl}"-->CYANL()"${NC} 
  colorStars
  colorStars
  colorStars
  echo " "
}
