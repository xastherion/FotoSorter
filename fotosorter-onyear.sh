#!/bin/bash

if [ -z "$1" ] || [ ! -d "$1" ]; then
    echo "Uso: $0 carpeta_origen"
    exit 1
fi

ORIGEN="$1"
cd "$ORIGEN" || exit 1

extensiones_validas=("jpg" "jpeg" "png" "gif" "heic" "bmp" "tiff" "webp" "mp4" "mov" "avi" "mkv" "3gp" "m4v")
declare -A fechas_archivo

# Preparar fechas y verificar que todas sean del mismo año
anio_unico=""

for archivo in *; do
    [ -f "$archivo" ] || continue

    nombre="${archivo%.*}"
    extension="${archivo##*.}"
    extension_min=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

    if [ "$extension" != "$extension_min" ]; then
        nuevo="${nombre}.${extension_min}"
        mv -n "$archivo" "$nuevo"
        archivo="$nuevo"
        extension="$extension_min"
    fi

    if [[ ! " ${extensiones_validas[*]} " =~ " $extension_min " ]]; then
        continue
    fi

    fecha_epoch=$(stat -f "%B" "$archivo")
    [ "$fecha_epoch" -gt 0 ] || continue

    fecha_completa=$(date -r "$fecha_epoch" "+%Y%m%d_%H%M")
    anio=${fecha_completa:0:4}
    mes=${fecha_completa:4:2}

    if [ -z "$anio_unico" ]; then
        anio_unico="$anio"
    elif [ "$anio_unico" != "$anio" ]; then
        echo "Error: Hay archivos de diferentes años. Este script solo funciona con un solo año."
        exit 1
    fi

    fechas_archivo["$archivo"]="$fecha_completa|$mes|$extension_min"
done

# Mover y renombrar
for archivo in "${!fechas_archivo[@]}"; do
    IFS="|" read -r fecha mes ext <<< "${fechas_archivo[$archivo]}"
    destino="${ORIGEN}/${mes}"
    mkdir -p "$destino"

    base="${fecha}.${ext}"
    contador=1
    nombre_final="$base"
    while [ -e "$destino/$nombre_final" ]; do
        nombre_final="${fecha}_$contador.${ext}"
        ((contador++))
    done

    mv -n "$archivo" "$destino/$nombre_final"
done

