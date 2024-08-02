# Create .po files from R Markdown or Quarto documents an build translated
# versions of these documents. Internally uses {reticulate} and Python's mdpo.
# Copyright (c) 2024, Philippe Grosjean <phgrosjean@sciviews.org> and
#                     Christian Wiat <w9204-r@yahoo.com>
# (probably to be released as the {rmdpo} R package under MIT license)
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

# This is a version using the mdpo Python library

# TODO:
# - Place this in the {rmdpo} R package in the SciViews organisation
# - Add an example vignette underlining various key points
# - Allow for a different directory (e.g., data.table -> data.table.fr)
# - Check on Windows, macOS & Linux, especially
#   https://github.com/mondeja/md-ulb-pwrap/issues/7
# - Compare current approach versus pot -> po mechanism
# - More metadata, particularly, version from DESCRIPTION + branch + commit
# - Discuss and advertise here:
#   https://github.com/Rdatatable/data.table/issues/6221 and here:
#   https://github.com/RConsortium/multilingual-documentation-wg

.check_mdpo <- function(pgm = "md2po", min.version = "2.0.0",
    mdpodir = getOption("mdpodir")) {

  if (!is.null(mdpodir) && nchar(mdpodir))
    pgm <- file.path(path.expand(mdpodir), pgm)

  pgm_version <- tryCatch(system2(pgm, args = "--version",
    stdout = TRUE, stderr = TRUE), error = function(e) stop(pgm,
      " not found. Install mdpo Python library and make it available.",
      call. = FALSE))
  # Returned string is like "md2po 2.0.0", but we need "2.0.0" only
  pgm_version <- sub("^[^ ]+ +", "", pgm_version)
  if (package_version(pgm_version) < min.version)
    stop(pgm, " version ", min.version, " or higher is required, but ",
      pgm_version, " is found.")
  pgm
}

.create_temp_rmd <- function(rmdfile, tmpfile) {
  # md2po is not aware of the Rmd peculiarities. It does not processes correctly
  # 1) The YAML header
  # 2) chunks with options like {r, echo=FALSE}
  # 3) List items with empty lines between items (list items are transformed
  #    into plain paragraphs to avoid this)
  # So, we change these to something that can be easily reversed on the
  # translated version to restore these Rmd/qmd features
  # This is done in a temporary file
  # Note: we assume that current directory is the one where we should place
  # the temporary file in the "lang" subdirectory

  rmddata <- readLines(rmdfile)
  rmddata <- sub("^---$", "~~~", rmddata)
  rmddata <- sub("^( *)```\\{([a-zA-Z]+[ ,][^}]+)\\}$",
    "\\1```{chunk_with_args}\n\\1#===== \\2", rmddata)
  rmddata <- sub("^( *[-+*] +.+)$", "=====\\1=====", rmddata)
  rmddata <- sub("^( *[0-9]+[.)] +.+)$", "=====\\1=====", rmddata)
  # Because mdpo squeezes multiple spaces into one, we replace them with _
  # ahead of lists (down to three indentation levels)
  rmddata <- sub("^=====(    )", "=====_", rmddata)
  rmddata <- sub("^=====_(    )", "=====__", rmddata)
  rmddata <- sub("^=====__(    )", "=====___", rmddata)
  writeLines(rmddata, tmpfile)
  invisible(tmpfile)
}

