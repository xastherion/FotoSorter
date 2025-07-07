#!/bin/bash
# Count how many files is on Folder, include subfolders and so on. 
# Usefull to verify if a directory hat the same numbers of fotos of anohter
#
# Try if exist an argument
if [ -z "$1" ]; then
  echo "Uso: $0 /ruta/a/carpeta"
  exit 1
fi

# Contar archivos recursivamente
TOTAL=$(find "$1" -type f | wc -l)

echo "Total de archivos en '$1': $TOTAL"

