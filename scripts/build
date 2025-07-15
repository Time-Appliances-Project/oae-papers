#!/bin/bash

# LaTeX Build Script
# Runs the standard build sequence: pdflatex → bibtex → pdflatex → pdflatex

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Build settings
VERBOSE=false
CLEAN_FIRST=false
OPEN_PDF=false

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

# Function to run command and capture output
run_command() {
    local cmd="$1"
    local step_name="$2"
    
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}Running:${NC} $cmd"
        eval $cmd
        local exit_code=$?
    else
        local output
        output=$(eval $cmd 2>&1)
        local exit_code=$?
        
        if [ $exit_code -ne 0 ]; then
            print_error "$step_name failed"
            echo "Command: $cmd"
            echo "Output:"
            echo "$output"
            return $exit_code
        fi
    fi
    
    return $exit_code
}

# Function to check if file exists
check_file() {
    if [ ! -f "$1" ]; then
        print_error "File not found: $1"
        return 1
    fi
    return 0
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS] <main.tex>"
    echo ""
    echo "Options:"
    echo "  -v, --verbose     Show detailed output from LaTeX commands"
    echo "  -c, --clean       Clean auxiliary files before building"
    echo "  -o, --open        Open PDF after successful build (macOS only)"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 main.tex                    # Standard build"
    echo "  $0 --verbose main.tex          # Build with detailed output"
    echo "  $0 --clean --open main.tex     # Clean, build, and open PDF"
}

# Function to clean auxiliary files
clean_aux_files() {
    print_step "Cleaning auxiliary files..."
    
    local base_name="${1%.*}"
    
    # Remove common LaTeX auxiliary files
    rm -f "${base_name}.aux" "${base_name}.bbl" "${base_name}.blg" \
          "${base_name}.log" "${base_name}.out" "${base_name}.toc" \
          "${base_name}.lof" "${base_name}.lot" "${base_name}.fls" \
          "${base_name}.fdb_latexmk" "${base_name}.synctex.gz" \
          "${base_name}.run.xml" "${base_name}.bcf"
    
    print_success "Auxiliary files cleaned"
}

