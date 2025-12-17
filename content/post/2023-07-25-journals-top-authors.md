---
title: "学术期刊 top 作者"
slug: "journals-top-authors"
date: 2023-07-25
author: 顾祖光
---



NCBI 提供的 [E-utilities](https://www.ncbi.nlm.nih.gov/books/NBK25501/) API 可以很方便的从 NCBI 的数据库中提取信息。对于其 PubMed 数据库，
**pubmedR** 封装了 E-utilities API（内部基于底层 **rentrez** 包），用户可以更为直接的从 PubMed 数据库提取相应的数据。

本文将展示如何获取来自某一学术期刊的所有论文，通过分析作者，获取在此学术期刊上发表论文最高的作者。

批量从 PubMed 上获取数据需要提供 NCBI 的 API key。可以免费获得，具体步骤为：登录 NCBI -> Account Settings -> API Key Management。


```r
library(pubmedR)
api_key = 
```



对 PubMed 数据库进行查询时，我们需要提供格式化的查询字串，详见 https://pubmed.ncbi.nlm.nih.gov/help/#using-search-field-tags 。如果不知道如何编写查询字串，可先在网页版上输入查询内容，PubMed 的搜索功能会自动将其格式化成标准查询字串，然后再
按照自己的需求略加修改即可。

注意通过 NCBI
API 最多一次只能获取一万条记录，如果超过一万条，需要分次获取。在下面的例子中，我们将所有2014年至2025年 Bioinformatics 期刊上的所有论文分两次获取。

期刊的标准名字可以在 https://ftp.ncbi.nlm.nih.gov/pubmed/J_Medline.txt 查询获得。


``` r
query = '("Bioinformatics (Oxford, England)"[Journal]) AND (("1998"[Date - Publication] : "2014"[Date - Publication]))'
res = pmQueryTotalCount(query = query, api_key = api_key)
D1 = pmApiRequest(query = query, limit = res$total_count, api_key = NULL)

query = '("Bioinformatics (Oxford, England)"[Journal]) AND (("2015"[Date - Publication] : "2025"[Date - Publication]))'
res = pmQueryTotalCount(query = query, api_key = api_key)
D2 = pmApiRequest(query = query, limit = res$total_count, api_key = NULL)

D1 = pmApi2df(D1)
D2 = pmApi2df(D2)
df = rbind(D1, D2)

df = df[df$DT == "JOURNAL ARTICLE", ]
```

现在所有的论文信息均存储在`df`数据框中，其中作者列表在`AF`列中。

以第一作者最高发文量前十名：


``` r
first_authors = gsub(";.*$", "", df$AF)
first_authors = first_authors[first_authors != ""]
sort(table(first_authors), decreasing = TRUE)[1:10]
```

```
## first_authors
##             LI, HENG   FOGG, CHRISTIANA N             CHEN, LI DEOROWICZ, SEBASTIAN 
##                   21                   17                   12                   11 
## SAVOJARDO, CASTRENSE             LIU, BIN          GU, ZUGUANG      HÄKKINEN, ANTTI 
##                   10                    9                    8                    8 
##             LI, YANG            CHEN, WEI 
##                    8                    7
```

以最后作者最高发文量前十名：


``` r
last_authors = gsub("^.*;", "", df$AF)
last_authors = last_authors[last_authors != ""]
sort(table(last_authors), decreasing = TRUE)[1:10]
```

```
## last_authors
##       WANG, JIANXIN  DEANE, CHARLOTTE M            GAO, XIN       BALDI, PIERRE      CHENG, JIANLIN 
##                  41                  30                  28                  27                  25 
## DOUGHERTY, EDWARD R       ASAI, KIYOSHI     BAR-JOSEPH, ZIV RAPHAEL, BENJAMIN J         ZHANG, YANG 
##                  25                  24                  24                  24                  24
```

我们可以让代码变得略微聪明一点，我们可以将总记录按年逐份提取，可以编写如下函数 `top_authors()`.


``` r
library(GetoptLong)

cache = new.env()
cache$data = list()

top_authors = function(journal, year_start = 2000, remove_single_author = FALSE) {

    year_end = as.integer(gsub("-.*$", "", as.character(Sys.Date())))

    df = NULL
    for(y in seq(year_start, year_end)) {
        query = qq('("@{journal}"[Journal]) AND (("@{y}/01/01"[Date - Publication] : "@{y}/12/31"[Date - Publication]))')
        cat(query, "\n")
        res = pmQueryTotalCount(query = query, api_key = api_key)
        if(res$total_count > 1) {

            if(!is.null(cache$data[[qq("@{journal}/@{y}")]])) {
                cat("  read from cache\n")
                m1 = cache$data[[qq("@{journal}/@{y}")]]
            } else {

                if(res$total_count > 8000) {
                    query = qq('("@{journal}"[Journal]) AND (("@{y}/01/01"[Date - Publication] : "@{y}/06/30"[Date - Publication]))')
                    cat("  ", query, "\n")
                    res = pmQueryTotalCount(query = query, api_key = api_key)
                    D1 = pmApiRequest(query = query, limit = res$total_count, api_key = api_key)
                    m1 = pmApi2df(D1)
                    
                    query = qq('("@{journal}"[Journal]) AND (("@{y}/07/01"[Date - Publication] : "@{y}/12/31"[Date - Publication]))')
                    cat("  ", query, "\n")
                    res = pmQueryTotalCount(query = query, api_key = api_key)
                    D1 = pmApiRequest(query = query, limit = res$total_count, api_key = api_key)
                    m1 = rbind(m1, pmApi2df(D1))

                } else {
                    D1 = pmApiRequest(query = query, limit = res$total_count, api_key = api_key)
                    m1 = pmApi2df(D1)
                }

                cache$data[[qq("@{journal}/@{y}")]] = m1
            }

            df = rbind(df, m1)
        }
    }

    df = df[df$DT == "JOURNAL ARTICLE", ]

    author_list = df$AF
    author_list = strsplit(author_list, ";")
    author_list = lapply(author_list, function(x) x[!grepl("^\\d*$", x)])
    author_list = author_list[sapply(author_list, length) > 0]

    # 某些期刊会有editor's letter，在pubmed中也算journal article
    # 一般来说，这种文章只有一个作者
    if(remove_single_author) {
        author_list = author_list[sapply(author_list, length) > 1]
    }

    authors = sapply(author_list, function(x) x[1])
    cat("top 10 first authors:\n")
    print(as.data.frame(sort(table(authors), decreasing = TRUE)[1:10]))

    # last author
    authors = sapply(author_list, function(x) x[length(x)])
    cat("top 10 last authors:\n")
    print(as.data.frame(sort(table(authors), decreasing = TRUE)[1:10]))

    # all authors
    authors = unlist(author_list)
    cat("top 10 all authors:\n")
    print(as.data.frame(sort(table(authors), decreasing = TRUE)[1:10]))

    return(invisible(df))
}
```

我们来试验一下近十年的：


```r
top_authors("BMC bioinformatics", year_start = 2015)
```


```
## top 10 first authors:
```

```
##               authors Freq
## 1           DENG, LEI    7
## 2        PENG, JIAJIE    6
## 3  FIANNACA, ANTONINO    5
## 4        TAGUCHI, Y-H    5
## 5      ZHANG, JUNPENG    5
## 6     ADHIKARI, BADRI    4
## 7   BONNICI, VINCENZO    4
## 8       CHEN, YAO-MEI    4
## 9      EZAWA, KIYOSHI    4
## 10      FAN, YONGXIAN    4
```

```
## top 10 last authors:
```

```
##                  authors Freq
## 1         CHENG, JIANLIN   15
## 2          SHANG, XUEQUN   13
## 3           WANG, YADONG   12
## 4  PAPPALARDO, FRANCESCO   11
## 5         ROST, BURKHARD   10
## 6             LI, JINYAN    9
## 7              WANG, LEI    9
## 8        ZHENG, CHUN-HOU    9
## 9        BOUTROS, PAUL C    7
## 10        KAHVECI, TAMER    7
```

```
## top 10 all authors:
```

```
##                  authors Freq
## 1              WANG, LEI   20
## 2           WANG, YADONG   20
## 3             WANG, JIAN   17
## 4          WANG, JIANXIN   16
## 5         CHENG, JIANLIN   15
## 6          LIU, JIN-XING   15
## 7           LIN, HONGFEI   14
## 8  PAPPALARDO, FRANCESCO   14
## 9          SHANG, XUEQUN   14
## 10             DENG, LEI   13
```


```r
top_authors("Genome biology", year_start = 2015)
```


```
## top 10 first authors:
```

```
##                   authors Freq
## 1       MARINOV, GEORGI K    4
## 2              ARAN, DVIR    3
## 3       DAVIDSON, NADIA M    3
## 4          HUANG, YUANHUA    3
## 5   LIPINSKA, AGNIESZKA P    3
## 6     MCCARTNEY, DANIEL L    3
## 7           MURAT, PIERRE    3
## 8           RUBIN, ALAN F    3
## 9           SONG, QINGXIN    3
## 10 TESCHENDORFF, ANDREW E    3
```

```
## top 10 last authors:
```

```
##                     authors Freq
## 1            STEGLE, OLIVER    9
## 2           YUAN, GUO-CHENG    9
## 3  BALASUBRAMANIAN, SHANKAR    8
## 4              ERNST, JASON    8
## 5            GERSTEIN, MARK    8
## 6        ALKURAYA, FOWZAN S    7
## 7             LANGMEAD, BEN    7
## 8        LI, JINGYI JESSICA    7
## 9          ROBINSON, MARK D    7
## 10   SCHLÖTTERER, CHRISTIAN    7
```

```
## top 10 all authors:
```

```
##                 authors Freq
## 1               LI, WEI   16
## 2        STEGLE, OLIVER   16
## 3       MARIONI, JOHN C   15
## 4            REIK, WOLF   13
## 5             HE, CHUAN   12
## 6    LI, JINGYI JESSICA   12
## 7  MASON, CHRISTOPHER E   12
## 8           SHI, LEMING   12
## 9             CHEN, WEI   11
## 10         FLICEK, PAUL   11
```

```r
top_authors("Nature communications", year_start = 2015)
```


```
## top 10 first authors:
```

```
##       authors Freq
## 1   LIU, YANG   25
## 2  YANG, YANG   25
## 3    LIU, WEI   23
## 4   WANG, WEI   22
## 5  ZHANG, LEI   22
## 6     LI, XIN   20
## 7    LI, YANG   19
## 8  LIU, CHANG   19
## 9  ZHANG, TAO   19
## 10   WANG, YU   18
```

```
## top 10 last authors:
```

```
##              authors Freq
## 1         HUANG, WEI   42
## 2    TANG, BEN ZHONG   40
## 3    WANG, ZHONG LIN   38
## 4  SARGENT, EDWARD H   35
## 5   STEFANSSON, KARI   33
## 6          CHEN, WEI   31
## 7         YANG, YANG   29
## 8          CHEN, JUN   28
## 9          WANG, LEI   28
## 10     NUREKI, OSAMU   27
```

```
## top 10 all authors:
```

```
##               authors Freq
## 1  TANIGUCHI, TAKASHI  249
## 2     WATANABE, KENJI  249
## 3             LI, WEI  222
## 4           LIU, YANG  218
## 5           WANG, WEI  199
## 6          ZHANG, WEI  189
## 7          WANG, JING  175
## 8           WANG, LEI  175
## 9          YANG, YANG  168
## 10          CHEN, WEI  165
```


```r
top_authors("Nature", year_start = 2015, remove_single_author = TRUE)
```


```
## top 10 first authors:
```

```
##                authors Freq
## 1            LIU, YANG   11
## 2            AHMADI, M    8
## 3           DONG, XIAO    6
## 4             WANG, LI    6
## 5     COORENS, TIM H H    5
## 6    EVARISTO, JAIVIME    5
## 7            LIU, PENG    5
## 8        ROGELJ, JOERI    5
## 9  ABBOSH, CHRISTOPHER    4
## 10    BLUVSTEIN, DOLEV    4
```

```
## top 10 last authors:
```

```
##                 authors Freq
## 1          BAKER, DAVID   36
## 2  MACMILLAN, DAVID W C   16
## 3       DUAN, XIANGFENG   15
## 4         PAN, JIAN-WEI   15
## 5     SARGENT, EDWARD H   15
## 6          GOUAUX, ERIC   14
## 7      LUKIN, MIKHAIL D   14
## 8         BARAN, PHIL S   13
## 9       CRAMER, PATRICK   13
## 10      DIXIT, VISHVA M   13
```

```
## top 10 all authors:
```

```
##               authors Freq
## 1     WATANABE, KENJI  132
## 2  TANIGUCHI, TAKASHI  130
## 3        BAKER, DAVID   51
## 4           LIU, YANG   44
## 5         REGEV, AVIV   41
## 6   CAMPBELL, PETER J   39
## 7           WANG, WEI   35
## 8     CHANG, HOWARD Y   30
## 9           ZHANG, YU   30
## 10          REN, BING   29
```


```r
top_authors("Science", year_start = 2015, remove_single_author = TRUE)
```


```
## top 10 first authors:
```

```
##              authors Freq
## 1    VIGNIERI, SACHA   44
## 2      LOPEZ, BIANCA   29
## 3       SMITH, JESSE   16
## 4     SMITH, KEITH T   16
## 5      ASH, CAROLINE   13
## 6   SIMONTI, CORINNE   12
## 7  GROCHOLSKI, BRENT   11
## 8     SMITH, H JESSE   11
## 9          JIANG, DI   10
## 10      STERN, PETER    9
```

```
## top 10 last authors:
```

```
##               authors Freq
## 1        BAKER, DAVID   29
## 2      OLINGY, CLAIRE   25
## 3         ZHANG, FENG   19
## 4         SHI, YIGONG   18
## 5  DOUDNA, JENNIFER A   15
## 6       BARAN, PHIL S   14
## 7      MALO, COURTNEY   14
## 8       PAN, JIAN-WEI   14
## 9   SABATINI, DAVID M   14
## 10      ASH, CAROLINE   13
```

```
## top 10 all authors:
```

```
##              authors Freq
## 1          JIANG, DI  135
## 2    VIGNIERI, SACHA  135
## 3     LAVINE, MARC S  129
## 4      SZUROMI, PHIL  125
## 5      ASH, CAROLINE  118
## 6    FUNK, MICHAEL A  115
## 7      LOPEZ, BIANCA  104
## 8     STAJIC, JELENA  104
## 9     MAROSO, MATTIA   98
## 10 GROCHOLSKI, BRENT   97
```


```r
top_authors("Cell", year_start = 2015, remove_single_author = TRUE)
```


```
## top 10 first authors:
```

```
##                       authors Freq
## 1          GRUBAUGH, NATHAN D    6
## 2          WALLS, ALEXANDRA C    5
## 3                     WU, JUN    5
## 4                 YAN, LIMING    5
## 5                   CHEN, YUN    4
## 6  GARCIA-BELTRAN, WILFREDO F    4
## 7            HOFFMANN, MARKUS    4
## 8                  LE, TUNG T    4
## 9          LÓPEZ-OTÍN, CARLOS    4
## 10             VATANEN, TOMMI    4
```

```
## top 10 last authors:
```

```
##                          authors Freq
## 1             DIAMOND, MICHAEL S   18
## 2                      AMIT, IDO   15
## 3                  CLEVERS, HANS   12
## 4                     LUO, LIQUN   12
## 5                 COLONNA, MARCO   11
## 6               DEISSEROTH, KARL   11
## 7                 DILLIN, ANDREW   11
## 8                 GINTY, DAVID D   11
## 9  IZPISUA BELMONTE, JUAN CARLOS   11
## 10                 FUCHS, ELAINE   10
```

```
## top 10 all authors:
```

```
##               authors Freq
## 1         REGEV, AVIV   45
## 2  DIAMOND, MICHAEL S   29
## 3             LI, WEI   27
## 4           AMIT, IDO   26
## 5    DEISSEROTH, KARL   25
## 6      GYGI, STEVEN P   25
## 7    GINHOUX, FLORENT   23
## 8         ZHANG, BING   23
## 9       CLEVERS, HANS   22
## 10     COLONNA, MARCO   22
```


Session Info：


``` r
sessionInfo()
```

```
## R version 4.4.2 (2024-10-31)
## Platform: aarch64-apple-darwin20
## Running under: macOS 26.1
## 
## Matrix products: default
## BLAS:   /Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/lib/libRblas.0.dylib 
## LAPACK: /Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.0
## 
## locale:
## [1] C.UTF-8/UTF-8/C.UTF-8/C/C.UTF-8/C.UTF-8
## 
## time zone: Europe/Berlin
## tzcode source: internal
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] GetoptLong_1.0.5 pubmedR_0.0.3    knitr_1.50       colorout_1.3-2  
## 
## loaded via a namespace (and not attached):
##  [1] crayon_1.5.3        httr_1.4.7          cli_3.6.4           rlang_1.1.5        
##  [5] xfun_0.51           jsonlite_1.9.0      rjson_0.2.23        htmltools_0.5.8.1  
##  [9] GlobalOptions_0.1.4 XML_3.99-0.18       sass_0.4.9          rmarkdown_2.29     
## [13] evaluate_1.0.3      jquerylib_0.1.4     fastmap_1.2.0       yaml_2.3.10        
## [17] lifecycle_1.0.4     bookdown_0.44       compiler_4.4.2      rentrez_1.2.4      
## [21] blogdown_1.19       digest_0.6.37       R6_2.6.1            curl_6.2.1         
## [25] bslib_0.9.0         tools_4.4.2         cachem_1.1.0
```