.postprocess_translated_rmd <- function(rmdfile) {
  # We have to rework a little bit the produced .Rmd/.qmd file to make sure
  # the YAML header, the R chunks headers and list items are correct
  rmddata <- readLines(rmdfile)
  # Restore the YAML header markers
  rmddata <- sub("~~~", "---", rmddata, fixed = TRUE)
  # Restore the R chunks headers
  rmddata <- sub("^( *)#===== (.+)$", "\\1```{\\2}", rmddata)
  rmddata <- rmddata[!grepl("```{chunk_with_args}", rmddata, fixed = TRUE)]
  # Restore proper spaces before indented list items
  rmddata <- sub("^=====___", "=====           ", rmddata)
  rmddata <- sub("^=====__", "=====        ", rmddata)
  rmddata <- sub("^=====_", "=====    ", rmddata)
  # Restore list items
  rmddata <- sub("^=====( *[-+*] *.+)=====$", "\\1", rmddata)
  rmddata <- sub("^=====( *[0-9]+[.)] *.+)=====$", "\\1", rmddata)
  rmddata <- gsub("===== =====", "\n", rmddata, fixed = TRUE)

  # This is not needed any more with the wrapping of list items within =====
  # Kept here commented for reference
  ## Indent code correctly in indented code chunks
  ## po2md indents tags and sometimes first line, but not the remaining lines
  ## This produces incorrect results => indent all lines now inside the chunk
  #inchunks <- grepl("^ +```", rmddata)
  #if (any(inchunks)) {
  #  # Verification: should be an even number
  #  if ((sum(inchunks) %% 2) != 0)
  #    stop("Incorrect number of indented code chunks markers in ", rmdfile)
  #  inchunklines <- (1:length(rmddata))[inchunks]
  #  # Odd lines are start markers, even lines are end markers
  #  starts <- inchunklines[c(TRUE, FALSE)]
  #  ends <- inchunklines[c(FALSE, TRUE)]
  #  # Process each chunk in turn
  #  for (i in seq_along(starts)) {
  #    chunk_range <- starts[i]:ends[i]
  #    chunk_header <- rmddata[starts[i]]
  #    # Number of space to use for indentation (seems to be always 3, but we
  #    # prefer to get it from the start header)
  #    spaces <- sub("^( +)`.*$", "\\1", chunk_header)
  #    # If we have a complex chunk header we also have to indent first line,
  #    # otherwise, not
  #    indent_first_line <- 3 # First code line is already correctly indented
  #    is_complex <- grepl("^( *)```\\{([a-zA-Z]+[ ,][^}]+)\\}$", chunk_header)
  #    if (is_complex) indent_first_line <- 2 # but not in this case
  #    # Are there remaining lines to indent?
  #    if (length(chunk_range) - indent_first_line > 0) {
  #      # Indent all remaining lines
  #      indent_range <- chunk_range[indent_first_line:(length(chunk_range) - 1)]
  #      rmddata[indent_range] <- paste0(spaces, rmddata[indent_range])
  #    }
  #  }
  #}
  #
  writeLines(rmddata, rmdfile)

  invisible(rmdfile)
}

