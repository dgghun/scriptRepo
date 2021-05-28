#!/bin/bash
#!/bin/bash
################################################################################
# SCRIPT NAME:    updateTestSystem.sh
# BY:             David Garcia
# DATE:           11/26/19
# DESCRIPTION:    Updates test system files from the NAS back up.
#                 
# 05/26/21 dgg include indexing of AIM indexes. Use proper db PMS,OUT,INS before starting.
# 05/12/21 dgg not copying over index files and just re-indexing 
# 06/17/20 dgg fixed "storage size error - not enough space". Process one file at a time.                 
# 
################################################################################
source /dbc/bin/functions.sh
source /dbc/bin/colorFunctions.sh
#VARIABLES......................................................................
cdb=$1
NASPATH="/media/dbcextra"       #NAS mount point
START=''
FIN=''
TSECS=''

#FUNCTIONS......................................................................
# trap CTRL + C and call ctrl_c()
trap ctrl_c INT
function ctrl_c() {
  echo ""
  echo "exiting"
  tput cnorm
  exit 1
}

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
  
  echo "COFQUEU${cdb} & COFQBTE${cdb}"
  filechk COFQUEU${cdb}.TXT -f
  i COFQUEU${cdb} COFQBTE${cdb} -e
  i COFQUEU${cdb} -e
  cp -fpv /dbc/txt/cdb${cdb}/COFQUEU${cdb}.TXT /dbc/txt/cdb${cdb}_backup/ 
  cp -fpv /dbc/isi/cdb${cdb}/COF{QUEU,QBTE}${cdb}.ISI /dbc/isi/cdb${cdb}_backup/ 
}

# SCRIPT START..................................................................
if [ "$cdb" == "" ];  then 
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

#use proper db before starting
case ${cdb} in
  1) PMS;;
  3) OUT;;
  8) INS;;
esac

startTime #start clock
mkdir ~/tempdir   &> /dev/null  #make the directory in case its not there
rm -f ~/tempdir/* &> /dev/null  #clear it out 
cd ~/tempdir

for dir in txt isi;do
  cntTotal=`ls ${NASPATH}/livefiles/cdb${cdb}/${dir}/* | wc -l`
  cnt=0
  
  for i in ${NASPATH}/livefiles/cdb${cdb}/${dir}/*;do
    infile="${i##*/}"   #get file name
    ((cnt++))
    
    tput setaf 6  #cyan
    echo "PROCESSING ${i} : ${cnt} of ${cntTotal} (${dir} files)"
    tput sgr0     #color off
    
    #index files, just re-index and copy to backup folder
    if [[ "${dir}" == "isi" ]];then
      indexSource=""
      opt=""
      indexType=""

      if [[ "${infile#*.}" == "AIM" ]];then
        opt='-a'
        indexType='aimdex'
      else
        opt='-i'
        indexType='index'
      fi

      indexSource=`filechk $infile ${opt} | grep "file is" -i | awk '{print $NF}'`
      echo "Re-indexing ${infile} with source index file ${indexSource}"
      /dbc/bin/${indexType} ${indexSource} ${infile} -e #>/dev/null
      
      echo "Copying ${infile} to CDB${cdb} ${dir^^} back up folder..."
      cp -fp /dbc/${dir}/cdb${cdb}/${infile} /dbc/${dir}/cdb${cdb}_backup/ 1> /dev/null
      
      echo -e "${infile} DONE!\n"
      continue
    fi

    echo "Copying ${infile} to `pwd`..."
    rsync -ah --progress "${i}" ./
    
    chmod -v 666 ${infile} &> /dev/null
    
    echo "Moving ${infile} to CDB${cdb} ${dir^^} back up folder..."
    mv -f "${infile}" /dbc/${dir}/cdb${cdb}_backup/ 1> /dev/null
    
    echo "Copying ${infile} to CDB${cdb} ${dir^^} folder..."
    cp -fp /dbc/${dir}/cdb${cdb}_backup/${infile} /dbc/${dir}/cdb${cdb}/ 1> /dev/null
    
    echo -e "${infile} DONE!\n"
  done 
done
stopTime  #stop clock

###re_index   #re-index files that have issues. 
