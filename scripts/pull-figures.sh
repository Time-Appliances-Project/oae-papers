#!/bin/bash

# Flexible Figure Organizer Script
# This script finds all figure references and copies them to local figures folders
# Works with any directory structure, not just chapters/

# Set the main FIGURES directory path (can be overridden)
DEFAULT_FIGURES_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/FIGURES"
FIGURES_DIR="${FIGURES_DIR:-$DEFAULT_FIGURES_DIR}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}LaTeX Figure Organizer (Flexible)${NC}"
echo "========================================"

# Function to extract figure names from various LaTeX commands and includegraphics
extract_figures() {
    local file="$1"
    local base_dir="$2"
    
    # Extract from \marginfig commands - second parameter (mandatory)
    grep '\\marginfig' "$file" 2>/dev/null | sed 's/.*{\([^}]*\)}.*/\1/' | head -1 2>/dev/null
    
    # Extract from \fig commands - second parameter (mandatory)  
    grep '\\fig' "$file" 2>/dev/null | sed 's/.*{\([^}]*\)}.*/\1/' | head -1 2>/dev/null
    
    # Extract from \includegraphics commands - handle various path patterns
    grep '\\includegraphics' "$file" 2>/dev/null | sed 's/.*{\([^}]*\)}.*/\1/' | while read -r path; do
        # Skip empty lines and comments
        if [ -z "$path" ]; then
            continue
        fi
        
        # Determine the actual figure path and desired local name
        case "$path" in
            "FIGURES/"*)
                # Direct FIGURES/ reference
                echo "${path#FIGURES/}"
                ;;
            "./figures/"*)
                # Local figures reference - extract just the filename
                echo "${path#./figures/}"
                ;;
            "../figures/"* | "../../figures/"*)
                # Relative figures reference - extract just the filename
                basename "$path"
                ;;
            ".././figures/"*)
                # Weird relative path - extract just the filename
                basename "$path"
                ;;
            "example-image-"*)
                # Skip example images - these are LaTeX built-ins
                ;;
            *)
                # Any other path - try to extract just the filename
                basename "$path"
                ;;
        esac
    done
}

# Function to find source file for a figure
find_source_figure() {
    local figure_name="$1"
    local target_dir="$2"
    
    # Try different locations in order of preference
    local search_paths=(
        "$FIGURES_DIR"
        "$(dirname "$target_dir")/figures"  # sibling directory figures
        "$target_dir/../FIGURES"            # relative to target
        "./FIGURES"                         # project root FIGURES
        "../FIGURES"                        # parent directory FIGURES
        "../../FIGURES"                     # grandparent directory FIGURES
        "."                                 # current directory
    )
    
    for search_path in "${search_paths[@]}"; do
        if [ -f "$search_path/$figure_name" ]; then
            echo "$search_path/$figure_name"
            return 0
        fi
        
        # If no extension, try common ones
        if [[ ! "$figure_name" =~ \.[a-zA-Z]+$ ]]; then
            for ext in pdf png jpg jpeg eps svg; do
                if [ -f "$search_path/$figure_name.$ext" ]; then
                    echo "$search_path/$figure_name.$ext"
                    return 0
                fi
            done
        fi
    done
    
    return 1
}

# Function to check if directory contains LaTeX files
has_tex_files() {
    local dir="$1"
    [ -n "$(find "$dir" -maxdepth 1 -name "*.tex" -print -quit 2>/dev/null)" ]
}

