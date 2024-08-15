��    
      l      �       �   �   �   z  �  \   6  �   �  �     �   �  S  O  a   �  a    �   g	  �   3
  �  �
  \   �  �   �  �   t  �     �  �  a   �  S                       
   	                     #===== r, echo = FALSE, message = FALSE
library(data.table)
knitr::opts_chunk$set(
  comment = "#",
    error = FALSE,
     tidy = FALSE,
    cache = FALSE,
 collapse = TRUE)
.old.th = setDTthreads(1)
 ===== - `i` $$$\Leftrightarrow$$$ where===== ===== - `j` $$$\Leftrightarrow$$$ select===== ===== - `:=` $$$\Leftrightarrow$$$ update===== ===== - `by` $$$\Leftrightarrow$$$ group by===== ===== - `i` $$$\Leftrightarrow$$$ order by (in compound syntax)===== ===== - `i` $$$\Leftrightarrow$$$ having (in compound syntax)===== ===== - `nomatch = NA` $$$\Leftrightarrow$$$ outer join===== ===== - `nomatch = NULL` $$$\Leftrightarrow$$$ inner join===== ===== - `mult = "first"|"last"` $$$\Leftrightarrow$$$ N/A because SQL is inherently unordered===== ===== - `roll = TRUE` $$$\Leftrightarrow$$$ N/A because SQL is inherently unordered===== A = data.frame(A = 1:4, B = letters[11:14], C = pi*1:4)
rownames(A) = letters[1:4]
A
B
A[B]
 DT = data.table(a = rep(1:3, 1:3), b = 1:6, c = 7:12)
DT
DT[ , { mySD = copy(.SD)
      mySD[1, b := 99L]
      mySD},
    by = a]
 DT[ , {
  cat("Objects:", paste(objects(), collapse = ","), "\n")
  cat("Trace: x=", as.character(x), " y=", y, "\n")
  sum(y)},
  by = x]
 Please file suggestions, bug reports and enhancement requests on our [issues tracker](https://github.com/Rdatatable/data.table/issues). This helps make the package better. This error (and similar, *e.g.*, "`getCharCE` must be called on a `CHARSXP`") may be nothing do with character data or locale. Instead, this can be a symptom of an earlier memory corruption. To date these have been reproducible and fixed (quickly). Please report it to our [issues tracker](https://github.com/Rdatatable/data.table/issues). rownames(A) = letters[1:4]
colnames(A) = LETTERS[1:3]
A
B = cbind(c("a", "c"), c("B", "C"))
A[B]
 title: "Frequently Asked Questions about data.table"
date: "`r Sys.Date()`"
output:
  markdown::html_format:
    options:
      toc: true
      number_sections: true
    meta:
      css: [default, css/toc.css]
vignette: >
  %\VignetteIndexEntry{Frequently Asked Questions about data.table}
  %\VignetteEngine{knitr::knitr}
  \usepackage[utf8]{inputenc}
 Project-Id-Version: 
PO-Revision-Date: 
Last-Translator: 
Language-Team: 
Language: fr
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.4.4
 #===== r, echo = FALSE, message = FALSE
library(data.table)
knitr::opts_chunk$set(
  comment = "#",
    error = FALSE,
     tidy = FALSE,
    cache = FALSE,
 collapse = TRUE)
.old.th = setDTthreads(1)
 ===== - `i` $$$\Leftrightarrow$$$ where===== ===== - `j` $$$\Leftrightarrow$$$ select===== ===== - ` :=` $$$\Leftrightarrow$$$ update===== ===== - `by` $$$\Leftrightarrow$ group by===== ===== - `i` $$$\Leftrightarrow$$$ order by (en syntaxe composée)===== ===== - `i` $$$\Leftrightarrow$$$ having (en syntaxe composée)===== ===== - `nomatch = NA` $$$\Leftrightarrow$$$ outer join===== ===== - `nomatch = NULL` $$$\Leftrightarrow$$$ inner join===== ===== - `mult = "first"|"last"` $$$\Leftrightarrow$$$ N/A parce que SQL est intrinsèquement non ordonné===== ===== - `roll = TRUE` $$$\Leftrightarrow$$$ N/A parce que SQL est intrinsèquement non ordonné===== A = data.frame(A = 1:4, B = letters[11:14], C = pi*1:4)
rownames(A) = letters[1:4]
A
B
A[B]
 DT = data.table(a = rep(1:3, 1:3), b = 1:6, c = 7:12)
DT
DT[ , { mySD = copy(.SD)
      mySD[1, b := 99L]
      mySD},
    by = a]
 DT[ , {
  cat("Objets :", paste(objects(), collapse = ","), "\n")
  cat("Trace : x=", as.character(x), " y=", y, "\n")
  sum(y)},
  by = x]
 Veuillez déposer des suggestions, des rapports de bogues et des demandes d'amélioration sur notre [gestionnaire de tickets (issues tracker)](https://github.com/Rdatatable/data.table/issues). Cela permet d'améliorer le package. Cette erreur (et d'autres similaires, *e.g.*, "`getCharCE` must be called on a `CHARSXP`") peut n'avoir rien à voir avec les données de caractères ou la locale. Au lieu de cela, cela peut être le symptôme d'une corruption de mémoire antérieure. Jusqu'à présent, ces problèmes ont pu être reproduits et corrigés (rapidement). Merci de le signaler sur notre [gestionnaire de tickets (issues tracker)](https://github.com/Rdatatable/data.table/issues). rownames(A) = letters[1:4]
colnames(A) = LETTERS[1:3]
A
B = cbind(c("a", "c"), c("B", "C"))
A[B]
 title: "Foire aux questions sur data.table"
date: "`r Sys.Date()`"
output:
  markdown::html_format :
    options:
      toc: true
      number_sections: true
    meta:
      css: [default, ../css/toc.css]
vignette: >
  %\VignetteIndexEntry{Foire aux questions sur data.table}
  %\VignetteEngine{knitr::knitr}
  \usepackage[utf8]{inputenc}
 