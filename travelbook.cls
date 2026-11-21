%% travelbook.cls -- a printable A5 travel memory book.
%%
%% Built on memoir, which separates the stock (the sheet the PDF is printed on)
%% from the trimmed page natively. Bleed and crop marks for the print shop are
%% therefore just a setting, and with the defaults the PDF is exactly A5.
%% Compile with LuaLaTeX (latexmk, see .latexmkrc).
%%
%% Style lives here; content lives in the document. Per-book choices (palette,
%% binding offset, bleed, cover photo) go in \travelsetup{...} in the preamble.
\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesClass{travelbook}[2026/11/21 v1.0 Printable A5 travel memory book]

% ---------------------------------------------------------------- options
% The language is a class option (english by default); everything else goes to memoir.
\def\tb@language{english}
\DeclareOption{english}{\def\tb@language{english}}
\DeclareOption{italian}{\def\tb@language{italian}}
\DeclareOption{french}{\def\tb@language{french}}
\DeclareOption{german}{\def\tb@language{ngerman}}
\DeclareOption{spanish}{\def\tb@language{spanish}}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{memoir}}
\ProcessOptions\relax
\LoadClass[11pt,twoside,openright]{memoir}

\RequirePackage{iftex}
\RequireLuaTeX

% ---------------------------------------------------------------- packages
\RequirePackage[\tb@language]{babel}
\RequirePackage{fontspec}
\RequirePackage{microtype}
\RequirePackage{graphicx}
\RequirePackage{xcolor}
\RequirePackage{tikz}
\usetikzlibrary{calc,fadings,shadows.blur}
\RequirePackage[hidelinks,pdfusetitle]{hyperref}

