#!/bin/bash

# LaTeX Code Formatter
# Formats .tex files with consistent indentation and clean code structure

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Settings
INDENT_SIZE=2
BACKUP=true
RECURSIVE=false
VERBOSE=false
DRY_RUN=false

# Function to print colored status messages
print_step() {
    echo -e "${CYAN}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS] [FILE1] [FILE2] ..."
    echo ""
    echo "Options:"
    echo "  -i, --indent SIZE     Set indentation size (default: 2)"
    echo "  -r, --recursive       Process all .tex files in subdirectories"
    echo "  -n, --no-backup       Don't create backup files (.tex.bak)"
    echo "  -d, --dry-run         Show what would be formatted without making changes"
    echo "  -v, --verbose         Show detailed output"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 main.tex                     # Format single file"
    echo "  $0 *.tex                        # Format all .tex files in current dir"
    echo "  $0 --recursive                  # Format all .tex files recursively"
    echo "  $0 --indent 4 --no-backup *.tex # Custom indent, no backups"
    echo "  $0 --dry-run --recursive        # Preview what would be formatted"
}

# Function to create backup
create_backup() {
    local file="$1"
    if [ "$BACKUP" = true ]; then
        cp "$file" "${file}.bak"
        [ "$VERBOSE" = true ] && echo "  Created backup: ${file}.bak"
    fi
}

