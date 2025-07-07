#!/bin/bash

# Comprobación de argumentos
if [[ $# -ne 2 ]]; then
  echo "Uso: $0 /ruta/origen /ruta/destino"
  exit 1
fi

ORIGEN="$1"
DESTINO="$2"

# Lista de extensiones válidas
EXTENSIONES=(
  jpg jpeg png gif bmp tiff heic
  mp4 mov avi mkv m4v webm 3gp
  mts m2ts mod
)

# Recorre archivos (sin ocultos)
find "$ORIGEN" -type f ! -path '*/.*' | while read -r archivo; do
  nombre_archivo="$(basename "$archivo")"
  extension="${archivo##*.}"
  extension_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

  # Validar extensión
  if [[ ! " ${EXTENSIONES[*]} " =~ " ${extension_lower} " ]]; then
    continue
  fi

  echo "Procesando: $archivo"

  # Obtener fecha de creación
  fecha=$(mdls -name kMDItemContentCreationDate -raw "$archivo" 2>/dev/null)
  if [[ -z "$fecha" || "$fecha" == "(null)" ]]; then
    echo "  ⚠️  Sin fecha válida → moviendo a carpeta ERROR"
    mkdir -p "$DESTINO/ERROR"
    mv "$archivo" "$DESTINO/ERROR/"
    continue
  fi

  # Extraer datos de fecha
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

  # Intentar renombrar sin colisiones
  for i in $(seq -w 0000 9999); do
    nuevo_nombre="${anio}-${mes}-${dia}-${hora}-${minuto}-${i}.${extension_lower}"
    ruta_destino="$carpeta_destino/$nuevo_nombre"
    if [[ ! -e "$ruta_destino" ]]; then
      mv "$archivo" "$ruta_destino"
      echo "  ✅ Movido a $carpeta_destino como $nuevo_nombre"
      break
    fi
  done

  # Si no se pudo mover por duplicados
  if [[ $i == "9999" && -e "$ruta_destino" ]]; then
    echo "  ❌ Duplicado no movido: $archivo"
    echo "Duplicado: $archivo" >> "$carpeta_destino/sort-results.txt"
  fi
done
# Borrar carpetas vacías en el origen
find "$ORIGEN" -type d -empty -not -path "$ORIGEN" -delete
echo "🧹 Carpetas vacías eliminadas en: $ORIGEN"

