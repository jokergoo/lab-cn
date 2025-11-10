---
title: "Support HCL colormaps in ComplexHeatmap"
date: 2022-03-08
author: Zuguang Gu
---



To demonstrate this new feature, I first generate a small random matrix.


``` r
set.seed(123)
nr1 = 4; nr2 = 8; nr3 = 6; nr = nr1 + nr2 + nr3
nc1 = 6; nc2 = 8; nc3 = 10; nc = nc1 + nc2 + nc3
mat = cbind(rbind(matrix(rnorm(nr1*nc1, mean = 1,   sd = 0.5), nr = nr1),
                  matrix(rnorm(nr2*nc1, mean = 0,   sd = 0.5), nr = nr2),
                  matrix(rnorm(nr3*nc1, mean = 0,   sd = 0.5), nr = nr3)),
            rbind(matrix(rnorm(nr1*nc2, mean = 0,   sd = 0.5), nr = nr1),
                  matrix(rnorm(nr2*nc2, mean = 1,   sd = 0.5), nr = nr2),
                  matrix(rnorm(nr3*nc2, mean = 0,   sd = 0.5), nr = nr3)),
            rbind(matrix(rnorm(nr1*nc3, mean = 0.5, sd = 0.5), nr = nr1),
                  matrix(rnorm(nr2*nc3, mean = 0.5, sd = 0.5), nr = nr2),
                  matrix(rnorm(nr3*nc3, mean = 1,   sd = 0.5), nr = nr3))
           )
```

Since this matrix contains both positive and negative values, we may want the color mapping to be symmetric to zero,
thus we define a zero-centric color mapping function with `circlize::colorRamp2()`.
The "blue-white-red" heatmap looks like as follows:


``` r
library(circlize)
library(ComplexHeatmap)
col_fun = colorRamp2(c(-2, 0, 2), c("blue", "white", "red"))
Heatmap(mat, name = "mat", col = col_fun,
    show_row_dend = FALSE, show_column_dend = FALSE)
```

<img src="/lab-cn/post/2022-03-08-support-hcl-colormaps-in-complex-heatmap_files/figure-html/unnamed-chunk-3-1.png" width="384" style="display: block; margin: auto;" />

