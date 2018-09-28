#!/bin/bash
# A zip script that uses an .archiveignore file to not process
# certain files
#
# Example usage:
#   ./tools/archive.sh archive.zip *

if [ "$#" -lt 2 ]; then
    echo "Expected usage: ./tools/archive.sh <archive-name.zip> <file-filter>"
    echo "  or"
    echo "Expected usage: ./tools/archive.sh <archive-name.zip> <directory> <file-filter>"
    exit 1
fi

if [ "$#" -eq 2 ]; then
    directory="."
    filter="$2"
    archiveignore="./.archiveignore"
elif [ "$#" -eq 3 ]; then
    directory="$2"
    filter="$3"
    archiveignore="$directory/.archiveignore"
fi


find $directory -type f -iname "$filter" -print0 | while IFS= read -r -d $'\0' line; do
    echo "$line" | grep -f $archiveignore
    if [ $? -ne 0 ]; then
        echo "✓  $line"
        zip $1 "$line"
    else
        echo "×  $line is blocked"
    fi
done