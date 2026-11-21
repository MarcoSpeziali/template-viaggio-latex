# Travel book template (LaTeX, A5)

A LaTeX class for a printable travel memory book in A5: a full-bleed photo cover,
one chapter per stop, one page per day, polaroid-style photo spaces after every
sight or day, an itinerary timeline, a map page and ruled pages for handwriting.

The PDF always compiles, photos or not: every missing photo is drawn as a
placeholder that prints the path where the file is expected. Add the photos,
compile again, and they take the placeholders' place.

## Contents

| File | What it is |
|---|---|
| `travelbook.cls` | The class: page layout, fonts, palette and all the commands. Style only. |
| `example.tex` | A short example book that uses every command. Start from a copy of it. |
| `photos/` | Where the photos go (see below). |
| `.latexmkrc` | Tells latexmk to use LuaLaTeX. |
| `.devcontainer/` | Docker image with TeX Live, for VS Code or plain `docker run`. |
| `Makefile` | `make pdf` builds through Docker. |

## Building

The class needs **LuaLaTeX** (for `fontspec` and the OpenType fonts) and the
fonts EB Garamond and Cormorant Garamond, which ship with TeX Live
(`texlive-fonts-extra` on Debian/Ubuntu).

With a local TeX Live:

```sh
latexmk example.tex        # .latexmkrc selects LuaLaTeX
latexmk -g example.tex     # force a rebuild, e.g. after adding photos
```

Without TeX Live, through Docker (the image is built on first use):

```sh
make pdf                   # builds example.tex
make pdf DOC=mybook        # builds mybook.tex
```

or by hand:

```sh
docker build -t travelbook-latex .devcontainer
docker run --rm -v "$PWD":/work travelbook-latex latexmk -g example.tex
```

In VS Code, *Reopen in Container* uses `.devcontainer/` and LaTeX Workshop
builds with latexmk.

latexmk does not notice new photos by itself: after adding some, build with
`-g` (the Makefile already does).

## Photos

Paths are relative to the main `.tex` file and are written **without extension**:
the class tries `.jpg`, `.jpeg`, `.png`, `.pdf` (and upper-case `.JPG`, `.JPEG`,
`.PNG`). A suggested layout:

```
photos/
  cover.jpg              the cover (default path, change it with coverphoto=)
  map.jpg                the map page
  stops/<stop>.jpg       the opening picture of each stop
  2028-05-12/            one folder per day
    01.jpg 02.jpg ...    numbered slots, see \photoslots
    lanterna.jpg         or any name, used with \photo
```

Photos are cropped to fill their frame, centred, so any orientation works. Phone
photos at full resolution make a heavy PDF: 2000 px on the long side is plenty
for A5.

## Commands

### Setup (preamble)

```latex
\documentclass[italian]{travelbook}   % english (default), italian, french, german, spanish
\travelsetup{
  palette    = sea,           % sea, jungle, ink, sunset
  binding    = 5mm,           % binding offset, added to the inner margin
  bleed      = 0mm,           % 3mm for most print shops
  cropmarks  = false,         % crop marks (only with bleed)
  showpaths  = true,          % placeholders print the expected path
  coverphoto = photos/cover,
}
\setcolors{1F4E5F}{4F8A8B}{E07A5F}{F2EADF}{222B2E} % own palette: primary, secondary, accent, paper, text
\setheadingfont{Cormorant Garamond}[...]           % optional: another heading font
\title{...} \subtitle{...} \author{...} \date{...} \dedication{...}
```

The language option sets hyphenation and the fixed labels (Part, Stop,
Itinerary, Map, Notes, "Today's memory"); each label is a command you can
redefine, e.g. `\renewcommand\memoryname{A note}`.

### Front matter

| Command | Result |
|---|---|
| `\makecover` | Full-bleed photo cover with gradient, title, subtitle, authors, dates; then a blank back. |
| `\maketitlepage` | Title page, with the dedication at the bottom if set. |
| `\contentspage` | Table of contents. |
| `\begin{itinerary}[title] \stage{date}{place}{text} ... \end{itinerary}` | Vertical timeline of the trip. |
| `\tripmap{file}{caption}` | A map image across the page. |

### Structure

| Command | Result |
|---|---|
| `\trippart{Title}{subtitle}` | Full-bleed colour page, e.g. one per country. |
| `\tripstop[photo]{Place}{subtitle}` | A chapter; with `[photo]` the top half of the page is a full-bleed picture. |
| `\tripday{date}{place}{title}` | A day, always on a new page, with date and place in the heading. |
| `\sight{Name}` | A small heading inside a day, for a place or an activity. |
| `\flourish` | A small closing ornament. |

### Photos

| Command | Result |
|---|---|
| `\photo[options]{file}{caption}` | One polaroid, centred. Options: `width=`, `landscape` (default), `portrait`, `square`, `angle=`. |
| `\photogrid[columns]{\photo{..}{..} \photo{..}{..} ...}` | Polaroids side by side, rows wrap and stay centred. |
| `\photoslots[columns]{folder}{n}` | `n` numbered slots `folder/01` ... with an empty caption strip for writing by hand. |

### Handwriting

| Command | Result |
|---|---|
| `\memory[title]{n}` | `n` ruled lines under a small label ("Today's memory"). |
| `\memoryfill[title]` | The same label, then ruled lines down to the foot of the page (new page if fewer than four would fit). |
| `\writinglines{n}` | `n` ruled lines. |
| `\notespage[title]` | A whole page of ruled lines. |

## Printing

* The default output is exactly A5 (148 × 210 mm), fine for home printing and
  for print shops that do not want bleed.
* For a print shop that does: `bleed = 3mm` makes the sheet 154 × 216 mm, the
  cover, part pages and stop pictures extend into the bleed, and the PDF carries
  the `TrimBox`/`BleedBox` they need. Add `cropmarks = true` if they ask for marks.
* `binding` widens the inner margin: 5 mm suits a perfect-bound paperback; use
  more for thick books or spiral binding.
* The cover is page 1 of the book. If the print shop wants the cover as a separate
  file, build once with only `\makecover` in the document.

## Design choices

* **memoir** rather than KOMA `scrbook`: both handle A5 and binding offsets well,
  but memoir natively separates stock and trimmed page (`\setstocksize`,
  `\settrims`), which is exactly what bleed and crop marks need.
* **LuaLaTeX + fontspec** for real OpenType fonts: EB Garamond for the text (old-style
  figures, small caps), Cormorant Garamond for headings and captions.
* **TikZ** for the cover, the placeholders and the polaroids, so nothing depends on
  external images being present.
