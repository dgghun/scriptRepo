import json
import sys



# print('Number of arguments:', len(sys.argv), 'arguments.')
# print('Argument List:' + str(sys.argv))

#..............................................................................
# FUNCTIONS
#..............................................................................
#Returns an array of all databases used in the program name passed in
def GetProgramUsedDatabases(prgname):
    dbArray = []
    with open('DBC-PROGRAM-USED.JSON', 'r') as infile:
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
                print(str(fCnt) + ":\t," + 
                field['Field-Name'] + "\t," + 
                field['Field-Type'] + "\t," +
                field['Field-Size'] + "\t," +
                str(field['Full-Name']).lower().replace(" ", "_")
                )


def GetDatabaseDefinition(db):
    dbName = db + '.TXT'
    db1Name = db + '1.TXT'
    dbInfo = {}
    with open('DBC-DEFINITION-FILES.JSON', 'r') as infile:
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

programName = sys.argv[1]       #get passed in program name
cdb = '1'                       

print('ProgramName: ' + programName)
dbs = GetProgramUsedDatabases(programName)  #get databases used in program
print('Databases Found: ', len(dbs))
ShowAllDefinitions(dbs)
