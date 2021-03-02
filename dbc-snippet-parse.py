import json

filePath = "C:\\Users\\DGarcia\\Documents\\GitHub\\dbc-snippets\\snippets\\snippets.code-snippets"

f = open(filePath, "r")
data = json.loads(f.read())
#with open(filePath) as f:
#  data = json.load(f)

snipArray = []
for desc in data:
  for key in data[desc]:
      snippet = data[desc][key]
      if(key == 'prefix'):
          snipArray.append(snippet[0])
          #print('Snippet: "'+ snippet[0] + '"' + ', Description: ' + desc)
          #print('')

tmpArray = sorted(snipArray)
for i in tmpArray:
  if len(i) > 0:
    print("* <span style='color:#1E90FF;'>" + i + "</span>")
