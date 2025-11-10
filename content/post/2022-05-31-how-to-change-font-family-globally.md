---
title: "How to change font family globally in ComplexHeatmap"
date: 2022-05-31
author: Zuguang Gu
---




In **grid**, every viewport is associated with its own graphics parameters and it by default inherits graphics parameters from
its parent viewport. So, to globally change the font family in a ComplexHeatmap plot, we can simply put the heatmap into
a "global viewport" where we can set a specific font family (also other graphics parameters) there:



``` r
library(ComplexHeatmap)
m = matrix(rnorm(100), 10)

pushViewport(viewport(gp = gpar(fontfamily = "HersheyScript")))
ht = Heatmap(m, top_annotation = HeatmapAnnotation(foo = 1:10),
    right_annotation = rowAnnotation(bar = anno_text(month.name[1:10])),
    column_title = "A small matrix")
draw(ht, newpage = FALSE)
popViewport()
```

<img src="/lab-cn/post/2022-05-31-how-to-change-font-family-globally_files/figure-html/unnamed-chunk-2-1.png" width="672" style="display: block; margin: auto;" />

Note in `draw()`, setting `newpage = FALSE` is important.
