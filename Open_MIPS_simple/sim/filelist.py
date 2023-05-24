#! /usr/bin/env python

import os

pathsearch = ["./../rtl/","./../tb/"];
print("Searching in:" , pathsearch)
res = []
filelist = []
for path in pathsearch:
    list = os.listdir(path)
    for filename in list:
        filelist.append(path+filename)

file = open('file.list','w')

for files in filelist:
    print(files)
    file.write(files+"\n")
file.close()

print("file.list is written done, total number of files is %d" %(len(filelist)))