# Main build function
build_latex() {
    local tex_file="$1"
    local base_name="${tex_file%.*}"
    local pdf_file="${base_name}.pdf"
    
    echo -e "${BLUE}LaTeX Build Script${NC}"
    echo "=================="
    echo "Building: $tex_file"
    echo "Output: $pdf_file"
    echo ""
    
    # Check if input file exists
    check_file "$tex_file" || exit 1
    
    # Clean if requested
    if [ "$CLEAN_FIRST" = true ]; then
        clean_aux_files "$tex_file"
        echo ""
    fi
    
    # Step 1: First pdflatex run
    print_step "Step 1/4: Running pdflatex (first pass)..."
    if ! run_command "pdflatex -interaction=nonstopmode \"$tex_file\"" "First pdflatex"; then
        exit 1
    fi
    print_success "First pdflatex completed"
    
    # Step 2: Check for bibliography and run bibtex if needed
    local run_bibtex=false
    
    # Check multiple conditions for bibliography
    if [ -f "${base_name}.aux" ]; then
        # Check for \bibdata command (from \bibliography{})
        if grep -q "\\\\bibdata" "${base_name}.aux" 2>/dev/null; then
            run_bibtex=true
        fi
        
        # Also check for \citation commands
        if grep -q "\\\\citation" "${base_name}.aux" 2>/dev/null; then
            run_bibtex=true
        fi
        
        # Check for \bibstyle command
        if grep -q "\\\\bibstyle" "${base_name}.aux" 2>/dev/null; then
            run_bibtex=true
        fi
    fi
    
    # Also check if .tex file contains \bibliography command
    if grep -q "\\\\bibliography{" "$tex_file" 2>/dev/null; then
        run_bibtex=true
    fi
    
    if [ "$run_bibtex" = true ]; then
        print_step "Step 2/4: Running bibtex..."
        if [ "$VERBOSE" = true ]; then
            echo "Debug: Bibliography indicators found:"
            [ -f "${base_name}.aux" ] && grep -E "(\\\\bibdata|\\\\citation|\\\\bibstyle)" "${base_name}.aux" 2>/dev/null | head -3
        fi
        
        if ! run_command "bibtex \"$base_name\"" "BibTeX"; then
            print_warning "BibTeX failed, continuing anyway..."
            if [ "$VERBOSE" = false ] && [ -f "${base_name}.blg" ]; then
                echo "BibTeX log:"
                cat "${base_name}.blg"
            fi
        else
            print_success "BibTeX completed"
        fi
    else
        print_step "Step 2/4: No bibliography detected, skipping bibtex"
        if [ "$VERBOSE" = true ]; then
            echo "Debug: Checked for:"
            echo "  - \\bibdata in ${base_name}.aux: $([ -f "${base_name}.aux" ] && grep -c "\\\\bibdata" "${base_name}.aux" 2>/dev/null || echo "0")"
            echo "  - \\citation in ${base_name}.aux: $([ -f "${base_name}.aux" ] && grep -c "\\\\citation" "${base_name}.aux" 2>/dev/null || echo "0")"
            echo "  - \\bibliography in $tex_file: $(grep -c "\\\\bibliography{" "$tex_file" 2>/dev/null || echo "0")"
        fi
    fi
    
    # Step 3: Second pdflatex run
    print_step "Step 3/4: Running pdflatex (second pass)..."
    if ! run_command "pdflatex -interaction=nonstopmode \"$tex_file\"" "Second pdflatex"; then
        exit 1
    fi
    print_success "Second pdflatex completed"
    
    # Step 4: Third pdflatex run
    print_step "Step 4/4: Running pdflatex (third pass)..."
    if ! run_command "pdflatex -interaction=nonstopmode \"$tex_file\"" "Third pdflatex"; then
        exit 1
    fi
    print_success "Third pdflatex completed"
    
    # Check if PDF was generated
    if [ -f "$pdf_file" ]; then
        local pdf_size=$(du -h "$pdf_file" | cut -f1)
        echo ""
        print_success "Build completed successfully!"
        echo -e "PDF generated: ${GREEN}$pdf_file${NC} (${pdf_size})"
        
        # Open PDF if requested (macOS)
        if [ "$OPEN_PDF" = true ]; then
            if command -v open >/dev/null 2>&1; then
                print_step "Opening PDF..."
                open "$pdf_file"
            else
                print_warning "Cannot open PDF: 'open' command not found"
            fi
        fi
        
        # Show any warnings from the log
        if [ -f "${base_name}.log" ]; then
            local warning_count=$(grep -c "Warning" "${base_name}.log" 2>/dev/null || echo "0")
            local overfull_count=$(grep -c "Overfull" "${base_name}.log" 2>/dev/null || echo "0")
            
            if [ "$warning_count" -gt 0 ] || [ "$overfull_count" -gt 0 ]; then
                echo ""
                print_warning "Build completed with issues:"
                [ "$warning_count" -gt 0 ] && echo "  - $warning_count warning(s)"
                [ "$overfull_count" -gt 0 ] && echo "  - $overfull_count overfull box(es)"
                echo "  Check ${base_name}.log for details"
            fi
        fi
    else
        print_error "PDF was not generated"
        exit 1
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -c|--clean)
            CLEAN_FIRST=true
            shift
            ;;
        -o|--open)
            OPEN_PDF=true
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
            TEX_FILE="$1"
            shift
            ;;
    esac
done

# Check if tex file was provided
if [ -z "$TEX_FILE" ]; then
    echo "Error: No .tex file specified"
    echo ""
    show_usage
    exit 1
fi

# Run the build
build_latex "$TEX_FILE"