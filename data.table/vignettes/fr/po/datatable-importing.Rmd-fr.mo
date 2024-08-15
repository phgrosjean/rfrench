��          <      \       p      q   �  }   �   _  �   -     �  ;    �   A                   **Before:** **Justification for Avoiding Blanket Imports:** =====1. **Documentation**: The NAMESPACE file can serve as good documentation of how you depend on certain packages.===== =====2. **Avoiding Conflicts**: Blanket imports leave you open to subtle breakage. For example, if you `import(pkgA)` and `import(pkgB)`, but later pkgB exports a function also exported by pkgA, this will break your package due to conflicts in your namespace, which is disallowed by `R CMD check` and CRAN.===== title: "Importing data.table"
date: "`r Sys.Date()`"
output:
  markdown::html_format
vignette: >
  %\VignetteIndexEntry{Importing data.table}
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
 **Avant :** **Justification pour éviter les importations globales:**
=====1. **Documentation** : le fichier NAMESPACE peut servir de bonne documentation sur la façon dont vous dépendez de certains packages.===== =====2. **Éviter les conflits** : les importations générales vous exposent à des cassures subtiles. Par exemple, si vous faites `import(pkgA)` et `import(pkgB)`, mais que plus tard pkgB exporte une fonction également exportée par pkgA, cela cassera votre package à cause de conflits dans votre espace de noms, ce qui est interdit par `R CMD check` et CRAN.===== title: "Importation dans data.table"
date: "`r Sys.Date()`"
output:
  markdown::html_format
vignette: >
  %\VignetteIndexEntry{Importation dans data.table}
  %\VignetteEngine{knitr::knitr}
  \usepackage[utf8]{inputenc}
 