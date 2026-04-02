---
title: "Which heatmap function is faster?"
date: 2020-06-19
author: Zuguang Gu
---




In this post I test the performance (the running time) of four heatmap
functions: `gplots::heatmap.2()`, `heatmap()` which is natively supported in R,
`ComplexHeatmap::Heatmap()` and `pheatmap::pheatmap()`.

We generate a 1000x1000 random matrix.



```r
library(ComplexHeatmap)
library(pheatmap)
library(gplots)
library(microbenchmark)

set.seed(123)
n = 1000
mat = matrix(rnorm(n*n), nrow = n)
```

First I test drawing heatmaps as well as drawing dendrograms (with applying
clustering):


```r
t1 = microbenchmark(
	"heatmap()" = {
		pdf(NULL) 
		heatmap(mat) 
		dev.off()
	},
	"heatmap.2()" = {
		pdf(NULL) 
		heatmap.2(mat, trace = "none") 
		dev.off()
	},
	"Heatmap()" = {
		pdf(NULL)
		draw(Heatmap(mat)) 
		dev.off()
	},
	"pheatmap()" = {
		pdf(NULL) 
		pheatmap(mat)
		dev.off()
	},
	times = 5
)
print(t1, unit = "s")
```

```
## Unit: seconds
##         expr   min    lq  mean median    uq   max neval
##    heatmap() 4.669 4.795 4.889  4.976 4.986 5.018     5
##  heatmap.2() 4.793 4.848 4.939  4.889 4.946 5.220     5
##    Heatmap() 7.110 7.187 7.681  7.200 7.604 9.302     5
##   pheatmap() 4.430 4.507 5.029  4.520 4.735 6.951     5
```

The running time for all four heatmap functions looks similar, it might due to that
clustering uses most of the running time. `Heatmap()` runs the longest, perhaps
because `Heatmap()` applies additional manipulations on the dendrograms such as 
dendrogram reordering.

Next I suppress the clustering on both rows and columns and with no dendrogram.


```r
t2 = microbenchmark(
	"heatmap()" = {
		pdf(NULL)
		heatmap(mat, Rowv = NA, Colv = NA)
		dev.off()
	},
	"heatmap.2()" = {
		pdf(NULL)
		heatmap.2(mat, dendrogram = "none", trace = "none")
		dev.off()
	},
	"Heatmap()" = {
		pdf(NULL)
		draw(Heatmap(mat, cluster_rows = FALSE, cluster_columns = FALSE))
		dev.off()
	},
	"pheatmap()" = {
		pdf(NULL)
		pheatmap(mat, cluster_rows = FALSE, cluster_cols = FALSE)
		dev.off()
	},
	times = 5
)
print(t2, unit = "s")
```

```
## Unit: seconds
##         expr    min     lq   mean median     uq    max neval
##    heatmap() 0.1630 0.1651 0.2082 0.1721 0.1724 0.3682     5
##  heatmap.2() 4.4864 4.6537 4.7142 4.7375 4.8001 4.8933     5
##    Heatmap() 1.6024 1.7065 1.7220 1.7416 1.7695 1.7899     5
##   pheatmap() 0.7469 0.7725 1.2555 0.8340 0.9026 3.0214     5
```


Now `heatmap.2()` now is the slowest if only draw the heatmap bodies.

Next I perform clustering in advance and send the clustering objects to the heatmap
functions. In this setting, dendrograms are also drawn along with the heatmaps.


```r
row_hc = hclust(dist(mat))
col_hc = hclust(dist(t(mat)))
```



```r
t3 = microbenchmark(
	"heatmap()" = {
		pdf(NULL)
		heatmap(mat, Rowv = as.dendrogram(row_hc), Colv = as.dendrogram(col_hc))
		dev.off()
	},
	"heatmap.2()" = {
		pdf(NULL)
		heatmap.2(mat, Rowv = row_hc, Colv = col_hc, trace = "none")
		dev.off()
	},
	"Heatmap()" = {
		pdf(NULL)
		draw(Heatmap(mat, cluster_rows = row_hc, cluster_columns = col_hc))
		dev.off()
	},
	"pheatmap()" = {
		pdf(NULL)
		pheatmap(mat, cluster_rows = row_hc, cluster_cols = col_hc)
		dev.off()
	},
	times = 5
)
print(t3, unit = "s")
```

