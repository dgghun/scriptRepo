#!/bin/bash
#!/bin/bash
################################################################################
# SCRIPT NAME:    updateTestSystem.sh
# BY:             David Garcia
# DATE:           11/26/19
# DESCRIPTION:    Updates test system files from the NAS back up.
#                 
# 
################################################################################
#VARIABLES......................................................................
cdb=$1
NASPATH="/media/dbcextra"       #NAS mount point
START=''
FIN=''
TSECS=''

#FUNCTIONS......................................................................

# startTime()
function startTime(){
  START=$(date "+%s")       #get start time in seconds
}

# stopTime()
function stopTime(){
  FIN=$(date "+%s")                       #get time in seconds
  TSECS=$(( (FIN - START) ))              #get TOTAL execution time
  
  tput setaf 5  #green
  if [ $(( $TSECS/60 )) -gt 59 ]; then    #if greater than 59 mins....
    HR=$(( $TSECS / 60 / 60 ))            #dived by 60 twice for hour
    MIN=$(( $TSECS / 60 % 60 ))           #dived once & mod once for mins
    SEC=$(( $TSECS % 60 ))                #mod once for seconds 
    echo "-TOTAL RUN TIME: hrs:$HR mins:$MIN secs:$SEC" 
  else                                    #is less than 59 mins
    MIN=$(( $TSECS / 60 ))                #dived once for mins
    SEC=$(( $TSECS % 60 ))                #mod once for seconds
    echo "-TOTAL RUN TIME: mins:$MIN secs:$SEC" 
  fi
  tput sgr0   #color off
}

# re-index()
# index files again that usually have issues
function re_index(){
  tput setaf 6
  echo -e "\nRe-indexing files with known issues:"
  tput sgr0
  
  echo "ANSLOG"
  index ANSLOG -e
}

# SCRIPT START..................................................................
if [ "$cdb" = "" ];  then 
  tput setaf 1  #red
  echo "No data base option (1,3,8) specified!"
  tput sgr0     #color off
  exit 1
elif [ "$cdb" != 8 ] && [ "$cdb" != 3 ] && [ "$cdb" != 1 ]; then
  tput setaf 1  #red
  echo "Incorrect data base entered! Must be 1, 3 or 8."
  tput sgr0     #color off
  exit 1
fi

startTime #start clock
mkdir ~/tempdir   &> /dev/null  #make the directory in case its not there
for dir in txt isi;do
  rm -f ~/tempdir/* &> /dev/null  #clear it out 
  
  tput setaf 6  #cyan
  echo "Copying remote CDB${cdb} ${dir^^} files to local temp directory..."
  tput sgr0     #color off
  rsync -ah --progress ${NASPATH}/livefiles/cdb${cdb}/${dir}/* ./tempdir/ 
  echo "Done!"
  chmod 666 ~/tempdir/* &> /dev/null

  tput setaf 6  #cyan
  echo "Moving ${dir^^} files to CDB${cdb} back folder..."
  tput sgr0     #color off
  cntTotal=`ls ~/tempdir/* | wc -l`
  cnt=0
  digits="${#cntTotal}"
  tput civis #invisible cursor
  for i in ~/tempdir/*; do
    ((cnt++))
    printf "%0${digits}d " ${cnt} ;printf "of ${cntTotal} \r"
    mv -f "${i}" /dbc/${dir}/cdb${cdb}_backup/ 1> /dev/null
  done
  printf "${cnt} of ${cntTotal} DONE!\n"
  tput cnorm #reset cursor

  tput setaf 6  #cyan
  echo "Copying ${dir^^} files to CDB${cdb} folder..."
  tput sgr0     #color off
  cntTotal=`ls /dbc/${dir}/cdb${cdb}_backup/* | wc -l`
  cnt=0
  digits="${#cntTotal}"
  tput civis #invisible cursor
  for i in /dbc/${dir}/cdb${cdb}_backup/*; do
    ((cnt++))
    printf "%0${digits}d " ${cnt} ;printf "of ${cntTotal} \r"
    cp -fp "${i}" /dbc/${dir}/cdb${cdb}/ 1> /dev/null
  done
  printf "${cnt} of ${cntTotal} DONE!\n"
  tput cnorm #reset cursor
done
stopTime  #stop clock

re_index   #re-index files that have issues. 
