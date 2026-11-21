# LuaLaTeX (serve per fontspec e i font OpenType).
$pdf_mode = 4;
$lualatex = 'lualatex -synctex=1 -interaction=nonstopmode -file-line-error %O %S';
$max_repeat = 4;
# Le foto cambiano senza che latexmk lo sappia: ricompilare con `latexmk -g` dopo averle aggiunte.
