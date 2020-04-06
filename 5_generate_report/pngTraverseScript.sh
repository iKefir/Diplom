# /usr/bin/bash

if [ "$#" -eq 0 ]; then
  echo >&2 "Missing folder name argument"
  exit 1
fi

DIR=$(dirname $0)

folder_to_traverse=${DIR}/$1

find ${folder_to_traverse} -type f -iname '*.png' -exec cp {} ${folder_to_traverse} \;