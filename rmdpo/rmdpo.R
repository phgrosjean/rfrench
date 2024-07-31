# Create .po files from R Markdown or Quarto documents an build translated
# versions of these documents. Internally uses {reticulate} and Python's mdpo.
# Copyright (c) 2024, Philippe Grosjean (phgrosjean@sciviews.org)
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
  rmddata <- sub("^```\\{([a-zA-Z]+[ ,][^}]+)\\}$",
    "```{chunk_with_args}\n# Chunk args: \\1", rmddata)
  writeLines(rmddata, tmpfile)

  # Create the .po file
  pofile <- file.path(lang, podir, paste0(rmdfilename, ".po"))
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
    rmddata <- sub("^```\\{([a-zA-Z]+[ ,][^}]+)\\}$",
      "```{chunk_with_args}\n# Chunk args: \\1", rmddata)
    writeLines(rmddata, tmpfile)
  }

  # Create translated .Rmd or .qmd file using original .Rmd/.qmd and .po file
  rmd2file <- file.path(lang, rmdfilename)
  pofile <- file.path(lang, podir, paste0(rmdfilename, ".po"))
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
  rmd2data <- sub("~~~", "---", rmd2data, fixed = TRUE)
  rmd2data <- sub("^# Chunk args: (.+)$", "```{\\1}", rmd2data)
  rmd2data <- rmd2data[!grepl("```{chunk_with_args}", rmd2data, fixed = TRUE)]
  writeLines(rmd2data, rmd2file)

  file.path(rmddir, rmd2file)
}

options(mdpodir = "~/miniconda3/bin")
rmd2po("~/Downloads/data.table-master/vignettes/datatable-secondary-indices-and-auto-indexing.Rmd", verbose = TRUE, , keep.tmpfile = TRUE)
# Translate strings using poEdit, then...
po2rmd("~/Downloads/data.table-master/vignettes/datatable-secondary-indices-and-auto-indexing.Rmd", verbose = TRUE)

