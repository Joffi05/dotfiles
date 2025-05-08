% myproblemset.cls
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{aufgaben}[2023/10/14 Custom class for physics problem sets]

% Base class
\LoadClass[12pt,a4paper]{article}

% Language settings
\RequirePackage[ngerman]{babel}    % German language support
\RequirePackage[utf8]{inputenc}    % UTF-8 encoding
\RequirePackage[T1]{fontenc}       % Font encoding

% Mathematics and physics packages
\RequirePackage{amsmath, amssymb}  % Advanced math
\RequirePackage{physics}           % Common physics notation
\RequirePackage{siunitx}           % SI units

% Formatting packages
\RequirePackage{geometry}          % Page geometry
\RequirePackage{graphicx}          % Including graphics
\RequirePackage{fancyhdr}          % Custom headers and footers
\RequirePackage{lastpage}          % Reference to the last page
\RequirePackage{enumitem}          % Customizable lists
\RequirePackage{hyperref}          % Hyperlinks
\RequirePackage{titlesec}          % Section formatting

% Set up page geometry
\geometry{
    left=2.5cm,
    right=2.5cm,
    top=2cm,
    bottom=2cm
}

% Custom header and footer
\pagestyle{fancy}
\fancyhf{}  % Clear all header and footer fields
\fancyhead[L]{\course}   % Left header: Course name
\fancyhead[R]{\studentname}  % Right header: Student name
\fancyfoot[L]{\today}    % Left footer: Date
\fancyfoot[R]{\university} % Right footer: University name

% Custom commands for student information
\newcommand{\studentname}{Name des Studenten}
\newcommand{\matrikelnummer}{Matrikelnummer}
\newcommand{\course}{Kursname}
\newcommand{\university}{Name der Universität}

% Title formatting
\renewcommand{\maketitle}{
    \begin{center}
        {\Large \textbf{\course}} \\
        {\large Problemset \problemsetnumber} \\
        \vspace{1em}
        \studentname \\
        Matrikelnummer: \matrikelnummer \\
        \today \\
    \end{center}
    \vspace{2em}
}

% Custom environment for problems
\newcounter{problem}
\newenvironment{problem}{
    \refstepcounter{problem}
    \par\noindent
    \textbf{Aufgabe \theproblem.}
}{
    \par
}

% Custom environment for solutions (optional)
\newenvironment{solution}{
    \par\noindent
    \textbf{Lösung zu Aufgabe \theproblem.}
    \par
}{
    \par
}

% Section formatting
\titleformat{\section}{\normalfont\Large\bfseries}{\thesection}{1em}{}

% Additional packages or commands can be added as needed

