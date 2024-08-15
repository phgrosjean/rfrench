��          �      \      �  d  �  T   6  �  �  �  j  �   �	  �   �
  �  ?    �  �   �  %  �  �   �  �   C  �   @  d     ,   w  o   �            �   !  �   �  �  �  T   W  �  �  �  �  �   -  �   �  �  t    T   �   j!  #   "  �   $#    �#  �   �$  a   �%  ,   &  o   8&     �&     �&  �   �&                                                                      
                      	       #===== r complex
outer = "sqrt"
inner = "square"
vars = c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")

syms = lapply(vars, as.name)
to_inner_call = function(var, fun) call(fun, var)
inner_calls = lapply(syms, to_inner_call, inner)
print(inner_calls)

to_add_call = function(x, y) call("+", x, y)
add_calls = Reduce(to_add_call, inner_calls)
print(add_calls)

rms = substitute2(
  expr = outer((add_calls) / len),
  env = list(
    outer = outer,
    add_calls = add_calls,
    len = length(vars)
  )
)
print(rms)

str(
  DT[, j, env = list(j = rms)]
)

# same, but skipping last substitute2 call and using add_calls directly
str(
  DT[, outer((add_calls) / len),
     env = list(
       outer = outer,
       add_calls = add_calls,
       len = length(vars)
    )]
)

# return as data.table
j = substitute2(j, list(j = as.list(setNames(nm = c(vars, "Species", "rms")))))
j[["rms"]] = rms
print(j)
DT[, j, env = list(j = j)]

# alternatively
j = as.call(c(
  quote(list),
  lapply(setNames(nm = vars), as.name),
  list(Species = as.name("Species")),
  list(rms = rms)
))
print(j)
DT[, j, env = list(j = j)]
 #===== r hypotenuse
square = function(x) x^2
quote(
  sqrt(square(a) + square(b))
)
 #===== r hypotenuse_datatable
DT = as.data.table(iris)

str(
  DT[, outer(inner(var1) + inner(var2)),
     env = list(
       outer = "sqrt",
       inner = "square",
       var1 = "Sepal.Length",
       var2 = "Sepal.Width"
    )]
)

# return as a data.table
DT[, .(Species, var1, var2, out = outer(inner(var1) + inner(var2))),
   env = list(
     outer = "sqrt",
     inner = "square",
     var1 = "Sepal.Length",
     var2 = "Sepal.Width",
     out = "Sepal.Hypotenuse"
  )]
 #===== r hypotenuse_datatable_i_j_by
DT[filter_col %in% filter_val,
   .(var1, var2, out = outer(inner(var1) + inner(var2))),
   by = by_col,
   env = list(
     outer = "sqrt",
     inner = "square",
     var1 = "Sepal.Length",
     var2 = "Sepal.Width",
     out = "Sepal.Hypotenuse",
     filter_col = "Species",
     filter_val = I(c("versicolor", "virginica")),
     by_col =  "Species"
  )]
 #===== r init, include = FALSE
require(data.table)
knitr::opts_chunk$set(
  comment = "#",
    error = FALSE,
     tidy = FALSE,
    cache = FALSE,
 collapse = TRUE
)
 #===== r old_get
v1 = "Petal.Width"
v2 = "Sepal.Width"

DT[, .(total = sum(get(v1), get(v2)))]

DT[, .(total = sum(v1, v2)),
   env = list(v1 = v1, v2 = v2)]
 #===== r splice_enlist
DT[, j,  # data.table automatically enlists nested lists into list calls
   env = list(j = as.list(cols)),
   verbose = TRUE]

DT[, j,  # turning the above 'j' list into a list call
   env = list(j = quote(list(Sepal.Length, Sepal.Width))),
   verbose = TRUE]

DT[, j,  # the same as above but accepts character vector
   env = list(j = as.call(c(quote(list), lapply(cols, as.name)))),
   verbose = TRUE]
 #===== r splice_not, error=TRUE, purl=FALSE
