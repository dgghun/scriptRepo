#!/bin/bash
################################################################################
# SCRIPT NAME:    coffDiff.sh
# BY:             David Garcia
# DATE:           
# DESCRIPTION:    Looks for file changes in cdb1, 3 or 8. If found, user is prompted
#                 to reset them or not.
#                 
# 
################################################################################
source ~/colorFunctions.sh

BACKUP="BACKUP.TXT"
CURRENT="CURRENT.TXT"

if [ "${1}" == "1" ] || [ "${1}" == "3" ] || [ "${1}" == "8" ];then
  db="${1}"
  CYANL "Processing CDB${db}..."
elif [ "${1}" == "" ];then
  CYANL "No data base entered. Defaulting to CDB1."
  db='1'
else
  echo `REDL "Invalid database entered --> CDB${1}"`
  exit 1
fi


du -a --time /dbc/isi/cdb${db}_backup/{COF,PMS,TEAM}*.{AIM,ISI} 2>/dev/null | awk '{print $4,$2"_"$3}' | sort | awk '{print $2,$1}' >  ./${BACKUP}
du -a --time /dbc/txt/cdb${db}_backup/{COF,PMS,TEAM}*.TXT       2>/dev/null | awk '{print $4,$2"_"$3}' | sort | awk '{print $2,$1}' >> ./${BACKUP}
sed -i "s/\/dbc\/txt\/cdb${db}_backup\///g" ./${BACKUP} 
sed -i "s/\/dbc\/isi\/cdb${db}_backup\///g" ./${BACKUP} 
sort -o ./${BACKUP} ./${BACKUP}
echo "$BACKUP = "$(wc -l ${BACKUP} | awk '{print $1}')" files."

du -a --time /dbc/isi/cdb${db}/{COF,PMS,TEAM}*{AIM,ISI} 2>/dev/null | awk '{print $4,$2"_"$3}' | sort | awk '{print $2,$1}' >  ./${CURRENT}
du -a --time /dbc/txt/cdb${db}/{COF,PMS,TEAM}*TXT       2>/dev/null | awk '{print $4,$2"_"$3}' | sort | awk '{print $2,$1}' >> ./${CURRENT}
sed -i "s/\/dbc\/txt\/cdb${db}\///g" ./${CURRENT} 
sed -i "s/\/dbc\/isi\/cdb${db}\///g" ./${CURRENT} 
sort -o ./${CURRENT} ./${CURRENT}
echo "$CURRENT = "$(wc -l ${CURRENT} | awk '{print $1}')" files."

echo "Comparing files: $BACKUP $CURRENT"
#diff ./${BACKUP} ./${CURRENT}
diffCnt=0
fileArray=()
for i in `diff ./${BACKUP} ./${CURRENT} | grep "[<>]" | awk '{print $3}' | sort | uniq`; do
  echo $(YELL "Different: ")${i}
  ((diffCnt++))
  fileArray+=("${i}")
done

if [ ${diffCnt} -gt 0 ]; then
  while true; do
    read -p "$(PURPL "Reset files? ") (Y)es, (N)o or Reset (A)ll: " yn
    case $yn in
        [Yy]* ) doResetArray=()
                for i in ${fileArray[*]}; do
                  read -p "- Reset $i? (y or n) " yn
                  if [ "${yn^^}" = "Y" ];then
                   doResetArray+=("Y")
                  else
                   doResetArray+=("N")
                  fi
                done
                
                for i in `seq 0 $((diffCnt - 1))`; do
                  if [ "${doResetArray[$i]}" = "Y" ];then
                    if [ "${fileArray[$i]#*.}" = "TXT" ];then 
                      cp -pv /dbc/txt/cdb${db}_backup/${fileArray[$i]} /dbc/txt/cdb${db}/
                    else
                      cp -pv /dbc/isi/cdb${db}_backup/${fileArray[$i]} /dbc/isi/cdb${db}/
                    fi
                  fi
                done
                
                echo "Done!"
                break;;
        [Aa]* ) for i in ${fileArray[*]}; do
                  if [ "${i#*.}" = "TXT" ];then 
                    cp -pv /dbc/txt/cdb${db}_backup/${i} /dbc/txt/cdb${db}/
                  else
                    cp -pv /dbc/isi/cdb${db}_backup/${i} /dbc/isi/cdb${db}/
                  fi
                done
                echo "Done!"
                break;;
        * )     echo "Ok, no changes made.";
                cnt=0
                for i in `seq 0 $((${#fileArray[*]}-1))`;do
                  tmp=${fileArray[$i]}
                  tmp=${tmp:3}
                  end=$((${#tmp} - 4))
                  echo "${tmp:0:${end}}"
                done | sort |uniq | tr '\n' ' '
                echo ""
                break;;
    esac
  done
else
  echo "$(PURPL "All COF files are the same. No changes made.")"
fi
