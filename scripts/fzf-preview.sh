#!/usr/bin/env bash

# Si no hay argumento, salir
if [ -z "$1" ]; then
    exit 0
fi

FILEPATH="$1"

# Obtener dimensiones pasadas por fzf
COLS="${FZF_PREVIEW_COLUMNS:-80}"
LINES="${FZF_PREVIEW_LINES:-24}"

# Si el archivo no existe, salir
if [ ! -e "$FILEPATH" ]; then
    echo "El archivo no existe."
    exit 0
fi

# Detectar tipo de archivo
MIMETYPE=$(file --mime-type -b "$FILEPATH")

case "$MIMETYPE" in
    image/*)
        # Es una imagen. Usamos chafa para renderizarla dentro de fzf ajustada al espacio
        chafa --size="${COLS}x${LINES}" "$FILEPATH"
        ;;
    inode/directory)
        # Es un directorio. Usamos eza para listarlo
        eza -la --color=always --icons=always --group-directories-first "$FILEPATH"
        ;;
    *)
        # Es texto, código o binario
        if grep -qE "text|json|xml|javascript|shell|yaml" <<< "$MIMETYPE"; then
            # Es texto. Usamos batcat para mostrarlo con colores
            batcat --style=numbers --color=always --line-range :500 "$FILEPATH"
        else
            # Intentar abrir con batcat por si acaso, si no muestra tipo de archivo binario
            if head -c 1024 "$FILEPATH" | grep -q "^[[:print:][:space:]]*$"; then
                batcat --style=numbers --color=always --line-range :500 "$FILEPATH"
            else
                echo "--- ARCHIVO BINARIO ---"
                file -b "$FILEPATH"
                echo "-----------------------"
                echo "Mime-type: $MIMETYPE"
            fi
        fi
        ;;
esac