```
## Unit: seconds
##         expr    min     lq   mean median     uq    max neval
##    heatmap() 0.7001 0.7102 0.7606 0.7201 0.8111 0.8613     5
##  heatmap.2() 4.7948 4.8538 5.0967 5.0467 5.1858 5.6026     5
##    Heatmap() 3.0238 3.0584 3.1259 3.1312 3.2051 3.2111     5
##   pheatmap() 0.7514 0.7516 1.2943 0.7820 0.9137 3.2729     5
```


Finally I put the mean running time into a table for easy comparison:



|                                |            |              |            |             |
|:-------------------------------|:-----------|:-------------|:-----------|:------------|
|                                |`heatmap()` |`heatmap.2()` |`Heatmap()` |`pheatmap()` |
|do clustering, draw dendrograms |`4.89s`     |`4.94s`       |**`7.68s`** |`5.03s`      |
|no clusteirng, no dendrogram    |`0.21s`     |**`4.71s`**   |`1.72s`     |`1.26s`      |
|only draw dendrograms           |`0.76s`     |**`5.10s`**   |`3.13s`     |`1.29s`      |

The following plots illustrate the mean running time for the four matrices with different dimensions.






<img src="/lab-cn/post/2020-06-19-which-heatmap-function-is-faster_files/figure-html/unnamed-chunk-10-1.png" width="700px" style="display: block; margin: auto;" />

Session info:


```r
sessionInfo()
```

```
## R version 4.3.3 (2024-02-29)
## Platform: x86_64-apple-darwin20 (64-bit)
## Running under: macOS 26.3.1
## 
## Matrix products: default
## BLAS:   /Library/Frameworks/R.framework/Versions/4.3-x86_64/Resources/lib/libRblas.0.dylib 
## LAPACK: /Library/Frameworks/R.framework/Versions/4.3-x86_64/Resources/lib/libRlapack.dylib;  LAPACK version 3.11.0
## 
## locale:
## [1] zh_CN.UTF-8/zh_CN.UTF-8/zh_CN.UTF-8/C/zh_CN.UTF-8/zh_CN.UTF-8
## 
## time zone: Asia/Shanghai
## tzcode source: internal
## 
## attached base packages:
## [1] grid      stats     graphics  grDevices utils     datasets  methods  
## [8] base     
## 
## other attached packages:
## [1] cowplot_1.1.3         ggplot2_3.5.1         microbenchmark_1.5.0 
## [4] gplots_3.1.3.1        pheatmap_1.0.12       ComplexHeatmap_2.23.1
## [7] GetoptLong_1.0.5      knitr_1.45           
## 
## loaded via a namespace (and not attached):
##  [1] gtable_0.3.5        circlize_0.4.16     shape_1.4.6.1      
##  [4] rjson_0.2.21        xfun_0.43           bslib_0.7.0        
##  [7] GlobalOptions_0.1.2 caTools_1.18.2      Cairo_1.6-2        
## [10] vctrs_0.6.5         tools_4.3.3         bitops_1.0-7       
## [13] generics_0.1.3      stats4_4.3.3        parallel_4.3.3     
## [16] tibble_3.2.1        fansi_1.0.6         highr_0.10         
## [19] cluster_2.1.6       pkgconfig_2.0.3     KernSmooth_2.23-22 
## [22] RColorBrewer_1.1-3  S4Vectors_0.40.2    lifecycle_1.0.4    
## [25] compiler_4.3.3      farver_2.1.1        munsell_0.5.1      
## [28] codetools_0.2-19    clue_0.3-65         htmltools_0.5.8.1  
## [31] sass_0.4.9          yaml_2.3.8          pillar_1.9.0       
## [34] crayon_1.5.2        jquerylib_0.1.4     cachem_1.0.8       
## [37] magick_2.8.3        iterators_1.0.14    foreach_1.5.2      
## [40] gtools_3.9.5        tidyselect_1.2.1    digest_0.6.35      
## [43] dplyr_1.1.4         bookdown_0.39       labeling_0.4.3     
## [46] fastmap_1.1.1       colorspace_2.1-0    cli_3.6.2          
## [49] magrittr_2.0.3      utf8_1.2.4          withr_3.0.0        
## [52] scales_1.3.0        rmarkdown_2.26      matrixStats_1.3.0  
## [55] blogdown_1.19       png_0.1-8           evaluate_0.23      
## [58] IRanges_2.36.0      doParallel_1.0.17   rlang_1.1.3        
## [61] Rcpp_1.0.12         glue_1.7.0          BiocGenerics_0.48.1
## [64] jsonlite_1.8.8      R6_2.5.1
```
