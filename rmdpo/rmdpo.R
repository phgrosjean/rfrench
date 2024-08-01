# Create .po files from R Markdown or Quarto documents an build translated
# versions of these documents. Internally uses {reticulate} and Python's mdpo.
# Copyright (c) 2024, Philippe Grosjean <phgrosjean@sciviews.org> and
#                     Christian Wiat <w9204-r@yahoo.com>
# (probably to be released as the {rmdpo} R package under MIT license)

#' Create a poEdit file from an R Markdown or Quarto document
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
#'
#' @return The path to the .po file (for `rmd2po()`) or to the translated
#'   Rmd/qmd file (for `po2rmd()`) is returned. The .po file or the translated
#'   Rmd/qmd file is created or updated on each call of the respective function.
#' @export
#'
#' @examples
#' # Not yet
rmd2po <- function(rmdfile, lang = "fr", podir = "po",
    mdpodir = getOption("mdpodir"), verbose = FALSE, keep.tmpfile = FALSE) {

  # Check if md2po is available
  if (!is.null(mdpodir) && nchar(mdpodir)) {
    md2po <- file.path(path.expand(mdpodir), "md2po")
  } else {
    md2po <- "md2po"
  }
  md2po_version <- tryCatch(system2(md2po, args = "--version",
    stdout = TRUE, stderr = TRUE), error = function(e) stop(
      "md2po not found. Install mdpo Python library and make it available.",
      call. = FALSE))
  if (isTRUE(verbose))
  message("This is ", md2po_version)

  if (!file.exists(rmdfile)) {
    stop("The file '", rmdfile, "' is not found.")
  }

  # md2po does not process quoted paths correctly. It is thus better to
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

  # md2po is not aware of the Rmd peculiarities. It does ont processes correctly
  # 1) The YAML header
  # 2) chunks with options like {r, echo=FALSE}
  # So, we change these to something that can be easily reversed on the
  # translated version to restore these Rmd/qmd features
  # This is done in temporary file
  dir.create(lang, showWarnings = FALSE)
  tmpfile <- file.path(lang, paste0(basename(rmdfile), ".tmp"))
  rmddata <- readLines(rmdfile)
  rmddata <- sub("^---$", "~~~", rmddata)
  rmddata <- sub("^( *)```\\{([a-zA-Z]+[ ,][^}]+)\\}$",
    "\\1```{chunk_with_args}\n\\1# Chunk args: \\2", rmddata)
  writeLines(rmddata, tmpfile)

  # Create the .po file
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
    mdpodir = getOption("mdpodir"), verbose = FALSE, keep.tmpfile = FALSE) {

  # Check if po2md is available
  if (!is.null(mdpodir) && nchar(mdpodir)) {
    po2md <- file.path(path.expand(mdpodir), "po2md")
  } else {
    po2md <- "po2md"
  }
  po2md_version <- tryCatch(system2(po2md, args = "--version",
    stdout = TRUE, stderr = TRUE), error = function(e) stop(
      "po2md not found. Install mdpo Python library and make it available.",
      call. = FALSE))
  if (isTRUE(verbose))
    message("This is ", po2md_version)

  if (!file.exists(rmdfile)) {
    stop("The file '", rmdfile, "' is not found.")
  }

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

  # md2po is not aware of the Rmd peculiarities. It does ont processes correctly
  # 1) The YAML header
  # 2) chunks with options like {r, echo=FALSE}
  # So, we change these to something that can be easily reversed on the
  # translated version to restore these Rmd/qmd features
  # This is done in temporary file
  dir.create(lang, showWarnings = FALSE)
  tmpfile <- file.path(lang, paste0(basename(rmdfile), ".tmp"))
  if (!file.exists(tmpfile)) {
    rmddata <- readLines(rmdfile)
    rmddata <- sub("^---$", "~~~", rmddata)
    rmddata <- sub("^( *)```\\{([a-zA-Z]+[ ,][^}]+)\\}$",
      "\\1```{chunk_with_args}\n\\1# Chunk args: \\2", rmddata)
    writeLines(rmddata, tmpfile)
  }

  # Create translated .Rmd or .qmd file using original .Rmd/.qmd and .po file
  rmd2file <- file.path(lang, rmdfilename)
  pofile <- file.path(lang, podir, paste0(rmdfilename, "-", lang, ".po"))
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

  # Now, we have to rework a little bit the produced .Rmd/.qmd file to make sure
  # the YAML header and the R chunks headers are correct
  rmd2data <- readLines(rmd2file)
  # Restore the YAML header markers
  rmd2data <- sub("~~~", "---", rmd2data, fixed = TRUE)
  # Restore the R chunks headers
  rmd2data <- sub("^( *)# Chunk args: (.+)$", "\\1```{\\2}", rmd2data)
  rmd2data <- rmd2data[!grepl("```{chunk_with_args}", rmd2data, fixed = TRUE)]
  # Indent code correctly in indented code chunks
  # po2md indents tags and sometimes first line, but not the remaining lines
  # This produces incorrect results => indent all lines now inside the chunk
  inchunks <- grepl("^ +```", rmd2data)
  if (any(inchunks)) {
    # Verification: should be an even number
    if ((sum(inchunks) %% 2) != 0)
      stop("Incorrect number of indented code chunks markers in ", rmd2file)
    inchunklines <- (1:length(rmd2data))[inchunks]
    # Odd lines are start markers, even lines are end markers
    starts <- inchunklines[c(TRUE, FALSE)]
    ends <- inchunklines[c(FALSE, TRUE)]
    # Process each chunk in turn
    for (i in seq_along(starts)) {
      chunk_range <- starts[i]:ends[i]
      chunk_header <- rmd2data[starts[i]]
      # Number of space to use for indentation (seems to be always 3, but we
      # prefer to get it from the start header)
      spaces <- sub("^( +)`.*$", "\\1", chunk_header)
      # If we have a complex chunk header we also have to indent first line,
      # otherwise, not
      indent_first_line <- 3 # First code line is already correctly indented
      is_complex <- grepl("^( *)```\\{([a-zA-Z]+[ ,][^}]+)\\}$", chunk_header)
      if (is_complex) indent_first_line <- 2 # but not in this case
      # Are there remaining lines to indent?
      if (length(chunk_range) - indent_first_line > 0) {
        # Indent all remaining lines
        indent_range <- chunk_range[indent_first_line:(length(chunk_range) - 1)]
        rmd2data[indent_range] <- paste0(spaces, rmd2data[indent_range])
      }
    }
  }
  writeLines(rmd2data, rmd2file)

  file.path(rmddir, rmd2file)
}

