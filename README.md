# Open Atomic Ethernet Specification

This repository contains the LaTeX source for the Open Atomic Ethernet (OAE) specification document.

<div align="center">
<img width="617" alt="Screenshot 2025-07-08 at 6 24 10 PM" src="https://github.com/user-attachments/assets/633a67f8-90b3-419a-96e0-267c4cf36e7c" />
</div>

## Quick Start

### Prerequisites

- **Required**: LaTeX distribution (e.g., MacTeX, TeX Live), `tufte-book` document class
- **Optional**: Python 3, fswatch/inotifywait (for auto-rebuild), aspell (spell check)

### Building the Complete Document

```bash
# Simple build (handles everything automatically)
make

# Or step by step
make setup    # Pull figures and references
make build    # Build the PDF
```

### Building Individual Chapters

```bash
# List available chapters
make list-chapters

# Build a specific chapter
make chapter CHAPTER=01_principles-of-operation

# Build all chapters
make build-all-chapters
```

### Development Workflow

```bash
# Auto-rebuild on file changes
make watch

# Quick build (single pass, for rapid iteration)
make quick

# Check for issues
make check

# Clean and rebuild
make clean build
```

## Document Structure

The specification is organized into the following chapters:

1. **Chapter 1: Principles of Operation** -- Overview of high-level ideas behind atomic ethernet. Not meant to explain theory or implementation. It is to give a conceptual backplane for the rest of the document.
2. **Chapter 2: Bits and Bytes** -- Deep dive into the bits and bytes and frame formats of atomic ethernet. Explains the operation of each byte, and the state machines governing transitions.
3. **Chapter 3: Cells and Links** -- Explores the fundamental elements of atomic ethernet: CELLs (reactive, self-contained participants) and LINKs (bidirectional tunnel-elements between CELLs). Covers failure modes, discovery protocols, and the importance of triangular relationships for atomicity.
4. **Chapter 4: Addressing and Routing** -- Details the algorithm for building Trees and using trees to restrict addressability. Explains the shortcomings of source/destination addressing.
5. **Chapter 5: Transactions** -- Details the mathematical foundations of reversible transactions, including vector-based data modeling, invertible operations, and state updates. Specifies how transactions can be precisely undone for rollback, audit, and error recovery.
6. **Chapter 6: Architecture** -- Describes the slice engine design and architectural framework with four Shannon-like levels of information processing. Covers ANT and BEE scouting protocols for local and global network exploration.
7. **Chapter 7: Topology** -- Examines graph-aware determinism and network resilience metrics. Introduces concepts like algebraic connectivity and edge-disjoint paths to measure and ensure network robustness under failures.
8. **Chapter 8: Ultra-Ethernet** -- Describes comparisons with various other network technologies (NVLink, UALink, Infiniband, Ethernet, Scale-Up Ethernet). Specifies Ultra Ethernet's scope, performance + scalability, open issues, and FITO analysis.
9. **Chapter 9: History** -- Traces the evolution of networking protocols from ALOHA to modern Ethernet, with special focus on ATM's flow control debates and InfiniBand's innovations in reliability and performance.
10. **Chapter 10: Theory** -- Challenges conventional networking concepts and terminology. Introduces new frameworks for understanding information, causality, and quantum mechanics in the context of distributed systems.
11. **Chapter 11: Requirements & Use Cases** -- Provides information on the functional requirements, scope, and analysis over the Open Atomic Ethernet Standard.

## Project Organization

### Directory Structure

```
├── OAE-SPEC-MAIN.tex          # Main document file
├── oae-settings.tex           # Document settings and packages
├── oae-commands.tex           # Custom LaTeX commands
├── Makefile                   # Build automation
├── scripts/                   # Build and utility scripts
│   ├── build.sh              # Main build script
│   ├── pull-figures.sh       # Figure synchronization
│   ├── pull-references.py    # Reference extraction
│   ├── format-latex.sh       # Code formatting
│   ├── cleanup.sh            # Cleanup auxiliary files
│   └── bundle.sh             # Create distribution archive
├── chapters/                  # Individual chapter directories
│   ├── 01_principles-of-operation/
│   │   ├── principles-of-operation.tex
│   │   └── sections/         # Chapter sections
│   ├── 02_bits-and-bytes/
│   └── ...
├── figures/                   # Local figures directory
├── references/                # Local references
│   └── references.bib        # Bibliography file
└── README.md
```

