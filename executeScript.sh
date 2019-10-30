# This script allows you to execute a script at a selected time and date.
#
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

TEMP=''
SCRIPT=''
DATE=''
TIME=''
START=''
TFORMAT="+%m/%d/%y %I:%M%P"
TFORMAT2="+%m/%d/%y %I:%M:%S%P"
CTIME=''

echo -e "${GREEN}----------SELECT TIME/DATE TO EXECUTE SCRIPT----------${NC}"
while [ "$DATE" = '' ]; do
  read -p 'Enter start date (mm/dd/yy): ' TEMP
  TEMP=$(date "+%m/%d/%y" --date=$TEMP) &> /dev/null
  if [ $? -eq 0 ]; then DATE="$TEMP"; fi  #no errors, set date
done
echo -e "${GREEN}Date: $DATE${NC}"

while [ "$TIME" = '' ]; do
  read -p 'Enter start time (HH:MMpm): ' TEMP
  TEMP=$(date "+%I:%M%P" --date=$TEMP) &> /dev/null
  if [ $? -eq 0 ]; then TIME="$TEMP"; fi  #no errors,set time
done
echo -e "${GREEN}Time: $TIME${NC}"

read -e -p 'Enter script to run: ' SCRIPT
echo -e "${GREEN}Script: $SCRIPT${NC}"

echo -e "\n${RED}-->Ready...${NC}\n\n\n"
START="$DATE $TIME"
tput civis   #invisible cursor
while [ "$START" != "$CTIME" ]; do
  tput cuu1   #move up one line
  tput cuu1   #move up one line
  tput cuu1   #move up one line
  CTIME=$(date "$TFORMAT")
  echo -e "Script to run: ${GREEN}$SCRIPT${NC}"
  echo -e "Starting time: ${GREEN}$START${NC}"
  echo -e " Current time: ${GREEN}$(date "$TFORMAT2")${NC}"
  sleep 1
done
tput cnorm   #display cursor again

echo -e "${RED}-->Go!${NC}"
sh ${SCRIPT}

