---
title: "Simplified simplifyEnrichment plot"
date: 2023-10-02
author: Zuguang Gu
---



The `lt` object contains a list of GO enrichment tables. 




``` r
names(lt)
```

```
## [1] "BP_km1" "BP_km2" "BP_km3" "BP_km4"
```

``` r
head(lt[[1]][, 1:7])
```

```
##                    ID                         Description GeneRatio   BgRatio RichFactor
## GO:0006974 GO:0006974                 DNA damage response    84/471 924/18986 0.09090909
## GO:0006281 GO:0006281                          DNA repair    65/471 625/18986 0.10400000
## GO:1903047 GO:1903047          mitotic cell cycle process    71/471 784/18986 0.09056122
## GO:0000278 GO:0000278                  mitotic cell cycle    76/471 929/18986 0.08180840
## GO:0051052 GO:0051052 regulation of DNA metabolic process    52/471 505/18986 0.10297030
## GO:0051276 GO:0051276             chromosome organization    58/471 644/18986 0.09006211
##            FoldEnrichment   zScore
## GO:0006974       3.664544 13.24432
## GO:0006281       4.192238 12.94318
## GO:1903047       3.650521 12.08881
## GO:0000278       3.297695 11.45332
## GO:0051052       4.150730 11.44585
## GO:0051276       3.630402 10.83167
```

We first demonstrate the new plot on the single enrichment table. To use the **simplifyEnrichment** package,
we extract significant GO terms, and then call `simplifyGO()`.


``` r
library(simplifyEnrichment)
df = lt[[1]]
go_id = df$ID[df$p.adjust < 0.01]
simplifyGO(go_id)
```

<img src="/lab-cn/post/2023-10-02-simplified-simplify-enrichment-plot_files/figure-html/unnamed-chunk-4-1.png" width="806.4" style="display: block; margin: auto;" />

The plot looks good, but it still contains too many graphic contents. For example, the GO similarity heatmap
is useful, but it takes too much space on the final plot. Here I developed a new function `summarizeGO()` which
simplifies the enrichment results even more. The idea is that since we already have the GO clusters, with a certain
statistic of enrichment, we can simply use its average for the GO cluster.

In the following example, we use `-log10(p.adjust)` as an enrichment measure. The heights of bars correspond to
the mean of `-log10(p.adjust)` of GO terms in different GO clusters. On the left side, we still use the word clouds which
efficiently show the general functions in each GO cluster.


``` r
l = df$p.adjust < 0.01
summarizeGO(df$ID[l], -log10(df$p.adjust)[l], axis_label = "average -log10(p.adjust)")
```

<img src="/lab-cn/post/2023-10-02-simplified-simplify-enrichment-plot_files/figure-html/unnamed-chunk-5-1.png" width="691.2" style="display: block; margin: auto;" />

GO IDs can be attached to the numeric value vector, but this time, the `value` argument
should be explicitely specified when calling `summarizeGO()`.


``` r
v = -log10(df$p.adjust)
names(v) = df$ID
summarizeGO(value = v[l], axis_label = "average -log10(p.adjust)")
```


Beside `-log10(p.adjust)`, we also suggest to use log2 fold enrichment as the enrichment measure. It is calculated as

$$ \log_2 \left( \frac{k/m_1}{m_2/n} \right) $$

where `\(k\)` is the number of DE genes (if the genes of interest are DE genes) in
a gene set, `\(m_1\)` is the size of DE genes, `\(m_2\)` is the size of the gene set,
`\(n\)` is the total number of genes in the universal set. Of course, the definition
of `\(m_1\)` and `\(m_2\)` can be switched.


``` r
k = as.numeric(gsub("/\\d+$", "", df$GeneRatio))
m1 = as.numeric(gsub("^\\d+/", "", df$GeneRatio))
m2 = as.numeric(gsub("/\\d+$", "", df$BgRatio))
n = as.numeric(gsub("^\\d+/", "", df$BgRatio))
log2_fold_enrichment = log2(k*n/m1/m2)

summarizeGO(df$ID[l], log2_fold_enrichment[l], axis_label = "average log2(fold_enrichment)")
```

<img src="/lab-cn/post/2023-10-02-simplified-simplify-enrichment-plot_files/figure-html/unnamed-chunk-7-1.png" width="691.2" style="display: block; margin: auto;" />

Of course, you can construct a named `log2_fold_enrichment` vector which only contains significant GO terms.


``` r
names(log2_fold_enrichment) = df$ID
summarizeGO(value = log2_fold_enrichment[l], axis_label = "average log2(fold_enrichment)")
```

For multiple GO enrichment results, `simplifyGOFromMultipleLists()` can be used to visualize and compare GO clusters.


``` r
simplifyGOFromMultipleLists(lt, padj_cutoff = 0.001)
```

<img src="/lab-cn/post/2023-10-02-simplified-simplify-enrichment-plot_files/figure-html/unnamed-chunk-9-1.png" width="100%" style="display: block; margin: auto;" />

`summarizeGO()` can also be used to simplify such plot. Now the value of `value` is a list of numeric named vectors which contains
significant GO terms in each enrichment table:


``` r
value = lapply(lt, function(df) {
    v = -log10(df$p.adjust)
    names(v) = df$ID
    v[df$p.adjust < 0.001]
})
summarizeGO(value = value, axis_label = "average -log10(p.adjust)", legend_title = "-log10(p.adjust)")
```

<img src="/lab-cn/post/2023-10-02-simplified-simplify-enrichment-plot_files/figure-html/unnamed-chunk-10-1.png" width="691.2" style="display: block; margin: auto;" />



