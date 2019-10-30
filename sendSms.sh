####
MSG=""
SUBJECT=""
NUM=""
SEND=""

#get input
while [ "$NUM" = "" ]; do
  read -p 'Enter number (e.g. 15555555555): ' NUM
done

while [ "$SUBJECT" = "" ]; do
  read -p 'Enter subject: ' SUBJECT
done

while [ "$MSG" = "" ]; do
  read -p 'Enter message: ' MSG
done

while [ "$SEND" != "Y" ] && [ "$SEND" != "N" ]; do
  echo -e "\nNumber:  $NUM"
  echo "Subject: $SUBJECT"
  echo "Message: $MSG"
  read -p 'Send message? (y or n): ' SEND
  if [ "$SEND" != "" ];then
    SEND=${SEND^^}
  fi
done

if [ "$SEND" = "Y" ];then
  echo "$MSG" | mailx -s "$SUBJECT" ${NUM}@tmomail.net
  echo "Sent!"
else
  echo "Not sent."
fi

