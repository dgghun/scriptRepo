#!/bin/bash
################################################################################
# SCRIPT NAME:    makeFileList.sh
# BY:             David Garcia
# DATE:           
# DESCRIPTION:    Creates a file list recursively from current directory
# 
################################################################################
#*******************************************************************************
# SCRIPT START ********************************************************************
#*******************************************************************************

totalFiles=`find ./ -type f 2> /dev/null| wc -l`
totalSize=`du -sh ./ 2> /dev/null | awk '{print $1}'`
printf "TOTAL FILES: "
printf "%'d" "$totalFiles"
echo ""
echo "TOTAL SIZE: $totalSize"
echo ""

ls -lhRA --time-style="+%x %I:%M%P" | 
  sed 's/^\.\//DIRECTORY: /g' | 
  sed 's/^total/DIRECTORY SIZE: /g' |
  grep ^l -v |
  awk '{
        if(NR <= 2)
         next
        
        if(NR == 3){
          print "TOP LEVEL DIRECTORIES"
          printf "%-7s %-13s %-10s %-25s \n",
                  "Size","Date","Time","Name"
        }
        
        if(length($0) <= 1){
          print ""
          next
        }
        
        if( $1 ~ /DIRECTORY:/){
          print substr($0,1,length($0)-1)
          getline
          print $0
          getline
          
          if(length($0) > 1)
           printf "%-7s %-13s %-10s %-25s \n",
                  "Size","Date","Time","Name"
        }
        
        if( (substr($0,1,1) == "l") || (substr($0,1,1) == "d") || (substr($0,1,1) == "-") ) {
          type=""
          if(substr($0,1,1) == "d")
            type="<- (Directory)"
          else if(substr($0,1,1) == "l")
            type="<- (Link)"
            
          #if($5 ~ /^[0-9]+$/)
           $5 = $5"B"
           
          printf "%-7s %-13s %-10s %-35s %-10s %-1s\n",
                  $5,$6,$7,$8,$9,type
        }
        else 
          print $0
       }' 2> /dev/null

