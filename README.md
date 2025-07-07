# FotoSorter
## Colecction of simple shell script as tools to organize fotos on system directory

First i concept fotosorter.sh as my system, but the problems to show content on folder and subfolders, and 12 folders per year, i decide to organize my order per quarter. 

After a while, i think the names like "20230712_1245.jpg
" are cleaner, but i have a lot of another folder with the - template. Feel you free to change the script as you want.

- filecounter.sh : count the files on a folder and subfolders. Take the folder as parameter
- quartarfolder.sh : make a directory with YYYY-Qn, YYYY+1-Qn+1 and so...
- sort-quartal.sh : take a subject and object as parameters, make directories like quartalfolder.sh, but move the fotos and videos from object with names as YYYY-MM-DD-HH-MM-nnnn.ext
- fotosorter.sh : simple convert a chaos folder with diferents names, formats, stils in so one:

2023
└─ 07
   ├─ 20230712_1245.jpg
   ├─ 20230712_1246.jpg
   └─ 20230712_1250.mov
└─ 07
   ├─ 20230812_1245.jpg

## USE:

run the script so you will with the origin and target(is the origin too) as parameter so:

sh fotosorter ~/myname/mycaoticfotofolder

that it's all, kiss!