DT[, j,  # list of symbols
   env = I(list(j = lapply(cols, as.name))),
   verbose = TRUE]

DT[, j,  # again the proper way, enlist list to list call automatically
   env = list(j = as.list(cols)),
   verbose = TRUE]
 #===== r subset_error, error=TRUE, purl=FALSE
my_subset = function(data, col, val) {
  subset(data, col == val)
}
my_subset(iris, Species, "setosa")
 #===== r subset_parse
my_subset = function(data, col, val) {
  data = deparse(substitute(data))
  col  = deparse(substitute(col))
  val  = paste0("'", val, "'")
  text = paste0("subset(", data, ", ", col, " == ", val, ")")
  eval(parse(text = text)[[1L]])
}
my_subset(iris, Species, "setosa")
 #===== r subset_substitute
my_subset = function(data, col, val) {
  eval(substitute(subset(data, col == val)))
}
my_subset(iris, Species, "setosa")
 #===== r substitute2_recursive
substitute2(   # all are symbols
  f(v1, v2),
  list(v1 = "a", v2 = list("b", list("c", "d")))
)
substitute2(   # 'a' and 'd' should stay as character
  f(v1, v2),
  list(v1 = I("a"), v2 = list("b", list("c", I("d"))))
)
 =====- lack of syntax validation===== =====- [vulnerability to code injection](https://github.com/Rdatatable/data.table/issues/2655#issuecomment-376781159)===== =====- the existence of better alternatives===== Martin Machler, R Project Core Developer, [once said](https://stackoverflow.com/a/40164111/2490497): `$$${\displaystyle c = \sqrt{a^2 + b^2}}$$$` `$$${\displaystyle x_{\text{RMS}}={\sqrt{{\frac{1}{n}}\left(x_{1}^{2}+x_{2}^{2}+\cdots +x_{n}^{2}\right)}}}$$$` `eval` `get` title: "Programming on data.table"
date: "`r Sys.Date()`"
output:
  markdown::html_format
vignette: >
  %\VignetteIndexEntry{Programming on data.table}
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
 #===== r complexe
outer = "sqrt"
inner = "square"
vars = c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")

syms = lapply(vars, as.name)
to_inner_call = function(var, fun) call(fun, var)
inner_calls = lapply(syms, to_inner_call, inner)
print(inner_calls)

to_add_call = function(x, y) call("+", x, y)
add_calls = Reduce(to_add_call, inner_calls)
print(add_calls)

rms = substitute2(
  expr = outer((add_calls) / len),
  env = list(
    outer = outer,
    add_calls = add_calls,
    len = length(vars)
  )
)
print(rms)

str(
  DT[, j, env = list(j = rms)]
)

# idem, mais en sautant le dernier appel à substitute2 et en utilisant directement add_calls
str(
  DT[, outer((add_calls) / len),
     env = list(
       outer = outer,
       add_calls = add_calls,
       len = length(vars)
    )]
)

# retourner le résultat en tant que data.table
j = substitute2(j, list(j = as.list(setNames(nm = c(vars, "Species", "rms")))))
j[["rms"]] = rms
print(j)
DT[, j, env = list(j = j)]

# ou alors :
j = as.call(c(
  quote(list),
  lapply(setNames(nm = vars), as.name),
  list(Species = as.name("Species")),
  list(rms = rms)
))
print(j)
DT[, j, env = list(j = j)]
 #===== r hypotenuse
square = function(x) x^2
quote(
  sqrt(square(a) + square(b))
)
 #===== r hypotenuse_datable
DT = as.data.table(iris)

str(
  DT[, outer(inner(var1) + inner(var2)),
     env = list(
       outer = "sqrt",
       inner = "square",
       var1 = "Sepal.Length",
       var2 = "Sepal.Width"
    )]
)

# retourner le résultat sous forme de data.table
DT[, .(Species, var1, var2, out = outer(inner(var1) + inner(var2))),
   env = list(
     outer = "sqrt",
     inner = "square",
     var1 = "Sepal.Length",
     var2 = "Sepal.Width",
     out = "Sepal.Hypotenuse"
  )]
 #===== r hypotenuse_datable_i_j_by
DT[filter_col %in% filter_val,
   .(var1, var2, out = outer(inner(var1) + inner(var2))),
   by = by_col,
   env = list(
     outer = "sqrt",
     inner = "square",
     var1 = "Sepal.Length",
     var2 = "Sepal.Width",
     out = "Sepal.Hypotenuse",
     filter_col = "Species",
     filter_val = I(c("versicolor", "virginica")),
     by_col = "Species"
  )]
 #===== r init, include = FALSE
require(data.table)
knitr::opts_chunk$set(
  comment = "#",
    error = FALSE,
     tidy = FALSE,
    cache = FALSE,
 collapse = TRUE
)
 #===== r old_get
v1 = "Petal.Width"
v2 = "Sepal.Width"

DT[, .(total = sum(get(v1), get(v2)))]

DT[, .(total = sum(v1, v2)),
   env = list(v1 = v1, v2 = v2)]
 #===== r splice_enlist
DT[, j, # data.table enrôle automatiquement les listes imbriquées dans des appels de liste
   env = list(j = as.list(cols)),
   verbose = TRUE]

DT[, j, # transformer la liste 'j' ci-dessus en un appel de liste
   env = list(j = quote(list(Sepal.Length, Sepal.Width))),
   verbose = TRUE]

DT[, j, # la même chose que ci-dessus mais accepte un vecteur de caractères
   env = list(j = as.call(c(quote(list), lapply(cols, as.name)))),
   verbose = TRUE]
 #===== r splice_not, error=TRUE, purl=FALSE
DT[, j, # liste de symboles
   env = I(list(j = lapply(cols, as.name))),
   verbose = VRAI]

DT[, j, # encore une fois de la  meilleure façon, appel automatique de liste à liste
   env = list(j = as.list(cols)),
   verbose = TRUE]
 #===== r subset_error, error=TRUE, purl=FALSE
my_subset = function(data, col, val) {
  subset(data, col == val)
}
my_subset(iris, Species, "setosa")
 #===== r subset_parse
my_subset = function(data, col, val) {
  data = deparse(substitute(data))
  col = deparse(substitute(col))
  val = paste0("'", val, "'")
  text = paste0("subset(", data, ", ", col, " == ", val, ")")
  eval(parse(text = text)[[1L]])
}
my_subset(iris, Species, "setosa")
 #===== r subset_substitute
my_subset = function(data, col, val) {
  eval(substitute(subset(data, col == val)))
}
my_subset(iris, Species, "setosa")
 #===== r substitute2_recursive
substitute2( # tous sont des symboles
  f(v1, v2),
  list(v1 = "a", v2 = list("b", list("c", "d")))
)
substitute2( # 'a' et 'd' doivent rester des chaines de caractères
  f(v1, v2),
  list(v1 = I("a"), v2 = list("b", list("c", I("d"))))
)
 =====- absence de validation syntaxique===== =====- [vulnérabilité à l'injection de code](https://github.com/Rdatatable/data.table/issues/2655#issuecomment-376781159)===== =====- existence de meilleures alternatives===== Martin Machler, R Project Core Developer, [a dit](https://stackoverflow.com/a/40164111/2490497) : `$$${\displaystyle c = \sqrt{a^2 + b^2}}$$$` `$$${\displaystyle x_{\text{RMS}}={\sqrt{{\frac{1}{n}}\left(x_{1}^{2}+x_{2}^{2}+\cdots +x_{n}^{2}\right)}}}$$$` `eval` `get` title: "Programmation avec data.table"
date: "`r Sys.Date()`"
output:
  markdown::html_format
vignette: >
  %\VignetteIndexEntry{Programmation avec data.table}
  %\VignetteEngine{knitr::knitr}
  \usepackage[utf8]{inputenc}
 