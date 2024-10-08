��    G      T  a   �        9     �   K  �    q   �  �  	  �   �  0  b  #   �  A   �  �   �  
  �  �   �  D   |  c   �  �   %  +     [  9  1  �  !   �  (  �  �     �  �  �   \           %   �  <      �!  %   �!  V   %"     |"     �"     �"     �"  Q   �"  f   #  B  #  \  �%  }   '  n   �'  "   (  �   /(  �   )     �)  S  �)  �  .+  �   �,  �  �-  .  �/  �   �0  w   @1  �   �1  w   v2  �   �2  �  �3  >   �5  O  �5  �   '7  y   �7  U   w8  p   �8  �   >9  X  :  ]   k;  t  �;  �   >=     �=  y   �=     P>  %  h>  A  �@    �A  >   �B  �   &C  �  �C  w   �E  �  %F  �   �H  L  �I  #   �J  A   !K  �   cK  J  UL  �   �Q  D   (R  c   mR  �   �R  +   �S  �  �S  l  �U  ,   Y  �  @Y  �   �[  �  �\  �   �^  "   a_     �_    �_     �a  '   �a  b   �a     bb     pb     }b     �b  Y   �b  n   c  �  wc  \  f  �   zg  �   'h  '   �h    �h  �   �i     �j  �  �j  �  Wl    n  8  /o  p  hq  �   �r  �   {s  �   t  �   �t    �u  -  �v  ?   �x  ^  y    lz  �   y{  T   �{  ~   T|  �   �|  �  �}  o   j  �  �  �   ��     S�  �   f�  $   �  �  �  `  ��     =      @   )   C   -       $                  E             <              4      ?       9   7   1      %   6   0              >       D       8   #                    F           '   B      G   A   +          !   "       (      &      3   5       2                        ,      /   	                :   *       .   
                       ;              ![Grouping, Illustrated](plots/grouping_illustration.png) #===== r assign_factors
Teams[ , names(.SD) := lapply(.SD, factor), .SDcols = patterns('teamID')]
# print out the first column to demonstrate success
head(unique(Teams[[fkt[1L]]]))
 #===== r conditional_join
# to exclude pitchers with exceptional performance in a few games,
#   subset first; then define rank of pitchers within their team each year
#   (in general, we should put more care into the 'ties.method' of frank)
Pitching[G > 5, rank_in_team := frank(ERA), by = .(teamID, yearID)]
Pitching[rank_in_team == 1, team_performance :=
           Teams[.SD, Rank, on = c('teamID', 'yearID')]]
 #===== r download_lahman
load('Teams.RData')
setDT(Teams)
Teams

load('Pitching.RData')
setDT(Pitching)
Pitching
 #===== r group_lm, results = 'hide', fig.cap="A histogram depicting the distribution of fitted coefficients. It is vaguely bell-shaped and concentrated around -.2"
# Overall coefficient for comparison
overall_coef = Pitching[ , coef(lm(ERA ~ W))['W']]
# use the .N > 20 filter to exclude teams with few observations
Pitching[ , if (.N > 20L) .(w_coef = coef(lm(ERA ~ W))['W']), by = teamID
          ][ , hist(w_coef, 20L, las = 1L,
                    xlab = 'Fitted Coefficient on W',
                    ylab = 'Number of Teams', col = 'darkgreen',
                    main = 'Team-Level Distribution\nWin Coefficients on ERA')]
abline(v = overall_coef, lty = 2L, col = 'red')
 #===== r group_sd_last
# the data is already sorted by year; if it weren't
#   we could do Teams[order(yearID), .SD[.N], by = teamID]
Teams[ , .SD[.N], by = teamID]
 #===== r identify_factors
# teamIDBR: Team ID used by Baseball Reference website
# teamIDlahman45: Team ID used in Lahman database version 4.5
# teamIDretro: Team ID used by Retrosheet
fkt = c('teamIDBR', 'teamIDlahman45', 'teamIDretro')
# confirm that they're stored as `character`
str(Teams[ , ..fkt])
 #===== r plain_sd
Pitching[ , .SD]
 #===== r plain_sd_is_table
identical(Pitching, Pitching[ , .SD])
 #===== r sd_as_logical
fct_idx = Teams[, which(sapply(.SD, is.factor))] # column numbers to show the class changing
str(Teams[[fct_idx[1L]]])
Teams[ , names(.SD) := lapply(.SD, as.character), .SDcols = is.factor]
str(Teams[[fct_idx[1L]]])
 #===== r sd_for_lm, cache = FALSE, fig.cap="Fit OLS coefficient on W, various specifications, depicted as bars with distinct colors."
# this generates a list of the 2^k possible extra variables
#   for models of the form ERA ~ G + (...)
extra_var = c('yearID', 'teamID', 'G', 'L')
models = unlist(
  lapply(0L:length(extra_var), combn, x = extra_var, simplify = FALSE),
  recursive = FALSE
)

# here are 16 visually distinct colors, taken from the list of 20 here:
#   https://sashat.me/2017/01/11/list-of-20-simple-distinct-colors/
col16 = c('#e6194b', '#3cb44b', '#ffe119', '#0082c8',
          '#f58231', '#911eb4', '#46f0f0', '#f032e6',
          '#d2f53c', '#fabebe', '#008080', '#e6beff',
          '#aa6e28', '#fffac8', '#800000', '#aaffc3')

par(oma = c(2, 0, 0, 0))
lm_coef = sapply(models, function(rhs) {
  # using ERA ~ . and data = .SD, then varying which
  #   columns are included in .SD allows us to perform this
  #   iteration over 16 models succinctly.
  #   coef(.)['W'] extracts the W coefficient from each model fit
  Pitching[ , coef(lm(ERA ~ ., data = .SD))['W'], .SDcols = c('W', rhs)]
})
barplot(lm_coef, names.arg = sapply(models, paste, collapse = '/'),
        main = 'Wins Coefficient\nWith Various Covariates',
        col = col16, las = 2L, cex.names = 0.8)
 #===== r sd_patterns
Teams[ , .SD, .SDcols = patterns('team')]
Teams[ , names(.SD) := lapply(.SD, factor), .SDcols = patterns('team')]
 #===== r sd_team_best_year
Teams[ , .SD[which.max(R)], by = teamID]
 #===== r simple_sdcols
# W: Wins; L: Losses; G: Games
Pitching[ , .SD, .SDcols = c('W', 'L', 'G')]
 #===== r, echo = FALSE, message = FALSE
require(data.table)
knitr::opts_chunk$set(
  comment = "#",
  error = FALSE,
  tidy = FALSE,
  cache = FALSE,
  collapse = TRUE,
  out.width = '100%',
  dpi = 144
)
.old.th = setDTthreads(1)
 #===== r, echo=FALSE
setDTthreads(.old.th)
 ** A proviso to the above: *explicitly* using column numbers (like `DT[ , (1) := rnorm(.N)]`) is bad practice and can lead to silently corrupted code over time if column positions change. Even implicitly using numbers can be dangerous if we don't keep smart/strict control over the ordering of when we create the numbered index and when we use it. *NB*: `.SD[1L]` is currently optimized by [*`GForce`*](https://Rdatatable.gitlab.io/data.table/library/data.table/html/datatable-optimize.html) ([see also](https://stackoverflow.com/questions/22137591/about-gforce-in-data-table-1-9-2)), `data.table` internals which massively speed up the most common grouped operations like `sum` or `mean` -- see `?GForce` for more details and keep an eye on/voice support for feature improvement requests for updates on this front: [1](https://github.com/Rdatatable/data.table/issues/735), [2](https://github.com/Rdatatable/data.table/issues/2778), [3](https://github.com/Rdatatable/data.table/issues/523), [4](https://github.com/Rdatatable/data.table/issues/971), [5](https://github.com/Rdatatable/data.table/issues/1197), [6](https://github.com/Rdatatable/data.table/issues/1414) *see `?patterns` for more details =====1. The `:=` is an assignment operator to update the `data.table` in place without making a copy. See [reference semantics](https://cran.r-project.org/package=data.table/vignettes/datatable-reference-semantics.html) for more. ===== =====2. The LHS, `names(.SD)`, indicates which columns we are updating - in this case we update the entire `.SD`.===== =====3. The RHS, `lapply()`, loops through each column of the `.SD` and converts the column to a factor.===== =====4. We use the `.SDcols` to only select columns that have pattern of `teamID`.===== =====1. any function such as `is.character` to filter *columns*===== =====2. the function^{*} `patterns()` to filter *column names* by regular expression===== =====3. integer and logical vectors===== Again, the `.SDcols` argument is quite flexible; above, we supplied `patterns` but we could have also supplied `fkt` or any `character` vector of column names. In other situations, it is more convenient to supply an `integer` vector of column *positions* or a `logical` vector dictating include/exclude for each column. Finally, the use of a function to filter columns is very helpful. Another common version of this is to use `.SD[1L]` instead to get the *first* observation for each group, or `.SD[sample(.N, 1L)]` to return a *random* row for each group. Column Subsetting: `.SDcols` Column Type Conversion Column type conversion is a fact of life for data munging. Though [`fwrite` recently gained the ability to declare the class of each column up front](https://github.com/Rdatatable/data.table/pull/2545), not all data sets come from `fread` (e.g. in this vignette) and conversions back and forth among `character`/`factor`/`numeric` types are common. We can use `.SD` and `.SDcols` to batch-convert groups of columns to a common type. Conditional Joins Controlling a Model's Right-Hand Side For example, we could do the following to convert all `factor` columns to `character`: Group Optima Group Subsetting Grouped Regression Grouped `.SD` operations Here's a short script leveraging the power of `.SD` which explores this question: In terms of subsetting, `.SD` is still a subset of the data, it's just a trivial one (the set itself). In the broadest sense, `.SD` is just shorthand for capturing a variable that comes up frequently in the context of data analysis. It can be understood to stand for *S*ubset, *S*elfsame, or *S*elf-reference of the *D*ata. That is, `.SD` is in its most basic guise a *reflexive reference* to the `data.table` itself -- as we'll see in examples below, this is particularly helpful for chaining together "queries" (extractions/subsets/etc using `[`). In particular, this also means that `.SD` is *itself a `data.table`* (with the caveat that it does not allow assignment with `:=`). In the case of grouping, `.SD` is multiple in nature -- it refers to *each* of these sub-`data.table`s, *one-at-a-time* (slightly more accurately, the scope of `.SD` is a single sub-`data.table`). This allows us to concisely express an operation that we'd like to perform on *each sub-`data.table`* before the re-assembled result is returned to us. Lastly, we can do pattern-based matching of columns in `.SDcols` to select all columns which contain `team` back to `factor`: Let's get the most recent season of data for each team in the Lahman data. This can be done quite simply with: Loading and Previewing Lahman Data Note that the `x[y]` syntax returns `nrow(y)` values (i.e., it's a right join), which is why `.SD` is on the right in `Teams[.SD]` (since the RHS of `:=` in this case requires `nrow(Pitching[rank_in_team == 1])` values). Note that this approach can of course be combined with `.SDcols` to return only portions of the `data.table` for each `.SD` (with the caveat that `.SDcols` should be fixed across the various subsets) Note: Often, we'd like to perform some operation on our data *at the group level*. When we specify `by =` (or `keyby = `), the mental model for what happens when `data.table` processes `j` is to think of your `data.table` as being split into many component sub-`data.table`s, each of which corresponds to a single value of your `by` variable(s): Readers up on baseball lingo should find the tables' contents familiar; `Teams` records some statistics for a given team in a given year, while `Pitching` records statistics for a given pitcher in a given year. Please do check out the [documentation](https://github.com/cdalzell/Lahman) and explore the data yourself a bit before proceeding to familiarize yourself with their structure. Recall that `.SD` is itself a `data.table`, and that `.N` refers to the total number of rows in a group (it's equal to `nrow(.SD)` within each group), so `.SD[.N]` returns the *entirety of `.SD`* for the final row associated with each `teamID`. Returning to the inquiry above regarding the relationship between `ERA` and `W`, suppose we expect this relationship to differ by team (i.e., there's a different slope for each team). We can easily re-run this regression to explore the heterogeneity in this relationship as follows (noting that the standard errors from this approach are generally incorrect -- the specification `ERA ~ W*teamID` will be better -- this approach is easier to read and the *coefficients* are OK): Suppose we wanted to return the *best* year for each team, as measured by their total number of runs scored (`R`; we could easily adjust this to refer to other metrics, of course). Instead of taking a *fixed* element from each sub-`data.table`, we now define the desired index *dynamically* as follows: That is, `Pitching[ , .SD]` has simply returned the whole table, i.e., this was an overly verbose way of writing `Pitching` or `Pitching[]`: The above is just a short introduction of the power of `.SD` in facilitating beautiful, efficient code in `data.table`! The coefficient always has the expected sign (better pitchers tend to have more wins and fewer runs allowed), but the magnitude can vary substantially depending on what else we control for. The first way to impact what `.SD` is is to limit the *columns* contained in `.SD` using the `.SDcols` argument to `[`: The goal is to add a column `team_performance` to the `Pitching` table that records the team's performance (rank) of the best pitcher on each team (as measured by the lowest ERA, among pitchers with at least 6 recorded games). The simpler usage of `.SD` is for column subsetting (i.e., when `.SDcols` is specified); as this version is much more straightforward to understand, we'll cover that first below. The interpretation of `.SD` in its second usage, grouping scenarios (i.e., when `by = ` or `keyby = ` is specified), is slightly different, conceptually (though at core it's the same, since, after all, a non-grouped operation is an edge case of grouping with just one group). The syntax to now convert these columns to `factor` is simple: This example is admittedly a tad contrived, but illustrates the idea; see here ([1](https://stackoverflow.com/questions/31329939/conditional-keyed-join-update-and-update-a-flag-column-for-matches), [2](https://stackoverflow.com/questions/29658627/conditional-binary-join-and-update-by-reference-using-the-data-table-package)) for more. This is great in general, but falls short when we wish to perform a *conditional join*, wherein the exact nature of the relationship among tables depends on some characteristics of the rows in one or more columns. This is just for illustration and was pretty boring. In addition to accepting a character vector, `.SDcols` also accepts: This is useful in a variety of settings, the most common of which are presented here: This simple usage lends itself to a wide variety of highly beneficial / ubiquitous data manipulation operations: This vignette will explain the most common ways to use the `.SD` variable in your `data.table` analyses. It is an adaptation of [this answer](https://stackoverflow.com/a/47406952/3576984) given on StackOverflow. To give this a more real-world feel, rather than making up data, let's load some data sets about baseball from the [Lahman database](https://github.com/cdalzell/Lahman). In typical R usage, we'd simply load these data sets from the `Lahman` R package; in this vignette, we've pre-downloaded them directly from the package's GitHub page instead. To illustrate what I mean about the reflexive nature of `.SD`, consider its most banal usage: Varying model specification is a core feature of robust statistical analysis. Let's try and predict a pitcher's ERA (Earned Runs Average, a measure of performance) using the small set of covariates available in the `Pitching` table. How does the (linear) relationship between `W` (wins) and `ERA` vary depending on which other covariates are included in the specification? We notice that the following columns are stored as `character` in the `Teams` data set, but might more logically be stored as `factor`s: What is `.SD`? While there is indeed a fair amount of heterogeneity, there's a distinct concentration around the observed overall value. `.SD` on Ungrouped Data `data.table` syntax is beautiful for its simplicity and robustness. The syntax `x[i]` flexibly handles three common approaches to subsetting -- when `i` is a `logical` vector, `x[i]` will return those rows of `x` corresponding to where `i` is `TRUE`; when `i` is *another `data.table`* (or a `list`), a (right) `join` is performed (in the plain form, using the `key`s of `x` and `i`, otherwise, when `on = ` is specified, using matches of those columns); and when `i` is a character, it is interpreted as shorthand for `x[list(i)]`, i.e., as a join. title: "Using .SD for Data Analysis"
date: "`r Sys.Date()`"
output:
  markdown::html_format:
    options:
      toc: true
      number_sections: true
    meta:
      css: [default, css/toc.css]
vignette: >
  %\VignetteIndexEntry{Using .SD for Data Analysis}
  %\VignetteEngine{knitr::knitr}
  \usepackage[utf8]{inputenc}
 Project-Id-Version: 
PO-Revision-Date: 
Last-Translator: Christian Wiat <w9204-rs@yahoo.com>
Language-Team: 
Language: fr
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Plural-Forms: nplurals=2; plural=(n > 1);
X-Generator: Poedit 3.5
 ![Regroupement, illustré](../plots/grouping_illustration.png) #===== r assign_factors
Teams[ , names(.SD) := lapply(.SD, factor), .SDcols = patterns('teamID')]
# imprime la première colonne pour montrer que c’est correct
head(unique(Teams[[fkt[1L]]]))
 #===== r conditional_join
# pour exclure les pichers ayant des performances exceptionnelles dans peu de jeux,
#   faire un sous-ensemble ; ensuite définir le rang des pichers dans leur équipe chaque
#   année (en général, nous nous focaliserions sur 'ties.method' de frank)
Pitching[G > 5, rank_in_team := frank(ERA), by = .(teamID, yearID)]
Pitching[rank_in_team == 1, team_performance :=
           Teams[.SD, Rank, on = c('teamID', 'yearID')]]
 #===== r download_lahman
load('../Teams.RData')
setDT(Teams)
Teams

load('../Pitching.RData')
setDT(Pitching)
Pitching
 #===== r group_lm, results = 'hide', fig.cap="Histogramme de la distribution des coefficients ajustés. Il a plus ou moins une forme en cloche centrée autour de -.2"
# Coefficients globaux pour comparaison
overall_coef = Pitching[ , coef(lm(ERA ~ W))['W']]
# utilisation du filtre .N > 20 pour exclure les équipes où il y a peu de données
Pitching[ , if (.N > 20L) .(w_coef = coef(lm(ERA ~ W))['W']), by = teamID
          ][ , hist(w_coef, 20L, las = 1L,
                    xlab = 'Fitted Coefficient on W',
                    ylab = 'Number of Teams', col = 'darkgreen',
                    main = 'Team-Level Distribution\nWin Coefficients on ERA')]
abline(v = overall_coef, lty = 2L, col = 'red')
 #===== r group_sd_last
# les données sont déjà triées par année ; si ce n’était pas le cas
#   nous pourrions faire Teams[order(yearID), .SD[.N], by = teamID]
Teams[ , .SD[.N], by = teamID]
 #===== r identify_factors
# teamIDBR: Team ID utilisé par le site de référence du baseball
# teamIDlahman45: Team ID utilisé dans la base de données Lahman v4.5
# teamIDretro: Team ID utilisé par Retrosheet
fkt = c('teamIDBR', 'teamIDlahman45', 'teamIDretro')
# confirmer que ce sont bien des `character`
str(Teams[ , ..fkt])
 #===== r plain_sd
Pitching[ , .SD]
 #===== r plain_sd_is_table
identical(Pitching, Pitching[ , .SD])
 #===== r sd_as_logical
fct_idx = Teams[, which(sapply(.SD, is.factor))] # numéros de colonnes (changement de classe)
str(Teams[[fct_idx[1L]]])
Teams[ , names(.SD) := lapply(.SD, as.character), .SDcols = is.factor]
str(Teams[[fct_idx[1L]]])
 #===== r sd_for_lm, cache = FALSE, fig.cap="Ajustement OLS pour le coefficient W, diverses spécifications, représentées par des barres de couleurs distinctes."
# ceci génère une liste des 2^k variables extra possibles
#   pour les modèles de forme ERA ~ G + (...)
extra_var = c('yearID', 'teamID', 'G', 'L')
models = unlist(
  lapply(0L:length(extra_var), combn, x = extra_var, simplify = FALSE),
  recursive = FALSE
)

# voici 16 couleurs distinctes, choisis dans une liste de 20 ici:
#   https://sashat.me/2017/01/11/list-of-20-simple-distinct-colors/
col16 = c('#e6194b', '#3cb44b', '#ffe119', '#0082c8',
          '#f58231', '#911eb4', '#46f0f0', '#f032e6',
          '#d2f53c', '#fabebe', '#008080', '#e6beff',
          '#aa6e28', '#fffac8', '#800000', '#aaffc3')

par(oma = c(2, 0, 0, 0))
lm_coef = sapply(models, function(rhs) {
  # utilisation de ERA ~ . et data = .SD, puis variation de
  #   quelles colonnes sont incluses dans .SD, ce qui nous permet
  #   de varier les iterations sur les 16 modèles facilement.
  #   coef(.)['W'] extrait le coefficient W de chaque modèle ajusté
  Pitching[ , coef(lm(ERA ~ ., data = .SD))['W'], .SDcols = c('W', rhs)]
})
barplot(lm_coef, names.arg = sapply(models, paste, collapse = '/'),
        main = 'Wins Coefficient\nWith Various Covariates',
        col = col16, las = 2L, cex.names = 0.8)
 #===== r sd_patterns
Teams[ , .SD, .SDcols = patterns('team')]
Teams[ , names(.SD) := lapply(.SD, factor), .SDcols = patterns('team')]
 #===== r sd_team_best_year
Teams[ , .SD[which.max(R)], by = teamID]
 #===== r simple_sdcols
# W: Wins; L: Losses; G: Games
Pitching[ , .SD, .SDcols = c('W', 'L', 'G')]
 #===== r, echo = FALSE, message = FALSE
require(data.table)
knitr::opts_chunk$set(
  comment = "#",
  error = FALSE,
  tidy = FALSE,
  cache = FALSE,
  collapse = TRUE,
  out.width = '100%',
  dpi = 144
)
.old.th = setDTthreads(1)
 #===== r, echo=FALSE
setDTthreads(.old.th)
 ** En plus de ce qui a été dit ci-dessus : *utiliser *explicitement* le numéro des colonnes (comme `DT[ , (1) := rnorm(.N)]`) n'est pas recommandé et peut conduire progressivement à obtenir un code corrompu au fil du temps si la position des colonnes change. Même l'utilisation implicite de numéros peut être dangereuse si nous ne gardons pas un contrôle intelligent et strict de l'ordre quand nous créons et utilisons l'index numéroté. *NB* : `.SD[1L]` est actuellement optimisé par [*`GForce`*](https://Rdatatable.gitlab.io/data.table/library/data.table/html/datatable-optimize.html) ([voir aussi](https://stackoverflow.com/questions/22137591/about-gforce-in-data-table-1-9-2)), `data.table` interne qui accélère massivement les opérations groupées les plus courantes comme `sum` ou `mean` -- voir ` ?GForce` pour plus de détails et gardez un oeil sur le support pour les demandes d'amélioration des fonctionnalités pour les mises à jour sur ce front : [1](https://github.com/Rdatatable/data.table/issues/735), [2](https://github.com/Rdatatable/data.table/issues/2778), [3](https://github.com/Rdatatable/data.table/issues/523), [4](https://github.com/Rdatatable/data.table/issues/971), [5](https://github.com/Rdatatable/data.table/issues/1197), [6](https://github.com/Rdatatable/data.table/issues/1414) *voir `?patterns` pour davantage de détails =====1. Le `:=` est un opérateur d'affectation qui permet de mettre à jour `data.table` sans faire de copie. Voir [reference semantics](https://cran.r-project.org/package=data.table/vignettes/datatable-reference-semantics.html) pour plus d'informations. ===== =====2. Le membre de gauche, `names(.SD)`, indique quelles colonnes nous mettons à jour - dans ce cas, nous mettons à jour l'intégralité de `.SD`.===== =====3. Le membre de droite, `lapply()`, parcourt chaque colonne du `.SD` et convertit la colonne en un facteur.===== =====4. Nous utilisons `.SDcols` pour sélectionner uniquement les colonnes qui ont le motif `teamID`.===== =====1. toute fonction telle que `is.character` pour filtrer les *colonnes*===== =====2. la fonction^*^ `patterns()` pour filtrer les *noms de colonnes* par expression régulière===== =====3. les vecteurs entiers et logiques===== A nouveau, l'argument `.SDcols` est très souple ; nous avons fourni ci-dessus `patterns` mais nous aurions pu passer également `fkt` ou tout vecteur `character` de noms de colonnes. Dans d'autres situations, il est plus pratique de fournir un vecteur `integer` de *positions* des colonnes ou un vecteur de `booléens` indiquant pour chaque colonne s'il faut l'inclure ou l'exclure. Finalement nous utilisons une fonction pour filtrer les colonnes ce qui est très pratique. Une autre version commune de ceci est l'utilisation de `.SD[1L]` à la place, pour obtenir la *première* observation de chaque groupe, ou `.SD[sample(.N, 1L)]` pour renvoyer une ligne *aléatoire* pour chaque groupe. Extraction de colonnes : `.SDcols` Convertir un type de colonne La conversion du type de colonne est une réalité en gestion des données. Bien que [`fwrite` a récemment gagné la possibilité de déclarer en amont la classe de chaque colonne](https://github.com/Rdatatable/data.table/pull/2545), chaque ensemble de données n'est pas forcément issu d'un `fread` (comme dans cette vignette) et les conversions alternatives parmi les types `character`, `factor`, et `numeric` sont courantes. Nous pouvons utiliser `.SD` et `.SDcols` pour convertir par lots des groupes de colonnes vers un type commun. Jointures conditionnelles Contrôler le membre droit d'un modèle Par exemple nous pourrions faire ceci pour convertir toutes les colonnes `factor` en `character` : Groupe Optima Sous-groupes Régression groupée Opérations `.SD` groupées Voici une courte description qui évalue la puissance de `.SD` explorant cette question : En terme de sous-groupe, `.SD` est un sous-groupe des données, le plus évident (c'est l'ensemble lui-même). Au sens large, `.SD` est simplement un raccourci pour capturer une variable qui apparait fréquemment dans le contexte de l'analyse de données. Il faut comprendre *S* pour *S*ubset, *S*elfsame, ou *S*elf-reference et *D* pour *D*onnée. Ce qui donne, `.SD` qui dans sa forme la plus basique est une *référence réflexive* de la `data.table` elle-même -- comme nous le verrons dans les exemples ci-dessous,  ceci est particulièrement utile pour chaîner ensemble les "requêtes" (extractions/sous-ensembles/etc... en utilisant `[`). E particulier cela signifie aussi que *`.SD` est lui-même une `data.table`* (avec la mise en garde qu'il ne peut être assigné avec `:=`). En cas de groupement, `.SD` est multiple par nature -- il se réfère à *chaque* sous-`data.table, *une à la fois* (ou plus précisément, la visibilité de `.SD` est une sous-`data.table` unique). Ceci nous permet d'indiquer précisément une opération à réaliser sur *chaque sous-`data.table`* avant de réassembler et renvoyer le résultat. Enfin, nous pouvons faire une correspondance basée sur les motifs des colonnes dans `.SDcols` pour sélectionner toutes les colonnes qui contiennent `team` vers `factor` : Essayons d'obtenir la saison la plus récente des données pour chaque équipe des données Lahman. Ceci peut être fait simplement avec : Charger et afficher les données Lahman Notez que la syntaxe de `x[y]` renvoie `nrow(y)` values (c'est une jointure droite), c'est pourquoi `.SD` se trouve à droite dans `Teams[.SD]` (parce que le membre de droite de `:=` dans ce cas nécessite les valeurs de `nrow(Pitching[rank_in_team == 1])` ). Notez que cette approche peut bien sûr être combinée avec `.SDcols` pour renvoyer uniquement les portions de `data.table` pour chaque `.SD` (avec la mise en garde que `.SDcols` soit initialisé en fonction des différents sous-ensembles) Note : Nous aimerions souvent réaliser une opération sur nos données *au niveau groupe*. Si nous indiquons `by =` (ou `keyby = `), le modèle que nous imaginons mentalement pour ce qui se passe quand `data.table` traite `j` est de considérer que la `data.table` est constituée de plusieurs composants sous-`data.table`, dont chacun correspond à une seule valeur des variables du `by` : Les lecteurs connaissant le jargon du baseball devraient trouver le contenu des tableaux familier ; `Teams` enregistre certaines statistiques pour une équipe et une année donnée, alors que `Pitching` enregistre les statistiques pour un lanceur et une année donnée. Veuillez lire la [documentation](https://github.com/cdalzell/Lahman) et explorer un peu les données avant  d'aller plus loin afin de vous familiariser avec leur structure. Rappelez-vous que `.SD` est lui-même une `data.table`, et que `.N` se rapporte au nombre total de lignes dans un groupe (c'est égal à `nrow(.SD)` à l'intérieur de chaque groupe), donc `.SD[.N]` renvoie la *totalité de `.SD`* pour la dernière ligne associée à chaque `teamID`. Revenons à la requête ci-dessus à propos des relations entre `ERA` et `W`; supposez que nous espérions que cette relation soit différente en fonction de l'équipe (c'est à dire que la pente soit différente pour chaque équipe). Nous pouvons facilement réexécuter cette régression pour explorer l'hétérogenéité dans cette relation comme ceci (en notant que les erreurs standard de cette approche sont généralement incorrectes -- la spécification `ERA ~ W*teamID` sera meilleurs -- cette approche est plus facile à lire et les *coefficients* sont OK) : Supposons que nous voulions renvoyer la *meilleure* année pour chaque équipe, tel que mesuré par leur nombre total de tournois enregistrés (`R`; il est facile d'ajuster cela pour s'adapter à d'autres métriques, bien sûr). Au lieu de prendre un élément *fixe* de chaque sous-`data.table`, nous définissons maintenant *dynamiquement* l'indice souhaité ainsi : C'est à dire que `Pitching[ , .SD]` a simplement renvoyé la table complète, et c'est une manière exagérément verbeuse d'écrire `Pitching` ou `Pitching[]`: Tout ceci n'est simplement qu'une brève introduction sur la puissance de `.SD` qui facilite la beauté et l'efficacité du code dans `data.table` ! Le coefficient a toujours le signe attendu (les meilleurs lanceurs ont tendance à avoir plus de victoires et moins de tours autorisés), mais l'amplitude peut varier substantiellement en fonction de ce qui est contrôlé par ailleurs. La première façon d'impacter ce que représente `.SD` c'est de limiter les *colonnes* contenues dans `.SD` en utilisant l'argument `.SDcols` dans `[` : Le but est d'ajouter une colonne `team_performance` à la table `Pitching` qui enregistre les performances de l'équipe (rang) du meilleur lanceur de chaque équipe (tel que mesuré par le ERA le plus faible, parmi les lanceurs ayant au moins 6 jeux enregistrés). L'utilisation la plus simple de `.SD` est pour le sous-ensemble de colonnes (i.e., quand `.SDcols` est spécifié) ; comme cette version est beaucoup plus simple à comprendre, nous allons la couvrir en premier ci-dessous. L'interprétation de `.SD` dans sa seconde utilisation, les scénarios de regroupement (i.e., quand `by = ` ou `keyby = ` est spécifié), est légèrement différente, conceptuellement (bien qu'au fond ce soit la même chose, puisque, après tout, une opération non regroupée est un cas limite de regroupement avec un seul groupe). La syntaxe pour convertir ces colonnes en `factor` est simple : Cet exemple est certes un peu artificiel, mais il illustre l'idée ; voir ici ([1](https://stackoverflow.com/questions/31329939/conditional-keyed-join-update-and-update-a-flag-column-for-matches), [2](https://stackoverflow.com/questions/29658627/conditional-binary-join-and-update-by-reference-using-the-data-table-package)) pour plus d'informations. C'est très bien en général, mais ce n'est pas suffisant lorsque nous souhaitons effectuer une "jointure conditionnelle", dans laquelle la nature exacte de la relation entre les tables dépend de certaines caractéristiques des lignes dans une ou plusieurs colonnes. Ceci ne sert que d'illustration et était très ennuyeux. En plus d'accepter un vecteur de caractères `.SDcols` accepte également : C'est utile pour diverses initialisations, les plus communes sont présentées ici : Cette simple utilisation permet une large variété d'opérations avantageuses ou équivalentes de manipulation des données : Cette vignette explique les manières habituelles d'utiliser la variable `.SD` dans vos analyses de `data.table` . C'est une adaptation ce [cette réponse](https://stackoverflow.com/a/47406952/3576984) donnée sur StackOverflow. Pour rendre cela un peu plus concret, plutôt que de modifier les données, chargeons quelques ensembles de données concernant le baseball à partir de la [base de données Lahman](https://github.com/cdalzell/Lahman). Dans R typiquement, nous aurions simplement chargé ces ensembles de données du package R `Lahman`; dans cette vignette, nous les avons préchargés à la place, directement à partir de la page GitHub du package. Pour illustrer ce que l'on entend par nature réflexive de `.SD`, considérons son utilisation la plus banale : Modifier les spécifications du modèle est une fonctionnalité de base en analyse statistique robuste. Essayons de prédire l'ERA d'un lanceur (Earned Runs Average, moyenne des tournois gagnés, une mesure de performance) en utilisant le petit ensemble des covariables disponible dans la table `Pitching`. Comment varie la relation (linéaire) entre `W` (wins) et `ERA` en fonction des autres covariables que l'on inclut dans la spécification ? Remarquons que les colonnes suivantes sont rangées en tant que `character` dans l'ensemble de données `Teams`, mais qu'elles pourraient avantageusement être rangées comme `factor` : C'est quoi `.SD` ? Tandis qu'il existe une grande hétérogénéité, la concentration autour de la valeur générale observée reste très distincte. `.SD` sur des données non groupées La syntaxe de `data.table` est belle par sa simplicité et sa robustesse. La syntaxe `x[i]` gère de manière souple trois approches communes du sous-groupement -- si `i` est un vecteur `booléen`, `x[i]` renvoie les lignes de `x` qui correspondent aux indices où `i` vaut `TRUE`; si `i` est une *autre `data.table`* (ou une `list`), une `jointure droite` (join right)  est réalisée (dans la forme à plat, en utilisant les `clés` de `x` et `i`, sinon, si `on = ` est spécifié, en utilisant les colonnes qui correspondent); et si `i` est un caratère, il est interprété comme raccourci pour `x[list(i)]`, c'est à dire comme une jointure. title: "Utiliser .SD pour l’analyse de données"
date: "`r Sys.Date()`"
output:
  markdown::html_format:
    options:
      toc: true
      number_sections: true
    meta:
      css: [default, ../css/toc.css]
vignette: >
  %\VignetteIndexEntry{Utiliser .SD pour l’analyse de données}
  %\VignetteEngine{knitr::knitr}
  \usepackage[utf8]{inputenc}
 