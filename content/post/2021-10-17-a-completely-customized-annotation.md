---
title: "A completely customized annotation"
date: 2021-10-17
author: Zuguang Gu
---



For most annotation functions implemented in **ComplexHeatmap**, they only draw one same type of annotation graphics, e.g. `anno_points()`
only draws points. From **ComplexHeatmap** version 2.9.4, I added a new annotation function `anno_customize()`, with which you can completely
freely define graphics for every annotation cell.

The input for `anno_customize()` should be a categorical vector.


``` r
library(ComplexHeatmap)
x = c("a", "a", "a", "b", "b", "b", "c", "c", "d", "d")
```

For each level, you need to define a graphics function for it. 


``` r
graphics = list(
    "a" = function(x, y, w, h) grid.rect(x, y, w*0.8, h*0.33, gp = gpar(fill = "red")),
    "b" = function(x, y, w, h) grid.text("A", x, y, gp = gpar(col = "darkgreen")),
    "c" = function(x, y, w, h) grid.points(x, y, gp = gpar(col = "orange"), pch = 16),
    "d" = function(x, y, w, h) {
        img = png::readPNG(system.file("extdata", "Rlogo.png", package = "circlize"))
        grid.raster(img, x, y, width = unit(0.8, "snpc"), height = unit(0.8, "snpc")*nrow(img)/ncol(img))
    }
)
```

When adding graphics, each annotation cell is an independent viewport, thus, the self-defined graphics function accepts four arguments: `x` and `y`: the center
of the viewport of the annotation cell, `w` and `h`: the width and height of the viewport. In the example above, we set a horizontal bar for `"a"`, a text for `"b"`,
a point for `"c"` and an image for `"d"`.

Then we add this new annotation to both row and column of the heatmap, just in the same way as normal annotations.


``` r
m = matrix(rnorm(100), 10)
Heatmap(m, 
    top_annotation = HeatmapAnnotation(foo = anno_customize(x, graphics = graphics)),
    right_annotation = rowAnnotation(bar = anno_customize(x, graphics = graphics)))
```

<img src="/lab-cn/post/2021-10-17-a-completely-customized-annotation_files/figure-html/unnamed-chunk-4-1.png" width="576" style="display: block; margin: auto;" />

Reordering and splitting are automatically adjusted.


``` r
Heatmap(m, 
    top_annotation = HeatmapAnnotation(foo = anno_customize(x, graphics = graphics)),
    right_annotation = rowAnnotation(bar = anno_customize(x, graphics = graphics)),
    column_split = x, row_split = x)
```

<img src="/lab-cn/post/2021-10-17-a-completely-customized-annotation_files/figure-html/unnamed-chunk-5-1.png" width="576" style="display: block; margin: auto;" />

`Legend()` function also accepts a `graphics` argument, so it is easy to add legends for the "customized annotations".


``` r
m = matrix(rnorm(100), 10)
ht = Heatmap(m, 
    top_annotation = HeatmapAnnotation(foo = anno_customize(x, graphics = graphics)))
lgd = Legend(title = "foo", at = names(graphics), graphics = graphics)
draw(ht, annotation_legend_list = lgd)
```

<img src="/lab-cn/post/2021-10-17-a-completely-customized-annotation_files/figure-html/unnamed-chunk-6-1.png" width="576" style="display: block; margin: auto;" />

## Session info


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
## [1] ComplexHeatmap_2.25.2 knitr_1.50            colorout_1.3-2       
## 
## loaded via a namespace (and not attached):
##  [1] jsonlite_1.9.0      compiler_4.4.2      rjson_0.2.23       
##  [4] crayon_1.5.3        Rcpp_1.0.14         magick_2.8.5       
##  [7] parallel_4.4.2      cluster_2.1.6       jquerylib_0.1.4    
## [10] IRanges_2.40.1      png_0.1-8           yaml_2.3.10        
## [13] fastmap_1.2.0       R6_2.6.1            shape_1.4.6.1      
## [16] Cairo_1.6-2         BiocGenerics_0.52.0 iterators_1.0.14   
## [19] GetoptLong_1.0.5    circlize_0.4.16     bookdown_0.44      
## [22] bslib_0.9.0         RColorBrewer_1.1-3  rlang_1.1.5        
## [25] cachem_1.1.0        xfun_0.51           sass_0.4.9         
## [28] GlobalOptions_0.1.2 doParallel_1.0.17   cli_3.6.4          
## [31] magrittr_2.0.3      digest_0.6.37       foreach_1.5.2      
## [34] clue_0.3-66         lifecycle_1.0.4     S4Vectors_0.44.0   
## [37] evaluate_1.0.3      blogdown_1.19       codetools_0.2-20   
## [40] stats4_4.4.2        colorspace_2.1-1    rmarkdown_2.29     
## [43] matrixStats_1.5.0   tools_4.4.2         htmltools_0.5.8.1
```
