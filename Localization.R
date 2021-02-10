# Make fr-po.tar.gz from src/library/*/po
#cd <root dir containing src>
#tar -zcvf fr-po.tar.gz --exclude .git,.DS_Store src/library/*/po/*fr.po
# send this file to R code team
# Translations of Recommended packages should be send to their maintainers

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


Sweave and complex projects

A thread on R-Help recently discussed using Sweave/LaTeX for complicated projects. Two really useful tips were highlighted in that conversation�I use the first of them regularly: In the beginning of a Rnw/Snw file, use the prefix.string option to set the location of an includes directory: \SweaveOpts{prefix.string=/Path/to/directory}

This is really useful for organizing all the files that built by your project. (Mine are all directed to an includes directory that lives beneath my main manuscript directory.)

The second tip is to use a makefile to build a project that consists of multiple Sweave files. I like makefiles as much as the next guy, but here is my TextMate-specific solution for the same dilemma: Within the TM project, use the TM_SWEAVE_MASTER variable to name a master file, and in this file, simply plug in a single Sweave section that invokes source (for R-only files) or Sweave for your project�s various files. When you want to build the whole project (for example when you begin work for the day and need to load up all your data) all you do is open up the project and invoke the Sweave -> Sweave Project in R command.

For example, my dissertation project sets TM_SWEAVE_MASTER to �diss-master.Snw,� and that file looks like this:


<<echo=false,results=hide>>=
source(file="�/data/diss/R/clean-summary.R")
source(file="�/data/diss/R/tables.R")
source(file="�/data/diss/R/figures.R")
source(file="�/data/diss/R/citystats.R")
Sweave(file="�/docs/diss/manuscript/data-collection.Snw")
Sweave(file="�/docs/diss/manuscript/longevity.Snw")
@

The several R files do a little bit of data tweaking and build some tables/figures. Once all that data is loaded up, the two Sweave files can be built. I do this once per work session, using the Sweave Project in R command, which makes sure everything in the project is up to date. Subsequently, I can simply Sweave any individual Snw file (using the corresponding TextMate command), without having to recompile the entire project. (This all of course integrates well with using TM_LATEX_MASTER, also set at the project level, to order LaTeX to typeset the overall document.) I have found it to be a really nice and functional workflow.