# Function to process a directory
process_directory() {
    local target_dir="$1"
    local dir_name=$(basename "$target_dir")
    
    echo -e "\n${YELLOW}Processing directory: $dir_name${NC}"
    echo "  Path: $target_dir"
    
    # Check if directory contains .tex files
    if ! has_tex_files "$target_dir"; then
        echo -e "  ${BLUE}No .tex files found, skipping${NC}"
        return
    fi
    
    # Create figures directory if it doesn't exist
    local figures_dest="$target_dir/figures"
    mkdir -p "$figures_dest"
    
    # Track figures found and copied
    local figures_found=0
    local figures_copied=0
    local figures_missing=0
    local figures_skipped=0
    
    # Keep track of unique figures to avoid duplicates
    local seen_figures_file=$(mktemp)
    trap "rm -f $seen_figures_file" EXIT
    
    # Find all .tex files in the directory (including subdirectories)
    while IFS= read -r -d '' tex_file; do
        echo "  Scanning: ${tex_file#$target_dir/}"
        
        # Extract figure references from this file
        while IFS= read -r figure_ref; do
            if [ -n "$figure_ref" ] && ! grep -q "^$figure_ref$" "$seen_figures_file" 2>/dev/null; then
                echo "$figure_ref" >> "$seen_figures_file"
                figures_found=$((figures_found + 1))
                
                # Skip example images
                if [[ "$figure_ref" =~ ^example-image- ]]; then
                    echo -e "    ${BLUE}↷${NC} Skipping example image: $figure_ref"
                    figures_skipped=$((figures_skipped + 1))
                    continue
                fi
                
                # Find the source file
                source_file=$(find_source_figure "$figure_ref" "$target_dir")
                
                if [ $? -eq 0 ] && [ -n "$source_file" ]; then
                    figure_name=$(basename "$source_file")
                    
                    # Copy if not already present or if source is newer
                    if [ ! -f "$figures_dest/$figure_name" ] || [ "$source_file" -nt "$figures_dest/$figure_name" ]; then
                        cp "$source_file" "$figures_dest/"
                        echo -e "    ${GREEN}✓${NC} Copied: $figure_name (from $(dirname "$source_file"))"
                        figures_copied=$((figures_copied + 1))
                    else
                        echo -e "    ${BLUE}≡${NC} Up to date: $figure_name"
                    fi
                else
                    echo -e "    ${RED}✗${NC} Missing: $figure_ref"
                    figures_missing=$((figures_missing + 1))
                fi
            fi
        done < <(extract_figures "$tex_file" "$target_dir")
        
    done < <(find "$target_dir" -name "*.tex" -print0)
    
    echo -e "  ${GREEN}Summary:${NC} $figures_found found, $figures_copied copied, $figures_missing missing, $figures_skipped skipped"
    
    # Show potentially unused figures in local directory
    if [ -d "$figures_dest" ] && [ "$(ls -A "$figures_dest" 2>/dev/null)" ]; then
        # echo "  Checking for unused figures in local directory..."
        # local unused_count=0
        # for fig in "$figures_dest"/*; do
        #     if [ -f "$fig" ]; then
        #         fig_name=$(basename "$fig")
        #         # Remove extension for search
        #         fig_base="${fig_name%.*}"
                
        #         # Search for any reference to this figure (with various path patterns)
        #         if ! grep -r "\(\\\\marginfig\|\\\\fig\|\\\\includegraphics\).*{\([^}]*\)\?$fig_base\|\(\\\\marginfig\|\\\\fig\|\\\\includegraphics\).*{\([^}]*\)\?$fig_name" "$target_dir"/ >/dev/null 2>&1; then
        #             echo -e "    ${YELLOW}? Potentially unused: $fig_name${NC}"
        #             unused_count=$((unused_count + 1))
        #             # Uncomment the next line to actually remove unused figures
        #             # rm "$fig" && echo -e "    ${RED}Removed unused: $fig_name${NC}"
        #         fi
        #     fi
        # done
        # if [ $unused_count -eq 0 ]; then
        #     echo -e "    ${GREEN}No unused figures found${NC}"
        # fi
        echo "  Skipped unused figure check (disabled for speed)"

    fi
}

# Function to show what figures would be found (dry run)
dry_run() {
    echo -e "${YELLOW}DRY RUN - Showing what figures would be processed:${NC}\n"
    
    if [ "$#" -eq 0 ]; then
        # Process current directory or auto-detect
        if has_tex_files "."; then
            dry_run_directory "."
        else
            # Look for subdirectories with .tex files
            for subdir in */; do
                if [ -d "$subdir" ] && has_tex_files "$subdir"; then
                    dry_run_directory "$subdir"
                fi
            done
        fi
    else
        # Process specific directories
        for dir_path in "$@"; do
            if [ -d "$dir_path" ]; then
                dry_run_directory "$dir_path"
            fi
        done
    fi
}

