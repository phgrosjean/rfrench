��    v      �  �   |      �	  �   �	  5   �
  ;   �
  :   �
  ,   -  �   Z  �   �  �   z  �   >  +        4     N     f  Z     ]   �  p   8  D   �     �  ;        C  +   Z     �  M   �  @   �  [   *  �   �  g    C   �  �  �    r  b   �  �   �  �  �  ~   %  /   �  ~   �  Q   S  Y   �  �   �  ~   �  �     �   �  C   4  %  x  M  �  �   �  �   �   �   Y!  �   �!    �"  �   �#  �   ]$  �   )%     �%  U   :&  �   �&  �   G'  �   	(  O   �(  R   �(     6)  )   C)  G   m)  4  �)  +  �*  I   ,  @  `,  �   �-     �.     �.  "   �.  �  �.  �  z0  (   2  �   F2  M   '3  	   u3  �   3  �    4  �   5     �5     �5  �   �5  E   �6  �  �6  �   �8  �   99  V   �9  �   $:  �   �:     �;  �   �;  E  m<  j   �=  �   >  .   ?  $   7?     \?     j?     �?     �?  R   �?  Y  @     aA  2   A     �A  �   �A  7   bB     �B  m   �C  G   )D  H   qD  �   �D  �   VE  �   F     �F     �F  �   G  �   �G  J   eH  H   �H  D   �H  +   >I  �   jI  �   J  �   �J  �   rK  +   <L  9   hL     �L  )   �L  i   �L  z   QM  �   �M  d   `N     �N  :   �N      O  B   >O     �O  O   �O  C   �O  j   )P  �   �P  �  <Q  a   S    gS  B  xU  w   �V  �   3W  �  �W  �   �Y  >   zZ  �   �Z  j   P[  x   �[  �   4\  �   �\  �   �]  �   @^  I   _  D  W_  �  �`  �   2b  �   &c  �   �c  �   �d  :  �e  �   g  #  �g  �   �h  �   �i  j   Cj  �   �j    �k  �   �l  [   :m  W   �m     �m  *   �m  S   *n  �  ~n  R  p  R   oq  x  �q    ;s      Qt     rt  1   t  
  �t  �  �v  +   cx  �   �x  R   �y  	   �y  �   �y  e  �z  �   |     �|     }  �   }  P   �}  C  1~  �   u�  �   
�  c   ��  �   �  �   �     ڃ    ��  �  �  l   ��    �  .   "�  0   Q�     ��  #   ��     ��     ǈ  o   ߈  �  O�  )   �  4   �     D�  �   b�  :   ��  %  0�  w   V�  G   ΍  H   �  �   _�  �   ��  �   ��     ��     ��           :   S      >   r   a   d             U      [           s   K                          3      7   b   Q   o           '   m   )   V      p          f   #   k   ,          &       n   J   
      2       "   P      /   @   c   ]   E           O                 6   5   -   q   ?   <              e      1         u   `          $   +   G       M   =      Z   h   4       	   W   g   X          L   0   I       !           R   9   D   \   T   t                  (          l       j   H   %          Y   B   v       *          8   ;   ^                     _       .   A   F   C       i   N    # RHS gets automatically recycled to length of LHS
flights[, c("speed", "max_speed", "max_dep_delay", "max_arr_delay") := NULL]
head(flights)
 # check again for '24'
flights[, sort(unique(hour))]
 # get all 'hours' in flights
flights[, sort(unique(hour))]
 # subassign by reference
flights[hour == 24L, hour := 0L]
 #===== r echo = FALSE
options(width = 100L)
 #===== r eval = FALSE
DF$c <- 18:13               # (1) -- replace entire column
# or
DF$c[DF$ID == "b"] <- 15:13 # (2) -- subassign in column 'c'
 #===== r eval = FALSE
DT[, `:=`(colA = valA, # valA is assigned to colA
          colB = valB, # valB is assigned to colB
          ...
)]
 #===== r eval = FALSE
DT[, c("colA", "colB", ...) := list(valA, valB, ...)]

# when you have only one column to assign to you
# can drop the quotes and list(), for convenience
DT[, colA := valA]
 #===== r, echo = FALSE, message = FALSE
require(data.table)
knitr::opts_chunk$set(
  comment = "#",
    error = FALSE,
     tidy = FALSE,
    cache = FALSE,
 collapse = TRUE)
.old.th = setDTthreads(1)
 #===== r, echo=FALSE
