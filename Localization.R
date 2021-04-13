# Make fr-po.tar.gz from src/library/*/po
#cd <root dir containing src>
#tar -zcvf fr-po.tar.gz --exclude .git,.DS_Store src/library/*/po/*fr.po
# send this file to R code team
# Translations of Recommended packages should be send to their maintainers, I compress them like this:
#tar -zcvf Matrix-fr-po.tar.gz --exclude .git,.DS_Store Matrix/po/*fr.po
# Always use the latest .po files:
# - cluster: https://svn.r-project.org/R-packages/trunk/cluster/
# - Matrix: https://r-forge.r-project.org/scm/viewvc.php/pkg/Matrix/po/?root=matrix

# Make pot files, translate in French, and then, install French translation
# Note: this only considers R code, not C code!
pkg <- "svMisc"
pkglib <- "/Users/phgrosjean/Documents/Pgm/Rforge/sciviews/pkg"
lang <- "fr"

pkgdir <- file.path(pkglib, pkg)
potdir <- file.path(pkgdir, "po")
instdir <- file.path(pkgdir, "inst", "po", lang, "LC_MESSAGES")
initialfile <- file.path(potdir, paste("R-", lang, ".mo", sep = ""))
finalfile <- file.path(instdir, paste("R-", pkg, ".mo", sep = ""))
library(tools)
dir.create(potdir)
setwd(potdir)
xgettext2pot(pkgdir)

# Create the R-fr.po file from the pot file and edit it with poedit...
# ... then:
dir.create(instdir, recursive = TRUE)
file.rename(initialfile, finalfile)
# Now, you can rebuild the package!


### This is for test building the vignettes
vig <- "tcltk2.Rnw"
tex <- sub("[.]Rnw", ".tex", vig)
pdf <- sub("[.]Rnw", ".pdf", vig)
options(par.ask.default = FALSE)
setwd("d:/pgm/sciviews/src/libraries/tcltk2/inst/doc")
Sweave(vig)
# To compile the pdf version
# Should use texi2dvi --pdf tcltk2.tex... but does not work!
# So, I follow advices in http://www.ci.tuwien.ac.at/~leisch/Sweave/Sweave-manual-20060104.pdf and place Sweave.sty (as well as Rd.sty and upquote.sty
# in the texmf/tex/generic/misc directory, and now it works!
res <- system(paste("texi2dvi --pdf", tex))
# Show the result
if (file.exists(pdf)) browseURL(file.path(getwd(), pdf))

# To extract R code from the vignette (can be sourced)
Stangle(vig)