### Asset Management

The project supports both cloud-synchronized and local-only workflows:

**Cloud Sync (with iCloud)**
- Figures and references are automatically pulled from central repositories
- Run `make check-icloud` to verify iCloud availability

**Local-Only (without iCloud)**
- Automatically detected and handled by the Makefile
- Run `make init-local-assets` to set up local directories
- Add figures to `figures/` directory
- Add bibliography entries to `references/references.bib`

## Build System Features

### Available Make Targets

#### Quick Reference
```bash
make                    # Build complete document
make help              # Show all available commands
make status            # Show project status
```

#### Build Targets
```bash
make build             # Full build with setup
make build-local       # Build using only local assets
make quick             # Quick build (single pass)
make fallback-build    # Build without scripts
```

#### Setup and Asset Management
```bash
make setup             # Pull figures and references
make setup-local       # Setup using local assets only
make figures           # Pull figures from repository
make figures-local     # Use local figures only
make references        # Extract references
make references-local  # Use local references only
make init-local-assets # Create local asset directories
```

#### Chapter Management
```bash
make list-chapters                      # List available chapters
make chapter CHAPTER=chapter-name       # Setup and build specific chapter
make build-chapter CHAPTER=chapter-name # Build specific chapter
make setup-chapter CHAPTER=chapter-name # Setup specific chapter
make clean-chapter CHAPTER=chapter-name # Clean specific chapter
make build-all-chapters                 # Build all chapters
```

#### Development Tools
```bash
make watch             # Auto-rebuild on changes
make format            # Format LaTeX code
make count             # Count words in documents
make check             # Check for undefined refs and missing figures
make spell             # Run spell checker
```

#### Cleanup and Packaging
```bash
make clean             # Remove auxiliary files
make clean-all         # Deep clean (including PDFs)
make bundle            # Create distribution archive
make backup            # Create timestamped backup
```

#### Utilities
```bash
make open              # Open generated PDF
make install-deps      # Check dependencies
make check-icloud      # Check iCloud availability
```

### Custom Variables
```bash
# Use different main file
make MAIN_TEX=custom.tex build

# Verbose output
make VERBOSE=1 build
```

## Chapter Development

### Chapter Structure

Each chapter is organized as a standalone document that can be compiled independently:

```tex
\documentclass[../../OAE-SPEC-MAIN.tex]{subfiles}

\title{Chapter Title}

\begin{document}

\chapter{Chapter Title}\label{sec:chapter-label}

\subfile{./sections/intro.tex}
\subfile{./sections/section1.tex}
% ... more sections

\end{document}
```

### Section Structure

Sections are stored as individual files in the chapter's `sections/` directory:

```tex
\documentclass[../../../OAE-SPEC-MAIN.tex]{subfiles}

\begin{document}

\section{Section Title}

Content goes here...

\end{document}
```

### Development Workflow

#### Compiling with `pdflatex` and `bibtex`
_PS: While the `Makefile` can be used to streamline development, typesetting in `pdflatex` and `bibtex` works as well_.

- Each section, chapter, or the entire specification can be compiled standalone with `pdflatex` for their respective `.tex` file.

Example:

Compiling entire document
```sh
pdflatex OAE_SPEC_MAIN.tex
bibtex OAE_SPEC_MAIN
pdflatex OAE_SPEC_MAIN.tex
pdflatex OAE_SPEC_MAIN.tex
```

Compiling a chapter
```sh
pdflatex ./chapters/03_cells-and-links/cells-and-links.tex
bibtex ./chapters/03_cells-and-links/cells-and-links
pdflatex ./chapters/03_cells-and-links/cells-and-links.tex
pdflatex ./chapters/03_cells-and-links/cells-and-links.tex
```

Compiling a section
```sh
pdflatex ./chapters/01_principles-of-operation/section/intro.tex
bibtex ./chapters/01_principles-of-operation/section/intro
pdflatex ./chapters/01_principles-of-operation/section/intro.tex
pdflatex ./chapters/01_principles-of-operation/section/intro.tex
```
#### For Individual Chapters

1. **List available chapters**:
   ```bash
   make list-chapters
   ```

