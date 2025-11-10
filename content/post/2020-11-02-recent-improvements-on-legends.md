---
title: "Recent improvements on legends"
date: 2020-10-29
author: Zuguang Gu
---





In this post, I will demonstrate several improvements on the legends in
**ComplexHeatmap** package (version 2.7.1).

First I load the **ComplexHeatmap** package.


``` r
library(ComplexHeatmap)
```

## Discrete legends

Now it works with multi-line labels:


``` r
lgd = Legend(labels = c("aaaaa\naaaaa", "bbbbb\nbbbbb", "c", "d"),
    legend_gp = gpar(fill = 1:4))
```


<img src="/lab-cn/post/2020-11-02-recent-improvements-on-legends_files/figure-html/unnamed-chunk-5-1.png" width="71.0824146981627" style="display: block; margin: auto;" />

When the multi-line legend labels are in different rows:



``` r
lgd = Legend(labels = c("aaaaa\naaaaa", "c", "d", "bbbbb\nbbbbb"),
    legend_gp = gpar(fill = 1:4), nrow = 2)
```

<img src="/lab-cn/post/2020-11-02-recent-improvements-on-legends_files/figure-html/unnamed-chunk-7-1.png" width="134.072440944882" style="display: block; margin: auto;" />

`Legend()` function has a new argument `graphics` where users can self-define the graphics
drawn in the legend. Check the following example:



``` r
lgd = Legend(labels = letters[1:4],
    graphics = list(
        function(x, y, w, h) grid.rect(x, y, w*0.33, h, gp = gpar(fill = "red")),
        function(x, y, w, h) grid.rect(x, y, w, h*0.33, gp = gpar(fill = "blue")),
        function(x, y, w, h) grid.text("A", x, y, gp = gpar(col = "darkgreen")),
        function(x, y, w, h) grid.points(x, y, gp = gpar(col = "orange"), pch = 16)
    ))
```


<img src="/lab-cn/post/2020-11-02-recent-improvements-on-legends_files/figure-html/unnamed-chunk-9-1.png" width="41.4290813648294" style="display: block; margin: auto;" />

