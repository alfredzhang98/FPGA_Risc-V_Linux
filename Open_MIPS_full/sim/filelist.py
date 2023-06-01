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
count = 0
for files in filelist:
    print(files)
    file.write(files+"\n")
    files2 = open(files,'r')
    n = len(files2.readlines())
    files2.close()
    count = count + n
file.close()

print("file.list is written done, total number of files is %d" %(len(filelist)))
print("The total lines of RTL code is %d" %(count))


