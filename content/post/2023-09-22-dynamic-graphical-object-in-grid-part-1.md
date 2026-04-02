---
title: "Dynamic graphical object in grid, part 1"
date: 2023-09-22
author: Zuguang Gu
---




Consider the following task: drawing two circles at `(1, 0)` and `(-1, 0)` with both radius of 1.


```r
theta = seq(0, 2*pi, length = 50)

x1 = cos(theta) + 1
y1 = sin(theta)

x2 = cos(theta) - 1
y2 = sin(theta)
```

We might think of the following way:


```r
library(grid)
grid.newpage()
pushViewport(viewport(xscale = c(-2, 2), yscale = c(-1, 1)))
grid.lines(x1, y1, default.units = "native")
grid.lines(x2, y2, default.units = "native")
```

<img src="/lab-cn/post/2023-09-22-dynamic-graphical-object-in-grid-part-1_files/figure-html/unnamed-chunk-3-1.png" width="768" style="display: block; margin: auto;" />

Unfortunately it only works when the width of the image is twice of the height.

To enforce the aspect ratio to 2:1, we may think of using the `snpc` unit. Taking
the height of the viewport to `1snpc` and the width of the viewport to `2snpc`.

It works when the height of the image is less than width/2 of the image (in this case, `1snpc` is the height of the image).


```r
grid.newpage()
pushViewport(viewport(xscale = c(-2, 2), yscale = c(-1, 1), 
    width = unit(2, "snpc"), height = unit(1, "snpc")))
grid.lines(x1, y1, default.units = "native")
grid.lines(x2, y2, default.units = "native")
```

<img src="/lab-cn/post/2023-09-22-dynamic-graphical-object-in-grid-part-1_files/figure-html/unnamed-chunk-4-1.png" width="768" style="display: block; margin: auto;" />

But when the height of the image is larger than width/2 but smaller than 
1width, circles will exceed the image area.

<img src="/lab-cn/post/2023-09-22-dynamic-graphical-object-in-grid-part-1_files/figure-html/unnamed-chunk-5-1.png" width="768" style="display: block; margin: auto;" />

You may set `width = unit(1, "snpc"), height = unit(0.5, "snpc")`, but it has the same problem.

Here the core problem is the viewport is dynamically changed. We want the size
of the two circles to be automatically adjusted to maximally fill the image.
In this post, I will introduce how to construct a dynamic graphical object.

First I create a new grob object in the class `double_circle` which contains two circles
(in form of two `linesGrob()` calls). I also create a viewport to include the two
line grobs.



```r
vp = viewport(xscale = c(-2, 2), yscale = c(-1, 1))
grob = grobTree(linesGrob(x1, y1, default.units = "native"), 
                linesGrob(x2, y2, default.units = "native"),
                vp = vp, cl = "double_circle")
```

As you may see, creating a new grob is quite simple. You just integrate a list
of simple grobs (e.g. points, lines) in the `grobTree()` function. The class
is defined by a character string assigned to the `cl` argument.


In `grob`, the viewport is in the `vp` slot which we will dynamically update later.


```r
str(grob$vp)
```

```
## List of 33
##  $ x             : 'simpleUnit' num 0.5npc
##   ..- attr(*, "unit")= int 0
##  $ y             : 'simpleUnit' num 0.5npc
##   ..- attr(*, "unit")= int 0
##  $ width         : 'simpleUnit' num 1npc
##   ..- attr(*, "unit")= int 0
##  $ height        : 'simpleUnit' num 1npc
##   ..- attr(*, "unit")= int 0
##  $ justification : num [1:2] 0.5 0.5
##  $ gp            : list()
##   ..- attr(*, "class")= chr "gpar"
##  $ clip          : logi FALSE
##  $ xscale        : num [1:2] -2 2
##  $ yscale        : num [1:2] -1 1
##  $ angle         : num 0
##  $ layout        : NULL
##  $ layout.pos.row: NULL
##  $ layout.pos.col: NULL
##  $ valid.just    : num [1:2] 0.5 0.5
##  $ valid.pos.row : NULL
##  $ valid.pos.col : NULL
##  $ name          : chr "GRID.VP.4"
##  $ parentgpar    : NULL
##  $ gpar          : NULL
##  $ trans         : NULL
##  $ widths        : NULL
##  $ heights       : NULL
##  $ width.cm      : NULL
##  $ height.cm     : NULL
##  $ rotation      : NULL
##  $ cliprect      : NULL
##  $ parent        : NULL
##  $ children      : NULL
##  $ devwidth      : NULL
##  $ devheight     : NULL
##  $ clippath      : NULL
##  $ mask          : logi TRUE
##  $ resolvedmask  : NULL
##  - attr(*, "class")= chr "viewport"
```

In **grid**, when a grob is drawn, a list of functions will be executed in
serial. Here I introduce the generic function `makeContext()` which will be
executed before drawing the graphics. To use `makeContext()`, you need to
define a S3 method for the grob class. The input is the grob and the output is
an edited grob. `makeContext()` is mainly for adjusting the viewport of the graphics in the grob.

In the following example, for the `double_circle` grob, the width and the
height of the current viewport are checked. If the width is larger than two
times of the height, the width is adjusted to two times of the height, or else
the height is adjusted to half of the width of the viewport.



```r
makeContext.double_circle = function(x) {
    vp_width = convertWidth(x$vp$width, "in", valueOnly = TRUE)
    vp_height = convertHeight(x$vp$height, "in", valueOnly = TRUE)

    if(vp_width > 2*vp_height) {
        x$vp$width = unit(2*vp_height, "in")
        x$vp$height = unit(vp_height, "in")
    } else {
        x$vp$width = unit(vp_width, "in")
        x$vp$height = unit(vp_width/2, "in")
    }
    x
}
```

Now we can use `grid.draw()` to draw the grob without worring the size of the image device.


```r
grid.newpage()
grid.draw(grob)
```

![](https://github.com/jokergoo/BioCartaImage/assets/449218/348453bb-f09b-443d-a8bb-dfb34b088679)




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
## [1] grid      stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] knitr_1.45
## 
## loaded via a namespace (and not attached):
##  [1] digest_0.6.35     R6_2.5.1          bookdown_0.39     fastmap_1.1.1     xfun_0.43        
##  [6] blogdown_1.19     cachem_1.0.8      htmltools_0.5.8.1 rmarkdown_2.26    lifecycle_1.0.4  
## [11] cli_3.6.2         sass_0.4.9        jquerylib_0.1.4   compiler_4.3.3    highr_0.10       
## [16] tools_4.3.3       evaluate_0.23     bslib_0.7.0       yaml_2.3.8        jsonlite_1.8.8   
## [21] rlang_1.1.3
```
