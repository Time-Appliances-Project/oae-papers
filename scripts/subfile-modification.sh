#!/bin/bash

# Script to add subfiles document structure to all .tex files in section/ directories

# Header to add
HEADER="\\documentclass[../../../OAE-SPEC-MAIN.tex]{subfiles}
\\begin{document}"

# Footer to add
FOOTER="\\end{document}"

# First, show what will be modified
echo "=== PREVIEW: Files that will be modified ==="
file_count=0
find . -type d -name "section" | while read -r section_dir; do
    find "$section_dir" -name "*.tex" -type f | while read -r tex_file; do
        if ! grep -q "\\documentclass" "$tex_file"; then
            echo "  $tex_file"
            ((file_count++))
        fi
    done
done

echo ""
echo "=== CONFIRMATION ==="
read -p "Do you want to proceed with modifying these files? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

echo ""
echo "Proceeding with modifications..."
echo ""

# Find all directories named 'section'
find . -type d -name "section" | while read -r section_dir; do
    echo "Processing directory: $section_dir"
    
    # Find all .tex files in this section directory
    find "$section_dir" -name "*.tex" -type f | while read -r tex_file; do
        echo "  Processing file: $tex_file"
        
        # Create a temporary file
        temp_file=$(mktemp)
        
        # Check if file already has \documentclass (to avoid duplicates)
        if grep -q "\\documentclass" "$tex_file"; then
            echo "    File already has \\documentclass, skipping: $tex_file"
        else
            # Add header, original content, then footer
            {
                echo "$HEADER"
                echo ""
                cat "$tex_file"
                echo ""
                echo "$FOOTER"
            } > "$temp_file"
            
            # Replace original file with modified version
            mv "$temp_file" "$tex_file"
            echo "    ✓ Added subfiles structure to: $tex_file"
        fi
    done
done

echo "Done! All .tex files in section/ directories have been processed