``` r
sessionInfo()
```

```
## R version 4.4.2 (2024-10-31)
## Platform: aarch64-apple-darwin20
## Running under: macOS 26.0.1
## 
## Matrix products: default
## BLAS:   /Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/lib/libRblas.0.dylib 
## LAPACK: /Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.0
## 
## Random number generation:
##  RNG:     L'Ecuyer-CMRG 
##  Normal:  Inversion 
##  Sample:  Rejection 
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
##  [1] simplifyEnrichment_2.0.0 hu6800.db_3.13.0         org.Hs.eg.db_3.20.0     
##  [4] AnnotationDbi_1.68.0     IRanges_2.40.1           S4Vectors_0.44.0        
##  [7] Biobase_2.66.0           BiocGenerics_0.52.0      cola_2.12.0             
## [10] knitr_1.50               colorout_1.3-2          
## 
## loaded via a namespace (and not attached):
##   [1] eulerr_7.0.2            RColorBrewer_1.1-3      jsonlite_1.9.0         
##   [4] shape_1.4.6.1           magrittr_2.0.3          magick_2.8.5           
##   [7] modeltools_0.2-24       ggtangle_0.0.6          farver_2.1.2           
##  [10] rmarkdown_2.29          GlobalOptions_0.1.2     fs_1.6.5               
##  [13] zlibbioc_1.52.0         vctrs_0.6.5             Cairo_1.6-2            
##  [16] memoise_2.0.1           ggtree_3.14.0           blogdown_1.19          
##  [19] htmltools_0.5.8.1       gridGraphics_0.5-1      sass_0.4.9             
##  [22] bslib_0.9.0             plyr_1.8.9              impute_1.80.0          
##  [25] cachem_1.1.0            commonmark_1.9.2        igraph_2.1.4           
##  [28] mime_0.12               lifecycle_1.0.4         iterators_1.0.14       
##  [31] pkgconfig_2.0.3         gson_0.1.0              Matrix_1.7-1           
##  [34] R6_2.6.1                fastmap_1.2.0           shiny_1.10.0           
##  [37] GenomeInfoDbData_1.2.13 MatrixGenerics_1.18.1   clue_0.3-66            
##  [40] digest_0.6.37           aplot_0.2.4             enrichplot_1.26.6      
##  [43] colorspace_2.1-1        patchwork_1.3.0         irlba_2.3.5.1          
##  [46] RSQLite_2.3.9           httr_1.4.7              compiler_4.4.2         
##  [49] microbenchmark_1.5.0    rngtools_1.5.2          bit64_4.6.0-1          
##  [52] doParallel_1.0.17       brew_1.0-10             BiocParallel_1.40.0    
##  [55] DBI_1.2.3               R.utils_2.13.0          scatterplot3d_0.3-44   
##  [58] rjson_0.2.23            tools_4.4.2             ape_5.8-1              
##  [61] skmeans_0.2-18          flexclust_1.5.0         httpuv_1.6.15          
##  [64] R.oo_1.27.0             glue_1.8.0              promises_1.3.2         
##  [67] nlme_3.1-166            GOSemSim_2.32.0         gridtext_0.1.5         
##  [70] grid_4.4.2              cluster_2.1.6           reshape2_1.4.4         
##  [73] fgsea_1.32.2            generics_0.1.3          gtable_0.3.6           
##  [76] class_7.3-22            R.methodsS3_1.8.2       tidyr_1.3.1            
##  [79] data.table_1.17.0       xml2_1.3.6              XVector_0.46.0         
##  [82] ggrepel_0.9.6           foreach_1.5.2           pillar_1.10.1          
##  [85] markdown_1.13           stringr_1.5.1           yulab.utils_0.2.0      
##  [88] later_1.4.1             genefilter_1.88.0       circlize_0.4.16        
##  [91] splines_4.4.2           dplyr_1.1.4             treeio_1.30.0          
##  [94] lattice_0.22-6          survival_3.7-0          bit_4.5.0.1            
##  [97] annotate_1.84.0         tidyselect_1.2.1        GO.db_3.20.0           
## [100] ComplexHeatmap_2.25.2   tm_0.7-16               Biostrings_2.74.1      
## [103] NLP_0.3-2               bookdown_0.44           xfun_0.51              
## [106] matrixStats_1.5.0       stringi_1.8.4           UCSC.utils_1.2.0       
## [109] lazyeval_0.2.2          ggfun_0.1.8             yaml_2.3.10            
## [112] evaluate_1.0.3          codetools_0.2-20        tibble_3.2.1           
## [115] qvalue_2.38.0           Polychrome_1.5.1        ggplotify_0.1.2        
## [118] cli_3.6.4               xtable_1.8-4            munsell_0.5.1          
## [121] jquerylib_0.1.4         Rcpp_1.0.14             GenomeInfoDb_1.42.3    
## [124] png_0.1-8               XML_3.99-0.18           parallel_4.4.2         
## [127] simona_1.7.1            ggplot2_3.5.2           blob_1.2.4             
## [130] clusterProfiler_4.14.6  mclust_6.1.1            doRNG_1.8.6.1          
## [133] DOSE_4.0.1              slam_0.1-55             tidytree_0.4.6         
## [136] scales_1.3.0            purrr_1.0.4             crayon_1.5.3           
## [139] GetoptLong_1.0.5        rlang_1.1.5             cowplot_1.1.3          
## [142] fastmatch_1.1-6         KEGGREST_1.46.0
```

