��    $      <  5   \      0     1  ~  K  �   �  �  M  }    �  	  H  N  �   �  �  2  �     �   �  ;  �  �  �  �   Y  �   �  J   �  �     �   �  �   0  �    &  �  &        2     G  d   [  6   �  *   �     "  E   ;  >   �  t   �      5  <   V  9  �  !   �  �   �     �   �  �   �   �"    Y#  �  _&  �  (  �  �*  �   l,  �  c-  �   X2  :  3    @4  �  �5  �   �7  #  Q8  r   u9  �   �9  �   �:    L;  �  ^<  ]  �>  (   W@     �@     �@  d   �@  J    A  >   kA     �A  E   �A  >   B  �   FB  6   �B  M   C  i  _C  +   �D     "                                 !                 #                                    
                                     	      $                                              *by reference* operations =====- `use.index=FALSE` will force the query not to use indices even if they exist, but existing keys are still used for optimization.===== =====- `auto.index=FALSE` disables building index automatically when doing subset on non-indexed data, but if indices were created before this option was set, or explicitly by calling `setindex` they still will be used for optimization.===== As of now `data.table()` has an overhead, thus inside loops it is preferred to use `as.data.table()` or `setDT()` on a valid list. DT = data.table(V1=1:10, V2=1:10, V3=1:10, V4=1:10)
setindex(DT)
v = c(1L, rep(11L, 9))
length(v)^4               # cross product of elements in filter
#[1] 10000                # <= 10000
DT[V1 %in% v & V2 %in% v & V3 %in% v & V4 %in% v, verbose=TRUE]
#Optimized subsetting with index 'V1__V2__V3__V4'
#on= matches existing index, using index
#Starting bmerge ...done in 0.000sec
#...
v = c(1L, rep(11L, 10))
length(v)^4               # cross product of elements in filter
#[1] 14641                # > 10000
DT[V1 %in% v & V2 %in% v & V3 %in% v & V4 %in% v, verbose=TRUE]
#Subsetting optimization disabled because the cross-product of RHS values exceeds 1e4, causing memory problems.
#...
 DT = data.table(a=3:1, b=letters[1:3])
setindex(DT, a)

# for (...) {                 # imagine loop here

  DT[a==2L, b := "z"]         # sub-assign by reference, uses index
  DT[, d := "z"]              # not sub-assign by reference, not uses index and adds overhead of `[.data.table`
  set(DT, j="d", value="z")   # no `[.data.table` overhead, but no index yet, till #1196

# }
 For convenience `data.table` automatically builds an index on fields you use to subset data. It will add some overhead to first subset on particular fields but greatly reduces time to query those columns in subsequent runs. When measuring speed, the best way is to measure index creation and query using an index separately. Having such timings it is easy to decide what is the optimal strategy for your use case. To control usage of index use following options: I'm very wary of benchmarks measured in anything under 1 second. Much prefer 10 seconds or more for a single run, achieved by increasing data size. A repetition count of 500 is setting off alarm bells. 3-5 runs should be enough to convince on larger data. Call overhead and time to GC affect inferences at this very small scale. Ideally each `fread` call should be run in fresh session with the following commands preceding R execution. This clears OS cache file in RAM and HD cache. If your benchmark is meant to be published it will be much more insightful if you will split it to measure time of atomic processes. This way your readers can see how much time was spent on reading data from source, cleaning, actual transformation, exporting results. Of course if your benchmark is meant to present to present an *end-to-end workflow*, then it makes perfect sense to present the overall timing. Nevertheless, separating out timing of individual steps is useful for understanding which steps are the main bottlenecks of a workflow. There are other cases when atomic benchmarking might not be desirable, for example when *reading a csv*, followed by *grouping*. R requires populating *R's global string cache* which adds extra overhead when importing character data to an R session. On the other hand, the *global string cache* might speed up processes like *grouping*. In such cases when comparing R to other languages it might be useful to include total timing. Index optimization for compound filter queries will be not be used when cross product of elements provided to filter on exceeds 1e4 elements. One of the main factors that is likely to impact timings is the number of threads available to your R session. In recent versions of `data.table`, some functions are parallelized. You can control the number of threads you want to use with `setDTthreads`. Protecting your `data.table` from being updated by reference operations can be achieved using `copy` or `data.table:::shallow` functions. Be aware `copy` might be very expensive as it needs to duplicate whole object. It is unlikely we want to include duplication time in time of the actual task we are benchmarking. Repeating a benchmark many times usually does not give the clearest picture for data processing tools. Of course, it makes perfect sense for more atomic calculations, but this is not a good representation of the most common way these tools will actually be used, namely for data processing tasks, which consist of batches of sequentially provided transformations, each run once. Matt once said: This document is meant to guide on measuring performance of `data.table`. Single place to document best practices and traps to avoid. This is very valid. The smaller time measurement is the relatively bigger noise is. Noise generated by method dispatch, package/class initialization, etc. Main focus of benchmark should be on real use case scenarios. Two other options control optimization globally, including use of indices: Unless this is what you truly want to measure you should prepare input objects of the expected class for every tool you are benchmarking. Unless you are utilizing index when doing *sub-assign by reference* you should prefer `set` function which does not impose overhead of `[.data.table` method call. When benchmarking `set*` functions it only makes sense to measure the first run. These functions update their input by reference, so subsequent runs will use the already-processed `data.table`, biasing the results. When comparing `fread` to non-R solutions be aware that R requires values of character columns to be added to *R's global string cache*. This takes time when reading data but later operations benefit since the character strings have already been cached. Consequently, in addition to timing isolated tasks (such as `fread` alone), it's a good idea to benchmark the total time of an end-to-end pipeline of tasks such as reading data, manipulating it, and producing final output. `options(datatable.optimize=2L)` will turn off optimization of subsets completely, while `options(datatable.optimize=3L)` will switch it back on. Those options affect many more optimizations and thus should not be used when only control of indices is needed. Read more in `?datatable.optimize`. avoid `microbenchmark(..., times=100)` avoid class coercion fread: clear caches free -g
sudo sh -c 'echo 3 >/proc/sys/vm/drop_caches'
sudo lshw -class disk
sudo hdparm -t /dev/sda
 inside a loop prefer `setDT` instead of `data.table()` inside a loop prefer `set` instead of `:=` multithreaded processing options(datatable.auto.index=TRUE)
options(datatable.use.index=TRUE)
 options(datatable.optimize=2L)
options(datatable.optimize=3L)
 setDTthreads(0)    # use all available cores (default)
getDTthreads()     # check how many cores are currently used
 subset: index aware benchmarking subset: threshold for index optimization on compound queries title: "Benchmarking data.table"
date: "`r Sys.Date()`"
output:
  markdown::html_format:
    options:
      toc: true
      number_sections: true
    meta:
      css: [default, css/toc.css]
vignette: >
  %\VignetteIndexEntry{Benchmarking data.table}
  %\VignetteEngine{knitr::knitr}
  \usepackage[utf8]{inputenc}
 try to benchmark atomic processes Project-Id-Version: 
PO-Revision-Date: 
Last-Translator: 
Language-Team: 
Language: fr
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: Poedit 3.4.4
 opérations *par référence* =====- `use.index=FALSE` forcera la requête à ne pas utiliser les index même s'ils existent, mais les clés existantes sont toujours utilisées pour l'optimisation.===== =====- `auto.index=FALSE` désactive la construction automatique d'index lors d'un sous-ensemble sur des données non indexées, mais si les index ont été créés avant que cette option ne soit définie, ou explicitement en appelant `setindex`, ils seront toujours utilisés pour l'optimisation.===== Pour l'instant, `data.table()` a un surcoût, donc à l'intérieur des boucles, il est préférable d'utiliser `as.data.table()` ou `setDT()` sur une liste valide. DT = data.table(V1=1:10, V2=1:10, V3=1:10, V4=1:10)
setindex(DT)
v = c(1L, rep(11L, 9))
length(v)^4               # produit en croix des éléments du filtre
#[1] 10000                # <= 10000
DT[V1 %in% v & V2 %in% v & V3 %in% v & V4 %in% v, verbose=TRUE]
#Optimisation du sous-ensemble avec l'index 'V1__V2__V3__V4'
#on= correspond à l'index existant, utilise l'index
#Démarrage de bmerge ...terminé en 0.000sec
#...
v = c(1L, rep(11L, 10))
length(v)^4              # produit croisé des éléments du filtre
#[1] 14641                # > 10000
DT[V1 %in% v & V2 %in% v & V3 %in% v & V4 %in% v, verbose=TRUE]
#Optimisation de la substitution désactivée car le produit croisé des valeurs du membre droit dépasse 1e4, ce qui cause des problèmes de mémoire.
#...
 DT = data.table(a=3:1, b=lettres[1:3])
setindex(DT, a)

# for (...) {                 # imaginez une boucle ici

  DT[a==2L, b := "z"]         # sous-affectation par référence, utilise l'index
  DT[, d := "z"]              # pas de sous-affectation par référence, n'utilise pas l'index et ajoute la surcharge de `[.data.table`
  set(DT, j="d", value="z")   # pas de surcharge `[.data.table`, mais pas encore d'index, jusqu'à #1196

# }
 Pour des raisons de commodité, `data.table` construit automatiquement un index sur les champs que vous utilisez pour sous-répertorier les données. Cela ajoutera une certaine surcharge au premier sous-ensemble sur des champs particuliers, mais réduira considérablement le temps d'interrogation de ces colonnes dans les exécutions suivantes. La meilleure façon de mesurer la vitesse est de mesurer séparément la création d'un index et les requêtes utilisant un index. Avec de tels temps, il est facile de décider quelle est la stratégie optimale pour votre cas d'utilisation. Pour contrôler l'utilisation de l'index, employez les options suivantes : Je me méfie beaucoup des benchmarks qui prennent moins d'une seconde. Je préfère de loin 10 secondes ou plus pour une seule exécution, obtenues en augmentant la taille des données. Un nombre de répétitions de 500 tire la sonnette d'alarme. 3 à 5 exécutions devraient suffire à convaincre sur des données plus importantes. Le coût des appels de fonctions et le temps nécessaire au GC affectent les calculs à une si petite échelle. Idéalement, chaque appel à `fread` devrait être exécuté dans une nouvelle session avec les commandes suivantes précédant l'exécution de R. Cela permet d'effacer le fichier cache du système d'exploitation en RAM et le cache du disque dur. Si votre analyse comparative est destinée à être publiée, elle sera beaucoup plus utile si vous la divisez pour mesurer la durée des processus atomiques. De cette manière, vos lecteurs pourront voir combien de temps a été consacré à la lecture des données à partir de la source, au nettoyage, à la transformation proprement dite et à l'exportation des résultats. Bien sûr, si votre benchmark est destiné à présenter un *flux de travail de bout en bout*, il est tout à fait logique de présenter le temps global. Néanmoins, la séparation des temps des étapes individuelles est utile pour comprendre quelles étapes sont les principaux goulots d'étranglement d'un flux de travail. Il existe d'autres cas où le benchmarking atomique n'est pas souhaitable, par exemple lors de la *lecture d'un csv*, suivie d'un *regroupement*. R nécessite de remplir le *cache global de chaînes de caractères de R*, ce qui ajoute une surcharge supplémentaire lors de l'importation de données de caractères dans une session R. D'un autre côté, le *cache global de chaînes de caractères* peut accélérer des processus tels que le *regroupement*. Dans de tels cas, lorsque l'on compare R à d'autres langages, il peut être utile d'inclure le temps total. L'optimisation de l'index pour les requêtes de filtres composés ne sera pas utilisée lorsque le produit croisé des éléments fournis au filtre dépasse 1e4 éléments. L'un des principaux facteurs susceptibles d'influer les délais d’exécution est le nombre de threads disponibles dans votre session R. Dans les versions récentes de `data.table`, certaines fonctions sont parallélisées. Vous pouvez contrôler le nombre de threads que vous voulez utiliser avec `setDTthreads`. Protéger votre `data.table` d'une mise à jour par des opérations de référence peut être réalisé en utilisant les fonctions `copy` ou `data.table:::shallow`. Soyez conscient que `copy` peut être très coûteux car il doit dupliquer l'objet entier. Il est peu probable que nous voulions inclure le temps de duplication dans le temps de la tâche réelle que nous benchmarkons. Répéter un benchmark plusieurs fois ne donne généralement pas l'image la plus claire des outils de traitement des données. Bien sûr, c'est parfaitement logique pour les calculs plus atomiques, mais ce n'est pas une bonne représentation de la manière la plus courante dont ces outils seront utilisés, à savoir pour les tâches de traitement des données, qui consistent en des lots de transformations fournies de manière séquentielle, chacune exécutée une fois. Matt a dit un jour : Ce document a pour but de guider la mesure de la performance de `data.table`. Il centralise la documentation des meilleures pratiques et des pièges à éviter. Ceci est tout à fait vrai. Plus la mesure du temps est petite, plus le bruit est important, de manière relative. Le bruit est généré par le dispatching des méthodes, l'initialisation de packages/classes, etc. Le benchmark devrait se concentrer sur des scénarios d'utilisation réelle. Deux autres options permettent de contrôler l'optimisation de manière globale, y compris l'utilisation d'index : Si ce n'est pas ce que vous voulez vraiment mesurer, vous devez préparer des objets d'entrée de la classe attendue pour chaque outil que vous comparez. À moins que vous n'utilisiez l'index en faisant un *sous-affectation par référence*, vous devriez préférer la fonction `set` qui n'impose pas la surcharge de l'appel à la méthode `[.data.table`. Lors de l'évaluation des fonctions `set*`, il n'est utile de mesurer que la première exécution. Ces fonctions mettent à jour leur entrée par référence, donc les exécutions suivantes utiliseront le fichier `data.table` déjà traité, ce qui faussera les résultats. Lorsque l'on compare `fread` à des solutions non-R, il faut savoir que R exige que les valeurs des colonnes de caractères soient ajoutées au *cache global de chaînes de caractères de R*. Cela prend du temps lors de la lecture des données, mais les opérations ultérieures en bénéficient puisque les chaînes de caractères ont déjà été mises en cache. Par conséquent, en plus de chronométrer des tâches isolées (comme `fread` seul), c'est une bonne idée d'évaluer le temps total d'un pipeline de traitement de données de bout en bout contenant des tâches telles que la lecture de données, leur manipulation et la production de la sortie finale. `options(datatable.optimize=2L)` désactivera complètement l'optimisation des sous-ensembles, tandis que `options(datatable.optimize=3L)` la réactivera. Ces options affectent beaucoup plus d'optimisations et ne devraient donc pas être utilisées lorsque seul le contrôle des index est nécessaire. Plus d'informations dans `?datatable.optimize`. éviter `microbenchmark(..., times=100)` éviter la coercition de classe fread : effacer les caches free -g
sudo sh -c 'echo 3 >/proc/sys/vm/drop_caches'
sudo lshw -class disk
sudo hdparm -t /dev/sda
 à l'intérieur d'une boucle, préférez `setDT` au lieu de `data.table()` à l'intérieur d'une boucle, préférez `set` au lieu de `:=` traitement multithread options(datatable.auto.index=TRUE)
options(datatable.use.index=TRUE)
 options(datatable.optimize=2L)
options(datatable.optimize=3L)
 setDTthreads(0)    # utilise tous les cœurs disponibles (par défaut)
getDTthreads()     # vérifie combien de cœurs sont actuellement utilisés
 sous-ensemble : analyse comparative basée sur l'index sous-ensemble : seuil d'optimisation de l'index pour les requêtes composées title: "Analyse comparative (benchmark) de data.table"
date: "`r Sys.Date()`"
output:
  markdown::html_format :
    options:
      toc: true
      number_sections: true
    meta:
      css: [default, ../css/toc.css]
vignette: >
  %\VignetteIndexEntry{Analyse comparative (benchmark) de data.table}
  %\VignetteEngine{knitr::knitr}
  \usepackage[utf8]{inputenc}
 tenter d'étalonner les processus atomiques 