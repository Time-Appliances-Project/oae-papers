#!/bin/bash

echo "Checking missing files..."

FIGURES_DIR="../../FIGURES"

# List of missing files from the dry run
missing_files=(
    "Ternary Logic"
    "linear-reversible.pdf"
    "mars-network.pdf"
    "placeholder.pdf"
    "link-fabrics-topology.pdf"
    "header-vs-block.pdf"
)

echo "=== Checking FIGURES directory ==="
if [ -d "$FIGURES_DIR" ]; then
    echo "FIGURES directory exists at: $FIGURES_DIR"
    echo "Total files: $(find "$FIGURES_DIR" -name "*.pdf" -o -name "*.png" -o -name "*.jpg" | wc -l)"
    echo
else
    echo "FIGURES directory NOT FOUND at: $FIGURES_DIR"
    # Try other common locations
    for alt_path in "./FIGURES" "../FIGURES" "./figures" "../figures"; do
        if [ -d "$alt_path" ]; then
            echo "Found alternative FIGURES at: $alt_path"
            FIGURES_DIR="$alt_path"
            break
        fi
    done
fi

echo "=== Checking each missing file ==="
for file in "${missing_files[@]}"; do
    echo "Checking: $file"
    
    if [ "$file" = "Ternary Logic" ]; then
        # Special case - no extension
        echo "  Looking for files with 'ternary' or 'logic' in name:"
        find "$FIGURES_DIR" -iname "*ternary*" -o -iname "*logic*" 2>/dev/null || echo "  None found"
    else
        # Check exact match
        if [ -f "$FIGURES_DIR/$file" ]; then
            echo "  ✓ Found: $FIGURES_DIR/$file"
        else
            echo "  ✗ Not found: $FIGURES_DIR/$file"
            
            # Try to find similar files
            basename_no_ext="${file%.*}"
            echo "  Looking for similar files:"
            find "$FIGURES_DIR" -iname "*$basename_no_ext*" 2>/dev/null | head -3 || echo "    None found"
        fi
    fi
    echo
done

echo "=== Sample of files in FIGURES directory ==="
if [ -d "$FIGURES_DIR" ]; then
    find "$FIGURES_DIR" -name "*.pdf" -o -name "*.png" | head -10
    echo "..."
    echo "(showing first 10 files)"
else
    echo "FIGURES directory not accessible"
fi