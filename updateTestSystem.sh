#!/bin/bash
###############################################################################
#COPY LIVE SYSTEM DATA TO TEST SYSTEM
###############################################################################
LOG=LOG_copynewfiles.txt
cdb=$1
DATEMASK="+--> %D %I:%M%p: "    #date mask = ' --> mm/dd/yy hh:mmAM/PM: '
source /dbc/bin/functions.sh    #dbc PMS, OUT, & INS functions
###############################################################################  
#echo "!!!!!!!! MAKE SURE YOU ARE IN A THE RIGHT SYSTEM (PMS, OUT, INS) !!!!!!!!"
if [ "$cdb" = "" ];  then 
  echo "No data base (1,3,8) specified! Copy live system aborted."
elif [ "$cdb" != 8 ] && [ "$cdb" != 3 ] && [ "$cdb" != 1 ]; then
  echo "Incorrect data base entered! Must be 1, 3 or 8. Copy live system aborted."
else
  if [ "$cdb" = 1 ];then 
    PMS
  elif [ "$cdb" = 3 ]; then
    OUT
  else
    INS
  fi
  START=$(date "+%s")       #get start time in seconds
  SHSTART=$START            #script start
  TSECS=$START              #get start time in seconds
  mkdir /home/dgdev/tempdir >& /dev/null #make the directory in case its not there
  rm -f /home/dgdev/tempdir/* >& /dev/null #clear it out if it exists
  echo $(date "$DATEMASK")"Copying live backup to test temp directory...."  |tee $LOG
  rsync -avh dgarcia@${XPROIP}:/dbc/backup/cdb${cdb}/*.TXT /home/dgdev/tempdir ###|tee -a $LOG
  
  for i in /home/dgdev/tempdir/*;do
    chmod 777 ${i}
  done
  
  echo $(date "$DATEMASK")"Copying live to test temp directory....DONE! "  |tee -a $LOG
  FIN=$(date "+%s")         #get time in seconds
  TSECS=$(( (FIN - START) ))    #get execution time
  if [ $TSECS -lt 59 ]; then echo "-RUN TIME: $TSECS seconds" |tee -a $LOG; else echo "-RUN TIME: $(( TSECS/60 )) mins" |tee -a $LOG; fi #display execution time
  echo -e "--------------------------------------------------------------------------------\n" |tee -a $LOG
  
  START=$(date "+%s")       #get start time in seconds
  echo $(date "$DATEMASK")"Moving copied files to test backup directory..."  |tee -a $LOG
  mv -fv /home/dgdev/tempdir/*.TXT /dbc/txt/cdb${cdb}_backup/ ###|tee -a $LOG
  echo $(date "$DATEMASK")"Moving copied files to backup directory...DONE!" |tee -a $LOG
  FIN=$(date "+%s")         #get time in seconds
  TSECS=$(( (FIN - START) ))    #get execution time
  if [ $TSECS -lt 59 ]; then echo "-RUN TIME: $TSECS seconds" |tee -a $LOG; else echo "-RUN TIME: $(( TSECS/60 )) mins" |tee -a $LOG; fi #display execution time
  echo -e "--------------------------------------------------------------------------------\n" |tee -a $LOG
  
  START=$(date "+%s")       #get start time in seconds
  echo $(date "$DATEMASK")"Copying backup files to CDB$cdb directory..."  |tee -a $LOG
  cp -fpv /dbc/txt/cdb${cdb}_backup/*.TXT /dbc/txt/cdb${cdb}/
  echo $(date "$DATEMASK")"Copying backup files to CDB$cdb directory...DONE!" |tee -a $LOG
  FIN=$(date "+%s")         #get time in seconds
  TSECS=$(( (FIN - START) ))    #get execution time
  if [ $TSECS -lt 59 ]; then echo "-RUN TIME: $TSECS seconds" |tee -a $LOG; else echo "-RUN TIME: $(( TSECS/60 )) mins" |tee -a $LOG; fi #display execution time
  echo -e "--------------------------------------------------------------------------------\n" |tee -a $LOG
  
  START=$(date "+%s")       #get start time in seconds
  echo $(date "$DATEMASK")"Running file check..."  |tee -a $LOG
  for i in /dbc/txt/cdb${cdb}/*.TXT ;do 
    /dbc/bin/filechk $i -fx   ###|tee -a $LOG #>& /dev/null   #null output
  done
  echo $(date "$DATEMASK")"Running file check...DONE!" |tee -a $LOG
  FIN=$(date "+%s")         #get time in seconds
  TSECS=$(( (FIN - START) ))    #get execution time
  if [ $TSECS -lt 59 ]; then echo "-RUN TIME: $TSECS seconds" |tee -a $LOG; else echo "-RUN TIME: $(( TSECS/60 )) mins" |tee -a $LOG; fi #display execution time
  echo -e "--------------------------------------------------------------------------------\n" |tee -a $LOG
  
  START=$(date "+%s")       #get start time in seconds
  echo $(date "$DATEMASK")"Processing indexes..."  |tee -a $LOG
  for i in /dbc/isi/cdb$cdb/*.ISI ; do 
    file1=${i%.*}
    isiname=${file1##*/}
    txtname=`filechk  $i -i |grep "Text file is" | awk '{print $4}'`
    echo "indexing $isiname with $txtname " |tee -a $LOG
    /dbc/bin/index $txtname $isiname -e -a=2000000 -w=$isiname.wrk  ###|tee -a $LOG 
  done
  echo $(date "$DATEMASK")"Processing indexes...DONE!" |tee -a $LOG
  FIN=$(date "+%s")         #get time in seconds
  TSECS=$(( (FIN - START) ))    #get execution time
  if [ $TSECS -lt 59 ]; then echo "-RUN TIME: $TSECS seconds" |tee -a $LOG; else echo "-RUN TIME: $(( TSECS/60 )) mins" |tee -a $LOG; fi #display execution time
  echo -e "--------------------------------------------------------------------------------\n" |tee -a $LOG

  START=$(date "+%s")       #get start time in seconds
  echo $(date "$DATEMASK")"Processing aim indexes..."  |tee -a $LOG
  for i in /dbc/isi/cdb$cdb/*.AIM ; do 
    file1=${i%.*}
    isiname=${file1##*/}
    echo $i
    /dbc/bin/aimdex $isiname -e  ###|tee -a $LOG
  done  
  echo $(date "$DATEMASK")"Processing aim indexes...DONE!" |tee -a $LOG
    FIN=$(date "+%s")         #get time in seconds
  TSECS=$(( (FIN - START) ))    #get execution time
  if [ $TSECS -lt 59 ]; then echo "-RUN TIME: $TSECS seconds" |tee -a $LOG; else echo "-RUN TIME: $(( TSECS/60 )) mins" |tee -a $LOG; fi #display execution time
  echo -e "--------------------------------------------------------------------------------\n" |tee -a $LOG
  
  START=$(date "+%s")       #get start time in seconds
  echo $(date "$DATEMASK")"Special..."  |tee -a $LOG
  /dbc/bin/index COFAR105 -P76=@ 42-52 -D -W=IZME.WRK -a=2000000
  /dbc/bin/index  COFBNKR$cdb  1-11 -p1NE" " -p1-10NE000        -a=2000000
  /dbc/bin/index  COFDEBT$cdb COFCACT$cdb -p119#" " 119-138 1-10 -j -a=2000000
  /dbc/bin/index  COFDEBT$cdb COFCACT5 -P119#" " 119-138 1-10 -A=85000
  /dbc/bin/index  COFDEBT$cdb COFDEB1$cdb -p41#" " 41-60 1-10 -j -a=2000000
  /dbc/bin/index  COFDEBT$cdb COFDEB2$cdb  -p71#" " 71-90 1-10 -j -a=2000000
  /dbc/bin/index  COFDEBT$cdb COFDEBC$cdb  -d 223-228 311-314 307-310 -p465#R OR -p465=R -p212-213NEPF -p212-213NESF -p212-213NECN -j -a=2000000
  /dbc/bin/index  COFDEBT$cdb COFDEBT$cdb  -P1#" " 1-10 -j -a=2000000
  /dbc/bin/index  COFDEBT$cdb COFEPH1$cdb  -p88#" " 88-97 1-10 -j -a=2000000
  /dbc/bin/index  COFDEBT$cdb COFEPH2 -p211#" " 211-220 1-10 -j -a=2000000
  /dbc/bin/index  COFDEBT$cdb COFFILE$cdb -p11#" "  11-30 1-10 -j -a=2000000
  /dbc/bin/index  COFDEBT$cdb COFFILET -p11ne" "  11-30 1-10 -j -a=2000000
  /dbc/bin/index  COFDEBT$cdb COFLPH0$cdb -j -p344#" "  344-353 1-10 -!
  /dbc/bin/index  COFDEBT$cdb COFPHN1$cdb -p230#" " 230-239 1-10 -j -a=2000000
  /dbc/bin/index  COFDEBT$cdb COFPHN2$cdb -p241#" " 241-250 1-10 -j -a=2000000
  /dbc/bin/index  COFDEBT$cdb COFPHN3$cdb -p252#" " 252-261 1-10 -j -a=2000000
  /dbc/bin/index  COFDEBT$cdb COFPSN1$cdb -p101#" " 106-109 41-70 1-10 -j -a=2000000
  /dbc/bin/index  COFDEBT$cdb COFPSN2$cdb -p110#" " 115-118 41-70 1-10 -j -a=2000000
  /dbc/bin/index  COFDEBT$cdb COFSSN1$cdb -p101#" " 101-109 1-10 -j -a=2000000
  /dbc/bin/index  COFDEBT$cdb COFSSN2$cdb -p110#" " 110-118 1-10 -j -a=2000000
  /dbc/bin/index  COFCLNT$cdb COFCLPR$cdb  -P2390ne" " 2390-2391 1-6 -a=2000000
  /dbc/bin/index  COFCLNT$cdb COFCLSE$cdb  -P2392ne" " 2392-2394 1-6 -a=2000000
  /dbc/bin/index  COFLGAL$cdb COFLPHO$cdb -j -p344#" "  344-353 1-10 -a=2000000
  /dbc/bin/index  COFMDCC$cdb COFMDCC$cdb -P1-10NE"000       " -P1-10NE"          " 1-10 -A=1500000
  /dbc/bin/index  COFMNTH$cdb COFMTHDT  1-10 19-26 84-85 11-17 -P84-85=EM -p44-52ne"      .00" OR -P84-85=ED -p44-52ne"      .00" OR -P84-85=VD -p44-52ne"      .00" OR -P84-85=VM -p44-52ne"      .00" OR -P84-85=VV -p44-52ne"      .00" OR -P84-85=VX -p44-52ne"      .00" -a=2000000
  /dbc/bin/index  COFINS$cdb  COFWCAB$cdb  609-614 -P609-614ne"     " -d -a=2000000
  /dbc/bin/index  COLSUM.PRT  COLSUM -P5=" " -P33=. -P6NE" " 2-4 -a=2000000
  /dbc/bin/index  COPRDALY.PRT COPRDALY 3-5 -P6=" " -P42=. -D -a=2000000
  /dbc/bin/index  NOCALL NOCALL 1-3 -p1#" " 
  /dbc/bin/index  UTFACCES UTFACCS2 91-93 -p74-77#GONE -a=2000000
  /dbc/bin/index  UTFACCES UTFACCS3 -p74-77#GONE 23-23 8-22 -a=2000000
  #...TESTING/dbc/bin/index  COFINS$cdb.TXT COFWCAB$cdb.ISI 609-623 -P609-623ne"               " -d -!
  /dbc/bin/index  COFINS$cdb COFWCAB$cdb 609-623 -P609-623ne"               " -d -!
  /dbc/bin/index  ANSLOG -e
  /dbc/bin/index  COFDEBT$cdb -e
  /dbc/bin/index  COFQUEU$cdb COFQBTE$cdb -e
  
  if    [ "$cdb" = "1" ] ; then 
    /dbc/bin/index  PRGCHRN$cdb  PRGCHRN$cdb 18-27 4-9 -D -P12=: -A=1500000
    /dbc/bin/index  PRGDEBT$cdb PRGDEB1$cdb -P41#" " 41-60 1-10 -a=2000000
    /dbc/bin/index  PRGDEBT$cdb PRGFILE$cdb -P11NE" " 11-30 1-10 -A=85000000 -d -J -!
  fi 
  
  echo $(date "$DATEMASK")"Special...DONE!" |tee -a $LOG
  FIN=$(date "+%s")         #get time in seconds
  TSECS=$(( (FIN - START) ))    #get execution time
  if [ $TSECS -lt 59 ]; then echo "-RUN TIME: $TSECS seconds" |tee -a $LOG; else echo "-RUN TIME: $(( TSECS/60 )) mins" |tee -a $LOG; fi #display execution time
  echo -e "--------------------------------------------------------------------------------\n" |tee -a $LOG

  
  #had some issues so re indexed some files in this block
  /dbc/bin/index  COFDEBT$cdb -e
  /dbc/bin/index  ANSLOG$cdb -e
  /dbc/bin/index  COFQUEU$cdb -e
  /dbc/bin/index  COFQUEU$cdb COFQBTE$cdb -e
  
