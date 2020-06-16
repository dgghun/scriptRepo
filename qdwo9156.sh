#!/bin/bash
################################################################################
# SCRIPT NAME:    qdwo9156.sh
# BY:             David Garcia
# DATE:           6/12/20
# DESCRIPTION:    wo9156 Data Cleanup
# 
################################################################################
source /dbc/bin/functions.sh
#...............................................................................
# VARIABLES
#...............................................................................
INFILE=SCS_PMS_ASSIGNMENT_ALL.TXT         #all assignment files from archive.
DEBTFILE=SCRIPPS-DEBT.CSV
WRKFILE=QDWO9156.WRK
HARFILE=SCS_HAR
RNFFILE=SCS_RNF.TXT
OUTFILE=SCS_NEWHAR.CSV
RSTR='-p223-228=GHS415 OR -p223-228=GHS410 OR -p223-228=MCY920 OR -p223-228=SCV410 OR -p223-228=SCV710 OR -p223-228=SEC925 OR -p223-228=SEC920 OR -p223-228=SHE920 OR -p223-228=SHE925 OR -p223-228=SRM820 OR -p223-228=SRM825 OR -p223-228=CLN970 OR -p223-228=MCY925 OR -p223-228=GHS210 OR -p223-228=GHS310 OR -p223-228=MCY910 OR -p223-228=SCV310 OR -p223-228=SCV610 OR -p223-228=SEC710 OR -p223-228=SEC910 OR -p223-228=SHE710 OR -p223-228=SHE910 OR -p223-228=SRM810'
BATES=1-10
ACCT=119-138
CLNTSPECIAL=901-910
ASGNDATE=307-314


#...............................................................................
# SCRIPT START
#...............................................................................
#
read -p "Do a reformat on COFDEBT1 and make work file?" YN
if [[ "${YN}" == [Yy] ]];then
  PMS &>/dev/null
  r COFDEBT1 ${DEBTFILE} ${ACCT} -f="," ${BATES} -f="," ${CLNTSPECIAL} -f="," ${ASGNDATE} ${RSTR} -t -!

  cat ${DEBTFILE} | awk -F',' '{
      for(i=1; i <= NF; i++){
          gsub(/^[ ]+/,"",$i)  #remove one or more (+) starting (^) spaces 
          gsub(/[ ]+$/,"",$i)  #remove one or more (+) ending ($) spaces 
      }
      
      if(length($3) == 8 ){
        print 
      }
    }' | sort -k2 > ${WRKFILE}
fi

read -p "Make HAR file from archived assignment files ? (hosp acct,clinic acct & gur ID)" YN
if [[ "${YN}" == [Yy] ]];then
  grep "^01" ${INFILE} | awk -F'^' '{print $2,$136}' | sort -k1 | uniq > ${HARFILE}.HOSP
  grep "^01" ${INFILE} | awk -F'^' '{print $3,$136}' | sort -k1 | uniq > ${HARFILE}.CLIN
fi

rm -f ${RNFFILE} ${OUTFILE} &>/dev/null
while IFS='' read -r line;do
  cact=`echo ${line} | awk '{print $1}'`      #account
  bate=`echo ${line} | awk '{print $2}'`      #bates
  cltf=`echo ${line} | awk '{print $3}'`      #client specific (current har)

  newHar=`grep -m1 ^${cact} ${HARFILE}.HOSP | awk '{print $2}'`   #check hospital
  if [[ "${newHar}" == "" ]];then
    newHar=`grep -m1 ^${cact} ${HARFILE}.CLIN | awk '{print $2}'` #check clinic
  fi
  
  echo "${bate},${cltf},${newHar}"
  
done < ${WRKFILE} | tee -a ${OUTFILE}





