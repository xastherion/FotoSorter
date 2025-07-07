#!/bin/bash

# Comprobación de argumentos
if [[ $# -ne 2 ]]; then
  echo "Uso: $0 /ruta/origen /ruta/destino"
  exit 1
fi

ORIGEN="$1"
DESTINO="$2"

# Lista de extensiones válidas (ampliada)
EXTENSIONES=(
  jpg jpeg png gif bmp tiff heic
  mp4 mov avi mkv m4v webm 3gp
  mts m2ts mod
)

# Crea una expresión regex para extensiones
EXT_REGEX="\.($(IFS="|"; echo "${EXTENSIONES[*]}"))$"

# Recorre archivos (sin ocultos)
find "$ORIGEN" -type f ! -path '*/.*' | while read -r archivo; do
  # Ignora archivos ocultos y no válidos
  nombre_archivo="$(basename "$archivo")"
  if [[ "$nombre_archivo" == .* ]]; then
    continue
  fi

  extension="${archivo##*.}"
  #extension_lower="${extension,,}"
  extension_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

  if [[ ! " ${EXTENSIONES[*]} " =~ " ${extension_lower} " ]]; then
    continue
  fi

  # Obtener fecha de creación
  fecha=$(mdls -name kMDItemContentCreationDate -raw "$archivo" 2>/dev/null)
  if [[ -z "$fecha" || "$fecha" == "(null)" ]]; then
    echo "Sin fecha válida: $archivo"
    continue
  fi

  # Parseo de fecha
  anio=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$fecha" "+%Y")
  mes=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$fecha" "+%m")
  dia=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$fecha" "+%d")
  hora=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$fecha" "+%H")
  minuto=$(date -j -f "%Y-%m-%d %H:%M:%S %z" "$fecha" "+%M")

  # Determinar cuartal
  case $mes in
    01|02|03) quartal="Q1" ;;
    04|05|06) quartal="Q2" ;;
    07|08|09) quartal="Q3" ;;
    10|11|12) quartal="Q4" ;;
  esac

  carpeta_destino="$DESTINO/${anio}-${quartal}"
  mkdir -p "$carpeta_destino"

  # Renombrar con contador de 0000 a 9999
  for i in $(seq -w 0000 9999); do
    nuevo_nombre="${anio}-${mes}-${dia}-${hora}-${minuto}-${i}.${extension_lower}"
    ruta_destino="$carpeta_destino/$nuevo_nombre"
    if [[ ! -e "$ruta_destino" ]]; then
      mv "$archivo" "$ruta_destino"
      break
    fi
  done

  # Si no se pudo mover
  if [[ $i == "9999" && -e "$ruta_destino" ]]; then
    echo "Duplicado no movido: $archivo" >> "$carpeta_destino/sort-results.txt"
  fi
done

