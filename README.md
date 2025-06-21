# Open Atomic Ethernet Specification

This repository contains the LaTeX source for the Open Atomic Ethernet (OAE) specification document.

## Document Structure

The specification is organized into the following chapters:

1. **Principles of Operation** -- Overview of high-level ideas behind atomic ethernet. Not meant to explain theory or implementation. It is to give a conceptual backplane for the rest of the document.
2. **Bits and Bytes** -- Deep dive into the bits and bytes and frame formats of atomic ethernet. Explains the operation of each byte, and the state machines governing transitions.
3. **Cells and Links** -- Explores the fundamental elements of atomic ethernet: CELLs (reactive, self-contained participants) and LINKs (bidirectional tunnel-elements between CELLs). Covers failure modes, discovery protocols, and the importance of triangular relationships for atomicity.
5. **Transactions** -- Details the mathematical foundations of reversible transactions, including vector-based data modeling, invertible operations, and state updates. Specifies how transactions can be precisely undone for rollback, audit, and error recovery.
6. **Architecture** -- Describes the slice engine design and architectural framework with four Shannon-like levels of information processing. Covers ANT and BEE scouting protocols for local and global network exploration.
7. **Topology** -- Examines graph-aware determinism and network resilience metrics. Introduces concepts like algebraic connectivity and edge-disjoint paths to measure and ensure network robustness under failures.
8. **History** -- Traces the evolution of networking protocols from ALOHA to modern Ethernet, with special focus on ATM's flow control debates and InfiniBand's innovations in reliability and performance.
9. **Theory** -- Challenges conventional networking concepts and terminology. Introduces new frameworks for understanding information, causality, and quantum mechanics in the context of distributed systems.


**I think we're missing a chapter currently**
- **Addressing and Routing** -- Details the algorithm for building Trees and using trees to restrict addressability. Explains the shortcomings of source/destination addressing.

## Building the Document

### Prerequisites

- A LaTeX distribution (e.g., MacTex)
- The `tufte-book` document class
- Required LaTeX packages (specified in `oae-settings.tex`)

### Building

To build the complete specification:

```bash
latex OAE-SPEC-MAIN.tex
bibtex OAE-SPEC-MAIN.tex
latex OAE-SPEC-MAIN.tex
latex OAE-SPEC-MAIN.tex
```

This will generate `OAE-SPEC-MAIN.pdf` containing the complete specification.

### Structure

The main file is designed to be extremely simple, and require no changes
when writing new content other than adding new chapters.

```tex
\documentclass[justified,nobib,oneside]{tufte-book}

\input{oae-settings}
\input{oae-commands}

\title{Open Atomic \\ Ethernet}
\author{}
\date{June 2025}
\publisher{Open Compute Project -- OAE Workstream}

\begin{document}
  \frontmatter\pagenumbering{roman}

  \maketitle

  \tableofcontents

  \mainmatter\setcounter{page}{1}\pagenumbering{arabic}

  \subfile{chapters/01_principles-of-operation}
  \subfile{chapters/02_bits-and-bytes}
  \subfile{chapters/03_cells-and-links}
  \subfile{chapters/04_transactions}
  \subfile{chapters/05_architecture}
  \subfile{chapters/06_topology}
  \subfile{chapters/07_history}
  \subfile{chapters/08_theory}
  
\end{document}

```


## Chapters

### Structure

Each chapter is stored in the `chapters/` directory as a separate `.tex` file. The main document (`OAE-SPEC-MAIN.tex`) includes these chapters using the `\subfile` command.

```tex
\documentclass[../OAE-SPEC-MAIN.tex]{subfiles}

\title{Principles of Operation}

\begin{document}

\chapter{Principles of Operation}\label{sec:principles-of-operation}

%...

\end{document}
```

### Handouts

Each chapter is designed to compile into a PDF containing only the chapter content. No additional
changes or modifications to the preamble are required.

```bash
latex 00_chapter.tex
bibtex 00_chapter.tex
latex 00_chapter.tex
latex 00_chapter.tex
```

### Making Changes

When modifying a chapter, follow this workflow to ensure safe editing:

1. **Create a Working Copy**
   - Copy only the chapter you want to modify to a work-in-progress copy
   - Example: `chapters/[PLB]03_cells-and-links.tex`

2. **Make Your Changes**
   - Edit the working copy
   - verify your changes locally with the per-chapter output PDF

3. **Replace Original**
   - Create a backup of the original chapter
   - Replace the original with your verified working copy
   - Ensure the full document compiles

This workflow ensures you always have a backup and can verify changes before replacing the original file.

## Copyright

Copyright © 2025 Open Compute Project Foundation

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
