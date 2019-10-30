#!/bin/bash
################################################################################
# SCRIPT NAME:
# BY:             David Garcia
# DATE:           6/7/19
# DESCRIPTION:    finds missing variables when compiling a program. The script
#                 will display all the variables found in the past in file. Useful
#                 when copying a program and need to find the missing variables
#                 fast and copy them over.
#
#
################################################################################
# $1 = program to search for variables '/dbc/work/COPRGNAME.DGG'
# $2 = program that needs the variables 'COPRG2NAME'
################################################################################

x=`CW ${2} | grep -i --color=always "Undefined" |
            awk '{
                   i=index($0,":")
                   print substr($0,i+2, length($0))
                 }
                ' | sort | uniq |
            awk 'BEGIN{
                   str=""
                  }
                  {
                    str="^"$0"\\\\|"str
                  }
                 END{
                    #str="\""str"\""
                    print substr(str,1, length(str)-3)
                    #print str
                  }
                '`

grep "$x" ${1}


