#!/bin/bash

# Script to push chapter figures incrementally to avoid Git push timeouts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BRANCH_NAME="refactor/new-version"

echo -e "${BLUE}Incremental Chapter Push Script${NC}"
echo "======================================="

# Check if we're on the right branch
current_branch=$(git branch --show-current)
if [ "$current_branch" != "$BRANCH_NAME" ]; then
    echo -e "${YELLOW}Warning: Currently on branch '$current_branch', not '$BRANCH_NAME'${NC}"
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting."
        exit 0
    fi
fi

# Function to safely add, commit and push
safe_push() {
    local files="$1"
    local commit_msg="$2"
    local is_first_push="$3"
    
    echo -e "\n${YELLOW}Processing: $commit_msg${NC}"
    
    # Check if files exist
    if ! ls $files >/dev/null 2>&1; then
        echo -e "${YELLOW}No files found matching: $files${NC}"
        return 0
    fi
    
    # Add files
    git add $files
    
    # Check if anything was actually staged
    if git diff --cached --quiet; then
        echo -e "${YELLOW}No changes to commit for: $files${NC}"
        return 0
    fi
    
    # Commit
    git commit -m "$commit_msg"
    
    # Push
    if [ "$is_first_push" = "true" ]; then
        echo -e "${BLUE}Setting upstream and pushing...${NC}"
        if git push --set-upstream origin "$BRANCH_NAME"; then
            echo -e "${GREEN}✓ Successfully pushed: $commit_msg${NC}"
        else
            echo -e "${RED}✗ Failed to push: $commit_msg${NC}"
            return 1
        fi
    else
        echo -e "${BLUE}Pushing...${NC}"
        if git push origin "$BRANCH_NAME"; then
            echo -e "${GREEN}✓ Successfully pushed: $commit_msg${NC}"
        else
            echo -e "${RED}✗ Failed to push: $commit_msg${NC}"
            return 1
        fi
    fi
    
    # Small delay to be nice to the server
    sleep 2
}

# Configuration for Git to handle large files better
echo -e "${BLUE}Configuring Git for large file handling...${NC}"
git config http.postBuffer 524288000    # 500MB
git config http.maxRequestBuffer 100M
git config core.compression 9

# Step 1: Push non-figure files first (if any are staged)
echo -e "\n${BLUE}Step 1: Checking for non-figure files...${NC}"
if git diff --cached --name-only | grep -E '\.(tex|bib|md|txt|sh)$' >/dev/null; then
    echo "Found staged text files, committing those first..."
    safe_push "*.tex *.bib *.md *.txt *.sh" "Add text files and scripts" "true"
    first_push_done="true"
else
    first_push_done="false"
fi

# Step 2: Process each chapter's figures
echo -e "\n${BLUE}Step 2: Processing chapter figures...${NC}"

chapters=(
    "01_principles-of-operation"
    "02_bits-and-bytes" 
    "03_cells-and-links"
    "04_addressing-and-routing"
    "05_reversible-transactions"
    "06_architecture"
    "07_topology"
    "08_context-and-comparisons"
    "09_history"
    "10_theory"
    "11_requirements-and-usecases"
)

for chapter in "${chapters[@]}"; do
    if [ -d "chapters/$chapter" ]; then
        # Push figures directory if it exists
        if [ -d "chapters/$chapter/figures" ]; then
            if [ "$first_push_done" = "false" ]; then
                safe_push "chapters/$chapter/figures/" "Add $chapter figures" "true"
                first_push_done="true"
            else
                safe_push "chapters/$chapter/figures/" "Add $chapter figures" "false"
            fi
        fi
        
        # Push any other files in the chapter
        if [ "$first_push_done" = "false" ]; then
            safe_push "chapters/$chapter/*.tex chapters/$chapter/*.pdf chapters/$chapter/section/" "Add $chapter files" "true"
            first_push_done="true"
        else
            safe_push "chapters/$chapter/*.tex chapters/$chapter/*.pdf chapters/$chapter/section/" "Add $chapter files" "false"
        fi
    else
        echo -e "${YELLOW}Chapter directory not found: chapters/$chapter${NC}"
    fi
done

# Step 3: Push any remaining files
echo -e "\n${BLUE}Step 3: Checking for remaining files...${NC}"
if ! git diff --cached --quiet; then
    echo "Found remaining staged files..."
    if [ "$first_push_done" = "false" ]; then
        safe_push "." "Add remaining files" "true"
    else
        safe_push "." "Add remaining files" "false"
    fi
elif git status --porcelain | grep -E '^[AM]' >/dev/null; then
    echo "Found unstaged changes, adding and pushing..."
    git add .
    if [ "$first_push_done" = "false" ]; then
        safe_push "." "Add all remaining files" "true"
    else
        safe_push "." "Add all remaining files" "false"
    fi
else
    echo -e "${GREEN}No remaining files to push${NC}"
fi

echo -e "\n${GREEN}Incremental push complete!${NC}"
echo -e "${BLUE}Branch '$BRANCH_NAME' should now be fully pushed to remote.${NC}"

# Final status check
echo -e "\n${BLUE}Final status:${NC}"
git status --porcelain
if [ $? -eq 0 ] && [ -z "$(git status --porcelain)" ]; then
    echo -e "${GREEN}✓ Working directory clean - all changes pushed${NC}"
else
    echo -e "${YELLOW}⚠ Some files may still need attention${NC}"
fi