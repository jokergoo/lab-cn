---
title: "Translate from pheatmap to ComplexHeatmap"
date: 2020-05-06
author: Zuguang Gu
---




## Introduction

**pheatmap** is a great R package for making heatmaps, inspiring a lot of other
heatmap packages such as **ComplexHeatmap**. From version 2.5.2 of
**ComplexHeatmap**, I implemented a new `ComplexHeatmap::pheatmap()` function
which actually maps all the parameters in `pheatmap::pheatmap()` to proper
parameters in `ComplexHeatmap::Heatmap()`, which means, it converts a pheatmap
to a complex heatmap. By doing this, the most significant improvement is now you
can add multiple pheatmaps and annotations (defined by
`ComplexHeatmap::rowAnnotation()`).

**`ComplexHeatmap::pheatmap()` includes all arguments in `pheatmap::pheatmap()`,
which means, you don't need to do any adaptation on your pheatmap code, you just
rerun your pheatmap code and it will automatically and nicely convert to the
complex heatmap.**

Some arguments in `pheatmap::pheatmap()` are disabled and ignored in this translation,
listed as follows:

- `kmeans_k`
- `filename`
- `width`
- `height`
- `silent`

The usage of remaining arguments is **exactly the same** as in `pheatmap::pheatmap()`.

In `pheatmap::pheatmap()`, the `color` argument is specified with a long color vector,
e.g. :


``` r
pheatmap::pheatmap(mat, 
	color = colorRampPalette(rev(brewer.pal(n = 7, name = "RdYlBu")))(100)
)
```

You can use the same setting of `color` in `ComplexHeatmap::pheatmap()`, but you
can also simplify it as:


``` r
ComplexHeatmap::pheatmap(mat, 
	color = rev(brewer.pal(n = 7, name = "RdYlBu"))
)
```

The colors for individual values are automatically interpolated.

## Examples

