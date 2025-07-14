#!/bin/bash

# Script to remove bibliography commands from all .tex files
# This removes \bibliographystyle and \bibliography lines from chapter and section files

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Bibliography Command Removal Script${NC}"
echo "============================================"

# Function to process a single file
process_file() {
    local file="$1"
    local backup_file="${file}.backup-$(date +%Y%m%d-%H%M%S)"
    
    echo "  Processing: $file"
    
    # Check if file contains bibliography commands
    if grep -q "\\\\bibliographystyle\|\\\\bibliography{" "$file"; then
        # Create backup
        cp "$file" "$backup_file"
        echo "    Backup created: $backup_file"
        
        # Count lines that will be removed
        local lines_to_remove=$(grep -c "\\\\bibliographystyle\|\\\\bibliography{" "$file")
        
        # Remove the bibliography commands
        # This removes lines containing \bibliographystyle or \bibliography{
        sed -i.tmp -E '/\\bibliographystyle|\\bibliography\{/d' "$file"
        rm -f "${file}.tmp"
        
        echo -e "    ${GREEN}✓${NC} Removed $lines_to_remove bibliography command(s)"
        return 1  # Return 1 to indicate changes were made
    else
        echo -e "    ${YELLOW}No bibliography commands found${NC}"
        return 0  # Return 0 to indicate no changes
    fi
}

# Function to show what would be removed (dry run)
dry_run() {
    echo -e "${YELLOW}DRY RUN - Showing what would be removed:${NC}\n"
    
    local total_files=0
    local files_with_bib=0
    
    # Find all .tex files
    while IFS= read -r -d '' tex_file; do
        total_files=$((total_files + 1))
        
        # Check for bibliography commands
        local matches=$(grep -n "\\\\bibliographystyle\|\\\\bibliography{" "$tex_file" 2>/dev/null || true)
        if [ -n "$matches" ]; then
            files_with_bib=$((files_with_bib + 1))
            echo -e "${BLUE}File: $tex_file${NC}"
            echo "$matches" | while read -r match; do
                echo "  $match"
            done
            echo
        fi
    done < <(find . -name "*.tex" -not -path "./OAE-SPEC-MAIN.tex" -print0)
    
    echo -e "${GREEN}Summary:${NC} Found bibliography commands in $files_with_bib out of $total_files .tex files"
}

# Function to process all files
process_all_files() {
    local total_files=0
    local files_modified=0
    local total_lines_removed=0
    
    echo "Processing all .tex files (excluding main document)..."
    echo
    
    # Find all .tex files except the main document
    while IFS= read -r -d '' tex_file; do
        total_files=$((total_files + 1))
        
        # Process the file
        process_file "$tex_file"
        if [ $? -eq 1 ]; then
            files_modified=$((files_modified + 1))
        fi
        
    done < <(find . -name "*.tex" -not -path "./OAE-SPEC-MAIN.tex" -print0)
    
    echo
    echo -e "${GREEN}Processing complete!${NC}"
    echo -e "${GREEN}Summary:${NC} Modified $files_modified out of $total_files .tex files"
}

# Function to process specific files or directories
process_specific() {
    local targets=("$@")
    local total_files=0
    local files_modified=0
    
    for target in "${targets[@]}"; do
        if [ -f "$target" ] && [[ "$target" == *.tex ]]; then
            # Single file
            total_files=$((total_files + 1))
            process_file "$target"
            if [ $? -eq 1 ]; then
                files_modified=$((files_modified + 1))
            fi
        elif [ -d "$target" ]; then
            # Directory - process all .tex files in it
            echo -e "\n${BLUE}Processing directory: $target${NC}"
            while IFS= read -r -d '' tex_file; do
                total_files=$((total_files + 1))
                process_file "$tex_file"
                if [ $? -eq 1 ]; then
                    files_modified=$((files_modified + 1))
                fi
            done < <(find "$target" -name "*.tex" -print0)
        else
            echo -e "${RED}Error: $target is not a .tex file or directory${NC}"
        fi
    done
    
    echo
    echo -e "${GREEN}Processing complete!${NC}"
    echo -e "${GREEN}Summary:${NC} Modified $files_modified out of $total_files files"
}

# Parse command line arguments
DRY_RUN=false
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run|-d)
            DRY_RUN=true
            shift
            ;;
        --force|-f)
            FORCE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS] [FILES_OR_DIRECTORIES...]"
            echo ""
            echo "Remove \\bibliographystyle and \\bibliography commands from LaTeX files."
            echo ""
            echo "Options:"
            echo "  --dry-run, -d       Show what would be removed without making changes"
            echo "  --force, -f         Skip confirmation prompt"
            echo "  --help, -h          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                                    # Process all .tex files"
            echo "  $0 chapters/01_principles-of-operation/  # Process specific directory"
            echo "  $0 chapter.tex section.tex           # Process specific files"
            echo "  $0 --dry-run                         # Preview changes"
            echo "  $0 --force                           # Process without confirmation"
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

# Show dry run if requested
if [ "$DRY_RUN" = true ]; then
    dry_run
    exit 0
fi

# Confirmation prompt unless --force is used
if [ "$FORCE" = false ]; then
    echo -e "${YELLOW}This will remove \\bibliographystyle and \\bibliography commands from .tex files.${NC}"
    echo -e "${YELLOW}Backup files will be created with timestamps.${NC}"
    echo -e "${YELLOW}The main document (OAE-SPEC-MAIN.tex) will NOT be modified.${NC}"
    echo ""
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        exit 0
    fi
fi

# Main execution
if [ "$#" -eq 0 ]; then
    # Process all files
    process_all_files
else
    # Process specific files/directories
    process_specific "$@"
fi

echo -e "\n${BLUE}Note:${NC} Add the bibliography commands to your main document (OAE-SPEC-MAIN.tex) if not already present:"
echo "\\bibliographystyle{plainnat}"
echo "\\bibliography{MASTER_REFERENCES}"