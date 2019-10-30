#!/usr/bin/env python2.6
#Zips up my personal scripts as listed in the Notepad++ workspace file.

import xml.etree.ElementTree as ET
import json
import zipfile
import shutil
import os


zf = zipfile.ZipFile("MyScripts.zip","w")
root = ET.parse('/dbc/work/PMS_DGG.workspace').getroot()


tagName = ''
for i in root.getiterator():
    tag = i.tag
    name = i.attrib.get('name',None)    #attribute name
    if(tag == 'Project'):
        tagName = i.attrib.get('name',None)
    if(tagName == 'MyScripts' and name != 'MyScripts'):
        print(name[3:])             #print all but first 3 chars
        file_to_copy = '/home/dgdev/' + name[3:]
        dst = '/home/dgdev/scriptRepo/' + name[3:]
        shutil.copyfile(file_to_copy, dst)
        zf.write(name[3:])          #zip them up

zf.close()

