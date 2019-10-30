#!/bin/bash
#checks for duplicates or no duplicates
# $1=array or string
# $2=file               
# $3=d or n       check for duplicates or non duplicates
IN=( "$@" )
FILE=$2
OPTION=$3
doCheck=0
DUPS="d"
NONDUPS="n"
#
if  [ "$IN" = "--help" ]; then
   echo -e "\t Sorry, I can't help you :)"
#  echo -e "\tThis script checks for duplicates or non duplicates in a file. If"
#  echo -e "\tno options are entered the default is a duplicates check."
#  echo -e "\tExamples:"
#  echo -e "\t\t$ dupCheck.sh string file.txt $DUPS"
#  echo -e "\t\t$ dupCheck.sh string file.txt $NONDUPS"
#  echo -e "\t\t$ dupCheck.sh array file.txt $DUPS"
#  echo -e "\t\t$ dupCheck.sh array file.txt $NONDUPS"
#  echo -e "\t\td = check for duplicates"
#  echo -e "\t\tn = check for non duplicates"
elif [ "$IN" = "" ]; then
  echo "No string or array entered! Type --help for examples."
elif [ "$FILE" = "" ]; then
  echo "No file entered! Type --help for examples."
#elif [ ! -e $FILE ]; then
#  echo "File does not exist! ($FILE)"
else
  n=0
  echo "Running check on $FILE"
  for i in "${IN[@]}";do 
    ((n++))
    x=$(grep $i $FILE -c)
#    if [ $x -eq 1 ]; then         #get match count
      echo "Loop_$n $i duplicates: $x"
#    fi
  done
fi
echo $1, $2, $3
#if  [ doCheck -eq 1 ]; then
#  for i in ${array[@]};do 
#    x=$(grep $i /dbc/work/COCOCVHP.DGG -c)
#    if [ $x -eq 1 ]; then
#      echo $i" count="$x
#    fi
#  done
#fi
