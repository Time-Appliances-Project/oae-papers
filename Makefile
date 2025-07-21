# LaTeX Project Makefile
# Modified for environments without iCloud access

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

# Local directories for figures and references
LOCAL_FIGURES_DIR = figures
LOCAL_REFERENCES_DIR = references
LOCAL_REFS_FILE = $(LOCAL_REFERENCES_DIR)/references.bib

# Colors for output
BLUE = \033[0;34m
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

# Check if we're in an environment without iCloud
ICLOUD_AVAILABLE := $(shell [ -d "$$HOME/Library/Mobile Documents" ] && echo "yes" || echo "no")

# Default target
.PHONY: all
all: setup build

# Help target (enhanced with iCloud alternatives)
.PHONY: help
help:
	@echo ""
	@echo "$(BLUE)╔══════════════════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║                     LaTeX Project Makefile (iCloud Optional)                ║$(NC)"
	@echo "$(BLUE)╚══════════════════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)📋 QUICK START$(NC)"
	@echo "  make                     Build the entire project (setup + build)"
	@echo "  make help                Show this help menu"
	@echo "  make status              Show project status and configuration"
	@echo ""
	@echo "$(YELLOW)🔨 BUILD TARGETS$(NC)"
	@echo "  build                    Full build with setup (figures + references + PDF)"
	@echo "  build-local              Build using only local assets (no iCloud sync)"
	@echo "  quick                    Quick build (single pdflatex pass, no setup)"
	@echo "  fallback-build           Build without using build scripts"
	@echo ""
	@echo "$(YELLOW)⚙️  SETUP TARGETS$(NC)"
	@echo "  setup                    Pull figures and extract references (with fallbacks)"
	@echo "  setup-local              Setup using only local assets"
	@echo "  figures                  Pull figures from repository (or use local)"
	@echo "  figures-local            Use local figures only"
	@echo "  references               Extract references (or use local)"
	@echo "  references-local         Use local references only"
	@echo "  init-local-assets        Create local asset directories and templates"
	@echo ""
	@echo "$(YELLOW)📚 CHAPTER MANAGEMENT$(NC)"
	@echo "  list-chapters            List all available chapters with build status"
	@echo "  build-chapter CHAPTER=<name>       Build specific chapter"
	@echo "  setup-chapter CHAPTER=<name>       Setup specific chapter (figures + refs)"
	@echo "  clean-chapter CHAPTER=<name>       Clean specific chapter auxiliary files"
	@echo "  chapter CHAPTER=<name>             Setup and build specific chapter"
	@echo "  build-all-chapters                 Build all chapters sequentially"
	@echo ""
	@echo "$(YELLOW)🧹 CLEANUP TARGETS$(NC)"
	@echo "  clean                    Remove auxiliary files (.aux, .log, .bbl, etc.)"
	@echo "  clean-all                Deep clean (auxiliary files + PDFs)"
	@echo "  fallback-clean           Clean using built-in rules (no cleanup script)"
	@echo ""
	@echo "$(YELLOW)📦 PACKAGING & DISTRIBUTION$(NC)"
	@echo "  bundle                   Create distribution archive (excludes aux files)"
	@echo "  pack                     Alias for bundle"
	@echo "  backup                   Create timestamped backup of entire project"
	@echo ""
	@echo "$(YELLOW)🔍 DEVELOPMENT & QUALITY$(NC)"
	@echo "  watch                    Auto-rebuild on .tex file changes"
	@echo "  format                   Format LaTeX code using format script"
	@echo "  count                    Count words in all .tex files"
	@echo "  check                    Check for undefined references and missing figures"
	@echo "  spell                    Run spell checker on .tex files"
	@echo ""
	@echo "$(YELLOW)🛠️  SYSTEM & UTILITIES$(NC)"
	@echo "  install-deps             Check for required dependencies"
	@echo "  open                     Open generated PDF"
	@echo "  check-icloud             Check iCloud availability"
	@echo ""
	

# Check iCloud availability
.PHONY: check-icloud
check-icloud:
	@echo "$(BLUE)▶ Checking iCloud availability...$(NC)"
	@if [ "$(ICLOUD_AVAILABLE)" = "yes" ]; then \
		echo "$(GREEN)✓ iCloud appears to be available$(NC)"; \
		echo "  Mobile Documents directory found"; \
	else \
		echo "$(YELLOW)⚠ iCloud not available$(NC)"; \
		echo "  Will use local fallbacks for figures and references"; \
	fi

# Initialize local asset directories
.PHONY: init-local-assets
init-local-assets:
	@echo "$(BLUE)▶ Initializing local asset directories...$(NC)"
	@mkdir -p $(LOCAL_FIGURES_DIR)
	@mkdir -p $(LOCAL_REFERENCES_DIR)
	@if [ ! -f "$(LOCAL_REFS_FILE)" ]; then \
		echo "% Local references file" > "$(LOCAL_REFS_FILE)"; \
		echo "% Add your bibliography entries here" >> "$(LOCAL_REFS_FILE)"; \
		echo "" >> "$(LOCAL_REFS_FILE)"; \
		echo "@article{example2024," >> "$(LOCAL_REFS_FILE)"; \
		echo "  title={Example Article}," >> "$(LOCAL_REFS_FILE)"; \
		echo "  author={Author, Example}," >> "$(LOCAL_REFS_FILE)"; \
		echo "  journal={Example Journal}," >> "$(LOCAL_REFS_FILE)"; \
		echo "  year={2024}" >> "$(LOCAL_REFS_FILE)"; \
		echo "}" >> "$(LOCAL_REFS_FILE)"; \
		echo "$(GREEN)✓ Created template references file$(NC)"; \
	fi
	@if [ ! -f "$(LOCAL_FIGURES_DIR)/README.md" ]; then \
		echo "# Local Figures Directory" > "$(LOCAL_FIGURES_DIR)/README.md"; \
		echo "" >> "$(LOCAL_FIGURES_DIR)/README.md"; \
		echo "Place your figure files (PNG, PDF, EPS, etc.) in this directory." >> "$(LOCAL_FIGURES_DIR)/README.md"; \
		echo "The LaTeX build process will find them automatically." >> "$(LOCAL_FIGURES_DIR)/README.md"; \
		echo "" >> "$(LOCAL_FIGURES_DIR)/README.md"; \
		echo "Supported formats:" >> "$(LOCAL_FIGURES_DIR)/README.md"; \
		echo "- PNG (for photos/screenshots)" >> "$(LOCAL_FIGURES_DIR)/README.md"; \
		echo "- PDF (for vector graphics)" >> "$(LOCAL_FIGURES_DIR)/README.md"; \
		echo "- EPS (for legacy vector graphics)" >> "$(LOCAL_FIGURES_DIR)/README.md"; \
		echo "- SVG (will need conversion to PDF)" >> "$(LOCAL_FIGURES_DIR)/README.md"; \
		echo "$(GREEN)✓ Created figures directory with README$(NC)"; \
	fi
	@echo "$(GREEN)✓ Local asset directories initialized$(NC)"

# Setup with iCloud fallbacks
.PHONY: setup
setup:
	@echo "$(BLUE)▶ Setting up project (with iCloud fallbacks)...$(NC)"
	@$(MAKE) check-icloud
	@if [ "$(ICLOUD_AVAILABLE)" = "yes" ]; then \
		$(MAKE) figures references; \
	else \
		echo "$(YELLOW)Using local setup (no iCloud)$(NC)"; \
		$(MAKE) setup-local; \
	fi
	@echo "$(GREEN)✓ Setup completed$(NC)"

# Local-only setup
.PHONY: setup-local
setup-local:
	@echo "$(BLUE)▶ Setting up using local assets only...$(NC)"
	@$(MAKE) init-local-assets
	@$(MAKE) figures-local
	@$(MAKE) references-local
	@echo "$(GREEN)✓ Local setup completed$(NC)"

# Pull figures with fallback to local
.PHONY: figures
figures:
	@echo "$(BLUE)▶ Pulling figures...$(NC)"
	@if [ -f "$(FIGURES_SCRIPT)" ] && [ "$(ICLOUD_AVAILABLE)" = "yes" ]; then \
		chmod +x "$(FIGURES_SCRIPT)" && "./$(FIGURES_SCRIPT)" || { \
			echo "$(YELLOW)⚠ Figure script failed, using local figures$(NC)"; \
			$(MAKE) figures-local; \
		}; \
	else \
		echo "$(YELLOW)⚠ Figure script not found or iCloud unavailable, using local figures$(NC)"; \
		$(MAKE) figures-local; \
	fi

# Use local figures only
.PHONY: figures-local
figures-local:
	@echo "$(BLUE)▶ Using local figures...$(NC)"
	@if [ ! -d "$(LOCAL_FIGURES_DIR)" ]; then \
		$(MAKE) init-local-assets; \
	fi
	@figure_count=$$(find $(LOCAL_FIGURES_DIR) -type f \( -name "*.png" -o -name "*.pdf" -o -name "*.eps" -o -name "*.jpg" -o -name "*.jpeg" \) 2>/dev/null | wc -l | xargs); \
	echo "Found $$figure_count figure(s) in $(LOCAL_FIGURES_DIR)"; \
	if [ "$$figure_count" -eq 0 ]; then \
		echo "$(YELLOW)⚠ No figures found. Add your images to $(LOCAL_FIGURES_DIR)/$(NC)"; \
	fi

# Extract references with fallback to local
.PHONY: references
references:
	@echo "$(BLUE)▶ Extracting references...$(NC)"
	@if [ -f "$(REFERENCES_SCRIPT)" ] && [ "$(ICLOUD_AVAILABLE)" = "yes" ]; then \
		chmod +x "$(REFERENCES_SCRIPT)" && $(PYTHON) "$(REFERENCES_SCRIPT)" || { \
			echo "$(YELLOW)⚠ References script failed, using local references$(NC)"; \
			$(MAKE) references-local; \
		}; \
	else \
		echo "$(YELLOW)⚠ References script not found or iCloud unavailable, using local references$(NC)"; \
		$(MAKE) references-local; \
	fi

# Use local references only
.PHONY: references-local
references-local:
	@echo "$(BLUE)▶ Using local references...$(NC)"
	@if [ ! -f "$(LOCAL_REFS_FILE)" ]; then \
		$(MAKE) init-local-assets; \
	fi
	@if [ -f "$(LOCAL_REFS_FILE)" ]; then \
		ref_count=$$(grep -c "^@" "$(LOCAL_REFS_FILE)" 2>/dev/null || echo "0"); \
		echo "Found $$ref_count reference(s) in $(LOCAL_REFS_FILE)"; \
		if [ "$$ref_count" -eq 0 ]; then \
			echo "$(YELLOW)⚠ No references found. Add entries to $(LOCAL_REFS_FILE)$(NC)"; \
		fi; \
	else \
		echo "$(RED)✗ Local references file not found$(NC)"; \
	fi

# Build with local assets only
.PHONY: build-local
build-local: setup-local
	@echo "$(BLUE)▶ Building PDF with local assets...$(NC)"
	@if [ -f "$(BUILD_SCRIPT)" ]; then \
		chmod +x "$(BUILD_SCRIPT)" && "./$(BUILD_SCRIPT)" $(MAIN_TEX); \
	else \
		echo "$(YELLOW)⚠ Build script not found, using fallback$(NC)"; \
		$(MAKE) fallback-build; \
	fi

# Enhanced build with iCloud fallbacks
.PHONY: build
build:
	@if [ "$(ICLOUD_AVAILABLE)" = "yes" ]; then \
		$(MAKE) setup; \
	else \
		$(MAKE) setup-local; \
	fi
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

# Enhanced check with local asset verification
.PHONY: check
check:
	@echo "$(BLUE)▶ Checking for issues...$(NC)"
	@echo "Checking for undefined references..."
	@if [ -f "$(MAIN_TEX:.tex=.log)" ]; then \
		grep -n "undefined" "$(MAIN_TEX:.tex=.log)" || echo "  No undefined references"; \
	fi
	@echo "Checking for missing figures..."
	@missing_figs=0; \
	grep -n "includegraphics" *.tex 2>/dev/null | while read line; do \
		file=$$(echo "$$line" | sed 's/.*{\([^}]*\)}.*/\1/'); \
		if [ ! -f "$(LOCAL_FIGURES_DIR)/$$file" ] && [ ! -f "$$file" ]; then \
			echo "  Missing: $$file"; \
			missing_figs=$$((missing_figs + 1)); \
		fi; \
	done || echo "  All figures found"
	@echo "Checking local assets..."
	@if [ -d "$(LOCAL_FIGURES_DIR)" ]; then \
		fig_count=$$(find $(LOCAL_FIGURES_DIR) -type f \( -name "*.png" -o -name "*.pdf" -o -name "*.eps" -o -name "*.jpg" \) 2>/dev/null | wc -l | xargs); \
		echo "  Local figures: $$fig_count"; \
	else \
		echo "  $(YELLOW)No local figures directory$(NC)"; \
	fi
	@if [ -f "$(LOCAL_REFS_FILE)" ]; then \
		ref_count=$$(grep -c "^@" "$(LOCAL_REFS_FILE)" 2>/dev/null || echo "0"); \
		echo "  Local references: $$ref_count"; \
	else \
		echo "  $(YELLOW)No local references file$(NC)"; \
	fi
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

# Open PDF
.PHONY: open
open:
	@if [ -f "$(MAIN_PDF)" ]; then \
		echo "$(BLUE)▶ Opening PDF...$(NC)"; \
		if command -v open >/dev/null 2>&1; then \
			open "$(MAIN_PDF)"; \
		elif command -v xdg-open >/dev/null 2>&1; then \
			xdg-open "$(MAIN_PDF)"; \
		else \
			echo "$(YELLOW)⚠ No PDF viewer command found$(NC)"; \
		fi; \
	else \
		echo "$(RED)✗ PDF not found: $(MAIN_PDF)$(NC)"; \
		echo "Run 'make build' first"; \
	fi

# Install dependencies
.PHONY: install-deps
install-deps:
	@echo "$(BLUE)▶ Checking dependencies...$(NC)"
	@echo "Required tools:"
	@command -v pdflatex >/dev/null 2>&1 && echo "$(GREEN)✓ pdflatex found$(NC)" || echo "$(RED)✗ pdflatex not found$(NC)"
	@command -v bibtex >/dev/null 2>&1 && echo "$(GREEN)✓ bibtex found$(NC)" || echo "$(RED)✗ bibtex not found$(NC)"
	@command -v $(PYTHON) >/dev/null 2>&1 && echo "$(GREEN)✓ $(PYTHON) found$(NC)" || echo "$(RED)✗ $(PYTHON) not found$(NC)"
	@echo "Optional tools:"
	@command -v fswatch >/dev/null 2>&1 && echo "$(GREEN)✓ fswatch found$(NC)" || echo "$(YELLOW)○ fswatch not found (for watch target)$(NC)"
	@command -v aspell >/dev/null 2>&1 && echo "$(GREEN)✓ aspell found$(NC)" || echo "$(YELLOW)○ aspell not found (for spell target)$(NC)"
	@command -v detex >/dev/null 2>&1 && echo "$(GREEN)✓ detex found$(NC)" || echo "$(YELLOW)○ detex not found (for count target)$(NC)"
	@echo "Environment:"
	@echo "  iCloud available: $(ICLOUD_AVAILABLE)"

# List available chapters
.PHONY: list-chapters
list-chapters:
	@echo "$(BLUE)Available chapters:$(NC)"
	@if [ -d "chapters" ]; then \
		for chapter_dir in chapters/*/; do \
			if [ -d "$$chapter_dir" ]; then \
				chapter_name=$$(basename "$$chapter_dir"); \
				tex_file=$$(find "$$chapter_dir" -name "*.tex" -maxdepth 1 | head -1); \
				if [ -n "$$tex_file" ]; then \
					pdf_file="$${tex_file%.tex}.pdf"; \
					if [ -f "$$pdf_file" ]; then \
						echo "  ✓ $$chapter_name (built)"; \
					else \
						echo "  ○ $$chapter_name (not built)"; \
					fi; \
				else \
					echo "  ? $$chapter_name (no .tex file)"; \
				fi; \
			fi; \
		done; \
	else \
		echo "  No chapters directory found"; \
	fi

# Build specific chapter with local fallbacks
.PHONY: build-chapter
build-chapter:
	@if [ -z "$(CHAPTER)" ]; then \
		echo "$(RED)Error: Specify chapter with CHAPTER=chapter-name$(NC)"; \
		echo "Example: make build-chapter CHAPTER=01_principles-of-operation"; \
		echo ""; \
		$(MAKE) list-chapters; \
		exit 1; \
	fi
	@if [ ! -d "chapters/$(CHAPTER)" ]; then \
		echo "$(RED)Error: Chapter directory not found: chapters/$(CHAPTER)$(NC)"; \
		echo "Available chapters:"; \
		$(MAKE) list-chapters; \
		exit 1; \
	fi
	@echo "$(BLUE)▶ Building chapter: $(CHAPTER)$(NC)"
	@CHAPTER_DIR="chapters/$(CHAPTER)"; \
	CHAPTER_TEX=$$(find "$$CHAPTER_DIR" -name "*.tex" -maxdepth 1 | head -1); \
	if [ -z "$$CHAPTER_TEX" ]; then \
		echo "$(RED)Error: No .tex file found in $$CHAPTER_DIR$(NC)"; \
		exit 1; \
	fi; \
	CHAPTER_TEX_NAME=$$(basename "$$CHAPTER_TEX"); \
	echo "Found LaTeX file: $$CHAPTER_TEX_NAME"; \
	cd "$$CHAPTER_DIR" && \
	if [ -f "../../scripts/build.sh" ]; then \
		echo "Using build script..."; \
		chmod +x "../../scripts/build.sh"; \
		../../scripts/build.sh "$$CHAPTER_TEX_NAME"; \
	else \
		echo "$(YELLOW)Build script not found, using fallback...$(NC)"; \
		pdflatex -interaction=nonstopmode "$$CHAPTER_TEX_NAME"; \
		if grep -q "\\bibdata" "$${CHAPTER_TEX_NAME%.tex}.aux" 2>/dev/null; then \
			bibtex "$${CHAPTER_TEX_NAME%.tex}"; \
			pdflatex -interaction=nonstopmode "$$CHAPTER_TEX_NAME"; \
		fi; \
		pdflatex -interaction=nonstopmode "$$CHAPTER_TEX_NAME"; \
	fi

# Setup specific chapter with local fallbacks
.PHONY: setup-chapter
setup-chapter:
	@if [ -z "$(CHAPTER)" ]; then \
		echo "$(RED)Error: Specify chapter with CHAPTER=chapter-name$(NC)"; \
		echo "Example: make setup-chapter CHAPTER=01_principles-of-operation"; \
		$(MAKE) list-chapters; \
		exit 1; \
	fi
	@if [ ! -d "chapters/$(CHAPTER)" ]; then \
		echo "$(RED)Error: Chapter directory not found: chapters/$(CHAPTER)$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)▶ Setting up chapter: $(CHAPTER)$(NC)"
	@CHAPTER_DIR="chapters/$(CHAPTER)"; \
	cd "$$CHAPTER_DIR" && \
	echo "Working in: $$(pwd)"; \
	if [ -f "../../scripts/pull-figures.sh" ] && [ "$(ICLOUD_AVAILABLE)" = "yes" ]; then \
		echo "Pulling figures..."; \
		chmod +x "../../scripts/pull-figures.sh"; \
		../../scripts/pull-figures.sh || echo "$(YELLOW)Figure script failed, continuing...$(NC)"; \
	else \
		echo "$(YELLOW)Using local figures (iCloud unavailable or script missing)$(NC)"; \
	fi; \
	if [ -f "../../scripts/pull-references.py" ] && [ "$(ICLOUD_AVAILABLE)" = "yes" ]; then \
		echo "Pulling references..."; \
		python3 ../../scripts/pull-references.py || echo "$(YELLOW)References script failed, continuing...$(NC)"; \
	else \
		echo "$(YELLOW)Using local references (iCloud unavailable or script missing)$(NC)"; \
	fi

# Clean specific chapter
.PHONY: clean-chapter
clean-chapter:
	@if [ -z "$(CHAPTER)" ]; then \
		echo "$(RED)Error: Specify chapter with CHAPTER=chapter-name$(NC)"; \
		$(MAKE) list-chapters; \
		exit 1; \
	fi
	@if [ ! -d "chapters/$(CHAPTER)" ]; then \
		echo "$(RED)Error: Chapter directory not found: chapters/$(CHAPTER)$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)▶ Cleaning chapter: $(CHAPTER)$(NC)"
	@CHAPTER_DIR="chapters/$(CHAPTER)"; \
	cd "$$CHAPTER_DIR" && \
	if [ -f "../../scripts/cleanup.sh" ]; then \
		chmod +x "../../scripts/cleanup.sh"; \
		../../scripts/cleanup.sh; \
	else \
		echo "$(YELLOW)Using fallback cleanup$(NC)"; \
		rm -f *.aux *.log *.bbl *.blg *.out *.toc *.synctex.gz *.fls *.fdb_latexmk; \
	fi; \
	echo "$(GREEN)✓ Chapter $(CHAPTER) cleaned$(NC)"

# Build all chapters
.PHONY: build-all-chapters
build-all-chapters:
	@echo "$(BLUE)▶ Building all chapters...$(NC)"
	@if [ -d "chapters" ]; then \
		for chapter_dir in chapters/*/; do \
			if [ -d "$$chapter_dir" ]; then \
				chapter_name=$$(basename "$$chapter_dir"); \
				echo "$(YELLOW)Building chapter: $$chapter_name$(NC)"; \
				$(MAKE) CHAPTER="$$chapter_name" build-chapter || exit 1; \
			fi; \
		done; \
		echo "$(GREEN)✓ All chapters built$(NC)"; \
	else \
		echo "$(RED)Error: No chapters directory found$(NC)"; \
	fi

# Setup and build specific chapter
.PHONY: chapter
chapter: setup-chapter build-chapter
	@echo "$(GREEN)✓ Chapter $(CHAPTER) setup and built$(NC)"

# Enhanced status with iCloud info
.PHONY: status
status:
	@echo "$(BLUE)================== PROJECT STATUS ==================$(NC)"
	@echo "Main file: $(MAIN_TEX)"
	@echo "PDF exists: $$([ -f '$(MAIN_PDF)' ] && echo 'Yes' || echo 'No')"
	@echo "Last build: $$([ -f '$(MAIN_PDF)' ] && stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S' '$(MAIN_PDF)' 2>/dev/null || echo 'Never')"
	@echo "TeX files: $$(ls *.tex 2>/dev/null | wc -l | xargs)"
	@echo ""
	@echo "$(BLUE)================== ASSETS STATUS ==================$(NC)"
	@echo "iCloud available: $(ICLOUD_AVAILABLE)"
	@if [ -d "$(LOCAL_FIGURES_DIR)" ]; then \
		fig_count=$$(find $(LOCAL_FIGURES_DIR) -type f \( -name "*.png" -o -name "*.pdf" -o -name "*.eps" -o -name "*.jpg" \) 2>/dev/null | wc -l | xargs); \
		echo "Local figures: $$fig_count"; \
	else \
		echo "Local figures: Directory not found"; \
	fi
	@if [ -f "$(LOCAL_REFS_FILE)" ]; then \
		ref_count=$$(grep -c "^@" "$(LOCAL_REFS_FILE)" 2>/dev/null || echo "0"); \
		echo "Local references: $$ref_count"; \
	else \
		echo "Local references: File not found"; \
	fi
	@echo "$(BLUE)====================================================$(NC)"

# Verbose mode
ifdef VERBOSE
  MAKEFLAGS += --debug=v
endif