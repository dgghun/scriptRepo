#!/bin/bash
################################################################################
# SCRIPT NAME:    split_save_pdfs.sh
# BY:             David Garcia
# DATE:           
# DESCRIPTION:    
# 
################################################################################
#...............................................................................
# ARGUMENTS
#...............................................................................
ARGCNT=5    #TESTING put right amount when done
PDFMASK="${1}"          #PDF file mask to process
PDFPROCESS="${2}"       #Options on how to process the PDFs:
                        # (M) = multiple PDFs with one account per pdf
                        # (O) = one PDF per assignment with multiple accounts in it
PAGESPERPDF="${3}"      #PDF pages per account
GREPACCT="${4}"         #Regular expression used by grep to find the account 
                        #number. This should make the account number be the last 
                        #piece of text. 
                        #Example for COCOHHBD "Account Number: [0-9]\{1,\} "
ASGNDATE="${5}"         #Assignment date
#ARCDIR="${}"           #where to archive PDFs when done
#COFILES=("${}")        #Temp CO files. Bash array form: CO1.TXT CO2.TXT ... COn.TXT

#...............................................................................
# VARIABLES
#...............................................................................
TMPPDF=SSPDF.pdf
TMPPDFMASK=SSPDF-tmp-%09d.pdf    #for pdfseparate command
TMPALLMASK=SSPDF-tmp-*.pdf
#PDFSTORAGE=/some/path
#...............................................................................
# VARIABLES
#...............................................................................
function setFileName() {
  infile=${1}
  
  acct=$(pdftotext -nopgbrk ${infile} /dev/stdout |      #print pdf to std out
    tr '\n' ' ' |                                 #make output one line
    grep "${GREPACCT}" -io |                      #search for account number
    awk '{print $NF}'                             #account should be last field
    )
  
  mv ${infile} ./"${acct}_${ASGNDATE}.pdf" &> /dev/null
  if ! [[ -f ./"${acct}_${ASGNDATE}.pdf" ]];then
    echo "ERROR: error creating PDF with account number on it. Exiting" > /dev/stderr
    exit 1
  fi
  echo "${acct}_${ASGNDATE}.pdf"    #return file name 
}

#...............................................................................
# SCRIPT START
#...............................................................................
if [[ $# -lt ${ARGCNT} ]];then
  echo "${ARGCNT} arguments are required. $# args passed in. Exiting."
  exit 1
fi

cp ~/files/${1} ./    #for testing 

if [[ ${PDFPROCESS} == [Mm] ]];then
  echo "Processing multiple PDFs with one account per pdf..."
elif [[ ${PDFPROCESS} == [Oo] ]];then
  echo "Processing one PDF per assignment with multiple accounts in it..."
  
  #Process all PDFs
  for pdfFile in ${PDFMASK};do
    pgCnt=`pdfinfo ${pdfFile} | grep -i "pages" | awk '{print $2}'`
    if [[ ${pgCnt} -lt 1 ]];then
      echo "ERROR: Page count error. Exiting"
      exit 1
    fi
    
    frstPage=1
    lastPage=${PAGESPERPDF}   #last PDF page per account

    #Parse all accounts into their own PDF file
    while [[ ${lastPage} -le ${pgCnt} ]]; do
      rm ./${TMPALLMASK} &> /dev/null
      
      echo "Separating page $frstPage to $lastPage for file ${pdfFile}..."
      pdfseparate -f ${frstPage} -l ${lastPage} ${pdfFile} ${TMPPDFMASK}
      if [[ $? -ne 0 ]];then
        echo "ERROR: error separating PDFs. Exiting"
        exit 1
      fi

      echo "Combining separated PDFs into one for file ${pdfFile}..."
      rm ./${TMPPDF} &> /dev/null
      pdfsToUnite=""
      for i in `ls ${TMPALLMASK} | sort`;do 
        pdfsToUnite="$pdfsToUnite ${i}"
      done
      pdfunite ${pdfsToUnite} ${TMPPDF}
      if [[ $? -ne 0 ]];then
        echo "ERROR: error combining separated PDFs. Exiting"
        exit 1
      fi
      
      newPdfFile=`setFileName ${TMPPDF}`   #call function to set PDF file name
      if [[ $? -eq 1 ]];then
        exit 1  #error in function, exit
      fi
      echo "New file: $newPdfFile"

      frstPage=`expr ${frstPage} + ${PAGESPERPDF}`
      lastPage=`expr ${lastPage} + ${PAGESPERPDF}`
      echo ""
    done  #END OF Parse all accounts into their own PDF file
  done  #END OF Process all PDFs
  
else
  echo "ERROR: Unrecognized script argument (${PDFPROCESS}). Exiting"
  exit 1
fi

rm ./${TMPALLMASK} ./${TMPPDF} &> /dev/null



