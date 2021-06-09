import json
import sys
import re

#..............................................................................
# Prints out all associated databases with a program. The database and program
# info is contained in pre-compiled JSON files defined below.
#..............................................................................

# print('Number of arguments:', len(sys.argv), 'arguments.')
# print('Argument List:' + str(sys.argv))

#..............................................................................
# VARIABLES
#..............................................................................
FILE_PROGRAMS_USED = 'DBC-PROGRAM-USED.JSON'        #contains all the database names a programs uses
FILE_DB_DEFINITIONS = 'DBC-DEFINITION-FILES.JSON'   #contains database/file definitions of a program
#..............................................................................
# FUNCTIONS
#..............................................................................
#Returns an array of all databases used in the program name passed in
def GetProgramUsedDatabases(prgname):
    dbArray = []
    with open(FILE_PROGRAMS_USED, 'r') as infile:
        data = json.load(infile)
        for i in data:
            for j in data[i]:
                if j['Program-Name'] == prgname:
                    dbArray = j['Databases-used']

    return dbArray

def ShowAllDefinitions(dbArray):
    cnt = 0
    for db in dbArray:
        cnt += 1
        dbDefs = GetDatabaseDefinition(db)
        
        print(' ')
        print("Database " + str(cnt) + ": " + db)
        if len(dbDefs) <= 0:
            print('ERROR:, Def file not found in, DBC-DEFINITION-FILES.JSON')
        else:
            print('Def File:    ' + dbDefs['Def-File-Name'])
            print('Field Cnt:   ' + dbDefs['Def-Field_Count'])
            print('Fields:')
            fCnt = 0
            print("#,\tName, \t\tType, \tSize, \tDescription")
            for field in dbDefs['Def-Field']:
                fCnt += 1
                fullName = str(field['Full-Name']).lower().replace(" ", "_")    #lower case & remove blanks
                fullName = re.sub('^[0-9]\.[0-9][A-Za-z]_','',fullName)         #remove prepended version numbers
                print(str(fCnt) + ":\t," + 
                field['Field-Name'] + "\t," + 
                field['Field-Type'] + "\t," +
                field['Field-Size'] + "\t," +
                fullName
                )


def GetDatabaseDefinition(db):
    dbName = db + '.TXT'
    db1Name = db + '1.TXT'
    dbInfo = {}
    with open(FILE_DB_DEFINITIONS, 'r') as infile:
        data = json.load(infile)
        for i in data:
           for j in data[i]:
               keys = j.keys()          #parse json keys
               key1 = list(keys)[0]     #get first key in dictionary as a list
               if key1 == 'DB-Name':
                   if j['DB-Name'] == dbName or j['DB-Name'] == db1Name:
                       dbInfo = j

    return dbInfo
#..............................................................................
# Script Start
#..............................................................................

try:
    programName = sys.argv[1]       #get passed in program name
except IndexError:
    print('No program name passed in.')
    print('Format: get_db_info.py programName')
    quit()    


print('ProgramName: ' + programName)
dbs = GetProgramUsedDatabases(programName)  #get databases used in program
print('Databases Found: ', len(dbs))
ShowAllDefinitions(dbs)
