---
title: "Align heatmap legends"
date: 2020-06-29
author: Zuguang Gu
---



In this post, I will demonstrate the automatic alignment of heatmap legends.
This new feature in avaiable in **ComplexHeatmap** >= 2.5.4.

In the following heatmaps, I use a random 10x10 matrix generated as
follows:


``` r
library(ComplexHeatmap)
set.seed(123)
m = matrix(rnorm(100), 10)
```

In the older versions (<= 2.5.3), the legends are put in the middle of a
viewport which almost has the same height as the whole plot. It looks nice
when there are no column names in the heatmap.

<img src="/lab-cn/post/2020-06-29-align-heatmap-legends_files/figure-html/unnamed-chunk-3-1.png" width="576" style="display: block; margin: auto;" />

When using heatmaps to visualize large data sets (e.g. with many columns),
normally we turn off the column names and the legends are in good positions.
However, for some cases, e.g. for a small matrix where column names/labels are
important to visualize, putting the legends in the center of that viewport
will make the plot look very strange. In the next code, I add long column
names to the matrix.


``` r
colnames(m) = strrep(letters[1:10], 20)
```

And the legend is too far away from the heatmap and it looks really bad.

<img src="/lab-cn/post/2020-06-29-align-heatmap-legends_files/figure-html/unnamed-chunk-5-1.png" width="576" style="display: block; margin: auto;" />

From version 2.5.4, the alignment of the legends can be controlled by 
`align_heatmap_legend` and `align_annotation_legend` arguments in 
the `draw()` function. There are three possible values:

- `global_center`: This is the same as in the old versions. The legends
       are put in the middle of the viewport.
- `heatmap_center`: The center of the legends is aligned to the center
      of the heatmap body.
- `heatmap_top`: The top of the legends is aligned to the top of the heatmap body.

An example code of setting e.g. `align_heatmap_legend` is:


``` r
ht = Heatmap(m, ...)
draw(ht, align_heatmap_legend = "heatmap_center", ...)
```

The visual effects of the three options are demonstrated in the following plot:

<img src="/lab-cn/post/2020-06-29-align-heatmap-legends_files/figure-html/unnamed-chunk-7-1.png" width="768" style="display: block; margin: auto;" />

Although you can manually set `align_heatmap_legend`/`align_annotation_legend`,
the good thing in version 2.5.4 is it can automatically identify which value
to set to these two arguments. The basic rules are (take `align_heatmap_legend` 
as an example):

1. If the height of the legends is smaller than the height of the heatmap body,
   the value for `align_heatmap_legend` is set to `"heatmap_center"`.
2. If the height of the legends is smaller than the height of the heatmap body plus
   the sum of heights of the bottom elements of the heatmap (e.g., column names, bottom annotations),
   the value for `align_heatmap_legend` is set to `"heatmap_top"`.
3. For other scenarios, the value for `align_heatmap_legend` is set to `"global_center"`.

In the following code, there are two heatmaps with two legends. The height of the 
two legends is still smaller than the height of the heatmap body, thus, as we can observe
from the plot, the legends are centered to the center of the heatmap body.


``` r
Heatmap(m, name = "mat1") + 
	Heatmap(m, name = "mat2")
```

<img src="/lab-cn/post/2020-06-29-align-heatmap-legends_files/figure-html/unnamed-chunk-8-1.png" width="384" style="display: block; margin: auto;" />

Next we add a third heatmap. Now the legends are higher than the 
heatmap body. Thus they are aligned to the top of the heatmap body.


``` r
Heatmap(m, name = "mat1") + 
	Heatmap(m, name = "mat2") + 
	Heatmap(m, name = "mat3")
```

<img src="/lab-cn/post/2020-06-29-align-heatmap-legends_files/figure-html/unnamed-chunk-9-1.png" width="576" style="display: block; margin: auto;" />

When there are four legends, their height is larger than the height of the heatmap body
and plus column names, so the mode is set to `"global_center"`.


``` r
Heatmap(m, name = "mat1") + 
	Heatmap(m, name = "mat2") + 
	Heatmap(m, name = "mat3") + 
	Heatmap(m, name = "mat4")
```

<img src="/lab-cn/post/2020-06-29-align-heatmap-legends_files/figure-html/unnamed-chunk-10-1.png" width="672" style="display: block; margin: auto;" />

When there are five legends, since the height of the legends now exceeds the height of the plot,
now they are wrapped into two columns.


``` r
Heatmap(m, name = "mat1") + 
	Heatmap(m, name = "mat2") + 
	Heatmap(m, name = "mat3") + 
	Heatmap(m, name = "mat4") + 
	Heatmap(m, name = "mat5")
```

<img src="/lab-cn/post/2020-06-29-align-heatmap-legends_files/figure-html/unnamed-chunk-11-1.png" width="672" style="display: block; margin: auto;" />

Similarly, for ten legends, they are wrapped into three columns, so all the legends are drawn
and visible in the plot.


``` r
Heatmap(m, name = "mat1") + Heatmap(m, name = "mat2") + 
	Heatmap(m, name = "mat3") + Heatmap(m, name = "mat4") + 
	Heatmap(m, name = "mat5") + Heatmap(m, name = "mat6") + 
	Heatmap(m, name = "mat7") + Heatmap(m, name = "mat8") + 
	Heatmap(m, name = "mat9") + Heatmap(m, name = "mat10")
```

<img src="/lab-cn/post/2020-06-29-align-heatmap-legends_files/figure-html/unnamed-chunk-12-1.png" width="672" style="display: block; margin: auto;" />

Let's try also with the annotation legends.


``` r
ha = HeatmapAnnotation(foo1 = 1:10)
Heatmap(m, name = "mat", top_annotation = ha)
```

<img src="/lab-cn/post/2020-06-29-align-heatmap-legends_files/figure-html/unnamed-chunk-13-1.png" width="288" style="display: block; margin: auto;" />


``` r
ha = HeatmapAnnotation(foo1 = 1:10, foo2 = 1:10)
Heatmap(m, name = "mat", top_annotation = ha)
```

<img src="/lab-cn/post/2020-06-29-align-heatmap-legends_files/figure-html/unnamed-chunk-14-1.png" width="288" style="display: block; margin: auto;" />

Currently, there is a limit for this new functionality that the legends might
overlap to the annotaiton labels if they are on the same side of the heatmap.


``` r
ha = HeatmapAnnotation(foo1 = 1:10, foo2 = 1:10, foo3 = 1:10)
Heatmap(m, name = "mat", top_annotation = ha)
```

<img src="/lab-cn/post/2020-06-29-align-heatmap-legends_files/figure-html/unnamed-chunk-15-1.png" width="288" style="display: block; margin: auto;" />

One solution is to move the annotation labels to the other side.


``` r
ha = HeatmapAnnotation(foo1 = 1:10, foo2 = 1:10, foo3 = 1:10, 
	annotation_name_side = "left")
Heatmap(m, name = "mat", top_annotation = ha)
```

<img src="/lab-cn/post/2020-06-29-align-heatmap-legends_files/figure-html/unnamed-chunk-16-1.png" width="288" style="display: block; margin: auto;" />

This new functionality also works for the horizontal legend list that is
put at the bottom of the heatmaps.