#' Create a poEdit file from an R Markdown or Quarto document, or translate such a document using the .po file
#'
#' @param rmdfile The path to the R Markdown or Quarto document to translate
#' @param lang The langugae to translate to, like `"fr"` for French, `"es"` for
#'   Spanish, ... Also the subdirectory to the directory where the original file
#'   is located where to place the translated .Rmd or .qmd file.
#' @param podir The subdirectory of `lang` where to place the .po file (by
#'   default, it is `"po"`)
#' @param mdpodir The directory that contains md2po and po2md programs (`NULL`,
#'   by default, if these programs are accessible directly from the command
#'   line within the R process)
#' @param min.version The minimum version of md2po and po2md required (string
#'   like "2.0.0")
#' @param verbose If `TRUE`, print more info about md2po or po2md and the
#'   command that is executed
#' @param keep.tmpfile If `TRUE`, keep the modified .tmp file that is created
#'   from the original .Rmd/.qmd to allow better handling of YAML header and R
#'   chunks. `FALSE` by default, change it only for debugging purposes
#'
#' @details This function internally uses md2po and po2md CLI programs that are
#' from the mdpo Python library. You have to install these before use and make
#' sure that md2po and po2md are accessible on the command line from within R,
#' or provide the absolute path where they are located in the `"mdpodir"` option
#' using something like `options(mdpodir = "/usr/bin")`.
#' md2po is not dealing well with YAML headers, chunk headers and list items in
#' the .Rmd/.qmd files. A special code '=====' is introduced in the strings to
#' "escape" them from a wrong processing by md2po. This code is removed in the
#' final tranlated .Rmd/.qmd file.
#' You should leave these "=====" codes in the translated string too in the .po
#' file.
#'
#' **A few advise when you translate the strings in poEdit:**
#' - Use a correct syntax in your .Rmd/.qmd file. Indent by **four** spaces when
#' required (do **not** use two spaces to indent items inside lists, for
#' instance). Do not wrap paragraphs and place one empty line between each
#' block. That way, you will get an exact correpondance of line numbers between
#' the original and tranlated .Rmd/.qmd files. Bring correction in the layout of
#' the oroginal file, if needed.
#' - The string "#=====" tags a complex chunk header. You should not change it,
#' except, may be the content of `fig.cap="..."` that could be translated.
#' - For chunks, it is easier to start from an identical copy using
#' Ctrl-B/Cmd-B. Most of the time, nothing or very little parts must be changed
#' (mostly comments, but also see next point here under). Take care of quotes ',
#' and " that could be changed, depending on the language used (e.g., French).
#' The French quotes are, of course, inappropriate in R code. If the change is
#' automatic in poEdit, Ctrl-Z/Cmd-Z undoes the change.
#' - Where the .Rmd/.qmd refers to a document in the same directory or in a
#' subdirectory, remember that the translated vignette is located in a "<lang>"
#' subdirectory. It means that the relative path must be prepended with "../" to
#' reflect its new location. For instance, for a dataset "flights14.csv",
#' `fread('fligth14.csv')` must be changed into `fread('../flights14.csv')` in
#' the translated version. Also for a figure "fig1.png" in, say the "plots"
#' subdirectory, `![](plots/fig1.png)` must be changed into
#' `![](../plots/fig1.png)`. Finally, documents referred in the YAML header must
#' also be changed accordingly. For a "style.css" file in the "css"
#' subdirectory, change `css: [default, css/toc.css]` into
#' `css: [default, ../css/toc.css]` inthe YAML header of the translated .Rmd
#' file. This way, there is no need to duplicate files. Failure to do so will
#' result in an error during compilation of the .Rmd file. So, go back to
#' poEdit, correct the concerned item, and relaunch `po2rmd()` until compilation
#' runs flawlessly.
#' - List items are surrounder by "=====" markers. This is to avoid po2md to
#' reinterpret them in a different way, and it is also to draw your attention on
#' pieces of text that may not be complete sentences. Keep the exact same tags
#' in the translated version. If list items are not sperated by an empty line,
#' they are concatenated into a sigle string in poEdit, something like:
#' "=====1. First item===== =====2. Second item===== =====3. Third item====="
#' This is normal. Just keep the same tags and correct list items will be placed
#' in the final tranlated .Rmd/.qmd file by `rmd2po()`.
#'
#' @return The path to the .po file (for `rmd2po()`) or to the translated
#'   Rmd/qmd file (for `po2rmd()`) is returned. The .po file or the translated
#'   Rmd/qmd file is created or updated on each call of the respective function.
#' @export
#'
#' @examples
#' # TODO: and example using a short vignette
rmd2po <- function(rmdfile, lang = "fr", podir = "po",
    mdpodir = getOption("mdpodir"), min.version = "2.0.0",
    verbose = FALSE, keep.tmpfile = FALSE) {

  # Check external program availability and version
  md2po <- .check_mdpo("md2po", min.version = min.version, mdpodir = mdpodir)

  if (!file.exists(rmdfile))
    stop("The file '", rmdfile, "' is not found.")

  # md2po does not process quoted paths correctly. It is thus better to
  # temporarily switch to the directory where the rdmfile is located and to
  # always escape spaces with backslashes if they exist in the vignette name
  # It also waits for the name of the md file to process on stdin, even if it
  # is provided as first argument (both using system() and system2()). So, we
  # provide it through input =
  rmddir <- dirname(rmdfile)
  rmdfilename <- basename(rmdfile)
  odir <- setwd(rmddir)
  on.exit(setwd(odir))
  if (isTRUE(verbose)) {
    message("Temporarily switching to directory '", rmddir, "'", sep = "")
    message("Processing: ", rmdfilename)
  }
  # Make sure required subdirectories exist
  dir.create(lang, showWarnings = FALSE)
  dir.create(file.path(lang, podir), showWarnings = FALSE)

  # Create temporary file with modified Rmd/qmd file so that it is correctly
  # processed with md2po
  tmpfile <- file.path(lang, paste0(basename(rmdfile), ".tmp"))
  .create_temp_rmd(rmdfile, tmpfile)

  # Create the .po file, using md2po on the temporary rmd file
  pofile <- file.path(lang, podir, paste0(rmdfilename, "-", lang, ".po"))
  cmd <- paste0('"', md2po, '" --quiet --metadata "Language: ', lang,
    '" --include-codeblocks --merge-pofiles --remove-not-found ',
    '--save --po-filepath ', pofile)
  if (isTRUE(verbose))
    message("Running: ", cmd)
  res <- tryCatch(system(cmd, input = tmpfile, intern = TRUE),
    error = function(e) stop(e, call. = FALSE))
  if (isTRUE(verbose))
    message(res)

  if (!isTRUE(keep.tmpfile))
    unlink(tmpfile)

  file.path(rmddir, pofile)
}

