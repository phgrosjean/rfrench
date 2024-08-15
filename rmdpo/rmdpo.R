# Create .po files from R Markdown or Quarto documents an build translated
# versions of these documents. Internally uses Python's mdpo.
# Copyright (c) 2024, Philippe Grosjean <phgrosjean@sciviews.org> and
#                     Christian Wiat <w9204-r@yahoo.com>

# Installation

# This is a version using the mdpo Python library. Obviously, you need Python
# and also to install the mdpo library. This can be done with pip:
#pip install mdpo # see here : https://github.com/mondeja/mdpo

# You also need to install thr rmdpo R package with this command in R:
#install.packages("remotes")
#remotes::install_github("SciViews/rmdpo")

# Usage

# 1. Define the path for md2po and po2md programs (the Python stuff)

# If using Anoconda's miniconda version, it is something like:
options(mdpodir = "~/miniconda3/bin")
# or for Windows with regular Python 3.8:
#options(mdpodir = "E:/program/Python/Python38/Scripts")

# 2. Indicate the directory where the vignettes reside (absolute or relative)

vigdir <- "data.table/vignettes" # Suppose that the current dir is rfrench
vigdir <- normalizePath(vigdir) # Absolute path (required by md2po and po2md)

# 3. Translate the vignettes

# Note : code for the vignettes that are already translated is commented out

library(rmdpo)

## datatable-intro.Rmd
#rmd2po(file.path(vigdir, "datatable-intro.Rmd"), verbose = TRUE, keep.tmpfile = TRUE)
# Translate strings using poEdit, then...
#po2rmd(file.path(vigdir, "datatable-intro.Rmd"), verbose = TRUE)

## datatable-sd-usage.Rmd
#rmd2po(file.path(vigdir, "datatable-sd-usage.Rmd"), verbose = TRUE, keep.tmpfile = TRUE)
# Translate strings using poEdit, then...
#po2rmd(file.path(vigdir, "datatable-sd-usage.Rmd"), verbose = TRUE)

## datatable-secondary-indices-and-auto-indexing.Rmd
#rmd2po(file.path(vigdir, "datatable-secondary-indices-and-auto-indexing.Rmd"), verbose = TRUE, keep.tmpfile = TRUE)
# Translate strings using poEdit, then...
#po2rmd(file.path(vigdir, "datatable-secondary-indices-and-auto-indexing.Rmd"), verbose = TRUE)

## datatable-benchmarking.Rmd
#rmd2po(file.path(vigdir, "datatable-benchmarking.Rmd"), verbose = TRUE, keep.tmpfile = TRUE)
# Translate strings using poEdit, then...
po2rmd(file.path(vigdir, "datatable-benchmarking.Rmd"), verbose = TRUE)

## datatable-faq.Rmd
#rmd2po(file.path(vigdir, "datatable-faq.Rmd"), verbose = TRUE, keep.tmpfile = TRUE)
# Translate strings using poEdit, then...
po2rmd(file.path(vigdir, "datatable-faq.Rmd"), verbose = TRUE)

## datatable-importing.Rmd
#rmd2po(file.path(vigdir, "datatable-importing.Rmd"), verbose = TRUE, keep.tmpfile = TRUE)
# Translate strings using poEdit, then...
po2rmd(file.path(vigdir, "datatable-importing.Rmd"), verbose = TRUE)

## datatable-keys-fast-subset.Rmd
#rmd2po(file.path(vigdir, "datatable-keys-fast-subset.Rmd"), verbose = TRUE, keep.tmpfile = TRUE)
# Translate strings using poEdit, then...
po2rmd(file.path(vigdir, "datatable-keys-fast-subset.Rmd"), verbose = TRUE)

## datatable-programming.Rmd
#rmd2po(file.path(vigdir, "datatable-programming.Rmd"), verbose = TRUE, keep.tmpfile = TRUE)
# Translate strings using poEdit, then...
po2rmd(file.path(vigdir, "datatable-programming.Rmd"), verbose = TRUE)

## datatable-reference-semantics.Rmd
#rmd2po(file.path(vigdir, "datatable-reference-semantics.Rmd"), verbose = TRUE, keep.tmpfile = TRUE)
# Translate strings using poEdit, then...
po2rmd(file.path(vigdir, "datatable-reference-semantics.Rmd"), verbose = TRUE)

## datatable-reshape.Rmd
#rmd2po(file.path(vigdir, "datatable-reshape.Rmd"), verbose = TRUE, keep.tmpfile = TRUE)
# Translate strings using poEdit, then...
po2rmd(file.path(vigdir, "datatable-reshape.Rmd"), verbose = TRUE)


################################################################################
#
# Note: there is also po4a that does the job. It is a Perl program that works
# on Linux and macOS (installation through Homebrew or Macports), but I have
# found nothing for Windows. Here is what I did with it on macOS:
#
# Create, or update a .pot file for one R Markdown document
#po4a-updatepo -f text -m <doc>.Rmd -p fr/po/<doc>.pot -p fr/po/<doc>-fr.po -M utf8 -o markdown -o neverwrap -o nobullets --wrap-po newlines --msgid-bugs-address <mail>@sciviews.org --copyright-holder "SciViews" --package-name "<doc>" --package-version "1.0.0"
#
# Translate an R Markdown document using an -fr.po file (with a minimal threshold of translated text set to 80%)
#po4a-translate -f text -m <doc>.Rmd -p fr/po/<doc>-fr.po -M utf8 -l fr/<doc>.Rmd -L utf8 -o markdown -o neverwrap -o nobullets --wrap-po newlines --keep 80
#
# Use a reworked (and correctly aligned!) translated .Rmd file to update the -fr.po file
#po4a-gettextize -f text -m <doc>.Rmd -l fr/<doc>.Rmd -p fr/po/<doc>.pot -p fr/po/<doc>-fr.po -M utf8 -L utf8 -o markdown -o neverwrap -o nobullets --msgid-bugs-address <mail>@sciviews.org --copyright-holder "SciViews" --package-name "<doc>" --package-version "1.0.0"