dry_run_directory() {
    local target_dir="$1"
    local dir_name=$(basename "$target_dir")
    
    echo -e "${BLUE}Directory: $dir_name${NC} (${target_dir})"
    
    if ! has_tex_files "$target_dir"; then
        echo "  No .tex files found"
        echo
        return
    fi
    
    local seen_figures_file=$(mktemp)
    
    while IFS= read -r -d '' tex_file; do
        while IFS= read -r figure_ref; do
            if [ -n "$figure_ref" ] && ! grep -q "^$figure_ref$" "$seen_figures_file" 2>/dev/null; then
                echo "$figure_ref" >> "$seen_figures_file"
                
                if [[ "$figure_ref" =~ ^example-image- ]]; then
                    echo "  ${figure_ref} (example image - would skip)"
                else
                    source_file=$(find_source_figure "$figure_ref" "$target_dir")
                    if [ $? -eq 0 ] && [ -n "$source_file" ]; then
                        echo "  ${figure_ref} → $(basename "$source_file") (from $(dirname "$source_file"))"
                    else
                        echo "  ${figure_ref} (MISSING)"
                    fi
                fi
            fi
        done < <(extract_figures "$tex_file" "$target_dir")
    done < <(find "$target_dir" -name "*.tex" -print0)
    
    rm -f "$seen_figures_file"
    echo
}

# Parse command line arguments
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run|-d)
            DRY_RUN=true
            shift
            ;;
        --figures-dir|-f)
            FIGURES_DIR="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS] [DIRECTORY_PATHS...]"
            echo ""
            echo "Options:"
            echo "  --dry-run, -d           Show what would be processed without making changes"
            echo "  --figures-dir, -f DIR   Set the source figures directory (default: $DEFAULT_FIGURES_DIR)"
            echo "  --help, -h              Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                                    # Process current directory or auto-detect subdirectories"
            echo "  $0 chapter1 chapter2                 # Process specific directories"
            echo "  $0 /path/to/latex/project            # Process absolute path"
            echo "  $0 --dry-run                         # Preview what would be processed"
            echo "  $0 -f ~/Library/Mobile\\ Documents/com~apple~CloudDocs/FIGURES .             # Use iCloud figures directory"
            echo ""
            echo "Environment Variables:"
            echo "  FIGURES_DIR             Override default figures directory"
            echo "                          Default: ~/Library/Mobile Documents/com~apple~CloudDocs/FIGURES"
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

# Check if FIGURES directory exists
if [ ! -d "$FIGURES_DIR" ]; then
    echo -e "${YELLOW}Warning: FIGURES directory not found at $FIGURES_DIR${NC}"
    echo "Will search for figures in relative locations"
fi

# Show dry run if requested
if [ "$DRY_RUN" = true ]; then
    dry_run "$@"
    exit 0
fi

# Main execution
if [ "$#" -eq 0 ]; then
    # Auto-detect: process current directory if it has .tex files, otherwise process subdirectories
    if has_tex_files "."; then
        echo "Processing current directory (contains .tex files)"
        process_directory "."
    else
        echo "Auto-detecting directories with .tex files..."
        processed_any=false
        
        for subdir in */; do
            if [ -d "$subdir" ] && has_tex_files "$subdir"; then
                process_directory "$subdir"
                processed_any=true
            fi
        done
        
        if [ "$processed_any" = false ]; then
            echo -e "${YELLOW}No directories with .tex files found${NC}"
            echo "Try specifying directories explicitly or check your location"
            exit 1
        fi
    fi
else
    # Process specific directories
    for dir_path in "$@"; do
        if [ -d "$dir_path" ]; then
            process_directory "$dir_path"
        else
            echo -e "${RED}Error: Directory not found: $dir_path${NC}"
        fi
    done
fi

echo -e "\n${GREEN}Figure organization complete!${NC}"
echo -e "${BLUE}Note:${NC} Update your \\graphicspath to include local figures directories"
echo -e "       Example: \\graphicspath{{./figures/}{./images/}{../FIGURES/}}"