---
title: "提速 ORA 富集分析"
slug: "Speed up over-representation enrichment analysis"
date: 2025-12-16
author: 顾祖光
---



富集分析，Over-representation analysis（ORA）是用来分析一个基因列表（例如差异基因，或者任意形式的基因列表，本文中我们以差异基因，也就是DE基因为例）是否富集在一个基因集合中的方法。我们一般使用超几何分布来计算*p*值，对应的函数是`phyper()`，参数为：

```r
phyper(x, m, n, k, lower.tail = FALSE)
```

其中

- `x`是基因集合中DE基因的个数，
- `m`是基因集合中基因的总数，
- `n`是不属于此基因集合的基因总数，
- `k`是DE基因的总数。

参数`lower.tail = FALSE`计算的是$\mathrm{Pr}(X > x)$。在计算*p*值时，我们常也包含$X = x$的情形，此时最终的*p*值应当为$\mathrm{Pr}(X \ge x)$。那么在使用`phyper()`时，我们需要将`x`调整为`x - 1`。

```r
phyper(x - 1, m, n, k, lower.tail = FALSE)
```

### 使用for/sapply循环

已知一个DE基因列表和一个基因集合，很容易能够计算出`phyper()`所需的四个参数的值。首先我们编写一个`ora_single()`函数用来计算对一个单独基因集合做富集分析的*p*值。如下代码所示，`ora_single()`需要三个参数：一个DE基因向量`genes`，一个基因集合基因向量`gene_set`和一个背景基因向量`universe`。在很多情况下，并不能保证背景基因能够完全包含DE基因或者基因集合，因此，我们需要手动去除不包含在背景基因中的基因（使用`intersect()`函数）。

在下面的例子中，我们假设所有的基因向量中的基因都具有相同类型的ID类型。


``` r
ora_single = function(genes, gene_set, universe) {
    n_universe = length(universe)

    # 将genes和gene_set都限制在universe中
    genes = intersect(genes, universe)
    gene_set = intersect(gene_set, universe)

    x = length(intersect(genes, gene_set)) # DE genes in the gene set
    m = length(gene_set)  # total genes in the gene set
    n = n_universe - m    # total genes not in the gene set
    k = length(genes)     # total DE genes

    phyper(x - 1, m, n, k, lower.tail = FALSE)
}
```

然后，对于一组基因集合，我们只需要使用`sapply()`或者`for`循环将`ora_single()`应用到每一个基因集合上。在`ora_v1()`中，我们假设基因集合的格式是一个list，其中每一个成员向量表示一个基因集合。`ora_v1()`返回一个*p*值向量。


``` r
# version 1
ora_v1 = function(genes, gene_sets, universe) {
    sapply(gene_sets, function(x) ora_single(genes, x, universe))
}
```

可见在R中编写一个支持ORA分析的函数非常简单。为了执行`ora_v1()`，我们使用GO基因集合，使用蛋白编码基因作为背景基因，从其中随机抽取1000个基因作为DE基因。


``` r
library(org.Hs.eg.db)
gs = as.list(org.Hs.egGO2ALLEGS)
gs = lapply(gs, unique)  # 基因有可能重复
library(GO.db)
gs = gs[Ontology(names(gs)) == "BP"]  # 取GO BP基因集合

pc_genes = select(org.Hs.eg.db, key = "protein-coding", 
    keytype = "GENETYPE", column = c("ENTREZID"))[, 2] # 获取所有的protein-coding基因
genes = sample(pc_genes, 1000)
```

注意在上述的例子中`pc_genes`作为背景基因，但是并不是所有`gs`中的基因均能被包含在`pc_genes`中。因为在GO注释中，也包含了非蛋白编码基因，如microRNA。


现在让我们运行`ora_v1()`：


``` r
system.time(p1 <- ora_v1(genes, gs, pc_genes))
```

```
##    user  system elapsed 
##   4.385   0.697   5.083
```

### 使用向量化的hyper()

在版本1中，我们使用循环的方式进行代码编写。在R中，我们往往推荐向量化计算。注意`phyper()`同样也支持以向量作为参数，同时计算多个*p*值。在版本2中，在运行`phyper()`之前，我们直接生成参数`x`，`m`和`n`向量。


``` r
# version 2
ora_v2 = function(genes, gene_sets, universe) {
    
    genes = intersect(genes, universe)
    gene_sets = lapply(gene_sets, function(x) intersect(x, universe))

    n_universe = length(universe)
    n_genes = length(genes)
    
    # 注意现在x, m, n, k均为向量
    x = sapply(gene_sets, function(x) length(intersect(x, genes)))
    m = sapply(gene_sets, length)
    n = n_universe - m
    k = n_genes
    
    phyper(x - 1, m, n, k, lower.tail = FALSE)
}
```

使用相同的`genes`，`gs`和`pc_genes`变量，运行`ora_v2()`。


``` r
system.time(p2 <- ora_v2(genes, gs, pc_genes))
```

```
##    user  system elapsed 
##   2.034   0.276   2.311
```

可见和`ora_v1()`相比，`ora_v2()`提速了一倍。

### 再看intersect()函数