#' @rdname rmd2po
#' @export
po2rmd <- function(rmdfile, lang = "fr", podir = "po",
    mdpodir = getOption("mdpodir"), min.version = "2.0.0",
    verbose = FALSE, keep.tmpfile = FALSE) {

  po2md <- .check_mdpo("po2md", min.version = min.version, mdpodir = mdpodir)

  if (!file.exists(rmdfile))
    stop("The file '", rmdfile, "' is not found.")

  # po2md does not process quoted paths correctly. It is thus better to
  # temporarily switch to the directory where the rdmfile is located and to
  # always escape spaces with backslashes if they exist in the vignette name
  # It also waits for the name of the md file to process on stdin, even if it
  # is provided as first argument (both using system() and system2()). So, we
  # provide it through input =
  rmddir <- dirname(rmdfile)
  rmdfilename <- basename(rmdfile)
  if (!dir.exists(rmddir))
    stop("The directory '", rmddir, "' is not found.")
  odir <- setwd(rmddir)
  on.exit(setwd(odir))
  if (isTRUE(verbose)) {
    message("Temporarily switching to directory '", rmddir, "'", sep = "")
    message("Processing: ", rmdfilename)
  }

  # Make sure required subdirectories exist
  dir.create(lang, showWarnings = FALSE)

  # Create temporary file, if needed, with modified Rmd/qmd file so that it is
  # correctly processed with po2md
  tmpfile <- file.path(lang, paste0(basename(rmdfile), ".tmp"))
  if (!file.exists(tmpfile))
    .create_temp_rmd(rmdfile, tmpfile)

  # Create translated .Rmd/.qmd file using the temporary .Rmd/.qmd and .po file
  rmd2file <- file.path(lang, rmdfilename)
  pofile <- file.path(lang, podir, paste0(rmdfilename, "-", lang, ".po"))
  if (!file.exists(pofile))
    stop("The .po file '", pofile, "' is not found.")
  cmd <- paste0('"', po2md, '" --quiet --pofiles ', pofile,
    ' --wrapwidth 0 --save ', rmd2file)
  if (isTRUE(verbose))
    message("Running: ", cmd)
  res <- tryCatch(system(cmd, input = tmpfile, intern = TRUE),
    error = function(e) stop(e, call. = FALSE))
  if (isTRUE(verbose))
    message(res)

  if (!isTRUE(keep.tmpfile))
    unlink(tmpfile)

  # Rework the translated .Rmd/.qmd file to restore YAML header, R chunks and
  # list items
  .postprocess_translated_rmd(rmd2file)

  file.path(rmddir, rmd2file)
}

# Usage:
# 1. Define the path for md2po and po2md programs
options(mdpodir = "~/miniconda3/bin")
# or for Windows
#options(mdpodir = "E:/program/Python/Python38/Scripts")

# 2. Indicate the directory where the vignettes reside (absolute or relative)
vigdir <- "data.table/vignettes" # Suppose that the current dir is rfrench
vigdir <- normalizePath(vigdir) # Absolute path (required by md2po and po2md)

# 3. Translate the vignettes

## datatable-intro.Rmd
#rmd2po(file.path(vigdir, "datatable-intro.Rmd"), verbose = TRUE, , keep.tmpfile = TRUE)
# Translate strings using poEdit, then...
#po2rmd(file.path(vigdir, "datatable-intro.Rmd"), verbose = TRUE)

## datatable-sd-usage.Rmd
#rmd2po(file.path(vigdir, "datatable-sd-usage.Rmd"), verbose = TRUE, , keep.tmpfile = TRUE)
# Translate strings using poEdit, then...
#po2rmd(file.path(vigdir, "datatable-sd-usage.Rmd"), verbose = TRUE)

## datatable-secondary-indices-and-auto-indexing.Rmd
#rmd2po(file.path(vigdir, "datatable-secondary-indices-and-auto-indexing.Rmd"), verbose = TRUE, , keep.tmpfile = TRUE)
# Translate strings using poEdit, then...
#po2rmd(file.path(vigdir, "datatable-secondary-indices-and-auto-indexing.Rmd"), verbose = TRUE)
