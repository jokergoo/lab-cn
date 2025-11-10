---
title: "Visualize CPAN modules with Hilbert curve"
date: 2023-01-09
author: Zuguang Gu
---



There is a nice visualization of CPAN (Perl) modules with the Hilbert curve on http://mapofcpan.org/. In this post, I will
demonstrate how to make the plot with the **HilbertCurve** package.


We first read the list of CPAN modules. The information is in the `02packages.details.txt` file which
can be directly accessed with the following link:


``` r
df = read.table(url("https://www.cpan.org/modules/02packages.details.txt"), skip = 9)
head(df)
```

```
##                     V1    V2                                            V3
## 1            A1z::Html  0.04              C/CE/CEEJAY/A1z-Html-0.04.tar.gz
## 2 A1z::HTML5::Template  0.22    C/CE/CEEJAY/A1z-HTML5-Template-0.22.tar.gz
## 3      A_Third_Package undef           C/CL/CLEMBURG/Test-Unit-0.13.tar.gz
## 4            AAA::Demo undef      J/JW/JWACH/Apache-FastForward-1.1.tar.gz
## 5            AAA::eBay undef      J/JW/JWACH/Apache-FastForward-1.1.tar.gz
## 6                 AAAA undef P/PR/PRBRENAN/Data-Table-Text-20210818.tar.gz
```

The modules are listed in the first column. We also sort it alphabetically.


``` r
all_modules = sort(df[, 1])
```

We take the "namespace" of the module which is the string before the first "::":


``` r
ns = gsub("::.*$", "", all_modules)
```

Next we will put every value in `ns` in a Hilbert curve. First let's convert it into an `Rle` object:


``` r
library(IRanges)
r = Rle(ns)
```

Now in `r`, each element corresponds to an unique namespace in `ns`, and the length or the width of the namespace in `ns` is also calculated. Let's get these values:


``` r
s = start(r)          # start position of each ns in r
e = end(r)            # end position of each ns in r
w = width(r)          # width of each ns in r
labels = runValue(r)  # corresponding labels
```

Now we can visualize it via the **HilbertCurve** package. We wil highlight the top 30 namespaces with the largest number of modules.


``` r
library(HilbertCurve)

ind = order(w, decreasing = TRUE)[1:30]
w_cutoff = w[ ind[30] ]

set.seed(123)  # because we have randomm colors
hc = HilbertCurve(0, length(all_modules), level = 8, mode = "pixel")
hc_layer(hc, x1 = s, x2 = e, 
	col = circlize::rand_color(nrun(r), transparency = ifelse(w >= w_cutoff, 0, 0.8)))
hc_text(hc, x1 = s[ind], x2 = e[ind], labels = labels[ind], 
	gp = gpar(fontsize = 9))
```

<img src="/lab-cn/post/2023-01-09-visualize-cpan-modules-with-hilbert-curve_files/figure-html/unnamed-chunk-7-1.png" width="768" style="display: block; margin: auto;" />


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
## locale:
## [1] C.UTF-8/UTF-8/C.UTF-8/C/C.UTF-8/C.UTF-8
## 
## time zone: Europe/Berlin
## tzcode source: internal
## 
## attached base packages:
## [1] grid      stats4    stats     graphics  grDevices utils     datasets 
## [8] methods   base     
## 
## other attached packages:
## [1] HilbertCurve_2.0.0  IRanges_2.40.1      S4Vectors_0.44.0   
## [4] BiocGenerics_0.52.0 knitr_1.50          colorout_1.3-2     
## 
## loaded via a namespace (and not attached):
##  [1] httr_1.4.7              cli_3.6.4               rlang_1.1.5            
##  [4] xfun_0.51               png_0.1-8               circlize_0.4.16        
##  [7] UCSC.utils_1.2.0        jsonlite_1.9.0          colorspace_2.1-1       
## [10] htmltools_0.5.8.1       GlobalOptions_0.1.2     sass_0.4.9             
## [13] rmarkdown_2.29          evaluate_1.0.3          jquerylib_0.1.4        
## [16] fastmap_1.2.0           GenomeInfoDb_1.42.3     yaml_2.3.10            
## [19] lifecycle_1.0.4         bookdown_0.44           compiler_4.4.2         
## [22] Rcpp_1.0.14             XVector_0.46.0          blogdown_1.19          
## [25] digest_0.6.37           R6_2.6.1                shape_1.4.6.1          
## [28] polylabelr_0.3.0        GenomeInfoDbData_1.2.13 GenomicRanges_1.58.0   
## [31] bslib_0.9.0             tools_4.4.2             zlibbioc_1.52.0        
## [34] cachem_1.1.0
```