In the example, the color mapping function `col_fun` defines three colors (blue/white/red) for the three breaks values (-2/0/2), and
other values are linearly interpolated in [the LAB color space (by default)](https://en.wikipedia.org/wiki/CIELAB_color_space).



In the paper ["colorspace: A Toolbox for Manipulating and Assessing Colors and Palettes"](https://www.jstatsoft.org/article/view/v096i01), it
described color maps in [the HCL color space](https://en.wikipedia.org/wiki/HCL_color_space), which are more natural for human perception of colors. It also provides rich color palettes extracted in the HCL color space. The list of color palettes are listed in `grDevides::hcl.pals()`.


``` r
hcl.pals("diverging")
```

```
##  [1] "Blue-Red"      "Blue-Red 2"    "Blue-Red 3"    "Red-Green"    
##  [5] "Purple-Green"  "Purple-Brown"  "Green-Brown"   "Blue-Yellow 2"
##  [9] "Blue-Yellow 3" "Green-Orange"  "Cyan-Magenta"  "Tropic"       
## [13] "Broc"          "Cork"          "Vik"           "Berlin"       
## [17] "Lisbon"        "Tofino"
```

``` r
hcl.pals("divergingx")
```

```
##  [1] "ArmyRose" "Earth"    "Fall"     "Geyser"   "TealRose" "Temps"   
##  [7] "PuOr"     "RdBu"     "RdGy"     "PiYG"     "PRGn"     "BrBG"    
## [13] "RdYlBu"   "RdYlGn"   "Spectral" "Zissou 1" "Cividis"  "Roma"
```

``` r
hcl.pals("sequential")
```

```
##  [1] "Grays"         "Light Grays"   "Blues 2"       "Blues 3"      
##  [5] "Purples 2"     "Purples 3"     "Reds 2"        "Reds 3"       
##  [9] "Greens 2"      "Greens 3"      "Oslo"          "Purple-Blue"  
## [13] "Red-Purple"    "Red-Blue"      "Purple-Orange" "Purple-Yellow"
## [17] "Blue-Yellow"   "Green-Yellow"  "Red-Yellow"    "Heat"         
## [21] "Heat 2"        "Terrain"       "Terrain 2"     "Viridis"      
## [25] "Plasma"        "Inferno"       "Rocket"        "Mako"         
## [29] "Dark Mint"     "Mint"          "BluGrn"        "Teal"         
## [33] "TealGrn"       "Emrld"         "BluYl"         "ag_GrnYl"     
## [37] "Peach"         "PinkYl"        "Burg"          "BurgYl"       
## [41] "RedOr"         "OrYel"         "Purp"          "PurpOr"       
## [45] "Sunset"        "Magenta"       "SunsetDark"    "ag_Sunset"    
## [49] "BrwnYl"        "YlOrRd"        "YlOrBr"        "OrRd"         
## [53] "Oranges"       "YlGn"          "YlGnBu"        "Reds"         
## [57] "RdPu"          "PuRd"          "Purples"       "PuBuGn"       
## [61] "PuBu"          "Greens"        "BuGn"          "GnBu"         
## [65] "BuPu"          "Blues"         "Lajolla"       "Turku"        
## [69] "Hawaii"        "Batlow"
```


From **circlize** version 0.4.14, the function `colorRamp2()` now accepts a
new argument `hcl_palette` which allows to set a specific HCL color palette.
The valid values are those supported in `grDevides::hcl.pals()`.


To set a color mapping function which extends colors in the HCL color space, simply set the `hcl_palette` argument. For example:


``` r
colorRamp2(c(-2, 0, 2), hcl_palette = "Blue-Red 2")
```

Please note: DO NOT set as in the following code. In there, three colors are extracted from the "Blue-Red 2" palette, but all other colors
are still interpolated in the LAB color space.



``` r
colorRamp2(c(-2, 0, 2), hcl.colors(3, "Blue-Red 2"))  # this is wrong
```


In the following, each heatmap uses a specific HCL color palette. You can see how the heatmap looks like under different HCL color palettes.


``` r
pl = list()
for(palette in sort(hcl.pals("diverging"))) {
    col_fun = colorRamp2(c(-2, 0, 2), hcl_palette = palette)
    ht = Heatmap(mat, name = "mat", col = col_fun, 
        show_row_dend = FALSE, show_column_dend = FALSE,
        column_title = paste0("palette = '", palette, "'"),
        heatmap_legend_param = list(legend_height = unit(6, "cm")))
    pl[[palette]] = grid.grabExpr(draw(ht))
}
library(cowplot)
plot_grid(plotlist = pl, ncol = 5)
```

<img src="/lab-cn/post/2022-03-08-support-hcl-colormaps-in-complex-heatmap_files/figure-html/unnamed-chunk-8-1.png" width="100%" style="display: block; margin: auto;" />


``` r
pl = list()
for(palette in sort(hcl.pals("divergingx"))) {
    col_fun = colorRamp2(c(-2, 0, 2), hcl_palette = palette)
    ht = Heatmap(mat, name = "mat", col = col_fun, 
        show_row_dend = FALSE, show_column_dend = FALSE,
        column_title = paste0("palette = '", palette, "'"),
        heatmap_legend_param = list(legend_height = unit(6, "cm")))
    pl[[palette]] = grid.grabExpr(draw(ht))
}
plot_grid(plotlist = pl, ncol = 5)
```

<img src="/lab-cn/post/2022-03-08-support-hcl-colormaps-in-complex-heatmap_files/figure-html/unnamed-chunk-9-1.png" width="100%" style="display: block; margin: auto;" />



``` r
pl = list()
for(palette in sort(hcl.pals("sequential"))) {
    col_fun = colorRamp2(range(mat), hcl_palette = palette, reverse = TRUE)
    ht = Heatmap(mat, name = "mat", col = col_fun, 
        show_row_dend = FALSE, show_column_dend = FALSE,
        column_title = paste0("palette = '", palette, "'"),
        heatmap_legend_param = list(legend_height = unit(6, "cm")))
    pl[[palette]] = grid.grabExpr(draw(ht))
}
plot_grid(plotlist = pl, ncol = 5)
```

<img src="/lab-cn/post/2022-03-08-support-hcl-colormaps-in-complex-heatmap_files/figure-html/unnamed-chunk-10-1.png" width="100%" style="display: block; margin: auto;" />