First we load an example dataset which is from [the "Examples" section of 
the documentation of `pheatmap::pheatmap()` function](https://rdrr.io/cran/pheatmap/man/pheatmap.html#heading-6) .


``` r
library(ComplexHeatmap)
test = matrix(rnorm(200), 20, 10)
test[1:10, seq(1, 10, 2)] = test[1:10, seq(1, 10, 2)] + 3
test[11:20, seq(2, 10, 2)] = test[11:20, seq(2, 10, 2)] + 2
test[15:20, seq(2, 10, 2)] = test[15:20, seq(2, 10, 2)] + 4
colnames(test) = paste("Test", 1:10, sep = "")
rownames(test) = paste("Gene", 1:20, sep = "")
```

Calling `pheatmap()` (which is now actually `ComplexHeatmap::pheatmap()`) generates
a similar heatmap as by `pheatmap::pheatmap()`.


``` r
pheatmap(test)  # this is ComplexHeatmap::pheatmap
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-5-1.png" width="384" style="display: block; margin: auto;" />

Everything looks the same except the style of the heatmap legend. There are also
some other visual difference which you can find in the "Comparisons" section in this post.

The next one is an example for setting annotations (you should be familiar with
how to set these data frames and color list if you are a pheatmap user). 


``` r
annotation_col = data.frame(
    CellType = factor(rep(c("CT1", "CT2"), 5)), 
    Time = 1:5
)
rownames(annotation_col) = paste("Test", 1:10, sep = "")

annotation_row = data.frame(
    GeneClass = factor(rep(c("Path1", "Path2", "Path3"), c(10, 4, 6)))
)
rownames(annotation_row) = paste("Gene", 1:20, sep = "")

ann_colors = list(
    Time = c("white", "firebrick"),
    CellType = c(CT1 = "#1B9E77", CT2 = "#D95F02"),
    GeneClass = c(Path1 = "#7570B3", Path2 = "#E7298A", Path3 = "#66A61E")
)
```


``` r
pheatmap(test, annotation_col = annotation_col, annotation_row = annotation_row, 
	annotation_colors = ann_colors)
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-7-1.png" width="480" style="display: block; margin: auto;" />

You can split the heatmap by rows or by columns, which is a unique feature of **ComplexHeatmap**.


``` r
pheatmap(test, annotation_col = annotation_col, annotation_row = annotation_row, 
	annotation_colors = ann_colors, 
	row_split = annotation_row$GeneClass,
	column_split = annotation_col$CellType)
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-8-1.png" width="480" style="display: block; margin: auto;" />

`ComplexHeatmap::pheatmap()` returns a `Heatmap` object, so it can be added with
other heatmaps and annotations. Or in other words, you can add multiple pheatmaps
and annotations. Cool!


``` r
p1 = pheatmap(test, name = "mat1")
p2 = rowAnnotation(foo = anno_barplot(1:nrow(test)))
p3 = pheatmap(test, name = "mat2", 
	col = colorRampPalette(c("navy", "white", "firebrick3"))(50))
# or you can simply specify as
# p3 = pheatmap(test, name = "mat2", col = c("navy", "white", "firebrick3"))
p1 + p2 + p3
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-9-1.png" width="576" style="display: block; margin: auto;" />

Nevertheless, if you really want to add multiple pheatmaps, I still suggest you
to directly use the `Heatmap()` function. You can find how to migrate from 
`pheatmap::pheatmap()` to `ComplexHeatmap::Heatmap()` in the next section.

One last thing is since `ComplexHeatmap::pheatmap()` returns a `Heatmap` object,
if `pheatmap()` is not called in an interactive environment, e.g. in an R script,
inside a function or in a `for` loop, you need to explicitly use `draw()` function:


``` r
for(...) {
	p = pheatmap(...)
	draw(p)
}
```

## Translation

Following table lists how to map parameters in `pheatmap::pheatmap()` to `ComplexHeatmap::Heatmap()`.

| Arguments in `pheatmap::pheatmap()`  | Identical settings/arguments in `ComplexHeatmap::Heatmap()` |
|:-------------------------------------|:---------------------------------------------------|
|`mat`                      | `matrix`     |
|`color`                    | Users can specify a color mapping function by `circlize::colorRamp2()`, or provide a vector of colors on which colors for individual values are linearly interpolated.     |
|`kmeans_k`                 | No corresponding parameter because it changes the matrix for heatmap.     |
|`breaks`                   | It should be specified in the color mapping function.     |
|`border_color`             | `rect_gp = gpar(col = border_color)`. In the annotations, it is `HeatmapAnnotation(..., gp = gpar(col = border_color))`.      |
|`cellwidth`                | `width = ncol(mat)*unit(cellwidth, "pt")`     |
|`cellheight`               | `height = nrow(mat)*unit(cellheight, "pt")`     |
|`scale`                    | Users should simply apply `scale()` on the matrix before sending to `Heatmap()`.     |
|`cluster_rows`             | `cluster_rows`     |
|`cluster_cols`             | `cluster_columns`     |
|`clustering_distance_rows` | `clustering_distance_rows`. The value `correlation` should be changed to `pearson`.     |
|`clustering_distance_cols` | `clustering_distance_columns`, The value `correlation` should be changed to `pearson`.    |
|`clustering_method`        | `clustering_method_rows`/`clustering_method_columns`     |
|`clustering_callback`      | The processing on the dendrogram should be applied before sending to `Heatmap()`.     |
|`cutree_rows`              | `row_split` and row clustering should be applied.     |
|`cutree_cols`              | `column_split` and column clustering should be applied.     |
|`treeheight_row`           | `row_dend_width = unit(treeheight_row, "pt")`     |
|`treeheight_col`           | `column_dend_height = unit(treeheight_col, "pt")`     |
|`legend`                   | `show_heatmap_legend`     | 
|`legend_breaks`            | `heatmap_legend_param = list(at = legend_breaks)`     |
|`legend_labels`            | `heatmap_legend_param = list(labels = legend_labels)`     |
|`annotation_row`           | `left_annotatioin = rowAnnotation(df = annotation_row)`     | 
|`annotation_col`           | `top_annotation = HeatmapAnnotation(df = annotation_col)`     |
|`annotation`               | Not supported.     |
|`annotation_colors`        | `col` argument in `HeatmapAnnotation()`/`rowAnnotation()`.     |
|`annotation_legend`        | `show_legend` argument in `HeatmapAnnotation()`/`rowAnnotation()`.     |
|`annotation_names_row`     | `show_annotation_name` in `rowAnnotation()`.     |
|`annotation_names_col`     | `show_annotation_name` in `HeatmaoAnnotation()`.     |
|`drop_levels`              | Unused levels are all dropped.   |
|`show_rownames`            | `show_row_names`     |
|`show_colnames`            | `show_column_names`     |
|`main`                     | `column_title`     |
|`fontsize`                 | `gpar(fontsize = fontsize)` in corresponding heatmap components.     |
|`fontsize_row`             | `row_names_gp = gpar(fontsize = fontsize_row)`     | 
|`fontsize_col`             | `column_names_gp = gpar(fontsize = fontsize_col)`     |
|`angle_col`                | `column_names_rot`. The rotation of row annotation names are not supported.     |
|`display_numbers`          | Users should set a proper `cell_fun` or `layer_fun` (vectorized and faster version of `cell_fun`). E.g. if `display_numbers` is `TRUE`, `layer_fun` can be set as `function(j, i, x, y, w, h, fill) { grid.text(sprintf(number_format, pindex(mat, i, j)), x = x, y = y, gp = gpar(col = number_color, fontsize = fontsize_number)) }`. If `display_numbers` is a matrix, replace `mat` to `display_numbers` in the `layer_fun`.    |
|`number_format`            | See above.     |
|`number_color`             | See above.     |
|`fontsize_number`          | See above.     |
|`gaps_row`                 | Users should construct a "splitting variable" and send to `row_split`. E.g. `slices = diff(c(0, gaps_row, nrow(mat))); rep(seq_along(slices), times = slices)`.     |
|`gaps_col`                 | Users should construct a "splitting variable" and send to `column_split`.     |
|`labels_row`               | `row_labels`     |
|`labels_col`               | `column_labels`     |
|`filename`                 | No corresponding setting in `Heatmap()`. Users need to explicitly use e.g. `pdf`().     |
|`width`                    | No corresponding setting in `Heatmap()`.     |
|`height`                   | No corresponding setting in `Heatmap()`.     |
|`silent`                   | No corresponding setting in `Heatmap()`.     |
|`na_col`                   | `na_col`     |

## Comparisons



I ran all the example code in [the "Examples" section of the documentation of
`pheatmap::pheatmap()` function](https://rdrr.io/cran/pheatmap/man/pheatmap.html#heading-6) . 
I also implemented a wrapper function `ComplexHeatmap::compare_pheatmap()` which basically uses the same
set of arguments for `pheatmap::pheatmap()` and `ComplexHeatmap::pheatmap()` and
draws two heatmaps, so that you can directly see the similarity and difference
of the two heatmap implementations.


``` r
compare_pheatmap(test)
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-12-1.png" width="768" style="display: block; margin: auto;" />


``` r
compare_pheatmap(test, scale = "row", clustering_distance_rows = "correlation")
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-13-1.png" width="768" style="display: block; margin: auto;" />


``` r
compare_pheatmap(test, 
	color = colorRampPalette(c("navy", "white", "firebrick3"))(50))
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-14-1.png" width="768" style="display: block; margin: auto;" />


``` r
compare_pheatmap(test, cluster_row = FALSE)
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-15-1.png" width="768" style="display: block; margin: auto;" />


``` r
compare_pheatmap(test, legend = FALSE)
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-16-1.png" width="768" style="display: block; margin: auto;" />



``` r
compare_pheatmap(test, display_numbers = TRUE)
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-17-1.png" width="768" style="display: block; margin: auto;" />


``` r
compare_pheatmap(test, display_numbers = TRUE, number_format = "%.1e")
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-18-1.png" width="768" style="display: block; margin: auto;" />


``` r
compare_pheatmap(test, 
	display_numbers = matrix(ifelse(test > 5, "*", ""), nrow(test)))
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-19-1.png" width="768" style="display: block; margin: auto;" />


``` r
compare_pheatmap(test, cluster_row = FALSE, legend_breaks = -1:4, 
	legend_labels = c("0", "1e-4", "1e-3", "1e-2", "1e-1", "1"))
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-20-1.png" width="768" style="display: block; margin: auto;" />


``` r
compare_pheatmap(test, cellwidth = 15, cellheight = 12, main = "Example heatmap")
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-21-1.png" width="768" style="display: block; margin: auto;" />



``` r
annotation_col = data.frame(
    CellType = factor(rep(c("CT1", "CT2"), 5)), 
    Time = 1:5
)
rownames(annotation_col) = paste("Test", 1:10, sep = "")

annotation_row = data.frame(
    GeneClass = factor(rep(c("Path1", "Path2", "Path3"), c(10, 4, 6)))
)
rownames(annotation_row) = paste("Gene", 1:20, sep = "")

compare_pheatmap(test, annotation_col = annotation_col)
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-22-1.png" width="768" style="display: block; margin: auto;" />


``` r
compare_pheatmap(test, annotation_col = annotation_col, annotation_legend = FALSE)
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-23-1.png" width="768" style="display: block; margin: auto;" />


``` r
compare_pheatmap(test, annotation_col = annotation_col, 
	annotation_row = annotation_row)
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-24-1.png" width="768" style="display: block; margin: auto;" />


``` r
compare_pheatmap(test, annotation_col = annotation_col, 
	annotation_row = annotation_row, angle_col = "45")
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-25-1.png" width="768" style="display: block; margin: auto;" />


``` r
compare_pheatmap(test, annotation_col = annotation_col, angle_col = "0")
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-26-1.png" width="768" style="display: block; margin: auto;" />


``` r
ann_colors = list(
    Time = c("white", "firebrick"),
    CellType = c(CT1 = "#1B9E77", CT2 = "#D95F02"),
    GeneClass = c(Path1 = "#7570B3", Path2 = "#E7298A", Path3 = "#66A61E")
)

compare_pheatmap(test, annotation_col = annotation_col, 
	annotation_colors = ann_colors, main = "Title")
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-27-1.png" width="768" style="display: block; margin: auto;" />


``` r
compare_pheatmap(test, annotation_col = annotation_col, 
	annotation_row = annotation_row, annotation_colors = ann_colors)
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-28-1.png" width="768" style="display: block; margin: auto;" />


``` r
compare_pheatmap(test, annotation_col = annotation_col, 
	annotation_colors = ann_colors[2]) 
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-29-1.png" width="768" style="display: block; margin: auto;" />


``` r
compare_pheatmap(test, annotation_col = annotation_col, cluster_rows = FALSE, 
	gaps_row = c(10, 14))
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-30-1.png" width="768" style="display: block; margin: auto;" />


``` r
compare_pheatmap(test, annotation_col = annotation_col, cluster_rows = FALSE, 
	gaps_row = c(10, 14), cutree_col = 2)
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-31-1.png" width="768" style="display: block; margin: auto;" />



``` r
labels_row = c("", "", "", "", "", "", "", "", "", "", "", "", "", "", "", 
	"", "", "Il10", "Il15", "Il1b")
compare_pheatmap(test, annotation_col = annotation_col, labels_row = labels_row)
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-32-1.png" width="768" style="display: block; margin: auto;" />



``` r
drows = dist(test, method = "minkowski")
dcols = dist(t(test), method = "minkowski")
compare_pheatmap(test, clustering_distance_rows = drows, 
	clustering_distance_cols = dcols)
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-33-1.png" width="768" style="display: block; margin: auto;" />


``` r
library(dendsort)
callback = function(hc, ...){dendsort(hc)}
compare_pheatmap(test, clustering_callback = callback)
```

<img src="/lab-cn/post/2020-05-06-translate-from-pheatmap-to-complexheatmap_files/figure-html/unnamed-chunk-34-1.png" width="768" style="display: block; margin: auto;" />

