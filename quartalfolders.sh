#!/bin/bash
#
echo "quartalfolders.sh:"
echo "Erstell ein Verzeichnissystem nach 2020-Q1 Notation"
echo 
echo "ACHTUNG: das Script sollte man von aktive Pfad ausführen, gehe mal zuerst dort mit cd /Ziel/path, ob der Script dort liegt spiel keine Rolle. Wenn du nicht in die richtige Verzeichniss bit, brichtmit ctrl + c ab"

echo "Weiter..."; read weiter

for year in $(seq 2000 2025); do
    for quartal in $(seq 1 4); do
        mkdir -p "${year}-Q${quartal}"
    done
done
