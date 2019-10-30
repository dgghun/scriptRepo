#1/bin/bash
START=$(date "+%s")       #get start time in seconds
#DB=""
#while [ "$DB" = "" ]; do
#  read -p 'What data base to reset (1,3,8)?' DB
#done

echo "Reseting test data..."
#rsync -avX -progress /dbc/isi/cdb${1}_backup/* /dbc/isi/cdb${1}/ &
#rsync -avX -progress /dbc/txt/cdb${1}_backup/*.TXT /dbc/txt/cdb${1} 
cp -vpf /dbc/isi/cdb${1}_backup/* /dbc/isi/cdb${1}/ &
cp -vpf /dbc/txt/cdb${1}_backup/*.TXT /dbc/txt/cdb${1} 
#I COFINS1 COFWCAB1 609-623 -p609-623ne"            " -D -!
echo "done"
FIN=$(date "+%s")         #get time in seconds
T=$(( (FIN - START) ))    #get execution time
if [ $T -lt 59 ]; then echo "-RUN TIME: $T seconds"; else echo "-RUN TIME: $(( T/60 )) mins"; fi #display execution time
echo -e "--------------------------------------------------------------------------------\n"
