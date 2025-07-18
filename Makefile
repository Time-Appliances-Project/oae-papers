# LaTeX Project Makefile
# Integrates all workflow scripts for a complete LaTeX development environment

# Configuration
MAIN_TEX = OAE-SPEC-MAIN.tex
MAIN_PDF = $(MAIN_TEX:.tex=.pdf)
PYTHON = python3
SCRIPTS_DIR = scripts
FIGURES_SCRIPT = $(SCRIPTS_DIR)/pull-figures.sh
REFERENCES_SCRIPT = $(SCRIPTS_DIR)/pull-references.py
BUILD_SCRIPT = $(SCRIPTS_DIR)/build.sh
FORMAT_SCRIPT = $(SCRIPTS_DIR)/format-latex.sh
CLEANUP_SCRIPT = $(SCRIPTS_DIR)/cleanup.sh
BUNDLE_SCRIPT = $(SCRIPTS_DIR)/bundle.sh

# Colors for output
BLUE = \033[0;34m
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

# Default target
.PHONY: all
all: setup build

# Help target
.PHONY: help
help:
	@echo "$(BLUE)LaTeX Project Makefile$(NC)"
	@echo "======================="
	@echo ""
	@echo "$(YELLOW)Main Targets:$(NC)"
	@echo "  all          - Setup and build (default)"
	@echo "  build        - Build PDF from LaTeX sources"
	@echo "  quick        - Quick build (single pdflatex pass)"
	@echo "  clean        - Remove auxiliary files"
	@echo "  setup        - Pull figures and references"
	@echo "  format       - Format LaTeX code"
	@echo "  pack         - Create distribution archive"
	@echo ""
	@echo "$(YELLOW)Chapter Targets:$(NC)"
	@echo "  build-chapter CHAPTER=name    - Build specific chapter"
	@echo "  setup-chapter CHAPTER=name    - Setup specific chapter"
	@echo "  clean-chapter CHAPTER=name    - Clean specific chapter"
	@echo "  build-all-chapters            - Build all chapters"
	@echo "  list-chapters                 - List available chapters"
	@echo ""
	@echo "  count        - Count words in document"
	@echo "  check        - Check for issues (refs, citations, etc.)"
	@echo ""
	@echo "$(YELLOW)Development:$(NC)"
	@echo "  clean-all    - Deep clean (including PDFs)"
	@echo "  backup       - Create timestamped backup"
	@echo "  figures      - Pull figures only"
	@echo "  references   - Extract references only"
	@echo ""
	@echo "$(YELLOW)Configuration:$(NC)"
	@echo "  MAIN_TEX     - Main LaTeX file (default: main.tex)"
	@echo "  VERBOSE      - Show detailed output (make VERBOSE=1)"
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make                    # Build everything"
	@echo "  make MAIN_TEX=thesis.tex # Use different main file"
	@echo "  make watch              # Auto-rebuild on changes"
	@echo "  make clean build        # Clean and rebuild"

# Setup: Pull figures and references
.PHONY: setup
setup: figures references
	@echo "$(GREEN)✓ Setup completed$(NC)"

# Pull figures from central repository
.PHONY: figures
figures:
	@echo "$(BLUE)▶ Pulling figures...$(NC)"
	@if [ -f "$(FIGURES_SCRIPT)" ]; then \
		chmod +x "$(FIGURES_SCRIPT)" && "./$(FIGURES_SCRIPT)"; \
	else \
		echo "$(YELLOW)⚠ Figure script not found: $(FIGURES_SCRIPT)$(NC)"; \
	fi

# Extract references from master bibliography
.PHONY: references
references:
	@echo "$(BLUE)▶ Extracting references...$(NC)"
	@if [ -f "$(REFERENCES_SCRIPT)" ]; then \
		chmod +x "$(REFERENCES_SCRIPT)" && $(PYTHON) "$(REFERENCES_SCRIPT)"; \
	else \
		echo "$(YELLOW)⚠ References script not found: $(REFERENCES_SCRIPT)$(NC)"; \
	fi

# Build PDF using the build script
.PHONY: build
build: setup
	@echo "$(BLUE)▶ Building PDF...$(NC)"
	@if [ -f "$(BUILD_SCRIPT)" ]; then \
		chmod +x "$(BUILD_SCRIPT)" && "./$(BUILD_SCRIPT)" $(MAIN_TEX); \
	else \
		echo "$(YELLOW)⚠ Build script not found, using fallback$(NC)"; \
		$(MAKE) fallback-build; \
	fi

# Fallback build if script not available
.PHONY: fallback-build
fallback-build:
	@echo "$(BLUE)▶ Running fallback build...$(NC)"
	pdflatex -interaction=nonstopmode $(MAIN_TEX)
	@if grep -q "\\bibdata" $(MAIN_TEX:.tex=.aux) 2>/dev/null; then \
		bibtex $(MAIN_TEX:.tex=); \
		pdflatex -interaction=nonstopmode $(MAIN_TEX); \
	fi
	pdflatex -interaction=nonstopmode $(MAIN_TEX)

# Quick build (single pass)
.PHONY: quick
quick:
	@echo "$(BLUE)▶ Quick build...$(NC)"
	pdflatex -interaction=nonstopmode $(MAIN_TEX)

# Format LaTeX code
.PHONY: format
format:
	@echo "$(BLUE)▶ Formatting LaTeX code...$(NC)"
	@if [ -f "$(FORMAT_SCRIPT)" ]; then \
		chmod +x "$(FORMAT_SCRIPT)" && "./$(FORMAT_SCRIPT)" --recursive; \
	else \
		echo "$(YELLOW)⚠ Format script not found: $(FORMAT_SCRIPT)$(NC)"; \
	fi

# Clean auxiliary files
.PHONY: clean
clean:
	@echo "$(BLUE)▶ Cleaning auxiliary files...$(NC)"
	@if [ -f "$(CLEANUP_SCRIPT)" ]; then \
		chmod +x "$(CLEANUP_SCRIPT)" && "./$(CLEANUP_SCRIPT)"; \
	else \
		echo "$(YELLOW)⚠ Cleanup script not found, using fallback$(NC)"; \
		$(MAKE) fallback-clean; \
	fi

# Fallback clean
.PHONY: fallback-clean
fallback-clean:
	@find . -name "*.aux" -o -name "*.log" -o -name "*.bbl" -o -name "*.blg" \
		-o -name "*.out" -o -name "*.toc" -o -name "*.synctex.gz" \
		-o -name "*.fls" -o -name "*.fdb_latexmk" | xargs rm -f
	@echo "$(GREEN)✓ Auxiliary files cleaned$(NC)"

# Deep clean (including PDFs)
.PHONY: clean-all
clean-all: clean
	@echo "$(BLUE)▶ Deep cleaning...$(NC)"
	@rm -f *.pdf
	@rm -f *.bak
	@echo "$(GREEN)✓ Deep clean completed$(NC)"

# Create distribution package
.PHONY: bundle
bundle: clean
	@echo "$(BLUE)▶ Creating distribution bundle...$(NC)"
	@if [ -f "$(BUNDLE_SCRIPT)" ]; then \
		chmod +x "$(BUNDLE_SCRIPT)" && "./$(BUNDLE_SCRIPT)"; \
	else \
		echo "$(YELLOW)⚠ Bundle script not found$(NC)"; \
		$(MAKE) fallback-bundle; \
	fi

# Legacy alias for bundle
.PHONY: pack
pack: bundle

# Fallback bundle
.PHONY: fallback-bundle
fallback-bundle:
	@PROJECT_NAME=$$(basename "$$(pwd)"); \
	TIMESTAMP=$$(date +"%Y%m%d_%H%M%S"); \
	tar -czf "../$${PROJECT_NAME}_$${TIMESTAMP}.tar.gz" \
		--exclude="*.aux" --exclude="*.log" --exclude="*.bbl" \
		--exclude="*.blg" --exclude="*.out" --exclude="*.toc" \
		--exclude="*.synctex.gz" --exclude=".DS_Store" .; \
	echo "$(GREEN)✓ Archive created: ../$${PROJECT_NAME}_$${TIMESTAMP}.tar.gz$(NC)"

# Watch for file changes and auto-rebuild
.PHONY: watch
watch:
	@echo "$(BLUE)▶ Watching for changes... (Ctrl+C to stop)$(NC)"
	@echo "Will rebuild when .tex files change"
	@if command -v fswatch >/dev/null 2>&1; then \
		fswatch -o . --include=".*\.tex$$" | while read num; do \
			echo "$(YELLOW)File changed, rebuilding...$(NC)"; \
			$(MAKE) quick; \
		done; \
	elif command -v inotifywait >/dev/null 2>&1; then \
		while inotifywait -e modify -r . --include=".*\.tex$$"; do \
			echo "$(YELLOW)File changed, rebuilding...$(NC)"; \
			$(MAKE) quick; \
		done; \
	else \
		echo "$(RED)✗ No file watching tool found (fswatch or inotifywait)$(NC)"; \
		echo "Install with: brew install fswatch (macOS) or apt install inotify-tools (Linux)"; \
	fi

# Word count
.PHONY: count
count:
	@echo "$(BLUE)▶ Counting words...$(NC)"
	@for file in *.tex; do \
		if [ -f "$$file" ]; then \
			words=$$(detex "$$file" 2>/dev/null | wc -w || echo "?"); \
			echo "$$file: $$words words"; \
		fi; \
	done
	@echo "$(GREEN)✓ Word count completed$(NC)"

# Check for common issues
.PHONY: check
check:
	@echo "$(BLUE)▶ Checking for issues...$(NC)"
	@echo "Checking for undefined references..."
	@if [ -f "$(MAIN_TEX:.tex=.log)" ]; then \
		grep -n "undefined" "$(MAIN_TEX:.tex=.log)" || echo "  No undefined references"; \
	fi
	@echo "Checking for missing figures..."
	@grep -n "includegraphics" *.tex | while read line; do \
		file=$$(echo "$$line" | cut -d: -f3 | sed 's/.*{\([^}]*\)}.*/\1/'); \
		if [ ! -f "figures/$$file" ] && [ ! -f "$$file" ]; then \
			echo "  Missing: $$file"; \
		fi; \
	done || echo "  All figures found"
	@echo "$(GREEN)✓ Check completed$(NC)"

# Spell check
.PHONY: spell
spell:
	@echo "$(BLUE)▶ Running spell check...$(NC)"
	@if command -v aspell >/dev/null 2>&1; then \
		for file in *.tex; do \
			if [ -f "$$file" ]; then \
				echo "Checking $$file..."; \
				aspell check "$$file"; \
			fi; \
		done; \
	else \
		echo "$(YELLOW)⚠ aspell not found. Install with: brew install aspell (macOS) or apt install aspell (Linux)$(NC)"; \
	fi

# Backup project
.PHONY: backup
backup:
	@echo "$(BLUE)▶ Creating backup...$(NC)"
	@PROJECT_NAME=$$(basename "$$(pwd)"); \
	TIMESTAMP=$$(date +"%Y%m%d_%H%M%S"); \
	BACKUP_NAME="$${PROJECT_NAME}_backup_$${TIMESTAMP}.tar.gz"; \
	tar -czf "../$$BACKUP_NAME" .; \
	echo "$(GREEN)✓ Backup created: ../$$BACKUP_NAME$(NC)"

# Open PDF (macOS only)
.PHONY: open
open:
	@if [ -f "$(MAIN_PDF)" ]; then \
		echo "$(BLUE)▶ Opening PDF...$(NC)"; \
		open "$(MAIN_PDF)"; \
	else \
		echo "$(RED)✗ PDF not found: $(MAIN_PDF)$(NC)"; \
		echo "Run 'make build' first"; \
	fi

# Install dependencies
.PHONY: install-deps
install-deps:
	@echo "$(BLUE)▶ Installing dependencies...$(NC)"
	@echo "Checking for required tools..."
	@command -v pdflatex >/dev/null 2>&1 || echo "$(RED)✗ pdflatex not found$(NC)"
	@command -v bibtex >/dev/null 2>&1 || echo "$(RED)✗ bibtex not found$(NC)"
	@command -v $(PYTHON) >/dev/null 2>&1 || echo "$(RED)✗ $(PYTHON) not found$(NC)"
	@echo "$(YELLOW)Optional tools:$(NC)"
	@command -v fswatch >/dev/null 2>&1 && echo "$(GREEN)✓ fswatch found$(NC)" || echo "$(YELLOW)○ fswatch not found (for watch target)$(NC)"
	@command -v aspell >/dev/null 2>&1 && echo "$(GREEN)✓ aspell found$(NC)" || echo "$(YELLOW)○ aspell not found (for spell target)$(NC)"
	@command -v detex >/dev/null 2>&1 && echo "$(GREEN)✓ detex found$(NC)" || echo "$(YELLOW)○ detex not found (for count target)$(NC)"

# List available chapters
.PHONY: list-chapters
list-chapters:
	@echo "$(BLUE)Available chapters:$(NC)"
	@for chapter_dir in chapters/*/; do \
		if [ -d "$chapter_dir" ]; then \
			chapter_name=$(basename "$chapter_dir"); \
			tex_file=$(find "$chapter_dir" -name "*.tex" -maxdepth 1 | head -1); \
			if [ -n "$tex_file" ]; then \
				pdf_file="${tex_file%.tex}.pdf"; \
				if [ -f "$pdf_file" ]; then \
					echo "  ✓ $chapter_name (built)"; \
				else \
					echo "  ○ $chapter_name (not built)"; \
				fi; \
			else \
				echo "  ? $chapter_name (no .tex file)"; \
			fi; \
		fi; \
	done

# Build specific chapter (FIXED)
.PHONY: build-chapter
build-chapter:
	@if [ -z "$(CHAPTER)" ]; then \
		echo "$(RED)Error: Specify chapter with CHAPTER=chapter-name$(NC)"; \
		echo "Available chapters:"; \
		$(MAKE) list-chapters; \
		exit 1; \
	fi
	@if [ ! -d "chapters/$(CHAPTER)" ]; then \
		echo "$(RED)Error: Chapter directory not found: chapters/$(CHAPTER)$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)▶ Building chapter: $(CHAPTER)$(NC)"
	@cd "chapters/$(CHAPTER)" && \
	CHAPTER_TEX=$(find . -name "*.tex" -maxdepth 1 | head -1) && \
	if [ -n "$CHAPTER_TEX" ]; then \
		echo "Found: $CHAPTER_TEX"; \
		if [ -f "../../scripts/build.sh" ]; then \
			../../scripts/build.sh "$CHAPTER_TEX"; \
		else \
			echo "$(RED)Error: build.sh not found$(NC)"; \
			exit 1; \
		fi; \
	else \
		echo "$(RED)Error: No .tex file found in chapters/$(CHAPTER)$(NC)"; \
		exit 1; \
	fi

# Setup for specific chapter (FIXED)
.PHONY: setup-chapter
setup-chapter:
	@if [ -z "$(CHAPTER)" ]; then \
		echo "$(RED)Error: Specify chapter with CHAPTER=chapter-name$(NC)"; \
		$(MAKE) list-chapters; \
		exit 1; \
	fi
	@if [ ! -d "chapters/$(CHAPTER)" ]; then \
		echo "$(RED)Error: Chapter directory not found: chapters/$(CHAPTER)$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)▶ Setting up chapter: $(CHAPTER)$(NC)"
	@cd "chapters/$(CHAPTER)" && \
	echo "Working in: $(pwd)" && \
	if [ -f "../../scripts/pull-figures.sh" ]; then \
		echo "Pulling figures..."; \
		../../scripts/pull-figures.sh; \
	else \
		echo "$(YELLOW)Warning: pull-figures.sh not found$(NC)"; \
	fi && \
	if [ -f "../../scripts/pull-references.py" ]; then \
		echo "Pulling references..."; \
		python3 ../../scripts/pull-references.py; \
	else \
		echo "$(YELLOW)Warning: pull-references.py not found$(NC)"; \
	fi

# Clean specific chapter
.PHONY: clean-chapter
clean-chapter:
	@if [ -z "$(CHAPTER)" ]; then \
		echo "$(RED)Error: Specify chapter with CHAPTER=chapter-name$(NC)"; \
		$(MAKE) list-chapters; \
		exit 1; \
	fi
	@echo "$(BLUE)▶ Cleaning chapter: $(CHAPTER)$(NC)"
	@cd "chapters/$(CHAPTER)" && \
	if [ -f "../../scripts/cleanup.sh" ]; then \
		../../scripts/cleanup.sh; \
	else \
		echo "$(YELLOW)Using fallback cleanup$(NC)"; \
		rm -f *.aux *.log *.bbl *.blg *.out *.toc *.synctex.gz *.fls *.fdb_latexmk; \
	fi

# Build all chapters
.PHONY: build-all-chapters
build-all-chapters:
	@echo "$(BLUE)▶ Building all chapters...$(NC)"
	@for chapter_dir in chapters/*/; do \
		if [ -d "$chapter_dir" ]; then \
			chapter_name=$(basename "$chapter_dir"); \
			echo "$(YELLOW)Building chapter: $chapter_name$(NC)"; \
			$(MAKE) CHAPTER="$chapter_name" build-chapter || exit 1; \
		fi; \
	done

# Setup for specific chapter
.PHONY: setup-chapter
setup-chapter:
	@if [ -z "$(CHAPTER)" ]; then \
		echo "$(RED)Error: Specify chapter with CHAPTER=01_principles-of-operation$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)▶ Setting up chapter: $(CHAPTER)$(NC)"
	@cd "chapters/$(CHAPTER)" && \
	if [ -f "../../scripts/pull-figures.sh" ]; then \
		../../scripts/pull-figures.sh; \
	fi && \
	if [ -f "../../scripts/pull-references.py" ]; then \
		python3 ../../scripts/pull-references.py; \
	fi
# Show project status
.PHONY: status
status:
	@echo "===================="
	@echo "Main file: $(MAIN_TEX)"
	@echo "PDF exists: $$([ -f '$(MAIN_PDF)' ] && echo 'Yes' || echo 'No')"
	@echo "Last build: $$([ -f '$(MAIN_PDF)' ] && stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S' '$(MAIN_PDF)' 2>/dev/null || echo 'Never')"
	@echo "TeX files: $$(ls *.tex 2>/dev/null | wc -l | xargs)"
	@echo "Figures: $$([ -d figures ] && ls figures/ 2>/dev/null | wc -l | xargs || echo '0')"
	@echo "References: $$([ -f references/references.bib ] && echo 'Yes' || echo 'No')"

# Verbose mode
ifdef VERBOSE
  MAKEFLAGS += --debug=v
endif