2. **Work on a specific chapter**:
   ```bash
   make chapter CHAPTER=01_principles-of-operation
   ```

3. **Auto-rebuild while editing**:
   ```bash
   cd chapters/01_principles-of-operation
   make watch  # From project root, or use your editor's LaTeX tools
   ```

#### For the Complete Document

1. **Make changes to any chapter or section**

2. **Test your changes**:
   ```bash
   make quick              # Fast single-pass build
   make check              # Check for issues
   ```

3. **Full rebuild**:
   ```bash
   make clean build        # Clean rebuild
   ```

### Safe Editing Practices

When modifying chapters, follow this workflow:

1. **Create a working copy**:
   ```bash
   cp chapters/03_cells-and-links/cells-and-links.tex \
      chapters/[WIP]03_cells-and-links.tex
   ```

2. **Make and test changes**:
   ```bash
   # Edit the working copy
   make build-chapter CHAPTER=[WIP]03_cells-and-links
   ```

3. **Replace original when ready**:
   ```bash
   cp chapters/03_cells-and-links/cells-and-links.tex \
      chapters/03_cells-and-links/cells-and-links.tex.backup
   cp chapters/[WIP]03_cells-and-links.tex \
      chapters/03_cells-and-links/cells-and-links.tex
   ```

4. **Verify full document**:
   ```bash
   make clean build
   ```

5. **Version control**:
   ```bash
   git checkout -b feature/chapter-updates
   git add .
   git commit -m "Update Chapter 3: Cells and Links"
   git push --set-upstream origin feature/chapter-updates
   ```

## Environment Setup

### Dependencies

**Required**:
- LaTeX distribution (MacTeX on macOS, TeX Live on Linux)
- `pdflatex` and `bibtex` commands
- `tufte-book` document class and required packages

**Optional but recommended**:
- Python 3 (for reference processing scripts)
- `fswatch` (macOS) or `inotifywait` (Linux) for auto-rebuild
- `aspell` for spell checking
- `detex` for word counting

### Installation Examples

**macOS**:
```bash
# Install MacTeX
brew install --cask mactex

# Install optional tools
brew install fswatch aspell python

# Check installation
make install-deps
```

**Ubuntu/Debian**:
```bash
# Install TeX Live
sudo apt-get install texlive-full

# Install optional tools
sudo apt-get install inotify-tools aspell python3 detex

# Check installation
make install-deps
```

### Troubleshooting

1. **Check system status**:
   ```bash
   make status
   make install-deps
   ```

2. **Build issues**:
   ```bash
   make check           # Check for common problems
   make clean build     # Clean rebuild
   make fallback-build  # Build without scripts
   ```

3. **Asset issues**:
   ```bash
   make check-icloud          # Check cloud sync availability
   make init-local-assets     # Set up local assets
   make build-local           # Build with local assets only
   ```

4. **Missing figures or references**:
   - Add figures to `figures/` directory
   - Add bibliography entries to `references/references.bib`
   - Run `make setup-local` to use local assets

## Advanced Features

### Auto-rebuild During Development

```bash
# Watch for changes and auto-rebuild
make watch
```

This monitors `.tex` files for changes and automatically rebuilds the document.

### Word Counting and Statistics

```bash
# Count words in all .tex files
make count

# Show project statistics
make status
```

### Quality Assurance

```bash
# Check for undefined references and missing figures
make check

# Run spell checker
make spell

# Format LaTeX code
make format
```

### Distribution and Backup

```bash
# Create clean distribution archive
make clean bundle

# Create timestamped backup
make backup
```

## Contributing

### Git Workflow

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/description
   ```

2. **Make your changes and test**:
   ```bash
   # Edit files
   make check
   make build
   ```

3. **Commit and push**:
   ```bash
   git add .
   git commit -m "Description of changes"
   git push --set-upstream origin feature/description
   ```

4. **Create a pull request** through GitHub

### Code Style

- Use the provided formatting tools: `make format`
- Follow existing chapter and section structure
- Test both individual chapters and the complete document
- Run `make check` before submitting changes

### Documentation

- Update this README when adding new features
- Document any new Make targets or scripts
- Include examples for complex workflows

## License

Copyright © 2025 Open Compute Project Foundation

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