# Function to format a single LaTeX file
format_latex_file() {
    local file="$1"
    local temp_file=$(mktemp)
    local indent_level=0
    local in_verbatim=false
    local in_comment_block=false
    local formatted_lines=0
    
    [ "$VERBOSE" = true ] && echo "  Processing: $file"
    
    # Read file line by line and format
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip formatting inside verbatim environments or comment blocks
        if [[ "$line" =~ \\begin\{(verbatim|lstlisting|minted|Verbatim)\} ]]; then
            in_verbatim=true
        elif [[ "$line" =~ \\end\{(verbatim|lstlisting|minted|Verbatim)\} ]]; then
            in_verbatim=false
            echo "$line" >> "$temp_file"
            continue
        elif [[ "$line" =~ ^[[:space:]]*\\iffalse ]]; then
            in_comment_block=true
        elif [[ "$line" =~ ^[[:space:]]*\\fi ]] && [ "$in_comment_block" = true ]; then
            in_comment_block=false
            echo "$line" >> "$temp_file"
            continue
        fi
        
        # Don't format verbatim content or comment blocks
        if [ "$in_verbatim" = true ] || [ "$in_comment_block" = true ]; then
            echo "$line" >> "$temp_file"
            continue
        fi
        
        # Trim leading and trailing whitespace
        local trimmed_line=$(echo "$line" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        
        # Skip empty lines (preserve them as-is)
        if [ -z "$trimmed_line" ]; then
            echo "" >> "$temp_file"
            continue
        fi
        
        # Decrease indent for end commands
        if [[ "$trimmed_line" =~ ^\\end\{ ]] || \
           [[ "$trimmed_line" =~ ^\} ]]; then
            ((indent_level > 0)) && ((indent_level--))
        fi
        
        # Apply indentation
        local spaces=$(printf "%*s" $((indent_level * INDENT_SIZE)) "")
        echo "${spaces}${trimmed_line}" >> "$temp_file"
        formatted_lines=$((formatted_lines + 1))
        
        # Increase indent for begin commands
        if [[ "$trimmed_line" =~ \\begin\{ ]] || \
           [[ "$trimmed_line" =~ \{[[:space:]]*$ ]]; then
            ((indent_level++))
        fi
        
        # Special handling for specific commands that should increase indent
        if [[ "$trimmed_line" =~ ^\\(chapter|section|subsection|subsubsection)\{ ]] || \
           [[ "$trimmed_line" =~ ^\\(title|author|date)\{ ]] || \
           [[ "$trimmed_line" =~ ^\\documentclass ]] || \
           [[ "$trimmed_line" =~ ^\\usepackage ]]; then
            # These don't change indent level
            :
        fi
        
    done < "$file"
    
    # Show diff if verbose or dry run
    if [ "$VERBOSE" = true ] || [ "$DRY_RUN" = true ]; then
        local changes=$(diff -u "$file" "$temp_file" | wc -l)
        if [ "$changes" -gt 0 ]; then
            echo "  Changes: $changes lines would be modified"
            if [ "$VERBOSE" = true ] && [ "$DRY_RUN" = false ]; then
                echo "  First few changes:"
                diff -u "$file" "$temp_file" | head -20
            fi
        else
            echo "  No formatting changes needed"
        fi
    fi
    
    # Apply changes if not dry run
    if [ "$DRY_RUN" = false ]; then
        create_backup "$file"
        mv "$temp_file" "$file"
        echo "  Formatted $formatted_lines lines"
    else
        rm "$temp_file"
    fi
}

# Function to organize preamble packages
organize_preamble() {
    local file="$1"
    local temp_file=$(mktemp)
    local in_preamble=true
    local packages=()
    local other_preamble=()
    local has_document=false
    
    [ "$VERBOSE" = true ] && echo "  Organizing preamble in: $file"
    
    # First pass: check if file contains \begin{document}
    if grep -q "\\\\begin{document}" "$file"; then
        has_document=true
    fi
    
    # If no \begin{document}, this is likely a preamble-only file - skip reorganization
    if [ "$has_document" = false ]; then
        [ "$VERBOSE" = true ] && echo "    Skipping preamble organization - no \\begin{document} found (likely preamble-only file)"
        rm "$temp_file"
        return
    fi
    
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ ^\\begin\{document\} ]]; then
            in_preamble=false
            # Output organized preamble
            if [ ${#packages[@]} -gt 0 ]; then
                echo "% Packages" >> "$temp_file"
                printf '%s\n' "${packages[@]}" | sort >> "$temp_file"
                echo "" >> "$temp_file"
            fi
            
            if [ ${#other_preamble[@]} -gt 0 ]; then
                echo "% Configuration" >> "$temp_file"
                printf '%s\n' "${other_preamble[@]}" >> "$temp_file"
                echo "" >> "$temp_file"
            fi
            
            echo "$line" >> "$temp_file"
        elif [ "$in_preamble" = true ]; then
            if [[ "$line" =~ ^\\usepackage ]] || [[ "$line" =~ ^\\RequirePackage ]]; then
                packages+=("$line")
            elif [[ "$line" =~ ^\\documentclass ]] || [[ "$line" =~ ^% ]] || [[ -z "$(echo "$line" | xargs)" ]]; then
                echo "$line" >> "$temp_file"
            else
                other_preamble+=("$line")
            fi
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$file"
    
    if [ "$DRY_RUN" = false ]; then
        mv "$temp_file" "$file"
    else
        rm "$temp_file"
    fi
}

# Function to clean up spacing
clean_spacing() {
    local file="$1"
    
    [ "$VERBOSE" = true ] && echo "  Cleaning spacing in: $file"
    
    if [ "$DRY_RUN" = false ]; then
        # Remove multiple consecutive blank lines (keep max 2)
        sed -i '/^$/N;/^\n$/d' "$file"
        
        # Remove trailing whitespace
        sed -i 's/[[:space:]]*$//' "$file"
        
        # Ensure file ends with newline
        sed -i -e '$a\' "$file"
    fi
}

# Function to find tex files
find_tex_files() {
    if [ "$RECURSIVE" = true ]; then
        find . -name "*.tex" -type f
    else
        ls *.tex 2>/dev/null || true
    fi
}

# Main formatting function
format_files() {
    local files=("$@")
    local total_files=0
    local formatted_files=0
    
    # Get the script's directory and go to parent (project root)
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
    cd "$PROJECT_ROOT"
    
    echo "Script directory: $SCRIPT_DIR"
    echo "Project root: $PROJECT_ROOT"
    echo "Working directory: $(pwd)"
    
    # If no files specified, find them
    if [ ${#files[@]} -eq 0 ]; then
        # Use a more compatible approach instead of mapfile
        while IFS= read -r -d '' file; do
            files+=("$file")
        done < <(find_tex_files | tr '\n' '\0')
    fi
    
    if [ ${#files[@]} -eq 0 ]; then
        print_error "No .tex files found"
        exit 1
    fi
    
    echo -e "${BLUE}LaTeX Code Formatter${NC}"
    echo "===================="
    [ "$DRY_RUN" = true ] && echo -e "${YELLOW}DRY RUN MODE - No files will be modified${NC}"
    echo "Indent size: $INDENT_SIZE spaces"
    echo "Backup files: $($BACKUP && echo "enabled" || echo "disabled")"
    echo "Files to process: ${#files[@]}"
    echo ""
    
    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            print_warning "File not found: $file"
            continue
        fi
        
        if [[ ! "$file" =~ \.tex$ ]]; then
            print_warning "Skipping non-tex file: $file"
            continue
        fi
        
        print_step "Processing $file"
        total_files=$((total_files + 1))
        
        # Format the file
        format_latex_file "$file"
        
        # Organize preamble
        organize_preamble "$file"
        
        # Clean up spacing
        clean_spacing "$file"
        
        print_success "Completed $file"
        formatted_files=$((formatted_files + 1))
    done
    
    echo ""
    if [ "$DRY_RUN" = true ]; then
        print_success "Dry run completed: $formatted_files files would be formatted"
    else
        print_success "Formatting completed: $formatted_files/$total_files files processed"
        if [ "$BACKUP" = true ] && [ $formatted_files -gt 0 ]; then
            echo "Backup files created with .bak extension"
        fi
    fi
}

# Parse command line arguments
FILES=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--indent)
            INDENT_SIZE="$2"
            shift 2
            ;;
        -r|--recursive)
            RECURSIVE=true
            shift
            ;;
        -n|--no-backup)
            BACKUP=false
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            FILES+=("$1")
            shift
            ;;
    esac
done

# Run the formatter
format_files "${FILES[@]}"