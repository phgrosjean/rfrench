��          �   %   �      @  ,   A  L   n  ?   �  U   �     Q  T   p  )   �     �  :   	  )   D  I   n  9   �  "   �  �        �  Z   �  4   	     >  K   ?  �   �  �   7  +   �  �   	  �   �	  �   �
  +   l  N   �  ?   �  U   '     }  Q   �  )   �       :   2  )   m  I   �  9   �  "     �   >     �  \   �  4   L     �  K   �  �   �  �   �  +   6  �   b  %                    
                                               	                                                             #===== r echo = FALSE
options(width = 100L)
 #===== r eval = FALSE
# key by origin,dest columns
flights[.("JFK", "MIA")]
 #===== r eval = FALSE
flights[origin == "JFK" & dest == "MIA"]
 #===== r eval = FALSE
setkey(flights, NULL)
flights[origin == "JFK" & dest == "MIA"]
 flights[, sort(unique(hour))]
 flights[.("JFK")]

## alternatively
# flights[J("JFK")] (or)
# flights[list("JFK")]
 flights[.("JFK", "MIA"), mult = "first"]
 flights[.("JFK", "MIA")]
 flights[.("LGA", "TPA"), .(arr_delay)][order(-arr_delay)]
 flights[.("LGA", "TPA"), max(arr_delay)]
 flights[.(c("LGA", "JFK", "EWR"), "XNA"), mult = "last", nomatch = NULL]
 flights[.(c("LGA", "JFK", "EWR"), "XNA"), mult = "last"]
 flights[.(unique(origin), "MIA")]
 key(DT)
## (1) Usual way of subsetting - vector scan approach
t1 <- system.time(ans1 <- DT[x == "g" & y == 877L])
t1
head(ans1)
dim(ans1)
 key(flights)
 key(flights)

flights[.("JFK")] ## or in this case simply flights["JFK"], for convenience
 key(flights)
flights[.("LGA", "TPA"), .(arr_delay)]
 set.seed(1L)
DF = data.frame(ID1 = sample(letters[1:2], 10, TRUE),
                ID2 = sample(1:3, 10, TRUE),
                val = sample(10),
                stringsAsFactors = FALSE,
                row.names = sample(LETTERS[1:10]))
DF

rownames(DF)
 setkey(flights, hour)
key(flights)
flights[.(24), hour := 0L]
key(flights)
 setkey(flights, origin)
head(flights)

## alternatively we can provide character vectors to the function 'setkeyv()'
# setkeyv(flights, "origin") # useful to program with
 setkey(flights, origin, dest)
head(flights)

## or alternatively
# setkeyv(flights, c("origin", "dest")) # provide a character vector of column names

key(flights)
 setkey(flights, origin, dest)
key(flights)
 setkeyv(DT, c("x", "y"))
key(DT)
## (2) Subsetting using keys
t2 <- system.time(ans2 <- DT[.("g", 877L)])
t2
head(ans2)
dim(ans2)

identical(ans1$val, ans2$val)
 title: "Keys and fast binary search based subset"
date: "`r Sys.Date()`"
output:
  markdown::html_format
vignette: >
  %\VignetteIndexEntry{Keys and fast binary search based subset}
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
 #===== r echo = FALSE
options(with = 100L)
 #===== r eval = FALSE
# clé par origin,dest columns
flights[.("JFK", "MIA")]
 #===== r eval = FALSE
flights[origin == "JFK" & dest == "MIA"]
 #===== r eval = FALSE
setkey(flights, NULL)
flights[origin == "JFK" & dest == "MIA"]
 flights[, sort(unique(hour))]
 flights[.("JFK")]

## ou alors :
# flights[J("JFK")] (ou)
# flights[list("JFK")]
 flights[.("JFK", "MIA"), mult = "first"]
 flights[.("JFK", "MIA")]
 flights[.("LGA", "TPA"), .(arr_delay)][order(-arr_delay)]
 flights[.("LGA", "TPA"), max(arr_delay)]
 flights[.(c("LGA", "JFK", "EWR"), "XNA"), mult = "last", nomatch = NULL]
 flights[.(c("LGA", "JFK", "EWR"), "XNA"), mult = "last"]
 flights[.(unique(origin), "MIA")]
 key(DT)
## (1) Méthode habituelle de sous-ensemble - approche par balayage vectoriel
t1 <- system.time(ans1 <- DT[x == "g" & y == 877L])
t1
head(ans1)
dim(ans1)
 key(flights)
 key(flights)

flights[.("JFK")] ## ou dans ce cas simplement flights["JFK"], par commodité
 key(flights)
flights[.("LGA", "TPA"), .(arr_delay)]
 set.seed(1L)
DF = data.frame(ID1 = sample(letters[1:2], 10, TRUE),
                ID2 = sample(1:3, 10, TRUE),
                val = sample(10),
                stringsAsFactors = FALSE,
                row.names = sample(LETTERS[1:10]))
DF

rownames(DF)
 setkey(flights, hour)
key(flights)
flights[.(24), hour := 0L]
key(flights)
 setkey(flights, origin)
head(flights)

## nous pouvons aussi fournir des vecteurs de caractères à la fonction 'setkeyv()'
# setkeyv(flights, "origin") # utile pour la programmation
 setkey(flights, origin, dest)
head(flights)

## ou alors :
# setkeyv(flights, c("origin", "dest")) # fournir un vecteur de caractères pour les noms de colonnes

key(flights)
 setkey(flights, origin, dest)
key(flights)
 setkeyv(DT, c("x", "y"))
key(DT)
## (2) Sous-ensemble à l'aide de clés
t2 <- system.time(ans2 <- DT[.("g", 877L)])
t2
head(ans2)
dim(ans2)

identical(ans1$val, ans2$val)
 title: "Sous-ensemble basé sur les clés et la recherche binaire rapide"
date: "`r Sys.Date()`"
output:
  markdown::html_format
vignette: >
  %\VignetteIndexEntry{Sous-ensemble basé sur les clés et la recherche binaire rapide}
  %\VignetteEngine{knitr::knitr}
  \usepackage[utf8]{inputenc}
 