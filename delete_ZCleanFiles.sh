#!/bin/bash
###############################################################################
#copy "ZCleanFiles" to test directory
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
###############################################################################
if [ "${1}" = "3"  ]; then CDB="3"
elif [ "${1}" = "8" ]; then CDB="8"
else CDB="1"
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'                                # No Color
F1="./other"                                #excluded file  
F2="./COFTABL1.ISI"                         #excluded file
F3="./COFTABL1.TXT"                         #excluded file
###############################################################################
# set array
###############################################################################
array[0]=./ASSGBKMU.TXT 
array[1]=./COFACTH${CDB}.ISI 
array[2]=./COFACTH${CDB}.TXT 
array[3]=./COFACTN${CDB}.ISI 
array[4]=./COFACTN${CDB}.TXT 
array[5]=./COFAJST${CDB}.TXT 
array[6]=./COFASST${CDB}.ISI 
array[7]=./COFASST${CDB}.TXT 
array[8]=./COFBNKR${CDB}.ISI 
array[9]=./COFBNKR${CDB}.TXT 
array[10]=./COFCACT${CDB}.ISI 
array[11]=./COFCHCK${CDB}.ISI 
array[12]=./COFCHCK${CDB}.TXT 
array[13]=./COFCHRM${CDB}.ISI 
array[14]=./COFCHRM${CDB}.TXT 
array[15]=./COFCHRN${CDB}.ISI 
array[16]=./COFCHRN${CDB}.TXT 
array[17]=./COFCLAS${CDB}.ISI 
array[18]=./COFCLAS${CDB}.TXT 
array[19]=./COFCLDE${CDB}.ISI 
array[20]=./COFCLDE${CDB}.TXT 
array[21]=./COFCOSG${CDB}.ISI 
array[22]=./COFCOSG${CDB}.TXT 
array[23]=./COFDBIT${CDB}.ISI 
array[24]=./COFDBIT${CDB}.TXT 
array[25]=./COFDEB1${CDB}.ISI 
array[26]=./COFDEB2${CDB}.ISI 
array[27]=./COFDEBT${CDB}.ISI 
array[28]=./COFDEBT${CDB}.TXT 
array[29]=./COFEMPL${CDB}.ISI 
array[30]=./COFEMPL${CDB}.TXT 
array[31]=./COFEPH1${CDB}.ISI 
array[32]=./COFEPH2${CDB}.ISI 
array[33]=./COFFILE${CDB}.ISI 
array[34]=./COFHIST${CDB}.ISI 
array[35]=./COFHIST${CDB}.TXT 
array[36]=./COFINS${CDB}.ISI  
array[37]=./COFINS${CDB}.TXT  
array[38]=./COFINVC${CDB}.ISI 
array[39]=./COFINVC${CDB}.TXT 
array[40]=./COFLGAL${CDB}.ISI 
array[41]=./COFLGAL${CDB}.TXT 
array[42]=./COFMANG${CDB}.ISI 
array[43]=./COFMANG${CDB}.TXT 
array[44]=./COFMDCC${CDB}.ISI 
array[45]=./COFMDCC${CDB}.TXT 
array[46]=./COFMNTH${CDB}.ISI 
array[47]=./COFMNTH${CDB}.TXT 
array[48]=./COFMULT${CDB}.ISI 
array[49]=./COFMULT${CDB}.TXT 
array[50]=./COFOLDP${CDB}.ISI 
array[51]=./COFOLDP${CDB}.TXT 
array[52]=./COFPAYG${CDB}.ISI 
array[53]=./COFPAYG${CDB}.TXT 
array[54]=./COFPERM${CDB}.ISI 
array[55]=./COFPERM${CDB}.TXT 
array[56]=./COFPOSS${CDB}.ISI 
array[57]=./COFPOSS${CDB}.TXT 
array[58]=./COFQBTE${CDB}.ISI 
array[59]=./COFQSCO${CDB}.ISI 
array[60]=./COFQUEU${CDB}.ISI 
array[61]=./COFQUEU${CDB}.TXT 
array[62]=./COFRDOC${CDB}.ISI 
array[63]=./COFRDOC${CDB}.TXT 
array[64]=./COFSALE${CDB}.ISI 
array[65]=./COFSALE${CDB}.TXT 
array[66]=./COFSD.ISI    
array[67]=./COFSD.TXT    
array[68]=./COFSDOS.ISI  
array[69]=./COFSDOS.TXT  
array[70]=./COFSDSK.ISI  
array[71]=./COFSDSK.TXT  
array[72]=./COFSDUCA.ISI 
array[73]=./COFSDUCA.TXT 
array[74]=./COFSSN1${CDB}.ISI 
array[75]=./COFSSN2${CDB}.ISI 
array[76]=./COFTIME${CDB}.ISI 
array[77]=./COFTIME${CDB}.TXT 
array[78]=./COFTRNS${CDB}.ISI 
array[79]=./COFTRNS${CDB}.TXT 
array[80]=./COFUNDER.ISI 
array[81]=./COFUNDER.TXT 
array[82]=./COSSPOSS.EXC 
array[83]=./DATEFILE.TXT 
array[84]=./MULTSBK.EXC  
array[85]=./PMSUSER.ISI  
array[86]=./PMSUSTM.ISI  
array[87]=./PRGCHRN${CDB}.ISI 
array[88]=./PRGCHRN${CDB}.TXT 
array[89]=./Q24.IN       
array[90]=./SORTAJST.ISI 
array[91]=./WATCH.TXT    
###############################################################################
COUNT=0                           #counter
DELCNT=0                          #deleted counter
echo "************************************************************************"
if  [ ${PWD##*/} = "ZCleanFiles" ]; then  #if you are in the source directory
  echo -e ${RED}"You can't delete original files!"${NC} 
 else                                     #good to go
  echo "- Deleting files..."
  for i in ${array[*]}; do                #delete all files
    ((COUNT++))                           #increment counter
    if [ ! -f "$i" ]; then                #file exist?
      echo -e ${RED}"-->"${NC}$i" does ${RED}NOT${NC} exist!"
    else                                  #it was deleted!
      rm -f $i 2>/dev/null                #delete file and pipe output to null
      if [ ! -f "$i" ]; then              #file still here?
        ((DELCNT++))                      #nope, increment delete count
      else                                #file wasn't deleted
        echo -e ${RED}"-->"${NC}$i" was ${RED}NOT${NC} deleted!"
      fi                                  #END file still here?
    fi                                    #END file exist?
  done
  echo "- DONE!"
  echo -e ${GREEN}$DELCNT ${NC}"out of "${GREEN}$COUNT ${NC}"files where deleted from "${GREEN}$(pwd)${NC}
fi                                        #END if you are in the source directory
echo "************************************************************************"
