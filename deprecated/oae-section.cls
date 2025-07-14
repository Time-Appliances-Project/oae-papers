\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{oae-chapter}[2025/07/05 OAE Section Class]

% Prevent problematic packages from loading by telling LaTeX they're already loaded
\makeatletter
\expandafter\let\csname ver@minitoc.sty\endcsname\@empty
\expandafter\let\csname ver@listings.sty\endcsname\@empty
\expandafter\let\csname ver@siunitx.sty\endcsname\@empty
\expandafter\let\csname ver@listingsutf8.sty\endcsname\@empty
\expandafter\let\csname ver@natbib.sty\endcsname\@empty
\expandafter\let\csname ver@acro.sty\endcsname\@empty
\expandafter\let\csname ver@usebib.sty\endcsname\@empty
\expandafter\let\csname ver@algorithm2e.sty\endcsname\@empty
\expandafter\let\csname ver@transparent.sty\endcsname\@empty
\makeatother

% Handle options and pass them to tufte-book
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{tufte-book}}
\ProcessOptions\relax

% Load base class
\LoadClass{tufte-book}

% Essential packages
\RequirePackage{graphicx}
\RequirePackage{subfiles}
\RequirePackage{verbatim}

% Set graphics path for chapter compilation
\graphicspath{{../../../../FIGURES/}{../../../../../FIGURES/}{./FIGURES/}}

% Define all problematic commands as no-ops BEFORE loading settings
\providecommand{\dominitoc}{}
\providecommand{\minitoc}{}
\providecommand{\mtcsetfont}[3]{}
\newcounter{minitocdepth}

% Define comprehensive listings-related commands as no-ops
\providecommand{\lstset}[1]{}
\providecommand{\lstinputlisting}[2][]{}
\providecommand{\lstdefinestyle}[2]{}
\providecommand{\lstnewenvironment}[3]{}
\providecommand{\lstloadlanguages}[1]{}
\providecommand{\lstalias}[2]{}
\providecommand{\lstMakeShortInline}[1]{}
\providecommand{\lstDeleteShortInline}[1]{}

% Define internal listings commands (use \def to avoid @ issues)
\makeatletter
\def\lst@AddToHook#1#2{}
\def\thelstnumber{\arabic{lstnumber}}
\def\NAT@set@cites{}
\def\NAT@idxtxt{}
\def\NAT@@setcites{}
\def\TRP@list{}
\makeatother

% Create listings counters and environments
\newcounter{lstlisting}
\newcounter{lstnumber}
\newenvironment{lstlisting}[1][]{\verbatim}{\endverbatim}

% Define siunitx commands as no-ops
\providecommand{\si}[1]{#1}
\providecommand{\SI}[2]{#1~#2}
\providecommand{\num}[1]{#1}
\providecommand{\sisetup}[1]{}

% Define natbib commands as no-ops
\providecommand{\citep}[2][]{\textbf{[CITE]}}
\providecommand{\citet}[2][]{\textbf{AUTHOR [CITE]}}
\providecommand{\setcitestyle}[1]{}

% Define acro commands as no-ops
\providecommand{\ACRO}[2]{}
\providecommand{\acrodef}[3][]{}
\providecommand{\ac}[1]{\textbf{#1}}
\providecommand{\acp}[1]{\textbf{#1s}}
\providecommand{\acf}[1]{\textbf{#1}}
\providecommand{\acs}[1]{\textbf{#1}}
\providecommand{\acl}[1]{\textbf{#1}}
\providecommand{\acsetup}[1]{}

% Define usebib commands as no-ops
\providecommand{\bibinput}[1]{}
\providecommand{\usebibdata}[1]{}

% Define algorithm2e commands as no-ops
\providecommand{\SetAlgoLined}{}
\providecommand{\SetAlgoShortEnd}{}
\providecommand{\SetAlgoVlined}{}
\providecommand{\DontPrintSemicolon}{}
\providecommand{\SetAlgoSkip}[1]{}
\providecommand{\KwSty}[1]{\textbf{#1}}
\providecommand{\ArgSty}[1]{\textit{#1}}
\providecommand{\SetKwComment}[3]{}
\providecommand{\CommentSty}[1]{\textit{#1}}
\providecommand{\SetKwProg}[4]{}
\providecommand{\ProgSty}[1]{\textbf{#1}}

% Define filename-related commands
\makeatletter
\providecommand{\filename@parse}[1]{%
  \def\filename@base{#1}%
  \def\filename@ext{}%
}
\providecommand{\filename@base}{}
\providecommand{\filename@ext}{}
\makeatother

% Disable tcolorbox listings integration
\providecommand{\tcbuselibrary}[1]{}
\AtBeginDocument{\let\tcbuselibrary\@gobble}

% Add verbatim environment for code blocks
\newenvironment{lstcode}{\verbatim}{\endverbatim}
\newenvironment{verilogcode}{\verbatim}{\endverbatim}

% Define package options to prevent clashes
\PassOptionsToPackage{detect-all}{siunitx}
\PassOptionsToPackage{list-style=longtable}{acro}

% Load settings and commands
\makeatletter
\AtBeginDocument{%
  % Load settings
  \IfFileExists{../../../oae-settings.tex}{%
    \typeout{*** Loading ../../../oae-settings.tex ***}%
    \input{../../../oae-settings.tex}%
    % Reset graphics path after settings load
    \graphicspath{{../../../../FIGURES/}{../../../../../FIGURES/}{./FIGURES/}}%
    \typeout{*** Graphics path set to ../../../../FIGURES/ ***}%
  }{%
    \typeout{*** WARNING: oae-settings.tex not found ***}%
  }%
  
  % Load commands  
  \IfFileExists{../../../oae-commands.tex}{%
    \typeout{*** Loading ../../../oae-commands.tex ***}%
    \input{../../../oae-commands.tex}%
  }{%
    \typeout{*** WARNING: oae-commands.tex not found ***}%
  }%
}
\makeatother