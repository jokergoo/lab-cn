---
title: "Cluster groups in ComplexHeatmap"
date: 2021-03-05
author: Zuguang Gu
---




When making heatmaps, we always have many additionally grouping information
for the samples, sush as subtypes, phenotypes. To emphasize the difference
between groups, we might want to only perform clustering on group level, while
not on the complete dataset. For these scenarios, **ComplexHeatmap** has two
functions: `cluster_between_groups()` and `cluster_within_group()`. The two
functions all perform clustering on group level. The difference is, in
`cluster_between_groups()`, inside each group, the order of samples is
unchanged, while in `cluster_within_group()`, samples in each group are still
clustered.

I demonstrate the use of the two functions with a simple random matrix. In the
first plot, `cluster_between_groups()` was applied. The column names
correspond to the original order in the matrix, so you can observe whether the
columns are reordered or not.



``` r
library(ComplexHeatmap)
set.seed(372)
m = matrix(rnorm(120), nc = 12)
colnames(m) = 1:12
fa = rep(c("a", "b", "c"), times = c(2, 4, 6))
fa_col = c("a" = 2, "b" = 3, "c" = 4)
dend1 = cluster_between_groups(m, fa)
Heatmap(m, cluster_columns = dend1, column_split = 3,
	row_title = "cluster_between_groups",
	top_annotation = HeatmapAnnotation(foo = fa, col = list(foo = fa_col)))
```

<img src="/lab-cn/post/2021-03-05-cluster-groups-in-complex-heatmap_files/figure-html/unnamed-chunk-2-1.png" width="480" style="display: block; margin: auto;" />

In the second plot, `cluster_within_group()` was applied. As you can see, columns
are also reordered inside each group.


``` r
dend2 = cluster_within_group(m, fa)
Heatmap(m, cluster_columns = dend2, column_split = 3,
	row_title = "cluster_within_group",
	top_annotation = HeatmapAnnotation(foo = fa, col = list(foo = fa_col)))
```

<img src="/lab-cn/post/2021-03-05-cluster-groups-in-complex-heatmap_files/figure-html/unnamed-chunk-3-1.png" width="480" style="display: block; margin: auto;" />

Note, they also work on heatmap rows. Please update to the current GitHub version to use these two functions.

Finally, thanks @[crazyhottommy](https://github.com/jokergoo/ComplexHeatmap/issues/694) for providing
this interesting use case.

