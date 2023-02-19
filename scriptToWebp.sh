#!/bin/bash

if [ $# -ne 1 ]
  then
    echo "Usage: $0 folder_path [-o | --overwrite] [-c | --copy]"
    echo "-o, --overwrite: Sobrescribe las imágenes originales con las imágenes webp."
    echo "-c, --copy: Copia las imágenes originales a una carpeta de respaldo y guarda las imágenes webp en una carpeta webp dentro del directorio original."
    exit 1
fi

folder_path=$1
overwrite=false
copy=false

# Lee los parametros
while [ "$#" -gt 0 ]
do
  case "$1" in
    -o|--overwrite) overwrite=true ;;
    -c|--copy) copy=true ;;
    esac
  shift
done

if [ "$overwrite" = true ] && [ "$copy" = true ]
then
  echo "Cannot use both --overwrite and --copy options at the same time."
  exit 1
fi

# Función para convertir imágenes a formato webp
function convert_to_webp {
  file=$1
  directory=$(dirname "$file")
  filename=$(basename "$file")
  
  if [ "$overwrite" = true ]
  then
    cwebp -q 90 "$file" -o "$file"
  elif [ "$copy" = true ]
  then
    mkdir -p "$directory/backup"
    cp "$file" "$directory/backup/$filename"
    cwebp -q 90 "$file" -o "$directory/webp/${filename%.*}.webp"
  else
    mkdir -p "$directory/webp"
    cwebp -q 90 "$file" -o "$directory/webp/${filename%.*}.webp"
  fi
}

# Busca todas las imágenes y llama a la función de conversión
find "$folder_path" -type f -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" | while read file; do
  convert_to_webp "$file"
done