This new feature in mainly used [to draw complex legends in
oncoPrint](https://jokergoo.github.io/ComplexHeatmap-reference/book/oncoprint.html).

## Continuous legends

I first define a color mapping function by `circlize::colorRamp2()` function.


``` r
library(circlize)
col_fun = colorRamp2(c(-2, 0, 2), c("green", "white", "red"))
```

By default the legend looks like:


``` r
lgd = Legend(col_fun = col_fun, title = "foo")
```

<img src="/lab-cn/post/2020-11-02-recent-improvements-on-legends_files/figure-html/unnamed-chunk-12-1.png" width="49.2157480314961" style="display: block; margin: auto;" />

If `at` is set in the decreasing order, the legend is reversed, _i.e._ the smallest value
is on the top of the legend.


``` r
lgd = Legend(col_fun = col_fun, title = "foo", at = c(2, 1, 0, -1, -2))
```

<img src="/lab-cn/post/2020-11-02-recent-improvements-on-legends_files/figure-html/unnamed-chunk-14-1.png" width="49.2157480314961" style="display: block; margin: auto;" />

Most continuous legends have legend breaks with equal distance, which I mean,
_e.g._ the distance between the first and the second breaks are the same as the
distance between the second and the third breaks. However, there are still special
cases where users want to set legend breaks with unequal distances.

In the following example, the color mapping function `col_fun_prop` visualizes
proportion values with breaks in `c(0, 0.05, 0.1, 0.5, 1)`. The legend breaks
with unequal distance might reflect the different importance of the values in `c(0, 1)`.
For example, maybe we want to see more details in the interval `c(0, 0.1)`.

Following is the default style of the legend where the breaks are selected from 0 to 1
with equal distance.


``` r
col_fun_prop = colorRamp2(c(0, 0.05, 0.1, 0.5, 1), 
	c("green", "white", "red", "black", "blue"))
lgd = Legend(col_fun = col_fun_prop, title = "Prop")
```

<img src="/lab-cn/post/2020-11-02-recent-improvements-on-legends_files/figure-html/unnamed-chunk-16-1.png" width="52.5490813648294" style="display: block; margin: auto;" />

You cann't see the details in the interval `c(0, 0.1)`, right? This also reminds us that
the breaks set in `colorRamp2()` only defines the color mapping while not determine
the breaks in the legend.

If we manually select the break values, the color bar keeps the same. The labels 
are shifted and lines connect them to the original positions. In this case, the distance
in the color bar is still proportional to the real difference in the break values, _i.e._,
the distance between 0.5 and 1 is five times longer than 0 and 0.1.


``` r
col_fun_prop = colorRamp2(c(0, 0.05, 0.1, 0.5, 1), 
	c("green", "white", "red", "black", "blue"))
lgd = Legend(col_fun = col_fun_prop, title = "Prop",
	at = c(0, 0.05, 0.1, 0.5, 1))
```

<img src="/lab-cn/post/2020-11-02-recent-improvements-on-legends_files/figure-html/unnamed-chunk-18-1.png" width="71.3009973753281" style="display: block; margin: auto;" />

From version 2.7.1, `Legend()` function has a new argument `break_dist` that
controls the distance between two neighbouring break values in the legend.
**It might be confusing, but from here, when I mention "break distance", it
always means the visual distance in the legend.** 

The value of `break_dist` should have length either one which means all break
values have equal distance in the legend, or `length(at) - 1`.


``` r
lgd = Legend(col_fun = col_fun_prop, title = "Prop", break_dist = 1)
```

<img src="/lab-cn/post/2020-11-02-recent-improvements-on-legends_files/figure-html/unnamed-chunk-20-1.png" width="59.9624146981627" style="display: block; margin: auto;" />

And in the following example, the top two break intervals are three times longer than
the bottom two intervals.


``` r
lgd = Legend(col_fun = col_fun_prop, title = "Prop", break_dist = c(1, 1, 3, 3))
```

<img src="/lab-cn/post/2020-11-02-recent-improvements-on-legends_files/figure-html/unnamed-chunk-22-1.png" width="71.3009973753281" style="display: block; margin: auto;" />

If we increase the legend height by `legend_height` argument, there will be enough space
for the labels and their positions are not adjusted any more.


``` r
lgd = Legend(col_fun = col_fun_prop, title = "Prop", break_dist = c(1, 1, 3, 3),
	legend_height = unit(4, "cm"))
```

<img src="/lab-cn/post/2020-11-02-recent-improvements-on-legends_files/figure-html/unnamed-chunk-24-1.png" width="59.9624146981627" style="display: block; margin: auto;" />

## Multi-scheme colors

Imaging following user case, we want to use one color scheme for the values in
`c(0, 0.1)` and a second color schema for the values in `c(0.1, 1)`, maybe for
the reason that we want to emphasize the two intervals are very different. The
color mapping can be defined as:


``` r
col_fun2 = colorRamp2(c(0, 0.1, 0.1+1e-6, 1), c("white", "red", "yellow", "blue"))
```

So here I just added a tiny shift (`1e-6`) to 0.1 and set it as the lower bound for the
second color scheme. The legend looks like:


``` r
lgd = Legend(col_fun = col_fun2, title = "Prop", at = c(0, 0.05, 0.1, 0.5, 1),
	break_dist = c(1, 1, 3, 3), legend_height = unit(4, "cm"))
```

<img src="/lab-cn/post/2020-11-02-recent-improvements-on-legends_files/figure-html/unnamed-chunk-27-1.png" width="59.9624146981627" style="display: block; margin: auto;" />

Now you can see the colors are not changed smoothly from 0 to 1 and there are two disticnt
color schemes.

## Work with heatmaps and annotations

As explained in [the **ComplexHeatmap**
book](https://jokergoo.github.io/ComplexHeatmap-reference/book/legends.html#heatmap-and-annotation-legends),
the new arguments be set either via argument `heatmap_legend_param` in
`Heatmap()` function or argument `annotation_legend_param` in
`HeatmapAnnotation()` function.

## Example with a heatmap

Here I made a simplified version of [the measles vaccine heatmap](https://jokergoo.github.io/ComplexHeatmap-reference/book/more-examples.html#the-measles-vaccine-heatmap).
Check how I set the `heatmap_legend_param` argument.


``` r
mat = readRDS(system.file("extdata", "measles.rds", package = "ComplexHeatmap"))
col_fun = colorRamp2(c(0, 800, 1000, 127000), c("white", "cornflowerblue", "yellow", "red"))
Heatmap(mat, name = "cases", col = col_fun, rect_gp = gpar(col= "white"),
    cluster_columns = FALSE, show_row_dend = FALSE, show_column_names = FALSE,
    row_names_side = "left", row_names_gp = gpar(fontsize = 8),
    heatmap_legend_param = list(
    	at = c(0, 400, 800, 50000, 100000, 150000), 
        labels = c("0", "400", "800", "50k", "100k", "150k"),
        break_dist = c(1, 1, 3, 3, 3), 
        legend_gp = gpar(col = "black"),
        legend_height = unit(5, "cm")
    )
)
```

<img src="/lab-cn/post/2020-11-02-recent-improvements-on-legends_files/figure-html/unnamed-chunk-28-1.png" width="672" style="display: block; margin: auto;" />

I can also adjust the legend to put it at the bottom of the heatmap.


``` r
ht = Heatmap(mat, name = "cases", col = col_fun, rect_gp = gpar(col= "white"),
    cluster_columns = FALSE, show_row_dend = FALSE, show_column_names = FALSE,
    row_names_side = "left", row_names_gp = gpar(fontsize = 8),
    heatmap_legend_param = list(
    	at = c(0, 400, 800, 50000, 100000, 150000), 
        labels = c("0", "400", "800", "50k", "100k", "150k"),
        break_dist = c(1, 1, 3, 3, 3), 
        legend_gp = gpar(col = "black"),
        legend_width = unit(9, "cm"),
        direction = "horizontal",
        title_position = "lefttop"
    )
)
draw(ht, heatmap_legend_side = "bottom")
```

<img src="/lab-cn/post/2020-11-02-recent-improvements-on-legends_files/figure-html/unnamed-chunk-29-1.png" width="672" style="display: block; margin: auto;" />

