��    V      �     |      x  l   y  d  �  �   K  T   ;  �  �  �  o  �   �  �   �  �   T  �   �  �   �  �  X  �   *  �  �    �  U   �  �   �  ;   p  2   �  �   �  �   u  %    �   @  �   �  &   �  i   �  Y  c  �   �   k   �!     �!     "     -"     G"  @  O"  �   �#  t   N$  �   �$  j  �%  *  (  �  F+    (-  �  ?.  �   ;1  �   (2     �2  �   �2    M3  *   l4    �4  S   �5  �   �5  d   �6  Z   +7  f   �7  �   �7  �   �8    |9     �;     �;     �;  "  �;  <  �=  )   )@  &   S@      z@     �@  9   �@  �   �@  �   �A    �B  S   �C  �   �C  4   �D  �   �D  �   ~E  W   _F     �F     �F  9  �F  A  "H  s  dI     �K     �K     �K  �   �K  �   �L  l   �M  �   N  �   �R  T   �S  �  �S  �  �U  �   xW  �   'X  �   �X  �   eY  �   Z  �  �Z  �   �\  �  s]  "  X_  U   {`  �   �`  ;   da  2   �a  �   �a  �   ib  #  c  �   2d    �d  &   �e  i   �e  �  hf  �   �g  �   �h     Xi     oi     �i     �i  X  �i  �   k  �   �k  �   Vl  �  <m  �  �o  B  �s  K  �u  �  -w    �z  �   �{     �|  �   �|  �  Q}  N   �~  :  )  T   d�  �   ��  a   ��  _   �  �   p�  -  ��  �   ,�  �  �     ��     ��     ڇ  �  �  ]  t�  5   Ҍ  ,   �  $   5�  $   Z�  D   �  ,  č  �   �  2  ��  r   �  �   e�  7   *�  �   b�    �  ^   +�     ��     ��  G  Ɣ  �  �  �  ��     ��     ��     ��  �   ��     J                 
   B                           @   R   *           T      #   S   V              1   E               Q       6   C      4       I      =         M   '   .                                                            0   7   L   2   +   5          <   	       (   /   ,       N                  8       >           P       G   U   3   K   !              F              O   &             :   9          )   %   -                  D   H      $   ;   "   ?   A    #===== r cleanup, echo=FALSE
options(.opts)
registerS3method("print", "data.frame", base::print.data.frame)
 #===== r complex
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
 #===== r df_print, echo=FALSE
registerS3method("print", "data.frame", function(x, ...) {
  base::print.data.frame(head(x, 2L), ...)
  cat("...\n")
  invisible(x)
})
.opts = options(
  datatable.print.topn=2L,
  datatable.print.nrows=20L
)
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
 #===== r hypotenuse_substitute2
substitute2(
  outer(inner(var1) + inner(var2)),
  env = list(
    outer = "sqrt",
    inner = "square",
    var1 = "a",
    var2 = "b"
  )
)
 #===== r init, include = FALSE
require(data.table)
knitr::opts_chunk$set(
  comment = "#",
    error = FALSE,
     tidy = FALSE,
    cache = FALSE,
 collapse = TRUE
)
 #===== r old_eval
cl = quote(
  .(Petal.Width = mean(Petal.Width), Sepal.Width = mean(Sepal.Width))
)

DT[, eval(cl)]

DT[, cl, env = list(cl = cl)]
 #===== r old_get
v1 = "Petal.Width"
v2 = "Sepal.Width"

DT[, .(total = sum(get(v1), get(v2)))]

DT[, .(total = sum(v1, v2)),
   env = list(v1 = v1, v2 = v2)]
 #===== r old_mget
v = c("Petal.Width", "Sepal.Width")

DT[, lapply(mget(v), mean)]

DT[, lapply(v, mean),
   env = list(v = as.list(v))]

DT[, lapply(v, mean),
   env = list(v = as.list(setNames(nm = v)))]
 #===== r rank
substitute(    # base R behaviour
  rank(input, ties.method = ties),
  env = list(input = as.name("Sepal.Width"), ties = "first")
)

