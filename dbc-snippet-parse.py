import json

filePath = "C:\\Users\\DGarcia\\Documents\\GitHub\\dbc-snippets\\snippets\\snippets.code-snippets"

#str = f.read()
with open(filePath) as f:
  data = json.load(f)

for desc in data:
    for key in data[desc]:
        snippet = data[desc][key]
        if(key == 'prefix'):
            print('Snippet: "'+ snippet[0] +'"')
            print('Description: ' + desc)
            print('')

