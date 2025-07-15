#!/bin/bash

# LaTeX Project Tar Creator
# Creates a compressed tar.gz archive of the project, excluding build artifacts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}LaTeX Project Tar Creator${NC}"
echo "========================================"

# Get the script's directory and go to parent (project root)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Get the current directory name for the archive
PROJECT_NAME=$(basename "$(pwd)")
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_NAME="${PROJECT_NAME}_${TIMESTAMP}.tar.gz"

echo -e "${YELLOW}Creating archive: ${ARCHIVE_NAME}${NC}"
echo "Script directory: $SCRIPT_DIR"
echo "Project root: $PROJECT_ROOT"
echo "From directory: $(pwd)"

# Create tar.gz while excluding LaTeX build artifacts
# Using the same exclusion patterns from your cleanup script
tar -czf "../${ARCHIVE_NAME}" \
  --exclude="*.aux" \
  --exclude="*.bbl" \
  --exclude="*.blg" \
  --exclude="*.fdb_latexmk" \
  --exclude="*.fls" \
  --exclude="*.log" \
  --exclude="*.out" \
  --exclude="*.toc" \
  --exclude="*.lof" \
  --exclude="*.lot" \
  --exclude="*.nlo" \
  --exclude="*.nls" \
  --exclude="*.ilg" \
  --exclude="*.ind" \
  --exclude="*.idx" \
  --exclude="*.synctex.gz" \
  --exclude="*.glg" \
  --exclude="*.glo" \
  --exclude="*.gls" \
  --exclude="*.ist" \
  --exclude="*.bcf" \
  --exclude="*.mw" \
  --exclude="*.run.xml" \
  --exclude="*.xdy" \
  --exclude="*.ent" \
  --exclude="*.loq" \
  --exclude="*acr" \
  --exclude="*.mtc*" \
  --exclude="*synctex(busy)" \
  --exclude="*.maf" \
  --exclude=".DS_Store" \
  --exclude="Thumbs.db" \
  --exclude="*.tmp" \
  --exclude="*~" \
  .

# Check if tar was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Archive created successfully!${NC}"
    echo -e "Archive location: ${BLUE}../$(basename "$ARCHIVE_NAME")${NC}"
    
    # Show archive size
    ARCHIVE_SIZE=$(du -h "../${ARCHIVE_NAME}" | cut -f1)
    echo -e "Archive size: ${YELLOW}${ARCHIVE_SIZE}${NC}"
    
    # Show what's included (first level)
    echo -e "\n${YELLOW}Archive contents (top level):${NC}"
    tar -tzf "../${ARCHIVE_NAME}" | head -20 | sed 's/^/  /'
    
    # Count total files
    TOTAL_FILES=$(tar -tzf "../${ARCHIVE_NAME}" | wc -l)
    echo -e "\nTotal files in archive: ${GREEN}${TOTAL_FILES}${NC}"
    
else
    echo -e "${RED}✗ Failed to create archive${NC}"
    exit 1
fi

echo -e "\n${GREEN}Archive creation complete!${NC}"