substitute2(   # mimicking base R's "substitute" using "I"
  rank(input, ties.method = ties),
  env = I(list(input = as.name("Sepal.Width"), ties = "first"))
)

substitute2(   # only particular elements of env are used "AsIs"
  rank(input, ties.method = ties),
  env = list(input = "Sepal.Width", ties = I("first"))
)
 #===== r splice_datatable
# this works
DT[, j,
   env = list(j = as.list(cols)),
   verbose = TRUE]

# this will not work
#DT[, list(cols),
#   env = list(cols = cols)]
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
 #===== r splice_sd
cols = c("Sepal.Length", "Sepal.Width")
DT[, .SD, .SDcols = cols]
 #===== r splice_substitute2_not
str(substitute2(j, env = I(list(j = lapply(cols, as.name)))))

str(substitute2(j, env = list(j = as.list(cols))))
 #===== r splice_tobe
DT[, list(Sepal.Length, Sepal.Width)]
 #===== r subset
subset(iris, Species == "setosa")
 #===== r subset_error, error=TRUE, purl=FALSE
my_subset = function(data, col, val) {
  subset(data, col == val)
}
my_subset(iris, Species, "setosa")
 #===== r subset_nolazy
my_subset = function(data, col, val) {
  data[data[[col]] == val & !is.na(data[[col]]), ]
}
my_subset(iris, col = "Species", val = "setosa")
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
 ${\displaystyle c = \sqrt{a^2 + b^2}}$ ${\displaystyle x_{\text{RMS}}={\sqrt{{\frac{1}{n}}\left(x_{1}^{2}+x_{2}^{2}+\cdots +x_{n}^{2}\right)}}}$ *Splicing* is an operation where a list of objects have to be inlined into an expression as a sequence of arguments to call. In base R, splicing `cols` into a `list` can be achieved using `as.call(c(quote(list), lapply(cols, as.name)))`. Additionally, starting from R 4.0.0, there is new interface for such an operation in the `bquote` function. =====- lack of syntax validation===== =====- [vulnerability to code injection](https://github.com/Rdatatable/data.table/issues/2655#issuecomment-376781159)===== =====- the existence of better alternatives===== An obvious use case could be to mimic `.SD` functionality by injecting a `list` call into the `j` argument. Approaches to the problem Avoid *lazy evaluation* Computing on the language Example First, we have to construct calls to the `square` function for each of the variables (see `inner_calls`). Then, we have to reduce the list of calls into a single call, having a nested sequence of `+` calls (see `add_calls`). Lastly, we have to substitute the constructed call into the surrounding expression (see `rms`). For more detailed explanation on that matter, please see the examples in the [`substitute2` documentation](https://rdatatable.gitlab.io/data.table/library/data.table/html/substitute2.html). Having `cols` parameter, we'd want to splice it into a `list` call, making `j` argument look like in the code below. Here, `subset` takes the second argument and evaluates it within the scope of the `data.frame` given as its first argument. This removes the need for variable repetition, making it less prone to errors, and makes the code more readable. Here, we compute a logical vector of length `nrow(iris)`, then this vector is supplied to the `i` argument of `[.data.frame` to perform ordinary "logical vector"-based subsetting. To align with `subset()`, which also drops NAs, we need to include an additional use of `data[[col]]` to catch that. It works well enough for this simple example, but it lacks flexibility, introduces variable repetition, and requires user to change the function interface to pass the column name as a character rather than unquoted symbol. The more complex the expression we need to parameterize, the less practical this approach becomes. Here, we used the base R `substitute` function to transform the call `subset(data, col == val)` into `subset(iris, Species == "setosa")` by substituting `data`, `col`, and `val` with their original names (or values) from their parent environment. The benefits of this approach to the previous ones should be clear. Note that because we operate at the level of language objects, and don't have to resort to string manipulation, we refer to this as *computing on the language*. There is a dedicated chapter on *Computing on the language* in [R language manual](https://cran.r-project.org/doc/manuals/r-release/R-lang.html). Although it is not necessary for *programming on data.table*, we encourage readers to read this chapter for the sake of better understanding this powerful and unique feature of R language. In `[.data.table`, it is also possible to use other mechanisms for variable substitution or for passing quoted expressions. These include `get` and `mget` for inline injection of variables by providing their names as strings, and `eval` that tells `[.data.table` that the expression we passed into an argument is a quoted expression and that it should be handled differently. Those interfaces should now be considered retired and we recommend using the new `env` argument, instead. In data.table, we make it easier by automatically *enlist*-ing a list of objects into a list call with those objects. This means that any `list` object inside the `env` list argument will be turned into list `call`, making the API for that use case as simple as presented below. In the above example, we have seen a convenient feature of `substitute2`: automatic conversion from strings into names/symbols. An obvious question arises: what if we actually want to substitute a parameter with a *character* value, so as to have base R `substitute` behaviour. We provide a mechanism to escape automatic conversion by wrapping the elements into base R `I()` call. The `I` function marks an object as *AsIs*, preventing its arguments from character-to-symbol automatic conversion. (Read the `?AsIs` documentation for more details.) If base R behaviour is desired for the whole `env` argument, then it's best to wrap the whole argument in `I()`. Alternatively, each list element can be wrapped in `I()` individually. Let's explore both cases below. In the last call, we added another parameter, `out = "Sepal.Hypotenuse"`, that conveys the intended name of output column. Unlike base R's `substitute`, `substitute2` will handle the substitution of the names of call arguments, as well. Instead of using `eval` function we can provide quoted expression into the element of `env` argument, no extra `eval` call is needed then. Introduction It is important to provide a call to `as.list`, rather than simply a list, inside the `env` list argument, as is shown in the above example. It takes arbitrary number of variables on input, but now we cannot just *splice* a list of arguments into a list call because each of those arguments have to be wrapped in a `square` call. In this case, we have to *splice* by hand rather than relying on data.table's automatic *enlist*. Let's explore *enlist*-ing in more detail. Let's say we want to have a general function that applies a function to sum of two arguments that has been applied another function. As a concrete example, below we have a function to compute the length of the hypotenuse in a right triangle, knowing length of its legs. Let's take, as an example of a more complex function, calculating root mean square. Let's use the `iris` data set as a demonstration. Just as an example, let's pretend we want to compute the `Sepal.Hypotenuse`, treating the sepal width and length as if they were legs of a right triangle. Martin Machler, R Project Core Developer, [once said](https://stackoverflow.com/a/40164111/2490497): Note that both expressions, although visually appearing to be the same, are not identical. Note that conversion works recursively on each list element, including the escape mechanism of course. Now let's try to pass a list of symbols, rather than list call to those symbols. We'll use `I()` to escape automatic *enlist*-ing but, as this will also turn off character to symbol conversion, we also have to use `as.name`. Now that we've established the proper way to parameterize code that uses *lazy evaluation*, we can move on to the main subject of this vignette, *programming on data.table*. Now, to use substitution inside `[.data.table`, we don't need to call the `substitute2` function. As it is now being used internally, all we have to do is to provide `env` argument, the same way as we've provided it to the `substitute2` function in the example above. Substitution can be applied to the `i`, `j` and `by` (or `keyby`) arguments of the `[.data.table` method. Note that setting the `verbose` argument to `TRUE` can be used to print expressions after substitution is applied. This is very useful for debugging. Problem description Programming on data.table Retired interfaces Sorry but I don't understand why too many people even think a string was something that could be evaluated. You must change your mindset, really. Forget all connections between strings on one side and expressions, calls, evaluation on the other side. The (possibly) only connection is via `parse(text = ....)` and all good R programmers should know that this is rarely an efficient or safe means to construct expressions (or calls). Rather learn more about `substitute()`, `quote()`, and possibly the power of using `do.call(substitute, ......)`. Starting from version 1.15.0, data.table provides a robust mechanism for parameterizing expressions passed to the `i`, `j`, and `by` (or `keyby`) arguments of `[.data.table`. It is built upon the base R `substitute` function, and mimics its interface. Here, we introduce `substitute2` as a more robust and more user-friendly version of base R's `substitute`. For a complete list of differences between `base::substitute` and `data.table::substitute2` please read the [`substitute2` manual](https://rdatatable.gitlab.io/data.table/library/data.table/html/substitute2.html). Substitute variables and character values Substituting lists of arbitrary length Substituting variables and names Substitution of a complex query Substitution works on `i` and `by` (or `keyby`), as well. The aforementioned functions, along with some others (including `as.call`, `as.name`/`as.symbol`, `bquote`, and `eval`), can be categorized as functions to *compute on the language*, as they operate on *language* objects (e.g. `call`, `name`/`symbol`). The easiest workaround is to avoid *lazy evaluation* in the first place, and fall back to less intuitive, more error-prone approaches like `df[["variable"]]`, etc. The example presented above illustrates a neat and powerful way to make your code more dynamic. However, there are many other much more complex cases that a developer might have to deal with. One common problem handling a list of arguments of arbitrary length. The goal is the make every name in the above call able to be passed as a parameter. The problem with this kind of interface is that we cannot easily parameterize the code that uses it. This is because the expressions passed to those functions are substituted before being evaluated. There are multiple ways to work around this problem. There are third party packages that can achieve what base R computing on the language routines do (`pryr`, `lazyeval` and `rlang`, to name a few). This method is usually preferred by newcomers to R as it is, perhaps, the most straightforward conceptually. This way requires producing the required expression using string concatenation, parsing it, and then evaluating it. Though these can be helpful, we will be discussing a `data.table`-unique approach here. Use of `parse` / `eval` Use third party packages We can see in the output that both the functions names, as well as the names of the variables passed to those functions, have been replaced. We used `substitute2` for convenience. In this simple case, base R's `substitute` could have been used as well, though it would've required usage of `lapply(env, as.name)`. We have to use `deparse(substitute(...))` to catch the actual names of objects passed to function, so we can construct the `subset` function call using those original names. Although this provides unlimited flexibility with relatively low complexity, **use of `eval(parse(...))` should be avoided**. The main reasons are: `data.table`, from its very first releases, enabled the usage of `subset` and `with` (or `within`) functions by defining the `[.data.table` method. `subset` and `with` are base R functions that are useful for reducing repetition in code, enhancing readability, and reducing number the total characters the user has to type. This functionality is possible in R because of a quite unique feature called *lazy evaluation*. This feature allows a function to catch its arguments, before they are evaluated, and to evaluate them in a different scope than the one in which they were called. Let's recap usage of the `subset` function. `eval` `get` `mget` title: "Programming on data.table"
date: "`r Sys.Date()`"
output:
  markdown::html_format
vignette: >
  %\VignetteIndexEntry{Programming on data.table}
  %\VignetteEngine{knitr::knitr}
  \usepackage[utf8]{inputenc}
 Project-Id-Version: 
PO-Revision-Date: 
Last-Translator: Elise Maigné <elise.maigne@inrae.fr>
Language-Team: 
Language: fr
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5
 #===== r cleanup, echo=FALSE
options(.opts)
registerS3method("print", "data.frame", base::print.data.frame)
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
 #===== r df_print, echo=FALSE
registerS3method("print", "data.frame", function(x, ...) {
  base::print.data.frame(head(x, 2L), ...)
  cat("...\n")
  invisible(x)
})
.opts = options(
  datatable.print.topn=2L,
  datatable.print.nrows=20L
)
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
 #===== r hypotenuse_substitute2
substitute2(
  outer(inner(var1) + inner(var2)),
  env = list(
    outer = "sqrt",
    inner = "square",
    var1 = "a",
    var2 = "b"
  )
)
 #===== r init, include = FALSE
require(data.table)
knitr::opts_chunk$set(
  comment = "#",
    error = FALSE,
     tidy = FALSE,
    cache = FALSE,
 collapse = TRUE
)
 #===== r old_eval
cl = quote(
  .(Petal.Width = mean(Petal.Width), Sepal.Width = mean(Sepal.Width))
)

DT[, eval(cl)]

DT[, cl, env = list(cl = cl)]
 #===== r old_get
v1 = "Petal.Width"
v2 = "Sepal.Width"

DT[, .(total = sum(get(v1), get(v2)))]

DT[, .(total = sum(v1, v2)),
   env = list(v1 = v1, v2 = v2)]
 #===== r old_mget
v = c("Petal.Width", "Sepal.Width")

DT[, lapply(mget(v), mean)]

DT[, lapply(v, mean),
   env = list(v = as.list(v))]

DT[, lapply(v, mean),
   env = list(v = as.list(setNames(nm = v)))]
 #===== r rank
substitute( # comportement de base de R
  rank(input, ties.method = ties),
  env = list(input = as.name("Sepal.Width"), ties = "first")
)

substitute2( # imite le comportement "substitute" de base R en utilisant "I"
  rank(input, ties.method = ties),
  env = I(list(input = as.name("Sepal.Width"), ties = "first"))
)

substitute2( # seuls certains éléments de env sont utilisés "AsIs"
  rank(input, ties.method = ties),
  env = list(input = "Sepal.Width", ties = I("first"))
)
 #===== r splice_datable
# cela fonctionne
DT[, j,
   env = list(j = as.list(cols)),
   verbose = TRUE]

# cela ne fonctionnera pas
#DT[, list(cols),
# env = list(cols = cols)]
 #===== r splice_enlist
DT[, j, # data.table met automatiquement en liste les listes imbriquées dans des appels de liste
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

DT[, j, # encore une fois de la meilleure façon, ajout automatique de la liste à l'appel de liste
   env = list(j = as.list(cols)),
   verbose = TRUE]
 #===== r splice_sd
cols = c("Sepal.Length", "Sepal.Width")
DT[, .SD, .SDcols = cols]
 #===== r splice_substitute2_not
str(substitute2(j, env = I(list(j = lapply(cols, as.name)))))

str(substitute2(j, env = list(j = as.list(cols))))
 #===== r splice_tobe
DT[, list(Sepal.Length, Sepal.Width)]
 #===== r subset
subset(iris, Species == "setosa")
 #===== r subset_error, error=TRUE, purl=FALSE
my_subset = function(data, col, val) {
  subset(data, col == val)
}
my_subset(iris, Species, "setosa")
 #===== r subset_nolazy
my_subset = function(data, col, val) {
  data[data[[col]] == val & !is.na(data[[col]]), ]
}
my_subset(iris, col = "Species", val = "setosa")
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
 ${{displaystyle c = \sqrt{a^2 + b^2}}$ ${\displaystyle x_{\text{RMS}}={\sqrt{{\frac{1}{n}}\left(x_{1}^{2}+x_{2}^{2}+\cdots +x_{n}^{2}\right)}}}$ Le *'splicing'* est une opération où une liste d'objets doit être intégrée dans une expression comme une séquence d'arguments à appeler. Dans R de base, le 'splicing' de `cols` dans une `liste` peut être réalisé en utilisant `as.call(c(quote(list), lapply(cols, as.name)))`. De plus, à partir de R 4.0.0, il y a une nouvelle interface pour une telle opération dans la fonction `bquote`. =====- absence de validation syntaxique===== =====- [vulnérabilité à l'injection de code](https://github.com/Rdatatable/data.table/issues/2655#issuecomment-376781159)===== =====- existence de meilleures alternatives===== Un cas d'utilisation évident pourrait être d'imiter la fonctionnalité `.SD` en injectant un appel `list` dans l'argument `j`. Approches du problème Éviter les *lazy evaluation* Calculs sur le langage Exemple Tout d'abord, nous devons construire des appels à la fonction `square` pour chacune des variables (voir `inner_calls`). Ensuite, nous devons réduire la liste des appels en un seul appel, avec une séquence imbriquée d'appels `+` (voir `add_calls`). Enfin, nous devons substituer l'appel construit dans l'expression environnante (voir `rms`). Pour une explication plus détaillée à ce sujet, veuillez consulter les exemples dans la [documentation `substitute2`](https://rdatatable.gitlab.io/data.table/library/data.table/html/substitute2.html). Avec le paramètre `cols`, nous voudrions l'intégrer dans un appel `list`, en faisant ressembler l'argument `j` au code ci-dessous. Ici, `subset` prend le second argument et l'évalue dans le cadre du `data.frame` donné comme premier argument. Cela supprime le besoin de répéter les variables, ce qui réduit le risque d'erreurs et rend le code plus lisible. Ici, nous calculons un vecteur logique de longueur `nrow(iris)`, puis ce vecteur est fourni à l'argument `i` de `[.data.frame` pour effectuer un sous-ensemble ordinaire basé sur un "vecteur logique". Pour s'aligner avec `subset()`, qui supprime aussi les NA, nous devons inclure une utilisation supplémentaire de `data[[col]]`. Cela fonctionne assez bien pour cet exemple simple, mais cela manque de flexibilité, introduit des répétitions de variables, et demande à l'utilisateur de changer l'interface de la fonction pour passer le nom de la colonne comme un caractère plutôt qu'un symbole sans guillemet. Plus l'expression à paramétrer est complexe, moins cette approche est pratique. Ici, nous avons utilisé la fonction de base R `substitute` pour transformer l'appel `subset(data, col = val)` en `subset(iris, Species == "setosa")` en remplaçant `data`, `col`, et `val` par leurs noms (ou valeurs) d'origine dans leur environnement parent. Les avantages de cette approche par rapport aux précédentes devraient être clairs. Notez que parce que nous opérons au niveau des objets du langage, et que nous n'avons pas à recourir à la manipulation de chaînes de caractères, nous nous référons à cela comme *calcul sur le langage* ('computing on the language'). Il existe un chapitre dédié au *calcul sur le langage* dans le [Manuel du langage R](https://cran.r-project.org/doc/manuals/r-release/R-lang.html). Bien qu'il ne soit pas nécessaire pour *programmer sur data.table*, nous encourageons les lecteurs à lire ce chapitre afin de mieux comprendre cette fonctionnalité puissante et unique du langage R. Dans `[.data.table`, il est aussi possible d'utiliser d'autres mécanismes pour la substitution de variables ou pour passer des expressions entre guillemets. Ceux-ci incluent `get` et `mget` pour l'injection en ligne de variables en fournissant leurs noms sous forme de chaînes, et `eval` qui indique à `[.data.table` que l'expression passée en argument est une expression entre guillemets et qu'elle doit être traitée différemment. Ces interfaces doivent maintenant être considérées comme retirées et nous recommandons d'utiliser le nouvel argument `env` à la place. Dans data.table, nous facilitons les choses en transformant automatiquement en liste une liste d'objets en un appel de liste avec ces objets. Cela signifie que tout objet `list` à l'intérieur de l'argument `env` list sera transformé en `call` list, rendant l'API pour ce cas d'utilisation aussi simple que présenté ci-dessous. Dans l'exemple ci-dessus, nous avons vu une fonctionnalité pratique de `substitute2` : la conversion automatique de chaînes de caractères en noms/symboles. Une question évidente se pose : que se passe-t-il si nous voulons substituer un paramètre par une valeur *caractère*, afin d'avoir le comportement `substitute` de R de base. Nous fournissons un mécanisme pour échapper à la conversion automatique en enveloppant les éléments dans l'appel de base R `I()`. La fonction `I` marque un objet comme *AsIs*, empêchant ses arguments d'être convertis automatiquement de caractère à symbole. (Lisez la documentation `?AsIs` pour plus de détails.) Si le comportement de R de base est souhaité pour l'ensemble de l'argument `env`, alors il est préférable d'envelopper l'ensemble de l'argument dans `I()`. Alternativement, chaque élément de la liste peut être enveloppé dans `I()` individuellement. Explorons les deux cas ci-dessous. Dans le dernier appel, nous avons ajouté un autre paramètre, `out = "Sepal.Hypotenuse"`, qui transmet le nom prévu de la colonne de sortie. Contrairement à `substitute` de base R, `substitute2` gérera également la substitution des noms des arguments d'appel. Au lieu d'utiliser la fonction `eval`, nous pouvons fournir une expression citée dans l'élément de l'argument `env`, aucun appel supplémentaire à `eval` n'est alors nécessaire. Introduction Il est important de fournir un appel à `as.list`, plutôt qu'une simple liste, à l'intérieur de l'argument list de `env`, comme le montre l'exemple ci-dessus. Il prend un nombre arbitraire de variables en entrée, mais maintenant nous ne pouvons pas simplement ajouter (splice) une liste d'arguments dans un appel de liste parce que chacun de ces arguments doit être enveloppé dans un appel `square`. Dans ce cas, nous devons faire l'opération à la main plutôt que de compter sur la transformation automatique en liste (*'enlist'*) de data.table. Examinons plus en détail la question de l'ajout à la liste ('*enlist*-ing'). Disons que nous voulons une fonction générale qui applique une fonction à la somme de deux arguments auxquels une autre fonction a été appliquée. Comme exemple concret, nous avons ci-dessous une fonction qui calcule la longueur de l'hypoténuse dans un triangle droit, connaissant la longueur de ses côtés. Prenons l'exemple d'une fonction plus complexe, le calcul de la moyenne quadratique. Utilisons le jeu de données `iris` comme démonstration. A titre d'exemple, imaginons que nous voulions calculer la `Sepal.Hypotenuse`, en traitant la largeur et la longueur du sépale comme s'il s'agissait des côtés d'un triangle rectangle. Martin Machler, R Project Core Developer, [a dit](https://stackoverflow.com/a/40164111/2490497) : Notez que les deux expressions, bien qu'elles semblent visuellement identiques, ne le sont pas. Notez que la conversion s'effectue de manière récursive sur chaque élément de la liste, y compris le mécanisme d'échappement bien sûr. Essayons maintenant de passer une liste de symboles, plutôt qu'un appel de liste à ces symboles. Nous utiliserons `I()` pour échapper à la mise en liste (*enlist*-ing) automatique, mais comme cela désactivera aussi la conversion des caractères en symboles, nous devrons aussi utiliser `as.name`. Maintenant que nous avons établi la bonne façon de paramétrer le code qui utilise l'évaluation paresseuse ('*lazy evaluation*'), nous pouvons passer au sujet principal de cette vignette, *la programmation sur data.table*. Maintenant, pour utiliser la substitution à l'intérieur de `[.data.table`, nous n'avons pas besoin d'appeler la fonction `substitute2`. Comme elle est maintenant utilisée en interne, tout ce que nous avons à faire est de fournir l'argument `env`, de la même manière que nous l'avons fourni à la fonction `substitute2` dans l'exemple ci-dessus. La substitution peut être appliquée aux arguments `i`, `j` et `by` (ou `keyby`) de la méthode `[.data.table`. Notez que le fait de mettre l'argument `verbose` à `TRUE` peut être utilisé pour afficher les expressions après que la substitution ait été appliquée. Ceci est très utile pour le débogage. Description du problème Programmation sur data.table Interfaces supprimées Désolé, mais je ne comprends pas pourquoi tant de gens pensent qu'une chaîne de caractères est quelque chose qui peut être évalué. Il faut vraiment changer d'état d'esprit. Oubliez toutes les connexions entre les chaînes d'un côté et les expressions, les appels, l'évaluation de l'autre côté. La (possible) seule connexion est via `parse(text = ....)` et tous les bons programmeurs R devraient savoir que c'est rarement un moyen efficace ou sûr de construire des expressions (ou des appels). Apprenez plutôt à connaître `substitute()`, `quote()`, et peut-être la puissance de l'utilisation de `do.call(substitute, ......)`. A partir de la version 1.15.0, data.table fournit un mécanisme robuste pour paramétrer les expressions passées aux arguments `i`, `j`, et `by` (ou `keyby`) de `[.data.table`. Il est construit sur la fonction de base R `substitute`, et imite son interface. Nous présentons ici `substitute2` comme une version plus robuste et plus conviviale de la fonction `substitute` de R de base. Pour une liste complète des différences entre `base::substitute` et `data.table::substitute2`, veuillez lire le [manuel `substitute2`](https://rdatatable.gitlab.io/data.table/library/data.table/html/substitute2.html). Remplacer des variables et des valeurs de caractères Substituer des listes de longueur arbitraire Substitution de variables et de noms Substitution d'une requête complexe La substitution fonctionne également pour `i` et `by` (ou `keyby`). Les fonctions mentionnées ci-dessus, ainsi que quelques autres (y compris `as.call`, `as.name`/`as.symbol`, `bquote`, et `eval`), peuvent être catégorisées comme des fonctions pour *calculer sur le langage*, puisqu'elles opèrent sur des objets du *langage* (par exemple `call`, `name`/`symbol`). La solution la plus simple est d'éviter les *évaluations paresseuses* ('lazy evaluation'), et de se rabattre sur des approches moins intuitives et plus sujettes aux erreurs comme `df[["variable"]]`, etc. L'exemple présenté ci-dessus illustre un moyen propre et puissant de rendre votre code plus dynamique. Cependant, il existe de nombreux autres cas beaucoup plus complexes auxquels un développeur peut être confronté. Un problème courant consiste à gérer une liste d'arguments de longueur arbitraire. L'objectif est de faire en sorte que chaque nom dans l'appel ci-dessus puisse être passé en tant que paramètre. Le problème de ce type d'interface est qu'il n'est pas facile de paramétrer le code qui l'utilise. En effet, les expressions passées à ces fonctions sont substituées avant d'être évaluées. Il existe plusieurs façons de contourner ce problème. Il existe des packages tiers qui peuvent réaliser ce que les routines de calcul du R de base sur le langage font (`pryr`, `lazyeval` et `rlang`, pour n'en citer que quelques-uns). Cette méthode est généralement préférée par les nouveaux venus dans R, car elle est peut-être la plus simple sur le plan conceptuel. Cette méthode consiste à produire l'expression requise à l'aide de la concaténation de chaînes, à l'analyser, puis à l'évaluer. Bien qu'ils puissent être utiles, nous discuterons ici d'une approche propre à `data.table`. Utilisation de `parse` / `eval` Utiliser des packages tiers Nous pouvons voir dans la sortie que les noms des fonctions, ainsi que les noms des variables passées à ces fonctions, ont été remplacés. Nous avons utilisé `substitute2` par commodité. Dans ce cas simple, le `substitute` de base R aurait pu être utilisé aussi, bien qu'il aurait fallu utiliser `lapply(env, as.name)`. Nous devons utiliser `deparse(substitute(...))` pour récupérer les noms réels des objets passés à la fonction, afin de pouvoir construire l'appel à la fonction `subset` en utilisant ces noms originaux. Bien que cela offre une flexibilité illimitée avec une complexité relativement faible, **l'utilisation de `eval(parse(...))` devrait être évitée**. Les raisons principales sont les suivantes : `data.table`, dès ses premières versions, a permis l'utilisation des fonctions `subset` et `with` (ou `within`) en définissant la méthode `[.data.table`. `subset` et `with` sont des fonctions de base de R qui sont utiles pour réduire les répétitions dans le code, améliorer la lisibilité, et réduire le nombre total de caractères que l'utilisateur doit taper. Cette fonctionnalité est possible dans R grâce à une fonction unique appelée *évaluation paresseuse* ('lazy evaluation'). Cette fonctionnalité permet à une fonction de récupérer ses arguments, avant qu'ils ne soient évalués, et de les évaluer dans un cadre différente de celle dans laquelle ils ont été appelés. Récapitulons l'utilisation de la fonction `subset`. `eval` `get` `mget` title: "Programmation avec data.table"
date: "`r Sys.Date()`"
output:
  markdown::html_format
vignette: >
  %\VignetteIndexEntry{Programmation avec data.table}
  %\VignetteEngine{knitr::knitr}
  \usepackage[utf8]{inputenc}
 