% ---------------------------------------------------------------- fixed strings
% English defaults, overridden for the other languages; redefine them freely.
\newcommand\partlabel{Part}
\newcommand\stoplabel{Stop}
\newcommand\itineraryname{Itinerary}
\newcommand\mapname{Map}
\renewcommand\notesname{Notes}
\newcommand\memoryname{Today's memory}
\def\tb@tmp{italian}\ifx\tb@language\tb@tmp
  \renewcommand\partlabel{Parte}\renewcommand\stoplabel{Tappa}
  \renewcommand\itineraryname{Itinerario}\renewcommand\mapname{Mappa}
  \renewcommand\notesname{Note}\renewcommand\memoryname{Il ricordo di oggi}
\fi
\def\tb@tmp{french}\ifx\tb@language\tb@tmp
  \renewcommand\partlabel{Partie}\renewcommand\stoplabel{\'Etape}
  \renewcommand\itineraryname{Itin\'eraire}\renewcommand\mapname{Carte}
  \renewcommand\notesname{Notes}\renewcommand\memoryname{Le souvenir du jour}
\fi
\def\tb@tmp{ngerman}\ifx\tb@language\tb@tmp
  \renewcommand\partlabel{Teil}\renewcommand\stoplabel{Etappe}
  \renewcommand\itineraryname{Reiseroute}\renewcommand\mapname{Karte}
  \renewcommand\notesname{Notizen}\renewcommand\memoryname{Erinnerung des Tages}
\fi
\def\tb@tmp{spanish}\ifx\tb@language\tb@tmp
  \renewcommand\partlabel{Parte}\renewcommand\stoplabel{Etapa}
  \renewcommand\itineraryname{Itinerario}\renewcommand\mapname{Mapa}
  \renewcommand\notesname{Notas}\renewcommand\memoryname{El recuerdo del d\'ia}
\fi

% ---------------------------------------------------------------- settings
\newlength\tb@bleed     % bleed on each side
\newlength\tb@binding   % binding offset, added to the inner margin
\setlength\tb@bleed{0mm}
\setlength\tb@binding{5mm}
\newif\iftb@cropmarks
\newif\iftb@showpaths \tb@showpathstrue
\def\tb@coverphoto{photos/cover}
\def\tb@subtitle{}

\pgfkeys{
  /travelbook/.is family, /travelbook,
  bleed/.code      = {\setlength\tb@bleed{#1}},
  binding/.code    = {\setlength\tb@binding{#1}},
  cropmarks/.is if = tb@cropmarks,
  showpaths/.is if = tb@showpaths,
  palette/.code    = {\usepalette{#1}},
  coverphoto/.store in = \tb@coverphoto,
}
%% \travelsetup{key=value, ...}: preamble only.
\newcommand\travelsetup[1]{\pgfkeys{/travelbook,#1}}

% ---------------------------------------------------------------- palette
%% Five named colours; each book picks a preset or sets its own.
%%   tb-primary    headings, part pages, rules
%%   tb-secondary  dates, small details
%%   tb-accent     dots, ornaments
%%   tb-paper      background of placeholders
%%   tb-text       body text
%% \setcolors{primary}{secondary}{accent}{paper}{text}, HTML hex codes.
\newcommand\setcolors[5]{%
  \definecolor{tb-primary}{HTML}{#1}%
  \definecolor{tb-secondary}{HTML}{#2}%
  \definecolor{tb-accent}{HTML}{#3}%
  \definecolor{tb-paper}{HTML}{#4}%
  \definecolor{tb-text}{HTML}{#5}%
}
\newcommand\tb@palette@sea{\setcolors{1F4E5F}{4F8A8B}{E07A5F}{F2EADF}{222B2E}}
\newcommand\tb@palette@jungle{\setcolors{2F4A34}{7A8B5A}{C0623B}{F1EAD8}{262620}}
\newcommand\tb@palette@ink{\setcolors{2B2A28}{6B6862}{B8862F}{EFEDE8}{1E1D1B}}
\newcommand\tb@palette@sunset{\setcolors{5B2A44}{B5654A}{E9A23B}{F6ECE2}{2A1E22}}
%% \usepalette{sea|jungle|ink|sunset}
\newcommand\usepalette[1]{%
  \ifcsname tb@palette@#1\endcsname
    \csname tb@palette@#1\endcsname
  \else
    \ClassWarning{travelbook}{Unknown palette `#1', using `sea'}\tb@palette@sea
  \fi}
\usepalette{sea}

% ---------------------------------------------------------------- fonts
%% EB Garamond for the text, Cormorant Garamond for headings and captions.
%% Change them in the document with \setmainfont and \setheadingfont.
\setmainfont{EBGaramond}[
  Extension      = .otf,
  UprightFont    = *-Regular,
  ItalicFont     = *-Italic,
  BoldFont       = *-SemiBold,
  BoldItalicFont = *-SemiBoldItalic,
  Numbers        = OldStyle,
]
\newfontfamily\tb@headingfont{CormorantGaramond}[
  Extension      = .ttf,
  UprightFont    = *-Medium,
  ItalicFont     = *-MediumItalic,
  BoldFont       = *-Bold,
  BoldItalicFont = *-BoldItalic,
  Numbers        = Lining,
]
\newfontfamily\tb@spacedfont{EBGaramond}[
  Extension   = .otf,
  UprightFont = *-Regular,
  Letters     = SmallCaps,
  Numbers     = Lining,
  LetterSpace = 6,
]
%% \setheadingfont{FontName}[fontspec options]
\NewDocumentCommand\setheadingfont{m O{}}{\setfontfamily\tb@headingfont{#1}[#2]}
\newcommand\headingfont{\tb@headingfont}
%% \spaced{text}: letter-spaced small caps, used for dates and labels.
\newcommand\spaced[1]{{\tb@spacedfont\MakeLowercase{#1}}}
%% Font of the polaroid captions; redefine for a different hand.
\newcommand\captionfont{\tb@headingfont\itshape}

\AtBeginDocument{\color{tb-text}}

% ---------------------------------------------------------------- page layout
%% A5 trimmed page, 148 x 210 mm. Inner margin = 16 mm + binding offset.
%% With bleed > 0 the PDF sheet grows by 2 x bleed, and TrimBox/BleedBox tell
%% the print shop where to cut.
\AddToHook{begindocument/before}{%
  \setstocksize{\dimexpr210mm+2\tb@bleed\relax}{\dimexpr148mm+2\tb@bleed\relax}%
  \settrimmedsize{210mm}{148mm}{*}%
  \settrims{\tb@bleed}{\tb@bleed}%
  \setlrmarginsandblock{\dimexpr16mm+\tb@binding\relax}{15mm}{*}%
  \setulmarginsandblock{20mm}{22mm}{*}%
  \setheadfoot{\onelineskip}{2.2\onelineskip}%
  \setheaderspaces{*}{7mm}{*}%
  \checkandfixthelayout[nearest]%
  \iftb@cropmarks \trimLmarks \else \trimNone \fi
  \ifdim\tb@bleed>\z@
    \edef\tb@b{\strip@pt\dimexpr0.99626\tb@bleed\relax}%
    \edef\tb@w{\strip@pt\dimexpr0.99626\dimexpr148mm+\tb@bleed\relax\relax}%
    \edef\tb@h{\strip@pt\dimexpr0.99626\dimexpr210mm+\tb@bleed\relax\relax}%
    \edef\tb@W{\strip@pt\dimexpr0.99626\dimexpr148mm+2\tb@bleed\relax\relax}%
    \edef\tb@H{\strip@pt\dimexpr0.99626\dimexpr210mm+2\tb@bleed\relax\relax}%
    \edef\tb@boxes{/TrimBox [\tb@b\space\tb@b\space\tb@w\space\tb@h]
      /BleedBox [0 0 \tb@W\space\tb@H]}%
    \global\pdfvariable pageattr\expandafter{\tb@boxes}%
  \fi
}

\setlength\parindent{1.1em}
\setlength\parskip{0pt}
\raggedbottom
\linespread{1.06}
\frenchspacing

% ---------------------------------------------------------------- the sheet in TikZ
%% With bleed, memoir's stock is larger than \paperwidth x \paperheight, and TikZ's
%% "current page" only covers the trimmed size, anchored at the sheet's lower-left
%% corner. \tb@sheet defines the true sheet corners for full-bleed drawing:
%% (sheet nw), (sheet ne), (sheet sw), (sheet se), (sheet n), (sheet s), (sheet c).
\newcommand\tb@sheet{%
  \coordinate (sheet sw) at (current page.south west);
  \coordinate (sheet ne) at ($(sheet sw)+(\stockwidth,\stockheight)$);
  \coordinate (sheet nw) at (sheet sw |- sheet ne);
  \coordinate (sheet se) at (sheet ne |- sheet sw);
  \coordinate (sheet n) at ($(sheet nw)!.5!(sheet ne)$);
  \coordinate (sheet s) at ($(sheet sw)!.5!(sheet se)$);
  \coordinate (sheet c) at ($(sheet nw)!.5!(sheet se)$);
}

% ---------------------------------------------------------------- running heads
%% Verso: the stop. Recto: the day. Folio at the outer edge of the footer.
\makepagestyle{travel}
\makeevenhead{travel}{\small\spaced{\leftmark}}{}{}
\makeoddhead{travel}{}{}{\small\spaced{\rightmark}}
\makeevenfoot{travel}{\small\headingfont\color{tb-secondary}\thepage}{}{}
\makeoddfoot{travel}{}{}{\small\headingfont\color{tb-secondary}\thepage}
\makeheadrule{travel}{0pt}{0pt}
\makepsmarks{travel}{%
  \def\chaptermark##1{\markboth{##1}{##1}}%
  \def\sectionmark##1{\markright{##1}}%
}
%% Folio only, for the front matter and the full pages.
\makepagestyle{travel-plain}
\makeevenfoot{travel-plain}{\small\headingfont\color{tb-secondary}\thepage}{}{}
\makeoddfoot{travel-plain}{}{}{\small\headingfont\color{tb-secondary}\thepage}
\pagestyle{travel}
\aliaspagestyle{chapter}{empty}
\aliaspagestyle{part}{empty}

% ---------------------------------------------------------------- photos: finding files
%% \tb@findphoto{path}: tries the name as given, then the common extensions.
%% Leaves the file found in \tb@file (empty if missing).
\def\tb@extensions{.jpg,.jpeg,.png,.pdf,.JPG,.JPEG,.PNG}
\newcommand\tb@findphoto[1]{%
  \let\tb@file\@empty
  \IfFileExists{#1}{\filename@parse{#1}\ifx\filename@ext\relax\else\def\tb@file{#1}\fi}{}%
  \ifx\tb@file\@empty
    \@for\tb@ext:=\tb@extensions\do{%
      \ifx\tb@file\@empty
        \IfFileExists{#1\tb@ext}{\edef\tb@file{#1\tb@ext}}{}%
      \fi}%
  \fi}

%% \tb@fill{width}{height}: puts \tb@file into \tb@box, scaled to cover the whole
%% frame (the caller clips it).
\newsavebox\tb@box
\newcommand\tb@fill[2]{%
  \sbox\tb@box{\includegraphics[width=#1]{\tb@file}}%
  \ifdim\dimexpr\ht\tb@box+\dp\tb@box\relax<#2\relax
    \sbox\tb@box{\includegraphics[height=#2]{\tb@file}}%
  \fi}

%% Placeholder: paper background, dashed frame, a little mountain and sun, and the
%% expected path. Inside a tikzpicture:
%% \tb@placeholder{corner}{opposite corner}{path}{text size in pt}
\newcommand\tb@placeholder[4]{%
  \coordinate (tb@a) at (#1);
  \coordinate (tb@b) at (#2);
  \fill[tb-paper] (tb@a) rectangle (tb@b);
  \draw[tb-secondary!60, dash pattern=on 2pt off 1.5pt, line width=.5pt]
    ($(tb@a)+(1.2mm,1.2mm)$) rectangle ($(tb@b)-(1.2mm,1.2mm)$);
  \coordinate (tb@c) at ($(tb@a)!.5!(tb@b)$);
  \path let \p1=($(tb@b)-(tb@a)$), \n1={min(abs(\x1),abs(\y1))/10} in
    [fill=tb-secondary!45]
      ($(tb@c)+(-2.2*\n1,-1*\n1)$) -- ++(1.5*\n1,1.9*\n1) -- ++(0.9*\n1,-1*\n1)
        -- ++(0.6*\n1,0.6*\n1) -- ++(1.4*\n1,-1.5*\n1) -- cycle
    [fill=tb-accent!70] ($(tb@c)+(1.25*\n1,1.25*\n1)$) circle[radius=0.42*\n1];
  \iftb@showpaths
    \node[text=tb-secondary, font=\fontsize{#4}{#4}\selectfont\ttfamily, inner sep=0, anchor=south]
      at ($(tb@c|-tb@a)+(0,2.6mm)$) {\detokenize\expandafter{#3}};
  \fi
}

% ---------------------------------------------------------------- polaroids
%% \photo[options]{file}{caption}
%% options: width=<length>, landscape (default), portrait, square, angle=<degrees>
%% The file is looked up with and without extension; if missing, a placeholder
%% shows where to put it. Outside a grid the polaroid is centred, 62% of the line.
\newcounter{tb@photo}
\newlength\tb@photowidth
\newif\iftb@ingrid
\pgfkeys{
  /travelbook/photo/.is family, /travelbook/photo,
  width/.code     = {\setlength\tb@photowidth{#1}},
  landscape/.code = {\def\tb@ratio{0.75}},
  portrait/.code  = {\def\tb@ratio{1.25}},
  square/.code    = {\def\tb@ratio{1}},
  angle/.store in = \tb@angle,
}
%% Small deterministic tilts, so the page looks hand-made but rebuilds identically.
\def\tb@angles{{-2.2,1.6,-0.9,2.3,-1.6,0.8,-2.6,1.2}}

\newcommand\tb@polaroid[3]{% #1 options, #2 file, #3 caption
  \begingroup
  \stepcounter{tb@photo}%
  \iftb@ingrid\else\setlength\tb@photowidth{.62\linewidth}\fi
  \def\tb@ratio{0.75}%
  \pgfmathparse{\tb@angles[mod(\value{tb@photo},8)]}\let\tb@angle\pgfmathresult
  \pgfkeys{/travelbook/photo,#1}%
  % geometry: border, picture area, caption strip
  \dimen@=\tb@photowidth
  \edef\tb@W{\the\dimen@}%
  \edef\tb@bd{\the\dimexpr\dimen@*6/100\relax}%
  \edef\tb@iw{\the\dimexpr\dimen@-2\dimexpr\dimen@*6/100\relax\relax}%
  \pgfmathsetlengthmacro\tb@ih{\tb@iw*\tb@ratio}%
  \pgfmathsetlengthmacro\tb@cap{max(\dimen@*0.2,9mm)}%
  \tb@findphoto{#2}%
  \ifx\tb@file\@empty\else\tb@fill{\tb@iw}{\tb@ih}\fi
  \begin{tikzpicture}[rotate=\tb@angle, transform shape, baseline=(current bounding box.center)]
    \coordinate (P0) at (0,0);
    \coordinate (P1) at (\tb@W, \tb@ih+\tb@bd+\tb@cap);
    \fill[white, blur shadow={shadow blur steps=6, shadow xshift=.5mm, shadow yshift=-.6mm,
          shadow opacity=28, shadow blur extra rounding=.4mm}]
      (P0) rectangle (P1);
    \draw[black!12, line width=.3pt] (P0) rectangle (P1);
    \coordinate (I0) at (\tb@bd, \tb@cap);
    \coordinate (I1) at (\tb@bd+\tb@iw, \tb@cap+\tb@ih);
    \ifx\tb@file\@empty
      \tb@placeholder{I0}{I1}{#2}{4.5}
    \else
      \begin{scope}
        \clip (I0) rectangle (I1);
        \node[inner sep=0, anchor=center] at ($(I0)!.5!(I1)$) {\usebox\tb@box};
      \end{scope}
    \fi
    \node[anchor=center, text width=\tb@iw, align=center, inner sep=0,
          font=\captionfont\color{tb-text}]
      at (\tb@W/2, \tb@cap/2) {#3};
  \end{tikzpicture}%
  \endgroup}

\NewDocumentCommand\photo{O{}mm}{%
  \iftb@ingrid
    \tb@polaroid{#1}{#2}{#3}\hskip\dimexpr\tb@gap\relax plus 1fil\relax
  \else
    \par\medskip
    {\centering\tb@polaroid{#1}{#2}{#3}\par}%
    \medskip
  \fi}

%% \photogrid[columns]{ \photo{..}{..} \photo{..}{..} ... }
%% Polaroids side by side; rows wrap by themselves and stay centred.
\newlength\tb@gap
\NewDocumentCommand\photogrid{O{2}+m}{%
  \par\medskip
  \begingroup
  \tb@ingridtrue
  \setlength\tb@gap{5mm}%
  \setlength\tb@photowidth{\dimexpr(\linewidth-\tb@gap*#1)*92/\numexpr100*#1\relax\relax}%
  \setlength\lineskip{5mm}\setlength\lineskiplimit{5mm}%
  \setlength\parindent{0pt}%
  \setlength\leftskip{0pt plus 1fil}\setlength\rightskip{0pt plus 1fil}%
  \setlength\parfillskip{0pt}%
  \hskip\dimexpr\tb@gap\relax plus 1fil\relax\ignorespaces #2\unskip\par
  \endgroup
  \medskip}

%% \photoslots[columns]{folder}{count}: numbered placeholders folder/01 ... folder/NN
%% without captions (the white strip is for writing by hand). Fill them by
%% putting 01.jpg, 02.jpg, ... in the folder and compiling again.
\NewDocumentCommand\photoslots{O{2}mm}{%
  \photogrid[#1]{%
    \@tempcnta\z@
    \loop\ifnum\@tempcnta<#3\relax
      \advance\@tempcnta\@ne
      \edef\tb@n{\ifnum\@tempcnta<10 0\fi\the\@tempcnta}%
      \expandafter\photo\expandafter{\expanded{#2/\tb@n}}{}%
    \repeat}}

% ---------------------------------------------------------------- cover
%% \makecover: full-bleed photo, dark gradient at the bottom and a light veil at the
%% top, then title, subtitle, authors and dates over it. Uses \title, \subtitle,
%% \author, \date. The file is set with coverphoto=... (default photos/cover).
%% The cover is followed by a blank page (its back).
\newcommand\subtitle[1]{\def\tb@subtitle{#1}}
\tikzfading[name=tb-fade-down, top color=transparent!100, bottom color=transparent!12]
\tikzfading[name=tb-fade-up, top color=transparent!55, bottom color=transparent!100]

\newcommand\makecover{%
  \begingroup
  \thispagestyle{empty}%
  \tb@findphoto{\tb@coverphoto}%
  \begin{tikzpicture}[remember picture, overlay]
    \tb@sheet
    \path let \p1=($(sheet ne)-(sheet sw)$) in
      \pgfextra{\xdef\tb@pw{\x1}\xdef\tb@ph{\y1}};
    \ifx\tb@file\@empty
      \fill[top color=tb-primary, bottom color=tb-secondary]
        (sheet sw) rectangle (sheet ne);
      \tb@placeholder{$(sheet sw)+(14mm,\tb@bleed+100mm)$}%
                     {$(sheet ne)-(14mm,\tb@bleed+30mm)$}{\tb@coverphoto}{7}
    \else
      \tb@fill{\tb@pw}{\tb@ph}%
      \begin{scope}
        \clip (sheet sw) rectangle (sheet ne);
        \node[inner sep=0] at (sheet c) {\usebox\tb@box};
      \end{scope}
    \fi
    \fill[black, path fading=tb-fade-down]
      (sheet sw) rectangle ($(sheet se)+(0,\tb@bleed+95mm)$);
    \fill[black, path fading=tb-fade-up]
      ($(sheet nw)-(0,\tb@bleed+40mm)$) rectangle (sheet ne);
    \node[anchor=north, text=white, inner sep=0, font=\small]
      at ($(sheet n)-(0,\tb@bleed+14mm)$) {\spaced{\theauthor}};
    \node[anchor=south west, text=white, text width=118mm, align=left, inner sep=0]
      at ($(sheet sw)+(\tb@bleed+15mm,\tb@bleed+20mm)$) {%
        {\headingfont\fontsize{34}{36}\selectfont\thetitle\par}%
        \ifx\tb@subtitle\@empty\else
          \vspace{3mm}{\headingfont\itshape\fontsize{15}{18}\selectfont\tb@subtitle\par}\fi
        \vspace{5mm}{\color{tb-accent}\rule{18mm}{.8pt}}\par\vspace{3mm}%
        {\small\spaced{\thedate}\par}};
  \end{tikzpicture}%
  \null\clearpage
  \thispagestyle{empty}\null\clearpage
  \endgroup}

%% \maketitlepage: a quiet title page, with an optional \dedication{...}.
\newcommand\tb@dedication{}
\newcommand\dedication[1]{\renewcommand\tb@dedication{#1}}
\newcommand\maketitlepage{%
  \cleardoublepage\thispagestyle{empty}%
  \vspace*{.22\textheight}%
  \begin{center}
    {\color{tb-primary}\headingfont\fontsize{26}{29}\selectfont\thetitle\par}
    \ifx\tb@subtitle\@empty\else\vspace{2mm}{\headingfont\itshape\large\tb@subtitle\par}\fi
    \vspace{6mm}{\color{tb-accent}\rule{14mm}{.6pt}}\par\vspace{6mm}
    {\spaced{\theauthor}\par}\vspace{1mm}
    {\small\spaced{\thedate}\par}
    \ifx\tb@dedication\@empty\else
      \vfill{\itshape\tb@dedication\par}\vspace*{.12\textheight}\fi
  \end{center}
  \clearpage}

%% \contentspage: table of contents on its own page, no running head.
\newcommand\contentspage{%
  \cleardoublepage
  \begingroup\pagestyle{travel-plain}\markboth{}{}%
  \tableofcontents*\clearpage\endgroup}

% ---------------------------------------------------------------- parts, stops, days
%% \trippart{Title}{subtitle}: a full-bleed page in the primary colour.
\NewDocumentCommand\trippart{mm}{%
  \cleardoublepage
  \thispagestyle{empty}%
  \refstepcounter{part}%
  \phantomsection\addcontentsline{toc}{part}{#1}%
  \markboth{#1}{#1}%
  \begin{tikzpicture}[remember picture, overlay]
    \tb@sheet
    \fill[tb-primary] (sheet sw) rectangle (sheet ne);
    \node[text=white, align=center, text width=110mm, inner sep=0]
      at ($(sheet c)+(0,10mm)$) {%
      {\small\spaced{\partlabel\ \Roman{part}}\par}\vspace{6mm}%
      {\headingfont\fontsize{38}{40}\selectfont #1\par}\vspace{5mm}%
      {\color{tb-accent}\rule{16mm}{.8pt}}\par\vspace{5mm}%
      {\headingfont\itshape\fontsize{14}{17}\selectfont #2\par}};
  \end{tikzpicture}%
  \null\clearpage
  \thispagestyle{empty}\null\clearpage}

%% \tripstop[photo]{Place}{subtitle}: a chapter. With [photo] the top half of the
%% opening page is a full-bleed picture (a placeholder while it is missing).
\NewDocumentCommand\tripstop{omm}{%
  \cleardoublepage
  \thispagestyle{empty}%
  \refstepcounter{chapter}%
  \phantomsection\addcontentsline{toc}{chapter}{#2}%
  \chaptermark{#2}%
  \IfValueT{#1}{%
    \tb@findphoto{#1}%
    \begin{tikzpicture}[remember picture, overlay]
    \tb@sheet
      \coordinate (T0) at ($(sheet nw)-(0,\tb@bleed+95mm)$);
      \path let \p1=($(sheet ne)-(T0)$) in \pgfextra{\xdef\tb@pw{\x1}\xdef\tb@ph{\y1}};
      \ifx\tb@file\@empty
        \tb@placeholder{T0}{sheet ne}{#1}{6}
      \else
        \tb@fill{\tb@pw}{\tb@ph}%
        \begin{scope}
          \clip (T0) rectangle (sheet ne);
          \node[inner sep=0] at ($(T0)!.5!(sheet ne)$) {\usebox\tb@box};
        \end{scope}
      \fi
    \end{tikzpicture}\par
    \vspace*{82mm}}%
  \IfNoValueT{#1}{\vspace*{.25\textheight}}%
  {\raggedright
   {\small\color{tb-secondary}\spaced{\stoplabel\ \arabic{chapter}}\par}\vspace{2mm}%
   {\color{tb-primary}\headingfont\fontsize{32}{34}\selectfont #2\par}\vspace{2mm}%
   {\color{tb-accent}\rule{16mm}{.7pt}}\par\vspace{2mm}%
   {\headingfont\itshape\fontsize{14}{17}\selectfont #3\par}}%
  \vspace{8mm}\noindent\ignorespaces}

%% \tripday{date}{place}{title}: every day starts on a new page.
\NewDocumentCommand\tripday{mmm}{%
  \clearpage
  \refstepcounter{section}%
  \phantomsection\addcontentsline{toc}{section}{#1 \textperiodcentered\ #3}%
  \sectionmark{#1}%
  \begingroup\raggedright\noindent
  {\color{tb-secondary}\small\spaced{#1}%
   \hfill{\color{tb-accent}\headingfont\itshape #2}\par}%
  \vspace{1.2mm}{\color{tb-primary}\leavevmode\leaders\hrule height .4pt\hfill\kern0pt\par}%
  \vspace{3mm}%
  {\color{tb-primary}\headingfont\fontsize{21}{24}\selectfont #3\par}%
  \endgroup
  \vspace{4mm}\noindent\ignorespaces}

%% \sight{Name}: a small heading inside a day, for a place or an activity.
\newcommand\sight[1]{%
  \par\addvspace{4mm}%
  \noindent{\color{tb-accent}\textbullet}\enspace
  {\color{tb-primary}\headingfont\bfseries\large #1}\par\nobreak\vspace{1mm}%
  \noindent\ignorespaces}

%% \flourish: a small closing ornament.
\newcommand\flourish{\par\medskip{\centering\color{tb-accent}\headingfont\large
  \textasteriskcentered\quad\textasteriskcentered\quad\textasteriskcentered\par}\medskip}

% ---------------------------------------------------------------- handwriting
%% \writinglines{n}: n ruled lines for writing by hand.
\newcommand\writinglines[1]{%
  \par\medskip
  \@tempcnta\z@
  \loop\ifnum\@tempcnta<#1\relax
    \advance\@tempcnta\@ne
    \noindent{\color{tb-secondary!45}\rule{\linewidth}{.35pt}}\par\vspace{7mm}%
  \repeat}
%% \memory[title]{n}: n ruled lines under a small label (default: \memoryname).
\NewDocumentCommand\memory{O{\memoryname}m}{%
  \par\addvspace{5mm}%
  \noindent{\color{tb-secondary}\small\spaced{#1}}\par\vspace{4mm}%
  \writinglines{#2}}
%% \notespage[title]: one full page of ruled lines, as many as fit.
\NewDocumentCommand\notespage{O{\notesname}}{%
  \clearpage
  \thispagestyle{travel-plain}%
  \noindent{\color{tb-primary}\headingfont\fontsize{21}{24}\selectfont #1\par}%
  \vspace{2mm}%
  \leaders\vbox to 8mm{\vss\noindent{\color{tb-secondary!45}\rule{\linewidth}{.35pt}}}\vfill
  \clearpage}

% ---------------------------------------------------------------- itinerary and map
%% \begin{itinerary}[title] \stage{date}{place}{description} ... \end{itinerary}
%% A vertical timeline; the description may be empty.
\newif\iftb@firststage
\newenvironment{itinerary}[1][\itineraryname]{%
  \clearpage
  \thispagestyle{travel-plain}%
  \noindent{\color{tb-primary}\headingfont\fontsize{21}{24}\selectfont #1\par}%
  \vspace{6mm}%
  \begingroup\setlength\parskip{0pt}\global\tb@firststagetrue}{%
  \par\endgroup\medskip}
\newcommand\stage[3]{%
  \par\nointerlineskip\noindent
  \begin{tikzpicture}[baseline=0pt]
    \node[anchor=base west, inner sep=0, text=tb-primary, font=\headingfont\bfseries\large] (T) at (25mm,0) {#2};
    \node[anchor=north west, inner sep=0, text width=\linewidth-26mm, align=left, font=\small]
      (D) at ($(T.south west)+(0,-.6mm)$) {#3};
    \node[anchor=base east, inner sep=0, text=tb-secondary, font=\footnotesize] at (19.5mm,0) {\spaced{#1}};
    \coordinate (top) at (22mm,\iftb@firststage 1mm\else 5.5mm\fi);
    \coordinate (bot) at ($(D.south -| top)+(0,-2.2mm)$);
    \draw[tb-secondary!50, line width=.6pt] (top) -- (bot);
    \fill[white] (22mm,1mm) circle[radius=2.6pt];
    \fill[tb-accent] (22mm,1mm) circle[radius=1.6pt];
    \path (0,5.5mm) (bot);
  \end{tikzpicture}\par
  \global\tb@firststagefalse}

%% \tripmap{file}{caption}: a map image across the text block, placeholder if missing.
\newcommand\tripmap[2]{%
  \clearpage
  \thispagestyle{travel-plain}%
  \noindent{\color{tb-primary}\headingfont\fontsize{21}{24}\selectfont \mapname\par}\vspace{5mm}%
  \tb@findphoto{#1}%
  \noindent\begin{tikzpicture}
    \coordinate (M0) at (0,0); \coordinate (M1) at (\linewidth,.68\textheight);
    \ifx\tb@file\@empty
      \tb@placeholder{M0}{M1}{#1}{6}
    \else
      \tb@fill{\linewidth}{.68\textheight}%
      \clip (M0) rectangle (M1);
      \node[inner sep=0] at ($(M0)!.5!(M1)$) {\usebox\tb@box};
    \fi
  \end{tikzpicture}\par\vspace{3mm}%
  {\centering\headingfont\itshape #2\par}%
  \clearpage}

% ---------------------------------------------------------------- table of contents
\setsecnumdepth{none}
\settocdepth{section}
\renewcommand\cftpartfont{\color{tb-primary}\headingfont\bfseries\large}
\renewcommand\cftpartpagefont{\color{tb-primary}\headingfont\bfseries\large}
\renewcommand\cftchapterfont{\color{tb-primary}\headingfont\bfseries}
\renewcommand\cftchapterpagefont{\headingfont\bfseries}
\renewcommand\cftsectionfont{\small}
\renewcommand\cftsectionpagefont{\small}
\setlength\cftsectionindent{1em}
\renewcommand\cftchapterleader{\cftdotfill{\cftdotsep}}
\renewcommand\printtoctitle[1]{\color{tb-primary}\headingfont\fontsize{21}{24}\selectfont #1}
\setlength\cftbeforepartskip{5mm}
\setlength\cftbeforechapterskip{2.5mm}

\endinput
