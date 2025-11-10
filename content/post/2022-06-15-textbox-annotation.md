---
title: "Textbox annotation"
date: 2022-06-15
author: Zuguang Gu
---



In [a previous post "Word cloud as heatmap
annotation"](https://jokergoo.github.io/2020/05/31/word-cloud-as-heatmap-annotation/),
I introduced how to make word clouds and attach them to heatmaps as
annotations. Here I will introduce a more general solution for making
textboxes.

The following new functions are implemented in **ComplexHeatmap** from version
2.13.1. Now you need to update **ComplexHeatmap** from GitHub.

First I will demonstrate a low-level `grid.*` family function
`grid.textbox()`. The function simply accepts a vector of texts. If the `col`
parameter is not specified in `gpar()`, random colors are used.



``` r
library(ComplexHeatmap)
set.seed(888)
words = sapply(1:30, function(x) strrep(sample(letters, 1), sample(3:10, 1)))
grid.newpage()
grid.textbox(words, gp = gpar(fontsize = runif(30, min = 5, max = 30)))
```

<img src="/lab-cn/post/2022-06-15-textbox-annotation_files/figure-html/unnamed-chunk-2-1.png" width="432" style="display: block; margin: auto;" />

`max_width` controls the maximal width of the textbox.


``` r
grid.newpage()
grid.textbox(words, gp = gpar(col = "red", fontsize = 1:30+5), max_width = unit(9, "in"))
```

<img src="/lab-cn/post/2022-06-15-textbox-annotation_files/figure-html/unnamed-chunk-3-1.png" width="960" style="display: block; margin: auto;" />

Set `round_corners` to `TRUE`, also set background graphics parameters:


``` r
grid.newpage()
grid.textbox(words, gp = gpar(fontsize = runif(30, min = 5, max = 30)),
    background_gp = gpar(fill = "#FFEEEE", lty = 2, col = "grey"), round_corners = TRUE,
    padding = unit(c(10, 20, 10, 20), "pt"))
```

<img src="/lab-cn/post/2022-06-15-textbox-annotation_files/figure-html/unnamed-chunk-4-1.png" width="480" style="display: block; margin: auto;" />

One feature of `grid.textbox()` is it can properly handle long phrases or sentences which are composed
by multiple words. By default, long phrases are treated as single words, which means, if there is no
enough space in a line, the whole phrase is moved to the next line.


``` r
sentenses = c("This is sentense 1", "This is a long long long long long long long sentense.")
grid.newpage()
grid.textbox(sentenses)
```

<img src="/lab-cn/post/2022-06-15-textbox-annotation_files/figure-html/unnamed-chunk-5-1.png" width="672" style="display: block; margin: auto;" />

Set `word_wrap = TRUE` so that long phrases are wrapped if they are too long:


``` r
grid.newpage()
grid.textbox(sentenses, word_wrap = TRUE)
```

<img src="/lab-cn/post/2022-06-15-textbox-annotation_files/figure-html/unnamed-chunk-6-1.png" width="672" style="display: block; margin: auto;" />

If `add_new_line` is set to `TRUE`, each phrase is put in a separated line.



``` r
grid.newpage()
grid.textbox(sentenses, word_wrap = TRUE, add_new_line = TRUE)
```

<img src="/lab-cn/post/2022-06-15-textbox-annotation_files/figure-html/unnamed-chunk-7-1.png" width="672" style="display: block; margin: auto;" />


Now we can implement the corresponding annotation function for heatmaps. In **ComplexHeatmap**,
there is a new annotation function `anno_textbox()`. The two major arguments for `anno_textbox()` are:

- `align_to`: It controls how the text boxes are aligned to the heatmap rows.
     The value can be a categorical vector which have the same length as
     heatmap rows, or a list of row indices. It does not necessarily include
     all row indices. 
- `text`: The corresponding texts. The value should be a
     list of texts. To control graphics parameters of texts in the boxes, The
     value of `text` can also be set as a list of data frames where the
     first column contains the text, from the second column contains graphics
     parameters for each text. The column names should be "col", "fontsize",
     "fontfamily" and "fontface".



``` r
library(circlize)
mat = matrix(rnorm(100*10), nrow = 100)

split = sample(letters[1:10], 100, replace = TRUE)
text = lapply(unique(split), function(x) {
    data.frame(month.name, col = rand_color(12, friendly = TRUE), fontsize = runif(12, 6, 14))
})
names(text) = unique(split)

split
```

```
##   [1] "b" "f" "h" "h" "c" "g" "a" "h" "d" "e" "g" "c" "j" "c" "c" "j" "a" "d"
##  [19] "i" "h" "a" "i" "g" "a" "b" "e" "i" "a" "c" "h" "j" "j" "b" "c" "c" "e"
##  [37] "j" "a" "d" "d" "j" "h" "j" "d" "b" "h" "e" "h" "b" "j" "a" "a" "a" "c"
##  [55] "g" "d" "b" "a" "a" "g" "b" "g" "h" "j" "g" "f" "i" "j" "a" "d" "i" "b"
##  [73] "c" "b" "f" "e" "h" "c" "a" "c" "a" "j" "h" "e" "e" "a" "j" "h" "a" "d"
##  [91] "e" "f" "j" "j" "c" "j" "f" "d" "b" "i"
```

``` r
text[1:2]
```

```
## $b
##    month.name       col  fontsize
## 1     January #0E0768FF  9.891577
## 2    February #0C8B21FF  7.416968
## 3       March #2C038DFF 12.242896
## 4       April #2AA00CFF 10.454699
## 5         May #74A80DFF  9.777079
## 6        June #4C089AFF  9.825270
## 7        July #4C008FFF  6.179774
## 8      August #0B7C04FF  7.696559
## 9   September #3A810BFF 10.993755
## 10    October #360078FF  8.168969
## 11   November #980228FF  9.337481
## 12   December #960C3DFF 10.450466
## 
## $f
##    month.name       col  fontsize
## 1     January #6E0B9BFF  6.639206
## 2    February #042F7DFF 12.770203
## 3       March #099801FF  9.718325
## 4       April #490E90FF  8.623842
## 5         May #092C79FF 12.441386
## 6        June #0A1274FF  9.944144
## 7        July #051B65FF 13.958028
## 8      August #0A0161FF  6.600719
## 9   September #05833AFF  9.839931
## 10    October #4D7704FF 10.190130
## 11   November #5B098FFF  6.375925
## 12   December #007974FF 10.547464
```

``` r
Heatmap(mat, cluster_rows = FALSE, row_split = split,
    right_annotation = rowAnnotation(wc = anno_textbox(split, text))
)
```

<img src="/lab-cn/post/2022-06-15-textbox-annotation_files/figure-html/unnamed-chunk-8-1.png" width="672" style="display: block; margin: auto;" />


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
## [1] grid      stats     graphics  grDevices utils     datasets  methods  
## [8] base     
## 
## other attached packages:
## [1] circlize_0.4.16       ComplexHeatmap_2.25.2 knitr_1.50           
## [4] colorout_1.3-2       
## 
## loaded via a namespace (and not attached):
##  [1] jsonlite_1.9.0      compiler_4.4.2      rjson_0.2.23       
##  [4] crayon_1.5.3        Rcpp_1.0.14         magick_2.8.5       
##  [7] parallel_4.4.2      cluster_2.1.6       jquerylib_0.1.4    
## [10] IRanges_2.40.1      png_0.1-8           yaml_2.3.10        
## [13] fastmap_1.2.0       R6_2.6.1            shape_1.4.6.1      
## [16] Cairo_1.6-2         BiocGenerics_0.52.0 iterators_1.0.14   
## [19] GetoptLong_1.0.5    bookdown_0.44       bslib_0.9.0        
## [22] RColorBrewer_1.1-3  rlang_1.1.5         cachem_1.1.0       
## [25] xfun_0.51           sass_0.4.9          GlobalOptions_0.1.2
## [28] doParallel_1.0.17   cli_3.6.4           magrittr_2.0.3     
## [31] digest_0.6.37       foreach_1.5.2       clue_0.3-66        
## [34] lifecycle_1.0.4     S4Vectors_0.44.0    evaluate_1.0.3     
## [37] blogdown_1.19       codetools_0.2-20    stats4_4.4.2       
## [40] colorspace_2.1-1    rmarkdown_2.29      matrixStats_1.5.0  
## [43] tools_4.4.2         htmltools_0.5.8.1
```
