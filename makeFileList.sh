#!/bin/bash
################################################################################
# SCRIPT NAME:    makeFileList.sh
# BY:             David Garcia
# DATE:           
# DESCRIPTION:                     
# 
################################################################################
#*******************************************************************************
# VARIABLES ********************************************************************
#*******************************************************************************
FILENAME="${1}"

ls -lhRA | 
  sed 's/^\.\//DIRECTORY: /g' | 
  sed 's/^total/DIRECTORY SIZE: /g' |
  awk '{
        if(NR <= 2)
         next
        
        if(NR == 3){
          print "TOP LEVEL DIRECTORIES"
          printf "%-7s %-8s %-8s %-1s \n",
                  "Size","Date","Time","Name"
        }
        
        if( $1 ~ /DIRECTORY:/){
          print substr($0,1,length($0)-1)
          getline
          print $0
          getline
          
          if(length($0) > 1)
           printf "%-7s %-8s %-8s %-1s \n",
                  "Size","Date","Time","Name"
        }
        
        if( (substr($0,1,1) == "d") || (substr($0,1,1) == "-") ) {
          type=""
          if(substr($0,1,1) == "d")
            type="<- (Directory)"
          printf "%-7s %-3s %-4s %-8s %-20s %-1s\n",
                  $5,$6,$7,$8,$9,type
        }
        else 
          print $0
       }'
totalFiles=`find ./ -type f | wc -l`
totalSize=`du -sh ./ | awk '{print $1}'`
echo ""
echo "TOTAL FILES: $totalFiles"
echo "TOTAL SIZE: $totalSize"

