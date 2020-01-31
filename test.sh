#!/bin/bash
################################################################################
# SCRIPT NAME:    
# BY:             David Garcia
# DATE:           
# DESCRIPTION:    FOR TESTING                   
# 
################################################################################
#*******************************************************************************
# VARIABLES ********************************************************************
#*******************************************************************************
source /dbc/bin/functions.sh

#add1 - mix num and chars
#add2 - mix num and chars
#city - chars
#state - 2 chars
#zip  - nums

inFile="NBPCHIN1.TXT"
addrStartPos=18   #address starting position (ie address 1)
maxDelims=53      #number of delimiters per record

awk -F ',' -v sPos="${addrStartPos}" -v maxD="${maxDelims}" '
  ### AWK FUNCTIONS ###
  #checks if string is all alphabetic chars
  function isAllChars(str){
    tempStr = str
    gsub(" ","",tempStr)
    if(tempStr ~ /^[A-Za-z]+$/)
      return true
    return false
  }

  #checks if string is all numbers
  function isAllNums(str){
    tempStr = str
    gsub(" ","",tempStr)
    if(tempStr ~ /^[0-9]+$/)
      return true
    return false
  }
  
  ###AWK GLOBAL VARIABLES###
  BEGIN{
    true=1
    false=0
  }
  
  ###AWK START##
  { 
    if(NF != maxD){
      add1=sPos
      add2=sPos+1
      city=sPos+2
      state=sPos+3
      zip=sPos+4
      other=sPos+5
      
      zipStr=$zip               #save zip
      gsub("-","",otherStr)     #remove zip minus sign
      otherStr=$other           #save possible zip
      gsub("-","",otherStr)     #remove zip minus sign
      
      if($city == "" && length($state) > 2 && length($zip) == 2){
        #TODO: Need to loop through all fields and shift them down by one.
        #      Then you need to add some signature char at the end so you can 
        #      remove it later on as well as the last delimiter (ie subtract a column).
        print "*** FIXED THIS ONE ***"
    
        #shift fields down one
        for(i=city; i < NF; i++){
          $i = $(i + 1)
        }
        $(NF - 1) = $NF   #shift last field down one
        $NF = "~~~"       #mark last field to be removed
        
        print "addr1: ",$add1
        print "addr2: ",$add2
        print "city:  ",$city
        print "state: ",$state
        print "zip:   ",$zip
        print "other: ",$other
        print "tail-1:",$(NF-1)
        print "tail:  ",$NF
        print ""
      }
      
      
      #not this address field#print "addr1: ",$add1
      #not this address field#print "addr2: ",$add2
      #not this address field#print "city:  ",$city
      #not this address field#print "state: ",$state
      #not this address field#print "zip:   ",$zip
      #not this address field#print "other: ",$other
      #not this address field#print "tail-1:",$(NF-1)
      #not this address field#print "tail:  ",$NF
      #not this address field#print ""
    }
    
  }' ${inFile}


