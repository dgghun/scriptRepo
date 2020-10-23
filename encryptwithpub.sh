#!/bin/bash
################################################################################
# SCRIPT NAME:    encryptwithpub.sh
# BY:             David Garcia
# DATE:           10/22/20
# DESCRIPTION:    Encrypts a file with the a passed in public key. The key id
#                 is extracted from the public key file and used to encrypt a
#                 file using gpg. 
# 
################################################################################
#...............................................................................
# VARIABLES
#...............................................................................
PUBKEYFILE="${1}"                   #public key to encrypt file with
OUTFILE="${2}"                      #file to encrypt
TMPDIR=./"gpgtmp`date +"%N"`"       #tmp gpg directory 
SNAME="encryptwithpub.sh"           #script name
#...............................................................................
# FUNCTIONS
#...............................................................................
function cleanUp(){
  echo "Cleaning up temp dir: ${TMPDIR}"
  rm -rf ${TMPDIR}
  echo "Done. Bye!"
}
#...............................................................................
# SCRIPT START
#...............................................................................
trap cleanUp SIGINT
trap cleanUp EXIT

echo "Public Key File: (${PUBKEYFILE})"
echo "File To Encrypt: (${OUTFILE})"

if ! [[ -f "${PUBKEYFILE}" ]];then
  echo "Public Key File does not exist (${PUBKEYFILE}). Exiting..."
  echo "Usage: ${SNAME} publicKeyFile fileToEncrypt"
  exit 1
elif ! [[ -f "${OUTFILE}" ]];then
  echo "File to encrypt does not exist. Exiting..."
  echo "Usage: ${SNAME} publicKeyFile fileToEncrypt"
  exit 1
fi

rm -fr ${TMPDIR}    #purge old temp directory (if there is one)
mkdir -p ${TMPDIR}     #make new one
chmod 700 ${TMPDIR} 

#Import key to a temporary folder
echo "IMPORTING PUBLIC FILE KEY: ${PUBKEYFILE}..."
gpg --homedir ${TMPDIR} --import "${PUBKEYFILE}" 
if [[ $? -ne 0 ]];then 
  echo "ERROR IMPORTING. Exiting.."
  exit 1
fi

#Determine the key ID of the key stored in the file:
echo "EXTRACTING PUBLIC KEY ID FOR ENCRYPTION..."
KEYID=`gpg --list-public-keys --batch --with-colons --homedir ${TMPDIR} 2>/dev/null | grep ^"pub" | cut -d: -f5`
if [[ $? -ne 0 ]];then 
  echo "ERROR EXTRACTING KEY ID. Exiting.."
  exit 1
fi
echo "KEYID: ${KEYID}"

#Encrypt a message to the recipient
echo "ENCRYPTING ${OUTFILE}"
gpg --homedir ${TMPDIR} --recipient ${KEYID} --batch --yes --trust-model always --encrypt "${OUTFILE}"


