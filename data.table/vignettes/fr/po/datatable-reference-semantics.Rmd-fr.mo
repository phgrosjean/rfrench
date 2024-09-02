��          �   %   �      P  5   Q  ;   �  :   �  �   �  �   �     �  �   �     6  �  �  (   Y  �   �  	   c  �   m  .   W	     �	  Y  �	  �   �
  7   �     �  m   �  G   S  H   �  �   �  �   �  �   /  �   �  J   �  H     D   Y  �   �  �   �     J  �   j  �   #  �  �  +   x  �   �  	   �    �  .   �     �  �  �  �   t  :     %  B  w   h  G   �  H   (  �   q  �     �   �        
      	                                                                                                               # check again for '24'
flights[, sort(unique(hour))]
 # get all 'hours' in flights
flights[, sort(unique(hour))]
 # subassign by reference
flights[hour == 24L, hour := 0L]
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
 -- Remove `delay` column =====2. then see how we can *add/update/delete* columns *by reference* in `j` using the `:=` operator and how to combine with `i` and `by`.===== =====3. and finally we will look at using `:=` for its *side-effect* and how we can avoid the side effects using `copy()`.===== Let's first delete the `speed` column we generated in the previous section.

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
 Let's look at all the `hours` to verify. Let's say we would like to create a function that would return the *maximum speed* for each month. But at the same time, we would also like to add the column `speed` to *flights*. We could write a simple function as follows: Note that ```{r}
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
 b) The `copy()` function both (1) and (2) resulted in deep copy of the entire data.frame in versions of `R` versions `< 3.1`. [It copied more than once](https://stackoverflow.com/q/23898969/559784). To improve performance by avoiding these redundant copies, *data.table* utilised the [available but unused `:=` operator in R](https://stackoverflow.com/q/7033106/559784). factor_cols <- sapply(flights, is.factor)
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
 Project-Id-Version: 
PO-Revision-Date: 
Last-Translator: 
Language-Team: 
Language: fr
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.5
 # vérifier à nouveau la présence de '24'
flights[, sort(unique(hour))]
 # récupère toutes les heures de flights
flights[, sort(unique(hour))]
 # sous-assignation par référence
flights[hour == 24L, hour := 0L]
 #===== r eval = FALSE
DT[, c("colA", "colB", ...) := list(valA, valB, ...)]

# lorsque vous n'avez qu'une seule colonne à assigner
# vous pouvez supprimer les guillemets et list(), pour plus de commodité
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
 -- Supprimer la colonne `delay` =====2. Ensuite, nous verrons comment ajouter/mettre à jour/supprimer des colonnes *par référence* dans `j` en utilisant l'opérateur `:=` et comment combiner avec `i` et `by`.===== =====3. Enfin, nous examinerons l'utilisation de `:=` pour ses *effets secondaires* et la façon dont nous pouvons éviter les effets secondaires en utilisant `copy()`.===== Supprimons d'abord la colonne `speed` que nous avons générée dans la section précédente.

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
 Regardons toutes les heures pour vérifier. Supposons que nous voulions créer une fonction qui renvoie la *vitesse maximale* pour chaque mois. Mais en même temps, nous aimerions aussi ajouter la colonne `vitesse` à *flights*. Nous pourrions écrire une petite fonction comme suit : Notez que ```{r}
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
 b) La fonction `copy()` (1) et (2) ont tous deux entraîné une copie profonde de l'ensemble du `data.frame` dans les versions de R < 3.1. [Il a été copié plus d'une fois](https://stackoverflow.com/q/23898969/559784). Pour améliorer les performances en évitant ces copies redondantes, *data.table* a utilisé l'opérateur [disponible mais inutilisé `:=` dans R](https://stackoverflow.com/q/7033106/559784). factor_cols <- sapply(flights, is.factor)
flights[, names(.SD) := lapply(.SD, as.character), .SDcols = factor_cols]
str(flights[, ..factor_cols])
 flights <- fread("../flights14.csv")
flights
dim(flights)
 flights[, `:=`(speed = distance / (air_time/60), # vitesse en mph (mi/h)
               delay = arr_delay + dep_delay)]   # délai en minutes
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
 