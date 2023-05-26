#! /usr/bin/env python

import os

pathsearch = ["./../rtl/","./../tb/"];
print("Searching in:" , pathsearch)
res = []
filelist = []
defi_index=0
for path in pathsearch:
    list = os.listdir(path)
    for filename in list:
        if filename == 'definitions.v':
            defi_index = len(filelist)
        filelist.append(path+filename)


temp = filelist[defi_index]
del filelist[defi_index]
filelist.insert(0,temp)

file = open('file.list','w')

for files in filelist:
    print(files)
    file.write(files+"\n")
file.close()

print("file.list is written done, total number of files is %d" %(len(filelist)))