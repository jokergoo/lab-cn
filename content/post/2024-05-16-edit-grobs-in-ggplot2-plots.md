---
title: "Edit grobs in ggplot2 plots"
date: 2024-05-16
author: Zuguang Gu
---




Load the packages and generate test dataset.


``` r
library(ggplot2)
library(grid)
df = data.frame(
    x = rep(c(2, 5, 7, 9, 12), 2),
    y = rep(c(1, 2), each = 5),
    z = factor(rep(1:5, each = 2)),
    w = rep(diff(c(0, 4, 6, 8, 10, 14)), 2)
)
```

We make a "heatmap" with the **ggplot2** package.



``` r
ggplot(df, aes(x, y)) +
    geom_tile(aes(fill = z), color = NA)
```

<img src="/lab-cn/post/2024-05-16-edit-grobs-in-ggplot2-plots_files/figure-html/unnamed-chunk-3-1.svg" width="672" style="display: block; margin: auto;" />

Depends on the "graphics device" you use, you might see white vertical and horizontal lines between cells in the plot. Here in
this example I use "svg", but there is no such problem with other devices such as "png" or "jpeg".

Of course you can remove `color = NA` to add borders for these cells. But you might see

One solution to remove such white lines

1. obtain the cells
2. for each cell, increase its width and height by 1 point on the four sides



``` r
ggplot(df, aes(x, y)) +
    geom_tile(aes(fill = z), color = NA)

# making viewports available
grid.force()

# obtain the path of `geom_rect`
vpath = grid.grep("geom_rect", grobs = TRUE, viewports = TRUE, grep = TRUE)

# obtain the rect grobs
grect = grid.get(vpath)

# edit the grob by extending 1pt on both sides
grect$width = grect$width + unit(2, "pt")
grect$height = grect$height + unit(2, "pt")

# update the plot
grid.set(vpath, grect)
```

<img src="/lab-cn/post/2024-05-16-edit-grobs-in-ggplot2-plots_files/figure-html/unnamed-chunk-4-1.svg" width="672" style="display: block; margin: auto;" />

