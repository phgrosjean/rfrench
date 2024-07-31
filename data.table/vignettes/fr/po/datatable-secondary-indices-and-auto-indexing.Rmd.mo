��    p      �  �         p	  3   q	  �   �	  2   v
  N   �
  g   �
  ;   `  �   �  [   i  W   �  E     r   c  ;   �  D     Y   W  V   �  @     g   I  "   �  F   �  N     l   j  h   �  *   @     k  <   �     �  �   �  A   �  9   �  �     R   �  e   
  �   p  �   a     �  �   �  �   �  C   x  �   �  �   ^     F     `  �   m  K   9  �   �  �     �   �  �   d  C   �  �   2  Z   �  �     �   �  =  �  u   �   �   d!  1  d"  ^   �#  S   �#  F  I$  �   �%  9  a&  �   �'  t   U(  �   �(  �   �)  }   V*  V   �*  �   ++  �   �+     M,  m   [,  =   �,  O   -     W-     l-     �-  M   �-  F   �-  �   7.  �   �.  N   �/     �/      �/  V   0     ]0  $   i0     �0  �   �0  .   .1  s   ]1     �1  =   �1  ~   )2     �2  8   �2  A    3  T   B3  C   �3  )   �3  c   4  S   i4  6   �4     �4     5  C   %5  �   i5  q   6  M   �6  �   �6  �   �7  �   �8  3   y9  �   �9  2   ~:  T   �:  m   ;  I   t;  �   �;  b   �<  \   �<  }   O=  �   �=  W   N>  [   �>  f   ?  s   i?  `   �?  t   >@  5   �@  g   �@  s   QA  �   �A  �   ^B  4   �B     C  L   3C     �C    �C  E   �D  D   �D  �   8E  _   �E  {   TF     �F  �   �G     �H  �   �H  +  �I  Q   �J  �   &K    �K      �L     M  �   %M  d   N  �   }N  �   O  �   �O  �   �P  L   lQ  �   �Q  u   oR  �   �R    �S    �T  ~   LV  1  �V  �  �W  i   �Y  h   ?Z  �  �Z  �   >\  �  =]    �^  �   �_  �   X`  �   8a  �   b  c   �b  �   $c  �   �c     ud  v   �d  B   �d  S   =e     �e  "   �e  &   �e  U   �e  ^   Lf  �   �f  �   tg  N   h     mh  .   �h  k   �h     i  5   ,i     bi  �   i  @   j  �   Sj      �j  @   k  y   Gk     �k  8   �k  A   l  T   [l  C   �l  )   �l  c   m  S   �m  6   �m     n     "n  C   :n  �   ~n  q   Wo  M   �o  �   p  �   q           +   &   H   h      b      e   O          7   2       6      <      D       *              g   F   
       !   R       ?   Z   5      )           ]   k   0      `          .   V   3   >      B   Q   ;   l   n   \   L   -   W           /   P       o   E       m   9   (   #             a   I   4       @       	   J                     ^   8                :       K   f   ,   1   S       G   c      =       Y       C       %                      M   N   p   T      X      d             i              "       U   [   '                  A      $   j   _        # Chunk args: r echo = FALSE
options(width = 100L)
 # Chunk args: r, echo = FALSE, message = FALSE
require(data.table)
knitr::opts_chunk$set(
  comment = "#",
    error = FALSE,
     tidy = FALSE,
    cache = FALSE,
 collapse = TRUE)
.old.th = setDTthreads(1)
 # Chunk args: r, echo=FALSE
setDTthreads(.old.th)
 # Chunk args: r, eval = FALSE
## not run
setkey(flights, dest)
flights["LAX"]
 # Chunk args: r, eval = FALSE
## not run
setkey(flights, origin)
flights["JFK"] # or flights[.("JFK")]
 # get all 'hours' in flights
flights[, sort(unique(hour))]
 ## have a look at all the attribute names
names(attributes(dt))

## run thefirst time
(t1 <- system.time(ans <- dt[x == 989L]))
head(ans)

## secondary index is created
names(attributes(dt))

indices(dt)
 ## successive subsets
(t2 <- system.time(dt[x == 989L]))
system.time(dt[x %in% 1989:2012])
 -- Find the maximum arrival delay corresponding to `origin = "LGA"` and `dest = "TPA"`. -- From the previous example, subset all rows only if there's a match -- Get the maximum departure delay for each `month` corresponding to `origin = "JFK"`. Order the result by `month` -- How can I subset based on `origin` *and* `dest` columns? -- How can we get all the secondary indices set so far in `flights`? -- How can we set the column `origin` as a secondary index in the *data.table* `flights`? -- On the result obtained above, use chaining to order the column in decreasing order. -- Reordering a data.table can be expensive and not always ideal -- Return `arr_delay` column alone as a data.table corresponding to `origin = "LGA"` and `dest = "TPA"` -- Secondary indices can be reused -- Subset all rows where the origin airport matches *"JFK"* using `on` -- Subset only the first matching row where `dest` matches *"BOS"* and *"DAY"* -- Subset only the last matching row where `origin` matches *"LGA", "JFK", "EWR"* and `dest` matches *"XNA"* -- The new `on` argument allows for cleaner syntax and automatic creation and reuse of secondary indices -- There can be only one `key` at the most 1. Secondary indices 2. Fast subsetting using `on` argument and secondary indices 3. Auto indexing All the operations we will discuss below are no different to the ones we already saw in the *Keys and fast binary search based subset* vignette. Except we'll be using the `on` argument instead of setting keys. Also note that the attribute `index` has been added to `flights`. And this is precisely what *secondary indices* allow for! And this reorders `flights` by `dest`, *again*. What we would really like is to be able to perform the fast subsetting by eliminating the reordering step. As we will see in the next section, the `on` argument provides several advantages: Auto indexing can be disabled by setting the global argument `options(datatable.auto.index = FALSE)`. Computing the order isn't the time consuming part, since data.table uses true radix sorting on integer, character and numeric vectors. However, reordering the data.table could be time consuming (depending on the number of rows and columns). Consider the case where you would like to perform a fast key based subset on `origin` column for the value "JFK". We'd do this as: Data {#data} Disabling auto indexing still allows to use indices created explicitly with `setindex` or `setindexv`. You can disable indices fully by setting global argument `options(datatable.use.index = FALSE)`. First we looked at how to fast subset using binary search using *keys*. Then we figured out that we could improve performance even further and have cleaner syntax by using secondary indices. For example, if we want to subset `"JFK", "LAX"` combination, then: If we had already created a secondary index, using `setindex()`, then `on` would reuse it instead of (re)computing it. We can see that by using `verbose = TRUE`: In recent version we extended auto indexing to expressions involving more than one column (combined with `&` operator). In the future, we plan to extend binary search to work with more binary operators like `<`, `<=`, `>` and `>=`. In this vignette, we will Introduction It *doesn't* physically reorder the entire data.table in RAM. Instead, it only computes the order for the set of columns provided and stores that *order vector* in an additional attribute called `index`. Let's start by creating a data.table big enough to highlight the advantage. Note that `flights` is **not** physically reordered in increasing order of `origin`, as would have been the case with `setkey()`. Note that `on` argument can also be used on keyed subsets as well. In fact, we encourage providing the `on` argument even when subsetting using keys for better readability. Note that by creating another index on the columns `origin, dest`, we do not lose the first index created on the column `origin`, i.e., we can have multiple secondary indices. Now if we would like to repeat the same operation but on `dest` column instead, for the value "LAX", then we have to `setkey()`, *again*. Now, let's check if `24` is replaced with `0` in the `hour` column. Running the first time took `r sprintf("%.3f", t1["elapsed"])` seconds where as the second time took `r sprintf("%.3f", t2["elapsed"])` seconds. Secondary indices are similar to `keys` in *data.table*, except for two major differences: Since the time to compute the secondary index is quite small, we don't have to use `setindex()`, unless, once again, the task involves repeated subsetting on the same column. Since there can be multiple secondary indices, and creating an index is as simple as storing the order vector as an attribute, this allows us to even eliminate the time to recompute the order vector if an index already exists. That is what *auto indexing* does. At the moment, it is only implemented for binary operators `==` and `%in%`. An index is automatically created *and* saved as an attribute. That is, unlike the `on` argument which computes the index on the fly each time (unless one already exists), a secondary index is created here. The function `indices()` returns all current secondary indices in the data.table. If none exists, `NULL` is returned. The other arguments including `mult` work exactly the same way as we saw in the *Keys and fast binary search based subset* vignette. The default value for `mult` is "all". We can choose, instead only the "first" or "last" matching rows should be returned. The time to subset the first time is the time to create the index + the time to subset. Since creating a secondary index involves only creating the order vector, this combined operation is faster than vector scans in many cases. But the real advantage comes in successive subsets. They are extremely fast. There are no flights connecting "JFK" and "XNA". Therefore, that row is skipped in the result. There can be more than one secondary index for a data.table (as we will see below). This is particularly a huge advantage of secondary indices. Previously, just to update a few rows of `hour`, we had to `setkey()` on it, which inevitably reorders the entire data.table. With `on`, the order is preserved, and the operation is much faster! Looking at the code, the task we wanted to perform is also quite clear. This statement performs a fast binary search based subset as well, by computing the index on the fly. However, note that it doesn't save the index as an attribute automatically. This may change in the future. This vignette assumes that the reader is familiar with data.table's `[i, j, by]` syntax, and how to perform fast key based subsets. If you're not familiar with these concepts, please read the *"Introduction to data.table"*, *"Reference semantics"* and *"Keys and fast binary search based subset"* vignettes first. Unless our task involves repeated subsetting on the same column, fast key based subsetting could effectively be nullified by the time to reorder, depending on our data.table dimensions. We can choose if queries that do not match should return `NA` or be skipped altogether using the `nomatch` argument. We have seen this example already in the *Reference semantics* and *Keys and fast binary search based subset* vignette. Let's take a look at all the `hours` available in the `flights` *data.table*: We see that there are totally `25` unique values in the data. Both *0* and *24* hours seem to be present. Let's go ahead and replace *24* with *0*, but this time using `on` instead of setting keys. We will discuss fast *subsets* using keys and secondary indices to *joins* in the next vignette, *"Joins and rolling joins"*. We will use the same `flights` data as in the *"Introduction to data.table"* vignette. We would have had to set the `key` back to `origin, dest` again, if we did not use `on` which internally builds secondary indices on the fly. When we use `==` or `%in%` on a single column for the first time, a secondary index is created automatically, and it is used to perform the subset. `on` argument `on` argument accepts a character vector of column names corresponding to the order provided to `i-argument`. `setindex(flights, NULL)` would remove all secondary indices. `setindex` and `setindexv()` allows adding a secondary index to the data.table. `setkey()` requires: a) Fast subsets in `i` a) What are secondary indices? a) computing the order vector for the column(s) provided, here, `origin`, and allows easy reuse of existing indices by just checking the attributes. allows for a cleaner syntax by having the columns on which the subset is performed as part of the syntax. This makes the code easier to follow when looking at it at a later point. and finally look at *auto indexing* which goes a step further and creates secondary indices automatically, but does so on native R syntax for subsetting. ans <- flights["JFK", max(dep_delay), keyby = month, on = "origin"]
head(ans)
 b) Select in `j` b) Set and get secondary indices b) reordering the entire data.table, by reference, based on the order vector computed. c) Chaining c) Why do we need secondary indices? d) Compute or *do* in `j` discuss *secondary indices* and provide rationale as to why we need them by citing cases where setting keys is not necessarily ideal, e) *sub-assign* by reference using `:=` in `j` enables subsetting by computing secondary indices on the fly. This eliminates having to do `setindex()` every time. f) Aggregation using `by` flights <- fread("flights14.csv")
head(flights)
dim(flights)
 flights["JFK", on = "origin"]

## alternatively
# flights[.("JFK"), on = "origin"] (or)
# flights[list("JFK"), on = "origin"]
 flights[, sort(unique(hour))]
 flights[.("JFK", "LAX"), on = c("origin", "dest")][1:5]
 flights[.("LGA", "TPA"), .(arr_delay), on = c("origin", "dest")]
 flights[.("LGA", "TPA"), .(arr_delay), on = c("origin", "dest")][order(-arr_delay)]
 flights[.("LGA", "TPA"), max(arr_delay), on = c("origin", "dest")]
 flights[.(24L), hour := 0L, on = "hour"]
 flights[.(c("LGA", "JFK", "EWR"), "XNA"), mult = "last", on = c("origin", "dest"), nomatch = NULL]
 flights[.(c("LGA", "JFK", "EWR"), "XNA"), on = c("origin", "dest"), mult = "last"]
 flights[c("BOS", "DAY"), on = "dest", mult = "first"]
 g) The *mult* argument h) The *nomatch* argument indices(flights)

setindex(flights, origin, dest)
indices(flights)
 perform fast subsetting, once again, but using the new `on` argument, which computes secondary indices internally for the task (temporarily), and reuses if one already exists, set.seed(1L)
dt = data.table(x = sample(1e5L, 1e7L, TRUE), y = runif(100L))
print(object.size(dt), units = "Mb")
 setindex(flights, origin)
flights["JFK", on = "origin", verbose = TRUE][1:5]
 setindex(flights, origin)
head(flights)

## alternatively we can provide character vectors to the function 'setindexv()'
# setindexv(flights, "origin") # useful to program with

# 'index' attribute added
names(attributes(flights))
 title: "Secondary indices and auto indexing"
date: "`r Sys.Date()`"
output:
  markdown::html_format
vignette: >
  %\VignetteIndexEntry{Secondary indices and auto indexing}
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
 # Chunk args: r echo = FALSE
options(width = 100L)
 # Chunk args: r, echo = FALSE, message = FALSE
require(data.table)
knitr::opts_chunk$set(
  comment = "#",
    error = FALSE,
     tidy = FALSE,
    cache = FALSE,
 collapse = TRUE)
.old.th = setDTthreads(1)
 # Chunk args: r, echo=FALSE
setDTthreads(.old.th)
 # Chunk args: r, eval = FALSE
## pas exécuté
setkey(flights, dest)
flights["LAX"]
 # Chunk args: r, eval = FALSE
## pas exécuté
setkey(flights, origin)
flights["JFK"] # or flights[.("JFK")]
 # récupère toutes les 'hours' de flights
flights[, sort(unique(hour))]
 ## inspection de tous les noms d’attributs
names(attributes(dt))

## première exécution
(t1 <- system.time(ans <- dt[x == 989L]))
head(ans)

## indice secondaire créé
names(attributes(dt))

indices(dt)
 ## sous-ensembles successifs
(t2 <- system.time(dt[x == 989L]))
system.time(dt[x %in% 1989:2012])
 -- Trouvez le délai d'arrivée maximal correspondant à `origin = "LGA"` et `dest = "TPA"`. -- D'après l'exemple précédent, le sous-ensemble de toutes les lignes n'est pris en compte que s'il y a une correspondance -- Obtenir le retard maximum au départ pour chaque `mois` correspondant à `origine = "JFK"`. Classer les résultats par `mois` -- Comment puis-je faire un sous-ensemble basé sur les colonnes `origin` *et* `dest` ? -- Comment obtenir tous les indices secondaires définis jusqu'à présent dans `flights` ? -- Comment définir la colonne `origin` comme index secondaire dans l’objet *data.table* `flights` ? -- Sur la base du résultat obtenu ci-dessus, utilisez le chaînage pour classer la colonne par ordre décroissant. -- La réorganisation d'une table de données peut être coûteuse et n'est pas toujours idéale -- Retourner la colonne `arr_delay` seule en tant que data.table correspondant à `origin = "LGA"` et `dest = "TPA"` -- Les indices secondaires peuvent être réutilisés -- Sous-ensemble de toutes les lignes où l'aéroport d'origine correspond à *"JFK"* en utilisant `on` -- Sous-ensemble contenant uniquement la première ligne correspondante où `dest` correspond à *"BOS"* et *"DAY"* -- Sous-ensemble contenant uniquement la dernière ligne correspondante où `origin` correspond à *"LGA", "JFK", "EWR"* et `dest` correspond à *"XNA"* -- Le nouvel argument `on` permet une syntaxe plus propre ainsi que la création et la réutilisation automatiques d'indices secondaires -- Il ne peut y avoir qu'une seule `clé` au maximum 1. Indices secondaires 2. Sous-ensemble rapide utilisant l'argument `on` et les indices secondaires 3. Indexation automatique Toutes les opérations que nous allons discuter ci-dessous ne sont pas différentes de celles que nous avons déjà vues dans la vignette *Clé et recherche binaire rapide basée sur un sous-ensemble*. Sauf que nous utiliserons l'argument `on` au lieu de définir des clés. Notez également que l'attribut `index` a été ajouté à `flights`. Et c'est précisément ce que permettent les *indices secondaires* ! Et cela réordonne les `vols` par `dest`, *encore une fois*. Ce que nous aimerions vraiment, c'est pouvoir effectuer le sous-ensemble rapidement en éliminant l'étape de réorganisation. Comme nous le verrons dans la section suivante, l'argument `on` présente plusieurs avantages : L'indexation automatique peut être désactivée en définissant l'argument global `options(datatable.auto.index = FALSE)`. Le calcul de l'ordre n'est pas la partie qui prend le plus de temps, puisque data.table utilise un vrai tri radix sur les vecteurs d'entiers, de caractères et de nombres. Cependant, réordonner le tableau data.table peut prendre du temps (en fonction du nombre de lignes et de colonnes). Considérons le cas où vous voudriez effectuer un sous-ensemble basé sur une clé rapide sur la colonne `origin` pour la valeur "JFK". Nous ferions cela comme suit : Données {#data} Désactiver l'indexation automatique permet toujours d'utiliser les indices créés explicitement avec `setindex` ou `setindexv`. Vous pouvez désactiver complètement les indices en définissant l'argument global `options(datatable.use.index = FALSE)`. Dans un premier temps, nous avons étudié comment effectuer un sous-ensemble rapide à l'aide d'une recherche binaire en utilisant des *clés*. Ensuite, nous avons découvert que nous pouvions améliorer encore les performances et avoir une syntaxe plus propre en utilisant des indices secondaires. Par exemple, si nous voulons un sous-ensemble combinant `"JFK" et "LAX"`, alors : Si nous avions déjà créé un indice secondaire en utilisant `setindex()`, alors `on` le réutiliserait au lieu de le (re)calculer. Nous pouvons le voir en utilisant `verbose = TRUE` : Dans la version récente, nous avons étendu l'indexation automatique aux expressions impliquant plus d'une colonne (combinées avec l'opérateur `&`). Dans le futur, nous prévoyons d'étendre la recherche binaire à d'autres opérateurs binaires comme `<`, `<=`, `>` et `>=`. Dans cette vignette, nous allons Introduction Il ne réorganise pas physiquement l'ensemble de la table de données en RAM. Au lieu de cela, il calcule seulement l'ordre pour l'ensemble des colonnes fournies et stocke ce *vecteur d'ordre* dans un attribut supplémentaire appelé `index`. Commençons par créer un tableau data.table suffisamment grand pour mettre en évidence l'avantage. Notez que `flights` n'est **pas** physiquement réordonné dans l'ordre croissant de `origin`, comme cela aurait été le cas avec `setkey()`. Notez que l'argument `on` peut également être utilisé pour les sous-ensembles à clés. En fait, nous encourageons à fournir l'argument `on` même lorsque le sous-ensemble utilise des clés pour une meilleure lisibilité. Notez qu'en créant un autre index sur les colonnes `origin, dest`, nous ne perdons pas le premier index créé sur la colonne `origin`, c'est-à-dire que nous pouvons avoir plusieurs index secondaires. Maintenant, si nous voulons répéter la même opération mais sur la colonne `dest` à la place, pour la valeur "LAX", alors nous devons utiliser `setkey()`, *une fois de plus*. Maintenant, vérifions si `24` est remplacé par `0` dans la colonne `hour`. L'exécution du code la première fois a nécessité `r sprintf("%.3f", t1["elapsed"])` secondes tandis que la seconde exécution a pris `r sprintf("%.3f", t2["elapsed"])` secondes. Les indices secondaires sont similaires aux `clés` dans *data.table*, à l'exception de deux différences majeures : Comme le temps de calcul de l'indice secondaire est assez faible, il n'est pas nécessaire d'utiliser `setindex()`, sauf si, une fois de plus, la tâche implique un sous-ensemble répété sur la même colonne. Comme il peut y avoir plusieurs indices secondaires et que la création d'un indice est aussi simple que le stockage du vecteur d'ordre en tant qu'attribut, cela nous permet même d'éliminer le temps nécessaire pour recalculer le vecteur d'ordre si un indice existe déjà. C'est ce que fait l'indexation automatique. Pour l'instant, il n'est implémenté que pour les opérateurs binaires `==` et `%in%`. Un indice est automatiquement créé *et* sauvegardé en tant qu'attribut. C'est-à-dire que contrairement à l'argument `on` qui calcule l'indice à la volée à chaque fois (à moins qu'il n'en existe déjà un), un indice secondaire est créé ici. La fonction `indices()` renvoie tous les indices secondaires actuels dans data.table. Si aucun n'existe, `NULL` est retourné. Les autres arguments, y compris `mult`, fonctionnent exactement de la même manière que nous l'avons vu dans la vignette *Keys and fast binary search based subset*. La valeur par défaut de `mult` est "all". Nous pouvons choisir de ne renvoyer que les "premières" ou "dernières" lignes correspondantes. Le temps nécessaire pour créer un sous-ensemble la première fois est égal au temps nécessaire pour créer l'indice + le temps nécessaire pour créer un sous-ensemble. Étant donné que la création d'un indice secondaire n'implique que la création du vecteur d'ordre, cette opération combinée est plus rapide que les balayages vectoriels dans de nombreux cas. Mais le véritable avantage réside dans les sous-ensembles successifs. Ils sont extrêmement rapides. Il n'y a pas de vols reliant "JFK" et "XNA". Par conséquent, cette ligne est ignorée dans le résultat. Il peut y avoir plus d'un indice secondaire pour une table data.table (comme nous le verrons plus loin). C'est en particulier un énorme avantage des indices secondaires. Auparavant, pour mettre à jour quelques lignes de `hour`, nous devions utiliser `setkey()` sur celui-ci, ce qui réorganisait inévitablement l'ensemble de la data.table. Avec `on`, l'ordre est préservé, et l'opération est beaucoup plus rapide ! En inspectant le code, la tâche que nous voulions effectuer est également très claire. Cette instruction effectue également une recherche binaire rapide basée sur le sous-ensemble, en calculant l'indice à la volée. Cependant, notez qu'elle n'enregistre pas automatiquement l'indice en tant qu'attribut. Cela pourrait changer à l'avenir. Cette vignette suppose que le lecteur est familier avec la syntaxe `[i, j, by]` de data.table, et sur la façon d’effectuer des sous-ensembles basés sur des clés rapides. Si vous n'êtes pas familier avec ces concepts, veuillez d'abord lire les vignettes *"Introduction à data.table"*, *"Sémantique de référence"* et *"Sous-ensembles basés sur les clés et la recherche binaire rapide"*. À moins que notre tâche n'implique un sous-ensemble répété sur la même colonne, le sous-ensemble basé sur une clé rapide pourrait effectivement être annulé par le temps nécessaire pour réorganiser, en fonction des dimensions de notre data.table. Nous pouvons choisir si les requêtes qui ne correspondent pas doivent retourner `NA` ou être ignorées en utilisant l'argument `nomatch`. Nous avons déjà vu cet exemple dans les vignettes *Sémantique des références* et *Clé et sous-ensemble basé sur la recherche binaire rapide*. Regardons toutes les `heures` disponibles dans le *data.table* `flights` : Nous constatons qu'il y a au total `25` valeurs uniques dans les données. Les heures *0* et *24* semblent être présentes. Remplaçons *24* par *0*, mais cette fois-ci en utilisant `on` au lieu de définir des clés. Nous aborderons les *sous-ensembles* rapides utilisant des clés et des indices secondaires pour les *joints* dans la prochaine vignette, *"Joints et jointures roulantes"*. Nous utiliserons les mêmes données `flights` que dans la vignette *"Introduction à data.table"*. Nous aurions dû remettre le `key` à `origin, dest`, si nous n'avions pas utilisé `on` qui construit en interne des indices secondaires à la volée. Lorsque nous utilisons `==` ou `%in%` sur une seule colonne pour la première fois, un indice secondaire est créé automatiquement, et il est utilisé pour effectuer le sous-ensemble. Argument `on` l'argument `on` accepte un vecteur de caractères de noms de colonnes correspondant à l'ordre fourni à `i-argument`. `setindex(flights, NULL)` supprimerait tous les index secondaires. `setindex` et `setindexv()` permettent d'ajouter un index secondaire à data.table. `setkey()` nécessite de : a) Sous-ensembles rapides dans `i` a) Qu'est-ce qu'un indice secondaire ? a) calculer le vecteur d'ordre pour la (les) colonne(s) fournie(s), ici, `origin`, et permet de réutiliser facilement les indices existants en vérifiant simplement les attributs. permet une syntaxe plus propre, car les colonnes sur lesquelles le sous-ensemble est effectué font partie de la syntaxe. Le code est ainsi plus facile à suivre lorsqu'on le consulte ultérieurement. et enfin, examiner l’*auto-indexation* qui va plus loin et crée des index secondaires automatiquement, mais en utilisant la syntaxe native de R pour le sous-ensemble. ans <- flights["JFK", max(dep_delay), keyby = month, on = "origin"]
head(ans)
 b) Sélection dans `j` b) Définir et obtenir des indices secondaires b) réordonner l'ensemble du tableau de données, par référence, sur la base du vecteur d'ordre calculé. c) Chaînage c) Pourquoi avons-nous besoin d'indices secondaires ? d) Calculer ou *do* dans `j` discuter des *indices secondaires* et justifier leur nécessité en citant des cas où l'établissement de clés n'est pas nécessairement idéal, e) *sous-assignation* par référence en utilisant `:=` dans `j` permet de réaliser un sous-ensemble en calculant les indices secondaires à la volée. Cela évite d'avoir à faire `setindex()` à chaque fois. f) Agrégation à l'aide de `by` flights <- fread("../flights14.csv")
head(flights)
dim(flights)
 flights["JFK", on = "origin"]

## ou alors
# flights[.("JFK"), on = "origin"] (or)
# flights[list("JFK"), on = "origin"]
 flights[, sort(unique(hour))]
 flights[.("JFK", "LAX"), on = c("origin", "dest")][1:5]
 flights[.("LGA", "TPA"), .(arr_delay), on = c("origin", "dest")]
 flights[.("LGA", "TPA"), .(arr_delay), on = c("origin", "dest")][order(-arr_delay)]
 flights[.("LGA", "TPA"), max(arr_delay), on = c("origin", "dest")]
 flights[.(24L), hour := 0L, on = "hour"]
 flights[.(c("LGA", "JFK", "EWR"), "XNA"), mult = "last", on = c("origin", "dest"), nomatch = NULL]
 flights[.(c("LGA", "JFK", "EWR"), "XNA"), on = c("origin", "dest"), mult = "last"]
 flights[c("BOS", "DAY"), on = "dest", mult = "first"]
 g) L'argument *mult* h) L'argument *nomatch* indices(flights)

setindex(flights, origin, dest)
indices(flights)
 réaliser un sous-ensemble rapide, une fois de plus, mais en utilisant le nouvel argument `on`, qui calcule des indices secondaires en interne pour la tâche (temporairement), et les réutilise s'il y en a déjà un, set.seed(1L)
dt = data.table(x = sample(1e5L, 1e7L, TRUE), y = runif(100L))
print(object.size(dt), units = "Mb")
 setindex(flights, origin)
flights["JFK", on = "origin", verbose = TRUE][1:5]
 setindex(flights, origin)
head(flights)

## nous pouvons aussi fournir des chaînes de caractères à la fonction ‘setindexv()’
# setindexv(flights, "origin") # utile en programmation

# attribut 'index' ajouté
names(attributes(flights))
 title: "Indices secondaires et auto-indexation"
date: "`r Sys.Date()`"
output:
  markdown::html_format
vignette: >
  %\VignetteIndexEntry{Indices secondaires et auto-indexation}
  %\VignetteEngine{knitr::knitr}
  \usepackage[utf8]{inputenc}
 