setDTthreads(.old.th)
 (a) The `LHS := RHS` form (b) The functional form *shallow* vs *deep* copy -- How can we add a new column which contains for each `orig,dest` pair the maximum speed? -- How can we add columns *speed* and *total delay* of each flight to `flights` *data.table*? -- How can we add two more columns computing `max()` of `dep_delay` and `arr_delay` for each month, using `.SD`? -- How can we update multiple existing columns in place using `.SD`? -- Remove `delay` column -- Replace those rows where `hour == 24` with the value `0` 1. Reference semantics 2. Add/update/delete columns *by reference* 3. `:=` and `copy()` =====* And `ans` contains the maximum speed corresponding to each month.===== =====* And `ans` contains the maximum speed for each month.===== =====* Assigning `NULL` to a column *deletes* that column. And it happens *instantly*.===== =====* Column `hour` is replaced with `0` only on those *row indices* where the condition `hour == 24L` specified in `i` evaluates to `TRUE`.===== =====* In (a), `LHS` takes a character vector of column names and `RHS` a *list of values*. `RHS` just needs to be a `list`, irrespective of how its generated (e.g., using `lapply()`, `list()`, `mget()`, `mapply()` etc.). This form is usually easy to program with and is particularly useful when you don't know the columns to assign values to in advance.===== =====* It is used to *add/update/delete* columns by reference.===== =====* Note that since we allow assignment by reference without quoting column names when there is only one column as explained in [Section 2c](#delete-convenience), we can not do `out_cols := lapply(.SD, max)`. That would result in adding one new column named `out_col`. Instead we should do either `c(out_cols)` or simply `(out_cols)`. Wrapping the variable name with `(` is enough to differentiate between the two cases.===== =====* Note that the new column `speed` has been added to `flights` *data.table*. This is because `:=` performs operations by reference. Since `DT` (the function argument) and `flights` refer to the same object in memory, modifying `DT` also reflects on `flights`.===== =====* On the other hand, (b) is handy if you would like to jot some comments down for later.===== =====* Since `:=` is available in `j`, we can combine it with `i` and `by` operations just like the aggregation operations we saw in the previous vignette.===== =====* The `LHS := RHS` form allows us to operate on multiple columns. In the RHS, to compute the `max` on columns specified in `.SDcols`, we make use of the base function `lapply()` along with `.SD` in the same way as we have seen before in the *"Introduction to data.table"* vignette. It returns a list of two elements, containing the maximum value corresponding to `dep_delay` and `arr_delay` for each group.===== =====* The `flights` *data.table* now contains the two newly added columns. This is what we mean by *added by reference*.===== =====* The result is returned *invisibly*.===== =====* Using `copy()` function did not update `flights` *data.table* by reference. It doesn't contain the column `speed`.===== =====* We add a new column `max_speed` using the `:=` operator by reference.===== =====* We also could have used `(factor_cols)` on the `LHS` instead of `names(.SD)`.===== =====* We can also pass column numbers instead of names in the `LHS`, although it is good programming practice to use column names.===== =====* We can use `:=` for its side effect or use `copy()` to not modify the original object while updating by reference.===== =====* We can use `i` along with `:=` in `j` the very same way as we have already seen in the *"Introduction to data.table"* vignette.===== =====* We could have also provided `by` with a *character vector* as we saw in the *Introduction to data.table* vignette, e.g., `by = c("origin", "dest")`.===== =====* We did not have to assign the result back to `flights`.===== =====* We have also seen how to use `:=` along with `i` and `by` the same way as we have seen in the *Introduction to data.table* vignette. We can in the same way use `keyby`, chain operations together, and pass expressions to `by` as well all in the same way. The syntax is *consistent*.===== =====* We provide the columns to group by the same way as shown in the *Introduction to data.table* vignette. For each group, `max(speed)` is computed, which returns a single value. That value is recycled to fit the length of the group. Once again, no copies are being made at all. `flights` *data.table* is modified *in-place*.===== =====* We use the `LHS := RHS` form. We store the input column names and the new columns to add in separate variables and provide them to `.SDcols` and for `LHS` (for better readability).===== =====* We used the functional form so that we could add comments on the side to explain what the computation does. You can also see the `LHS := RHS` form (commented).===== =====* When there is just one column to delete, we can drop the `c()` and double quotes and just use the column name *unquoted*, for convenience. That is:===== =====* `:=` returns the result invisibly. Sometimes it might be necessary to see the result after the assignment. We can accomplish that by adding an empty `[]` at the end of the query as shown below:===== =====1. Contrary to the situation we have seen in the previous point, we may not want the input data.table to a function to be modified *by reference*. As an example, let's consider the task in the previous section, except we don't want to modify `flights` by reference.===== =====1. first discuss reference semantics briefly and look at the two different forms in which the `:=` operator can be used===== =====2. When we store the column names on to a variable, e.g., `DT_n = names(DT)`, and then *add/update/delete* column(s) *by reference*. It would also modify `DT_n`, unless we do `copy(names(DT))`.===== =====2. then see how we can *add/update/delete* columns *by reference* in `j` using the `:=` operator and how to combine with `i` and `by`.===== =====3. and finally we will look at using `:=` for its *side-effect* and how we can avoid the side effects using `copy()`.===== A *deep* copy on the other hand copies the entire data to another location in memory. A *shallow* copy is just a copy of the vector of column pointers (corresponding to the columns in a *data.frame* or *data.table*). The actual data is not physically copied in memory. All the operations we have seen so far in the previous vignette resulted in a new data set. We will see how to *add* new column(s), *update* or *delete* existing column(s) on the original data. Before moving on to the next section, let's clean up the newly created columns `speed`, `max_speed`, `max_dep_delay` and `max_arr_delay`. Before we look at *reference semantics*, consider the *data.frame* shown below: DF = data.frame(ID = c("b","b","b","a","a","c"), a = 1:6, b = 7:12, c = 13:18)