下面我们对`ora_v2()`进行代码profiling，看看其中最耗时的是哪一部分。


``` r
Rprof()
p2 = ora_v2(genes, gs, pc_genes)
Rprof(NULL)
summaryRprof()$by.self
```

```
##                   self.time self.pct total.time total.pct
## "base::intersect"      2.16      100       2.16       100
```

可见`intersect()`是代码中最耗时的一步。


数学中，`intersect(A, B)`和`intersect(B, A)`是等价的，但是在R中，`intersect()`内部是基于哈希表，其第一个参数是输入向量，而第二个参数会被视为“字典”用来内部构建一个哈希表。
让我们做如下实验：



``` r
system.time(lapply(gs, function(x) intersect(x, pc_genes)))
```

```
##    user  system elapsed 
##   1.845   0.310   2.158
```

``` r
system.time(lapply(gs, function(x) intersect(pc_genes, x)))
```

```
##    user  system elapsed 
##   4.897   0.683   5.581
```

在上述代码的第一行中，因为`pc_genes`只需要在第一次运行`intersect()`时生成一份临时的哈希表，而在以后的运行时可以重复使用。而在第二行中，由于`intersect()`的第二个参数为`x`，在每次循环中都会发生变化，因此每次都会重新生成关于`x`的新的哈希表。

那么到这里的讨论告诉我们，如果以后我们需要对一组向量对同一个向量做intersect，永远把那个单独的向量作为`intersect()`的第二个参数。

### fastmatch包


如果你查看`intersect()`的源代码，会发现其内部使用了`match()`函数。在R中，**fastmatch**提供了一个更快的match操作，名为`fmatch()`，或者与`%in%`类似的`%fin%`。我们来把`ora_v2()`修改一下：



``` r
# version 3
library(fastmatch)
ora_v3 = function(genes, gene_sets, universe) {
    
    genes = genes[genes %fin% universe]
    gene_sets = lapply(gene_sets, function(x) x[x %fin% universe])

    n_universe = length(universe)
    n_genes = length(genes)
    
    # 注意现在x, m, n, k均为向量
    x = sapply(gene_sets, function(x) sum(x %fin% genes))
    m = sapply(gene_sets, length)
    n = n_universe - m
    k = n_genes
    
    phyper(x - 1, m, n, k, lower.tail = FALSE)
}
system.time(p3 <- ora_v3(genes, gs, pc_genes))
```

```
##    user  system elapsed 
##   0.045   0.001   0.046
```

速度得到了超大幅度的提升！

三个方法得到的*p*值是相同的。


``` r
identical(p1, p2)
```

```
## [1] TRUE
```

``` r
identical(p1, p3)
```

```
## [1] TRUE
```

### 结语

下面综合比较一下：


``` r
library(microbenchmark)
microbenchmark(
    "loop(v1)"       = ora_v1(genes, gs, pc_genes),
    "vectorized(v2)" = ora_v2(genes, gs, pc_genes),
    "fastmatch(v3)"  = ora_v3(genes, gs, pc_genes),
    times = 10
)
```

```
## Unit: milliseconds
##            expr       min        lq       mean     median         uq        max neval
##        loop(v1) 5318.1961 5383.5570 5828.39005 5880.66780 6045.01761 6804.51104    10
##  vectorized(v2) 2308.4575 2318.3023 2439.03654 2373.14585 2584.79236 2665.35383    10
##   fastmatch(v3)   40.7178   42.7744   44.96102   43.88181   45.23243   52.91075    10
```



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
## [1] stats4    stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
##  [1] microbenchmark_1.5.0 fastmatch_1.1-6      GO.db_3.20.0         org.Hs.eg.db_3.20.0 
##  [5] AnnotationDbi_1.68.0 IRanges_2.40.1       S4Vectors_0.44.0     Biobase_2.66.0      
##  [9] BiocGenerics_0.52.0  knitr_1.50           colorout_1.3-2      
## 
## loaded via a namespace (and not attached):
##  [1] bit_4.5.0.1             jsonlite_1.9.0          compiler_4.4.2          crayon_1.5.3           
##  [5] blob_1.2.4              Biostrings_2.74.1       jquerylib_0.1.4         png_0.1-8              
##  [9] yaml_2.3.10             fastmap_1.2.0           R6_2.6.1                XVector_0.46.0         
## [13] GenomeInfoDb_1.42.3     bookdown_0.44           GenomeInfoDbData_1.2.13 DBI_1.2.3              
## [17] bslib_0.9.0             rlang_1.1.5             KEGGREST_1.46.0         cachem_1.1.0           
## [21] xfun_0.51               sass_0.4.9              bit64_4.6.0-1           RSQLite_2.3.9          
## [25] memoise_2.0.1           cli_3.6.4               zlibbioc_1.52.0         digest_0.6.37          
## [29] lifecycle_1.0.4         vctrs_0.6.5             evaluate_1.0.3          blogdown_1.19          
## [33] rmarkdown_2.29          httr_1.4.7              pkgconfig_2.0.3         tools_4.4.2            
## [37] htmltools_0.5.8.1       UCSC.utils_1.2.0
```
