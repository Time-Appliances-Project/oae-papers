\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{oae-chapter}[2025/07/07 OAE Chapter Class - Fixed]

% Handle options and pass them to tufte-book
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{tufte-book}}
\ProcessOptions\relax

% PREVENT problematic packages from loading completely
\makeatletter
\expandafter\edef\csname ver@minitoc.sty\endcsname{2020/01/01}
\expandafter\edef\csname ver@listings.sty\endcsname{2020/03/24}
\expandafter\edef\csname ver@listingsutf8.sty\endcsname{2013/02/03}
\expandafter\edef\csname ver@natbib.sty\endcsname{2010/09/13}
\expandafter\edef\csname ver@usebib.sty\endcsname{2006/05/30}
\expandafter\edef\csname ver@transparent.sty\endcsname{2019/11/29}
\expandafter\edef\csname ver@siunitx.sty\endcsname{2021/02/11}
\expandafter\edef\csname ver@algorithm2e.sty\endcsname{2017/10/25}
\expandafter\edef\csname ver@acro.sty\endcsname{2021/02/26}
\makeatother

% Pass options for packages that we DO want to load
\PassOptionsToPackage{colorlinks=true}{hyperref}
\PassOptionsToPackage{enhanced,breakable,skins,theorems}{tcolorbox}

% Load base class
\LoadClass{tufte-book}

% Essential packages
\RequirePackage{graphicx}
\RequirePackage{subfiles}
\RequirePackage{verbatim}

% Set graphics path for chapter compilation
\graphicspath{{../../../../FIGURES/}{../../../../../FIGURES/}{./FIGURES/}}

% Define no-ops for problematic commands BEFORE loading settings
\makeatletter
\providecommand{\dominitoc}{}
\providecommand{\minitoc}{}
\providecommand{\mtcsetfont}[3]{}
\newcounter{minitocdepth}

% listings no-ops
\providecommand{\lstset}[1]{}
\providecommand{\lstinputlisting}[2][]{}
\providecommand{\lstdefinestyle}[2]{}
\providecommand{\lstnewenvironment}[3]{}
\providecommand{\lstloadlanguages}[1]{}
\providecommand{\lstalias}[2]{}
\providecommand{\lstMakeShortInline}[1]{}
\providecommand{\lstDeleteShortInline}[1]{}
\def\lst@AddToHook#1#2{}
\def\thelstnumber{\arabic{lstnumber}}
\newcounter{lstlisting}
\newcounter{lstnumber}
\newenvironment{lstlisting}[1][]{\verbatim}{\endverbatim}

% natbib no-ops
\providecommand{\citep}[2][]{\textbf{[CITE]}}
\providecommand{\citet}[2][]{\textbf{AUTHOR [CITE]}}
\providecommand{\setcitestyle}[1]{}
\def\NAT@set@cites{}
\def\NAT@idxtxt{}
\def\NAT@@setcites{}

% usebib no-ops
\providecommand{\bibinput}[1]{}
\providecommand{\usebibdata}[1]{}

% transparent no-ops
\def\TRP@list{}

% acro no-ops (but allow it to load since it's not as problematic)
\providecommand{\ACRO}[2]{}
\providecommand{\acrodef}[3][]{}
\providecommand{\ac}[1]{\textbf{#1}}
\providecommand{\acp}[1]{\textbf{#1s}}
\providecommand{\acf}[1]{\textbf{#1}}
\providecommand{\acs}[1]{\textbf{#1}}
\providecommand{\acl}[1]{\textbf{#1}}
\providecommand{\acsetup}[1]{}

% filename parsing
\providecommand{\filename@parse}[1]{%
  \edef\@tempa{#1}%
  \expandafter\filename@parse@aux\@tempa.\relax%
}
\def\filename@parse@aux#1.#2\relax{%
  \def\filename@base{#1}%
  \ifx\relax#2\relax
    \def\filename@ext{}%
  \else
    \def\filename@ext{#2}%
  \fi
}
\providecommand{\filename@base}{}
\providecommand{\filename@ext}{}

% Handle algorithm2e and siunitx by completely blocking them and providing robust no-ops
\providecommand{\DontPrintSemicolon}{}
\providecommand{\SetAlgoSkip}[1]{}
\providecommand{\SetAlgoLined}{}
\providecommand{\SetAlgoShortEnd}{}
\providecommand{\SetAlgoVlined}{}
\providecommand{\KwSty}[1]{\textbf{#1}}
\providecommand{\ArgSty}[1]{\textit{#1}}
\providecommand{\SetKwComment}[3]{}
\providecommand{\CommentSty}[1]{\textit{#1}}
\providecommand{\SetKwProg}[4]{}
\providecommand{\ProgSty}[1]{\textbf{#1}}
\providecommand{\algocf@nl@sethref}{}
\providecommand{\@algocf@init}{}
\providecommand{\algocf@within}{}

% siunitx no-ops - these MUST come before any possibility of siunitx loading
\providecommand{\si}[1]{#1}
\providecommand{\SI}[2]{#1~#2}
\providecommand{\num}[1]{#1}
\providecommand{\sisetup}[1]{}
\makeatother

% Load settings and commands WITHOUT debug output
\AtBeginDocument{%
  % Load settings silently
  \IfFileExists{../../oae-settings.tex}{%
    \input{../../oae-settings.tex}%
    % Reset graphics path after settings load
    \graphicspath{{../../../../FIGURES/}{../../../../../FIGURES/}{./FIGURES/}}%
  }{}%
  
  % Load commands silently
  \IfFileExists{../../oae-commands.tex}{%
    \input{../../oae-commands.tex}%
  }{}%
}