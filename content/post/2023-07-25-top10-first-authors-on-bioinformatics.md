---
title: "Top10 first-authors on Bioinformatics"
date: 2023-07-25
author: Zuguang Gu
---



Following code obtains numbers of papers for first-authors on Bioinformatics.

```r
library(pubmedR)

api_key = NULL

# pubmed only allows downloading less than 10k records at a time,
# so I split them into two parts
query = '("Bioinformatics (Oxford, England)"[Journal]) AND (("1998"[Date - Publication] : "2014"[Date - Publication]))'
res <- pmQueryTotalCount(query = query, api_key = api_key)
D1 <- pmApiRequest(query = query, limit = res$total_count, api_key = NULL)

query = '("Bioinformatics (Oxford, England)"[Journal]) AND (("2015"[Date - Publication] : "2023"[Date - Publication]))'
res <- pmQueryTotalCount(query = query, api_key = api_key)
D2 <- pmApiRequest(query = query, limit = res$total_count, api_key = NULL)

m1 = pmApi2df(D1)
m2 = pmApi2df(D2)
m = rbind(m1, m2)

df = df[df$DT == "JOURNAL ARTICLE", ]
```

The top 10 first-authors are:

```r
fa = gsub(";.*$", "", df$AF)
sort(table(fa), decreasing = TRUE)[1:10]
```


```
## fa
##   FOGG, CHRISTIANA N             LI, HENG             CHEN, LI DEOROWICZ, SEBASTIAN 
##                   20                   19                   12                   10 
##             LIU, BIN SAVOJARDO, CASTRENSE          GU, ZUGUANG      HÄKKINEN, ANTTI 
##                    9                    9                    8                    8 
##            CHEN, WEI     HAMADA, MICHIAKI 
##                    7                    7
```
