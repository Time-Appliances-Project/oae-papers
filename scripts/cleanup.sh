#!/bin/bash

# Debug version of cleanup script
echo "🧹 LaTeX Cleanup Script (Debug Mode)"
echo "===================================="

# Get the script's directory and go to parent
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"
echo "Script directory: $SCRIPT_DIR"
echo "Project root: $PROJECT_ROOT"
echo "Working directory: $(pwd)"

echo "🔍 Scanning for LaTeX auxiliary files..."

# First, let's see what files exist
aux_files=$(find . -type f \( \
  -name "*.aux" -o -name "*.bbl" -o -name "*.blg" -o -name "*.fdb_latexmk" -o \
  -name "*.fls" -o -name "*.log" -o -name "*.out" -o -name "*.toc" -o \
  -name "*.lof" -o -name "*.lot" -o -name "*.nlo" -o -name "*.nls" -o \
  -name "*.ilg" -o -name "*.ind" -o -name "*.idx" -o -name "*.synctex.gz" -o \
  -name "*.glg" -o -name "*.glo" -o -name "*.gls" -o -name "*.ist" -o \
  -name "*.bcf" -o -name "*.mw" -o -name "*.run.xml" -o -name "*.xdy" -o \
  -name "*.ent" -o -name "*.loq" -o -name "*acr" -o -name "*.mtc*" -o \
  -name "*synctex(busy)" -o -name "*.maf" \
\))

if [ -z "$aux_files" ]; then
    echo "✅ No auxiliary files found to clean"
else
    echo "📁 Found auxiliary files:"
    echo "$aux_files" | while read -r file; do
        echo "  - $file"
    done
    
    echo ""
    echo "🗑️  Removing files..."
    
    # Actually delete them
    find . -type f \( \
      -name "*.aux" -o -name "*.bbl" -o -name "*.blg" -o -name "*.fdb_latexmk" -o \
      -name "*.fls" -o -name "*.log" -o -name "*.out" -o -name "*.toc" -o \
      -name "*.lof" -o -name "*.lot" -o -name "*.nlo" -o -name "*.nls" -o \
      -name "*.ilg" -o -name "*.ind" -o -name "*.idx" -o -name "*.synctex.gz" -o \
      -name "*.glg" -o -name "*.glo" -o -name "*.gls" -o -name "*.ist" -o \
      -name "*.bcf" -o -name "*.mw" -o -name "*.run.xml" -o -name "*.xdy" -o \
      -name "*.ent" -o -name "*.loq" -o -name "*acr" -o -name "*.mtc*" -o \
      -name "*synctex(busy)" -o -name "*.maf" \
    \) -exec rm -fv {} +
    
    echo "✅ Cleanup completed!"
fi

echo ""
echo "📊 Current directory contents:"
ls -la