DF
 Data {#data} Exercise: {#update-by-reference-question} For the rest of the vignette, we will work with `flights` *data.table*. Great performance improvements were made in `R v3.1` as a result of which only a *shallow* copy is made for (1) and not *deep* copy. However, for (2) still, the entire column is *deep* copied even in `R v3.1+`. This means the more columns one subassigns to in the *same query*, the more *deep* copies R does. However we could improve this functionality further by *shallow* copying instead of *deep* copying. In fact, we would very much like to [provide this functionality for `v1.9.8`](https://github.com/Rdatatable/data.table/issues/617). We will touch up on this again in the *data.table design* vignette. If you can't figure it out, have a look at the `Note` section of `?":="`. In the previous section, we used `:=` for its side effect. But of course this may not be always desirable. Sometimes, we would like to pass a *data.table* object to a function, and might want to use the `:=` operator, but *wouldn't* want to update the original object. We can accomplish this using the function `copy()`. In the two forms of `:=` shown above, note that we don't assign the result back to a variable. Because we don't need to. The input *data.table* is modified by reference. Let's go through examples to understand what we mean by this. In this vignette, we will Introduction It can be used in `j` in two ways: Let's clean up again and convert our newly-made factor columns back into character columns. This time we will make use of `.SDcols` accepting a function to decide which columns to include. In this case, `is.factor()` will return the columns which are factors. For more on the **S**ubset of the **D**ata, there is also an [SD Usage vignette](https://cran.r-project.org/package=data.table/vignettes/datatable-sd-usage.html). Let's first delete the `speed` column we generated in the previous section.

```{r}
flights[, speed := NULL]
```
Now, we could accomplish the task as follows:

```{r}
foo <- function(DT) {
  DT <- copy(DT)                              ## deep copy
  DT[, speed := distance / (air_time/60)]     ## doesn't affect 'flights'
  DT[, .(max_speed = max(speed)), by = month]
}
ans <- foo(flights)
head(flights)
head(ans)
```
 Let's look at all the `hours` to verify. Let's say we would like to create a function that would return the *maximum speed* for each month. But at the same time, we would also like to add the column `speed` to *flights*. We could write a simple function as follows: Let's take a look at all the `hours` available in the `flights` *data.table*: Note that Note that the code above explains how `:=` can be used. They are not working examples. We will start using them on `flights` *data.table* from the next section. So far we have seen a whole lot in `j`, and how to combine it with `by` and little of `i`. Let's turn our attention back to `i` in the next vignette *"Keys and fast binary search based subset"* to perform *blazing fast subsets* by *keying data.tables*. Sometimes, it is also nice to keep track of columns that we transform. That way, even after we convert our columns we would be able to call the specific columns we were updating. Summary The `:=` operator The `copy()` function *deep* copies the input object and therefore any subsequent update by reference operations performed on the copied object will not affect the original object. There are two particular places where `copy()` function is essential: This vignette discusses *data.table*'s reference semantics which allows to *add/update/delete* columns of a *data.table by reference*, and also combine them with `i` and `by`. It is aimed at those who are already familiar with *data.table* syntax, its general form, how to subset rows in `i`, select and compute on columns, and perform aggregations by group. If you're not familiar with these concepts, please read the *"Introduction to data.table"* vignette first. We have already seen the use of `i` along with `:=` in [Section 2b](#ref-i-j). Let's now see how we can use `:=` along with `by`. We see that there are totally `25` unique values in the data. Both *0* and *24* hours seem to be present. Let's go ahead and replace *24* with *0*. We will use the same `flights` data as in the *"Introduction to data.table"* vignette. What is the difference between `flights[hour == 24L, hour := 0L]` and `flights[hour == 24L][, hour := 0L]`? Hint: The latter needs an assignment (`<-`) if you would want to use the result later. When subsetting a *data.table* using `i` (e.g., `DT[1:10]`), a *deep* copy is made. However, when `i` is not provided or equals `TRUE`, a *shallow* copy is made. When we did: With *data.table's* `:=` operator, absolutely no copies are made in *both* (1) and (2), irrespective of R version you are using. This is because `:=` operator updates *data.table* columns *in-place* (by reference). `:=` modifies the input object by reference. Apart from the features we have discussed already, sometimes we might want to use the update by reference feature for its side effect. And at other times it may not be desirable to modify the original object, in which case we can use `copy()` function, as we will see in a moment. ```{chunk_with_args}
#===== r eval = FALSE
flights[, delay := NULL]
```

is equivalent to the code above.
 ```{r}
DT = data.table(x = 1L, y = 2L)
DT_n = names(DT)
DT_n

## add a new column by reference
DT[, z := 3L]

## DT_n also gets updated
DT_n

## use `copy()`
DT_n = copy(names(DT))
DT[, w := 4L]

## DT_n doesn't get updated
DT_n
```
 ```{r}
flights[hour == 24L, hour := 0L][]
```
 a) Add columns by reference {#ref-j} a) Background a) `:=` for its side effect b) The `:=` operator b) The `copy()` function b) Update some rows of columns by reference - *sub-assign* by reference {#ref-i-j} both (1) and (2) resulted in deep copy of the entire data.frame in versions of `R` versions `< 3.1`. [It copied more than once](https://stackoverflow.com/q/23898969/559784). To improve performance by avoiding these redundant copies, *data.table* utilised the [available but unused `:=` operator in R](https://stackoverflow.com/q/7033106/559784). c) Delete column by reference d) `:=` along with grouping using `by` {#ref-j-by} e) Multiple columns and `:=` factor_cols <- sapply(flights, is.factor)
flights[, names(.SD) := lapply(.SD, as.character), .SDcols = factor_cols]
str(flights[, ..factor_cols])
 flights <- fread("flights14.csv")
flights
dim(flights)
 flights[, `:=`(speed = distance / (air_time/60), # speed in mph (mi/h)
               delay = arr_delay + dep_delay)]   # delay in minutes
head(flights)

## alternatively, using the 'LHS := RHS' form
# flights[, c("speed", "delay") := list(distance/(air_time/60), arr_delay + dep_delay)]
 flights[, c("delay") := NULL]
head(flights)

## or using the functional form
# flights[, `:=`(delay = NULL)]
 flights[, max_speed := max(speed), by = .(origin, dest)]
head(flights)
 flights[, names(.SD) := lapply(.SD, as.factor), .SDcols = is.character]
 foo <- function(DT) {
  DT[, speed := distance / (air_time/60)]
  DT[, .(max_speed = max(speed)), by = month]
}
ans = foo(flights)
head(flights)
head(ans)
 in_cols  = c("dep_delay", "arr_delay")
out_cols = c("max_dep_delay", "max_arr_delay")
flights[, c(out_cols) := lapply(.SD, max), by = month, .SDcols = in_cols]
head(flights)
 title: "Reference semantics"
date: "`r Sys.Date()`"
output:
  markdown::html_format
vignette: >
  %\VignetteIndexEntry{Reference semantics}
  %\VignetteEngine{knitr::knitr}
  \usepackage[utf8]{inputenc}
 {#delete-convenience} {.bs-callout .bs-callout-info} Project-Id-Version: 
PO-Revision-Date: 
Last-Translator: 
Language-Team: 
Language: fr
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5
 # RHS est automatiquement recyclé à la longueur de LHS
flights[, c("speed", "max_speed", "max_dep_delay", "max_arr_delay") := NULL]
head(flights)
 # vérifier à nouveau la présence de '24'
flights[, sort(unique(hour))]
 # récupère toutes les heures de flights
flights[, sort(unique(hour))]
 # sous-assignation par référence
flights[hour == 24L, hour := 0L]
 #===== r echo = FALSE
options(with = 100L)
 #===== r eval = FALSE
DF$c <- 18:13 # (1) -- remplacer toute une colonne
# ou
DF$c[DF$ID == "b"] <- 15:13 # (2) -- sous-assignation dans la colonne 'c'
 #===== r eval = FALSE
DT[, `:=`(colA = valA, # valA est assigné à colA
          colB = valB, # valB est assigné à colB
          ...
)]
 #===== r eval = FALSE
DT[, c("colA", "colB", ...) := list(valA, valB, ...)]

# lorsque vous n'avez qu'une seule colonne à assigner
# vous pouvez omettre les guillemets et `list(), pour plus de commodité
DT[, colA := valA]
 #===== r, echo = FALSE, message = FALSE
require(data.table)
knitr::opts_chunk$set(
  comment = "#",
    error = FALSE,
     tidy = FALSE,
    cache = FALSE,
 collapse = TRUE)
.old.th = setDTthreads(1)
 #===== r, echo=FALSE
setDTthreads(.old.th)
 (a) La forme `LHS := RHS` (côté gauche := côté droit) (b) La forme fonctionnelle Copie *superficielle* vs copie *profonde* -- Comment ajouter une nouvelle colonne qui contienne pour chaque paire `orig,dest` la vitesse maximale ? -- Comment ajouter les colonnes vitesse *speed* et retard total *total delay* de chaque vol à la *data.table* `flights` ? -- Comment peut-on ajouter deux colonnes supplémentaires en calculant `max()` de `dep_delay` et `arr_delay` pour chaque mois, en utilisant `.SD` ? -- Comment peut-on mettre à jour plusieurs colonnes existantes par référence en utilisant `.SD` ? -- Supprimer la colonne `delay` -- Remplacer les lignes où `hour == 24` par la valeur `0` 1. Sémantique de référence 2. Ajouter/mettre à jour/supprimer des colonnes *par référence* 3. `:=` et `copy()` =====* Et `ans` contient la vitesse maximale correspondant à chaque mois.===== =====* Et `ans` contient la vitesse maximale pour chaque mois.===== =====* Assigner `NULL` à une colonne *supprime* cette colonne. Et cela se produit *instantanément*.===== =====* La colonne `hour` est remplacée par `0` uniquement sur les *indices de ligne* où la condition `hour == 24L` spécifiée dans `i` est évaluée à `TRUE`.===== =====* Dans (a), `LHS` prend un vecteur de caractères de noms de colonnes et `RHS` une *liste de valeurs*. `RHS` doit juste être un objet `list`, indépendamment de la façon dont elle est générée (par exemple, en utilisant `lapply()`, `list()`, `mget()`, `mapply()`, etc.) Cette forme est généralement facile à programmer et est particulièrement utile lorsque vous ne connaissez pas à l'avance les colonnes auxquelles attribuer des valeurs.===== =====* Il est utilisé pour *ajouter/mettre à jour/supprimer* des colonnes par référence.===== =====* Notez que puisque nous autorisons l'assignation par référence sans mettre les noms de colonnes entre guillemets lorsqu'il n'y a qu'une seule colonne comme expliqué dans la [Section 2c](#delete-convenience), nous ne pouvons pas faire `out_cols := lapply(.SD, max)`. Cela rajouterait une nouvelle colonne nommée `out_col`. À la place, nous devrions utiliser soit `c(out_cols)`, soit simplement `(out_cols)`. Envelopper le nom de la variable dans des parenthèses `(` est suffisant pour différencier les deux cas.===== =====* Notez que la nouvelle colonne `speed` a été ajoutée à la *data.table* `flights`. C'est parce que `:=` effectue des opérations par référence. Puisque `DT` (l'argument de la fonction) et `flights` font référence au même objet en mémoire, la modification de `DT` se répercute également sur `flights`.===== =====* En revanche, le point (b) est pratique si vous souhaitez commenter votre code (voir exemple sur `flights`).===== =====* Puisque `:=` est disponible dans `j`, nous pouvons le combiner avec les opérations `i` et `by` tout comme les opérations d'agrégation que nous avons vues dans la vignette précédente.===== =====* La forme `LHS := RHS` nous permet d'opérer sur plusieurs colonnes. Dans le membre de droite (RHS), pour calculer le `max` sur les colonnes spécifiées dans `.SDcols`, nous utilisons la fonction de base `lapply()` avec `.SD` de la même manière que nous l'avons vu précédemment dans la vignette *"Introduction to data.table "*. Ceci renvoie une liste de deux éléments, contenant la valeur maximale correspondant à `dep_delay` et `arr_delay` pour chaque groupe.===== =====* La *data.table* `flights` contient maintenant les deux colonnes nouvellement ajoutées. C'est ce que nous entendons par *ajouté par référence*.===== =====* Le résultat est renvoyé de manière *invisible*.===== =====* L'utilisation de la fonction `copy()` n'a pas modifié la *data.table* `flights` par référence. Elle ne contient pas la colonne `speed`.===== =====* Nous ajoutons une nouvelle colonne `max_speed` en utilisant l'opérateur `:=` par référence.===== =====* Nous aurions également pu utiliser `(factor_cols)` sur le membre de gauche (`LHS`) au lieu de `names(.SD)`.===== =====* Nous pouvons également passer des numéros de colonnes au lieu de noms dans le membre de gauche (`LHS`), bien qu'il soit de bonne pratique de programmation d'utiliser des noms de colonnes.===== =====* Nous pouvons utiliser `:=` pour ses effets secondaires ou utiliser `copy()` pour ne pas modifier l'objet original tout en mettant à jour par référence.===== =====* Nous pouvons utiliser `i` avec `:=` dans `j` de la même manière que nous l'avons déjà vu dans la vignette *"Introduction à data.table "*.===== =====* Nous aurions également pu fournir à `by` un *vecteur de caractères* comme nous l'avons vu dans la vignette *Introduction à data.table*, par exemple en utilisant `by = c("origin", "dest")`.===== =====* Nous n'avons pas eu à réaffecter le résultat à `flights`.===== =====* Nous avons aussi vu comment utiliser `:=` avec `i` et `by` de la même manière que nous l'avons vu dans la vignette *Introduction à data.table*. Nous pouvons de la même manière utiliser `keyby`, enchaîner des opérations, et passer des expressions à `by` de la même manière. La syntaxe est *consistante*.===== =====* Nous fournissons les colonnes pour le regroupement de la même manière qu’indiqué dans la vignette *Introduction à data.table*. Pour chaque groupe, `max(speed)` est calculé, ce qui renvoie une seule valeur. Cette valeur est recyclée pour s'adapter à la longueur du groupe. Encore une fois, aucune copie n'est faite. La *data.table* `flights` est modifié directement « sur place ».===== =====* Nous utilisons la forme `LHS := RHS`. Nous stockons les noms des colonnes d'entrée et les nouvelles colonnes à ajouter dans des variables séparées, puis les fournissons à `.SDcols` et à `LHS` (pour une meilleure lisibilité).===== =====* Nous avons utilisé la forme fonctionnelle pour pouvoir ajouter des commentaires sur le côté afin d'expliquer ce que fait le calcul. Vous pouvez également voir la forme `LHS := RHS` (en commentaire).===== =====* Lorsqu'il n'y a qu'une seule colonne à supprimer, nous pouvons omettre le `c()` et les guillemets doubles et simplement utiliser le nom de la colonne *sans guillemets*, pour plus de commodité. C'est-à-dire :===== =====* `:=` renvoie le résultat de manière invisible. Parfois, il peut être nécessaire de voir le résultat après l'affectation. Nous pouvons y parvenir en ajoutant des crochets vides `[]` à la fin de la requête, comme indiqué ci-dessous :===== =====1. Contrairement à ce que nous avons vu au point précédent, nous pouvons ne pas vouloir que les données d'entrée d'une fonction soient modifiées *par référence*. A titre d'exemple, considérons la tâche de la section précédente, sauf que nous ne voulons pas modifier `flights` par référence.===== =====1. d’abord discuter brièvement les sémantiques de référence et examiner les deux formes différentes pour lesquelles l’opérateur `:=` peut être utilisé===== =====2. Lorsque nous stockons les noms de colonnes dans une variable, par exemple, `DT_n = names(DT)`, puis que nous *ajoutons/mettons à jour/supprimons* une ou plusieurs colonne(s) *par référence*, cela modifierait également `DT_n`, à moins que nous ne fassions `copy(names(DT))`.===== =====2. ensuite, voir comment ajouter/mettre à jour/supprimer des colonnes *par référence* dans `j` en utilisant l'opérateur `:=` et comment le combiner avec `i` et `by`.===== =====3. et enfin, nous examinerons l'utilisation de `:=` pour ses *effets secondaires* et comment nous pouvons éviter ces effets secondaires en utilisant `copy()`.===== Une copie *profonde*, en revanche, copie l'intégralité des données à un autre emplacement en mémoire. Une copie *superficielle* consiste uniquement en une copie du vecteur de pointeurs de colonnes (correspondant aux colonnes d'un *data.frame* ou d'un *data.table*). Les données réelles ne sont pas physiquement copiées en mémoire. Toutes les opérations que nous avons vues jusqu'à présent dans la vignette précédente ont abouti à un nouveau jeu de données. Nous allons voir comment *ajouter* de nouvelles colonnes, *mettre à jour* ou *supprimer* des colonnes existantes sur les données originales. Avant de passer à la section suivante, nettoyons les colonnes nouvellement créées `speed`, `max_speed`, `max_dep_delay` et `max_arr_delay`. Avant d'examiner la *sémantique de référence*, considérons le *data.frame* ci-dessous : DF = data.frame(ID = c("b", "b", "b", "a", "a", "c"), a = 1:6, b = 7:12, c = 13:18)
DF
 Données {#data} Exercice : {#update-by-reference-question} Pour la suite de cette vignette, nous travaillerons avec la *data.table* `flights`. D’importantes améliorations de performance ont été réalisées dans `R v3.1`, à la suite desquelles seule une copie *superficielle* est faite pour (1) et non une copie *profonde*. Cependant, pour (2), la colonne entière est encore *copiée en profondeur* même dans `R v3.1+`. Cela signifie que plus on effectue de sous-assignations de colonnes dans une *même requête*, plus R fait de *copies profondes*. Cependant, nous pourrions encore améliorer cette fonctionnalité en faisant une copie *superficielle* au lieu d'une copie *profonde*. En fait, nous aimerions beaucoup [fournir cette fonctionnalité pour `v1.9.8`](https://github.com/Rdatatable/data.table/issues/617). Nous reviendrons sur ce point dans la vignette *design de data.table*. Si vous ne parvenez pas à le comprendre, consultez la section `Note` de ` ?":="`. Dans la section précédente, nous avons utilisé `:=` pour son effet secondaire. Mais bien sûr, ce n'est pas toujours souhaitable. Parfois, nous voudrions passer un objet *data.table* à une fonction, et nous pourrions vouloir utiliser l'opérateur `:=`, mais *ne voudrions pas* mettre à jour l'objet original. Nous pouvons accomplir cela en utilisant la fonction `copy()`. Dans les deux formes de `:=` présentées ci-dessus, notez que nous n'assignons pas le résultat à une variable, parce que nous n'en avons pas besoin. La *data.table* en entrée est modifiée par référence. Prenons des exemples pour comprendre ce que nous entendons par là. Dans cette vignette, nous allons Introduction Il peut être utilisé dans `j` de deux façons : Nettoyons à nouveau et convertissons nos colonnes de facteurs nouvellement créées en colonnes de caractères. Cette fois, nous allons utiliser `.SDcols` qui accepte une fonction pour décider quelles colonnes inclure. Dans ce cas, `is.factor()` retournera les colonnes qui sont des facteurs. Pour en savoir plus sur le **S**ous-ensemble des **D**onnées (**S**ubset of the **D**ata), il y a aussi une [vignette sur l’utilisation de SD](https://cran.r-project.org/package=data.table/vignettes/datatable-sd-usage.html). Supprimons d'abord la colonne `speed` que nous avons générée dans la section précédente.

```{r}
flights[, vitesse := NULL]
```
Maintenant, nous pourrions accomplir la tâche comme suit :

```{r}
foo <- function(DT) {
  DT <- copy(DT) ## copie profonde
  DT[, speed := distance / (air_time/60)] ## n'affecte pas les vols
  DT[, .(max_speed = max(speed)), by = month]
}
ans <- foo(flights)
head(flights)
head(ans)
```
 Regardons toutes les heures pour vérifier. Supposons que nous voulions créer une fonction qui renvoie la vitesse maximale (*maximum speed*) pour chaque mois. Mais en même temps, nous aimerions aussi ajouter la colonne `speed` à *flights*. Nous pourrions écrire une petite fonction comme suit : Examinons toutes les heures (`hours`) disponibles dans la *data.table* `flights` : Notez que Notez que le code ci-dessus explique comment `:=` peut être utilisé. Ce ne sont pas des exemples pratiques. Nous en proposerons un premier avec le *data.table* `flights` dans la section suivante. Jusqu'à présent, nous avons vu beaucoup d’opérations en `j`, et comment les combiner avec `by`, mais peu de choses concernant `i`. Tournons notre attention vers `i` dans la prochaine vignette *"Clés et sous-ensembles basés sur une recherche binaire rapide"* pour réaliser des *sous-ensembles ultra-rapides* en *utilisant des clés dans data.tables*. Parfois, il est également utile de garder une trace des colonnes que nous transformons. Ainsi, même après avoir converti nos colonnes, nous pourrons toujours appeler les colonnes spécifiques que nous avons mises à jour. Résumé L'opérateur `:=` La fonction `copy()` effectue une copie *profonde* de l'objet d'entrée, et donc, toutes les opérations de mise à jour par référence effectuées sur l'objet copié n'affecteront pas l'objet d'origine. Il y a deux situations particulières où la fonction `copy()` est essentielle : Cette vignette traite de la sémantique de référence de *data.table* qui permet d'ajouter, de mettre à jour ou de supprimer des colonnes d'un *data.table par référence*, ainsi que de les combiner avec `i` et `by`. Elle s'adresse à ceux qui sont déjà familiers avec la syntaxe de *data.table*, avec sa forme générale, avec la façon de filtrer des lignes avec `i`, de sélectionner et calculer sur des colonnes, et d'effectuer des agrégations par groupe. Si vous n'êtes pas familier avec ces concepts, veuillez d'abord lire la vignette *"Introduction à data.table "*. Nous avons déjà vu l'utilisation de `i` avec `:=` dans la [Section 2b] (#ref-i-j). Voyons maintenant comment nous pouvons utiliser `:=` avec `by`. Nous constatons qu'il y a au total `25` valeurs uniques dans les données. Les heures *0* et *24* semblent toutes les deux être présentes. Remplaçons *24* par *0*. Nous utiliserons les mêmes données `flights` que dans la vignette *"Introduction à data.table"*. Quelle est la différence entre `flights[hour == 24L, hour := 0L]` et `flights[hour == 24L][, hour := 0L]` ? Indice : le dernier a besoin d'une affectation (`<-`) si vous voulez utiliser le résultat plus tard. Lorsque l'on utilise `i` (par exemple, `DT[1:10]`) pour sélectionner des lignes dans une *data.table*, une copie *profonde* est effectuée. Cependant, lorsque `i` n'est pas fourni ou est égal à `TRUE`, une copie *superficielle* est faite. Quand nous faisions : Avec l'opérateur `:=` de *data.table*, absolument aucune copie n'est effectuée dans *les deux cas* (1) et (2), quelle que soit la version de R que vous utilisez. Cela s’explique par le fait que l’opérateur `:=` met à jour les colonnes de *data.table* en place (par référence). `:=` modifie l'objet d'entrée par référence. En dehors des fonctionnalités que nous avons déjà discutées, il arrive parfois que nous souhaitions utiliser la fonctionnalité de mise à jour par référence pour ses effets secondaires. À d’autres moments, il n'est pas souhaitable de modifier l'objet original, auquel cas nous pouvons utiliser la fonction `copy()`, comme nous le verrons dans un instant. ```{chunk_with_args}
#===== r eval = FALSE
flights[, delay := NULL]
```

est équivalent au code ci-dessus.
 ```{r}
DT = data.table(x = 1L, y = 2L)
DT_n = names(DT)
DT_n

## ajouter une nouvelle colonne par référence
DT[, z := 3L]

## DT_n est également mis à jour
DT_n

## utiliser `copy()`
DT_n = copy(names(DT))
DT[, w := 4L]

## DT_n n'est pas mis à jour
DT_n
```
 ```{r}
flights[hour == 24L, hour := 0L][]
```
 a) Ajouter des colonnes par référence {#ref-j} a) Contexte a) `:=` pour ses effets secondaires b) L'opérateur `:=` b) La fonction `copy()` b) Mise à jour de certaines lignes de colonnes par référence - *sous-assignation* par référence {#ref-i-j} À la fois (1) et (2) ont tous deux entraîné une copie profonde de l'ensemble du `data.frame` dans les versions de R < 3.1. [Ces version copiaient plus d’une fois](https://stackoverflow.com/q/23898969/559784). Pour améliorer les performances en évitant ces copies redondantes, *data.table* a utilisé l'opérateur [`:=` disponible mais inutilisé dans R](https://stackoverflow.com/q/7033106/559784). c) Suppression de colonne par référence d) `:=` avec regroupement utilisant `by` {#ref-j-by} e) Colonnes multiples et `:=` factor_cols <- sapply(flights, is.factor)
flights[, names(.SD) := lapply(.SD, as.character), .SDcols = factor_cols]
str(flights[, ..factor_cols])
 flights <- fread("../flights14.csv")
flights
dim(flights)
 flights[, `:=`(speed = distance / (air_time/60), # vitesse en mph (mi/h)
               delay = arr_delay + dep_delay)]   # retard en minutes
head(flights)

## ou alors, en utilisant la forme 'LHS := RHS'
# flights[, c("speed", "delay") := list(distance/(air_time/60), arr_delay + dep_delay)]
 flights[, c("delay") := NULL]
head(flights)

## ou en utilisant la forme fonctionnelle
# flights[, `:=`(delay = NULL)]
 flights[, max_speed := max(speed), by = .(origin, dest)]
head(flights)
 flights[, names(.SD) := lapply(.SD, as.factor), .SDcols = is.character]
 foo <- function(DT) {
  DT[, speed := distance / (air_time/60)]
  DT[, .(max_speed = max(speed)), by = month]
}
ans = foo(flights)
head(flights)
head(ans)
 in_cols = c("dep_delay", "arr_delay")
out_cols = c("max_dep_delay", "max_arr_delay")
flights[, c(out_cols) := lapply(.SD, max), by = month, .SDcols = in_cols]
head(flights)
 title: "Sémantique de référence"
date: "`r Sys.Date()`"
output:
  markdown::html_format
vignette: >
  %\VignetteIndexEntry{Sémantique de référence}
  %\VignetteEngine{knitr::knitr}
  \usepackage[utf8]{inputenc}
 {#delete-convenience} {.bs-callout .bs-callout-info} 