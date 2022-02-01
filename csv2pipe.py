################################################################################
# SCRIPT NAME:    csv2pipe.py
# BY:             David Garcia
# DATE:           08/19/2021
# DESCRIPTION:    Makes a CSV pipe delimited. Useful when fixing a CSV file that 
#                 contains commas in between double quotes that can cause 
#                 delimiter parsing issues.  
#
# 
# REVISIONS:
# 
################################################################################
#..............................................................................
# PASSED IN VARIABLES
#..............................................................................
# $1=Input file name. Comma delimited CSV file to fix.
#..............................................................................
import csv
import sys
import os
import shutil
#..............................................................................
# VARIABLES
#..............................................................................
PRGNAME = 'csv2pipe'              #program name
#..............................................................................
# SCRIPT START
#..............................................................................
try:
  fileName = sys.argv[1]       #get passed in file name
except IndexError:
  print('No file name passed in\nExiting...')
  exit()

if os.path.isfile(fileName) == False:
  print('File does not exist: "' + fileName + '"\nExiting...')
  exit()


#parse csv and replace commas with pipes
tmpFile1 = fileName + '-' + PRGNAME + '1'
if os.path.isfile(tmpFile1):
  os.remove(tmpFile1)
#1.0? reader = csv.reader(open(fileName,"rb"), delimiter=',')
reader = csv.reader(open(fileName,"rt"), delimiter=',') #1.0?
writer = csv.writer(open(tmpFile1,"w"), delimiter='|', quotechar='"', quoting=csv.QUOTE_MINIMAL)

#write CSV file to temp file pipe delimited
for row in reader:
  writer.writerow(row)

shutil.move(tmpFile1, fileName)         #move tmp to input file

