#!/bin/bash

cd "$(dirname "$0")"  # go to the directory of the script

# File extensions to delete
EXTENSIONS=("*.log" "*.idx" "*.maf" "*.mtc*" "*.out" "*.synctex.gz" "*.toc" "*.aux")

# Loop through each pattern and delete matching files
for pattern in "${EXTENSIONS[@]}"; do
  find . -type f -name "$pattern" -exec rm -v {} +
done