##  echo $(date "$DATEMASK")"ALL DONE AND READY TO USE TEST SYSTEM!"  |tee -a $LOG

  START=$(date "+%s")       #get start time in seconds
  echo $(date "$DATEMASK")"Copying indexed files back to backup directory..." |tee -a $LOG
  cp -pf /dbc/isi/cdb$cdb/* /dbc/isi/cdb${cdb}_backup/  &
  cp -pf /dbc/txt/cdb$cdb/*.TXT /dbc/txt/cdb${cdb}_backup/ 

  

  echo $(date "$DATEMASK")"Copying indexed files back to backup directory...DONE!" |tee -a $LOG
  FIN=$(date "+%s")         #get time in seconds
  TSECS=$(( (FIN - START) ))    #get execution time
  if [ $TSECS -lt 59 ]; then echo "-RUN TIME: $TSECS seconds" |tee -a $LOG; else echo "-RUN TIME: $(( TSECS/60 )) mins" |tee -a $LOG; fi #display execution time
  echo -e "--------------------------------------------------------------------------------\n" |tee -a $LOG
  
  TSECS=$(( (FIN - SHSTART) ))    #get TOTAL execution time
  echo $(date "$DATEMASK")"DONE!...bye!"  |tee -a $LOG
  if [ $(( $TSECS/60 )) -gt 59 ]; then    #if greater than 59 mins....
    HR=$(( $TSECS / 60 / 60 ))            #dived by 60 twice for hour
    MIN=$(( $TSECS / 60 % 60 ))           #dived once & mod once for mins
    SEC=$(( $TSECS % 60 ))                #mod once for seconds 
    echo "-TOTAL RUN TIME: hrs:$HR mins:$MIN secs:$SEC" |tee -a $LOG
  else                                    #is less than 59 mins
    MIN=$(( $TSECS / 60 ))                #dived once for mins
    SEC=$(( $TSECS % 60 ))                #mod once for seconds
    echo "-TOTAL RUN TIME: mins:$MIN secs:$SEC" |tee -a $LOG
  fi
fi
