#!/bin/bash

# Verificar carpeta de origen
if [ -z "$1" ] || [ ! -d "$1" ]; then
    echo "Uso: $0 carpeta_origen"
    exit 1
fi

ORIGEN="$1"
cd "$ORIGEN" || exit 1

# Extensiones válidas
extensiones_validas=("jpg" "jpeg" "png" "gif" "heic" "bmp" "tiff" "webp" "mp4" "mov" "avi" "mkv" "3gp" "m4v")

# Procesar cada archivo
for archivo in *; do
    [ -f "$archivo" ] || continue

    nombre="${archivo%.*}"
    extension="${archivo##*.}"
    extension_min=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

    # Renombrar a extensión en minúsculas si es necesario
    if [ "$extension" != "$extension_min" ]; then
        nuevo="${nombre}.${extension_min}"
        mv -n "$archivo" "$nuevo"
        archivo="$nuevo"
        extension="$extension_min"
    fi

    # Validar extensión
    if [[ ! " ${extensiones_validas[*]} " =~ " $extension " ]]; then
        continue
    fi

    # Obtener fecha de creación en segundos desde epoch
    fecha_epoch=$(stat -f "%B" "$archivo")
    if [ "$fecha_epoch" -le 0 ]; then
        echo "No se pudo obtener la fecha de creación de $archivo"
        continue
    fi

    # Convertir a formato AAAAMMDD_HHMM
    fecha_completa=$(date -r "$fecha_epoch" "+%Y%m%d_%H%M")
    anio=${fecha_completa:0:4}
    mes=${fecha_completa:4:2}

    # Crear carpeta destino
    destino="${ORIGEN}/${anio}/${mes}"
    mkdir -p "$destino"

    # Generar nombre único
    base="${fecha_completa}.${extension}"
    contador=1
    nombre_final="$base"
    while [ -e "$destino/$nombre_final" ]; do
        nombre_final="${fecha_completa}_$contador.${extension}"
        ((contador++))
    done

    # Mover y renombrar
    mv -n "$archivo" "$destino/$nombre_final"
done

