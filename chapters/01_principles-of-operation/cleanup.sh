#!/bin/bash

# Ask for confirmation (optional)
# osascript -e 'display dialog "Are you sure you want to clean up LaTeX files?" buttons {"Cancel", "OK"} default button "OK"'

# Change to the directory of the script
cd "$(dirname "$0")"

echo "Cleaning up LaTeX auxiliary files..."

# Recursively find and delete LaTeX-generated files
find . -type f \( \
  -name "*.aux" -o -name "*.bbl" -o -name "*.blg" -o -name "*.fdb_latexmk" -o \
  -name "*.fls" -o -name "*.log" -o -name "*.out" -o -name "*.toc" -o \
  -name "*.lof" -o -name "*.lot" -o -name "*.nlo" -o -name "*.nls" -o \
  -name "*.ilg" -o -name "*.ind" -o -name "*.idx" -o -name "*.synctex.gz" -o \
  -name "*.glg" -o -name "*.glo" -o -name "*.gls" -o -name "*.ist" -o \
  -name "*.bcf" -o -name "*.mw" -o -name "*.run.xml" -o -name "*.xdy" -o \
  -name "*.ent" -o -name "*.loq" \
\) -exec rm -f {} +

echo "Clean-up completed!"