# Usage:
# 1. Define the path for md2po and po2md programs
options(mdpodir = "~/miniconda3/bin")

# 2. Indicate the directory where the vignettes reside (absolute or relative)
vigdir <- "data.table/vignettes" # Suppose that the current dir is rfrench
vigdir <- normalizePath(vigdir) # Absolute path (required by md2po and po2md)

# 3. Translate the vignettes

## datatable-intro.Rmd
rmd2po(file.path(vigdir, "datatable-intro.Rmd"), verbose = TRUE, , keep.tmpfile = TRUE)
# Translate strings using poEdit, then...
po2rmd(file.path(vigdir, "datatable-intro.Rmd"), verbose = TRUE)

## datatable-sd-usage.Rmd
rmd2po(file.path(vigdir, "datatable-sd-usage.Rmd"), verbose = TRUE, , keep.tmpfile = TRUE)
# Translate strings using poEdit, then...
po2rmd(file.path(vigdir, "datatable-sd-usage.Rmd"), verbose = TRUE)

## datatable-secondary-indices-and-auto-indexing.Rmd
rmd2po(file.path(vigdir, "datatable-secondary-indices-and-auto-indexing.Rmd"), verbose = TRUE, , keep.tmpfile = TRUE)
# Translate strings using poEdit, then...
po2rmd(file.path(vigdir, "datatable-secondary-indices-and-auto-indexing.Rmd"), verbose = TRUE)

# Remarks:
# - The strings "# Chunk args:" should not be translated ! However, if there is a fig.cap="..." parameter, then the sentence inside it (the figure legend) could be translated
# - For chunks, it is easier to start from an identical copy using Ctrl-B/Cmd-B. Most of the time, nothing or very little parts must be changed (mostly comments, but also see last point here under). Take care of quotes ', and " that could be changed into French quotes automatically, which is inappropriate in R code, of course. If the change is automatic, Ctrl-Z/Cmd-Z undoes the change.
# - In the translated .Rmd, there is no empty line between list items, nor between lists items and chunks. This does not affect much the rendering (technically, pandoc generates two different types of lists if there is empty line or not between items, but it is barely noticeable on the final result)
# - Numbered list items all start with 1. ... This is OK, and pandoc renumbers the items adequately in the rendered document.
# - Where the .Rmd refers to a document in the same directory or in a subdirectory, remember that the translated vignette is located in the "fr" subdirectory. It means that the relative path must be prepended with '../' to reflect its new location. For instance, for a dataset "flights14.csv", `fread('fligth14.csv')` must be changed into `fread('../flights14.csv')` in the translated version. Also for a figure "fig1.png" in, say the "plots" subdirectory, `![](plots/fig1.png)` must be changed into `![](../plots/fig1.png)`. Finally, documents used in the YAML header must also be changed accordingly. For a "style.css" file in the "css" subdirectory, change `css: [default, css/toc.css]` into `css: [default, ../css/toc.css]` inthe YAML header of the translated .Rmd file. This way, there is no need to duplicate files. Failure to do so will result in an error during compilation of the .Rmd file. So, go back to poEdit, correct the concerned item, and relaunch `po2rmd()` until compilation runs flawlessly.
