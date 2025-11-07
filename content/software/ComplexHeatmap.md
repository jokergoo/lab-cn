---
title: ComplexHeatmap
---




ComplexHeatmap 提供了复杂热图可视化的通用方法。


### 基本信息

<div id="soft-info">

软件包 | 链接 
:------ | :----------
编程语言 | R
Bioconductor | https://bioconductor.org/packages/ComplexHeatmap/ 
GitHub | https://github.com/jokergoo/ComplexHeatmap
文档 | https://jokergoo.github.io/ComplexHeatmap-reference/book/
论文 | Zuguang Gu, [Complex heatmap visualization](https://doi.org/10.1002/imt2.43). _iMeta_ 2022. <br>Zuguang Gu, et al., [Complex heatmaps reveal patterns and correlations in multidimensional genomic data](https://doi.org/10.1093/bioinformatics/btw313). _Bioinformatics_ 2016.



</div>

### 例子

首先简单生成一个随机矩阵。


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
mat = mat[sample(nr, nr), sample(nc, nc)] # random shuffle rows and columns
rownames(mat) = paste0("row", seq_len(nr))
colnames(mat) = paste0("column", seq_len(nc))
```

直接绘制相应的热图：


``` r
library(ComplexHeatmap)
Heatmap(mat)
```

<img src="/software/ComplexHeatmap_files/figure-html/unnamed-chunk-3-1.png" width="768" />


对行和列进行切分：


``` r
Heatmap(mat, name = "mat", 
    row_split = rep(c("A", "B"), 9), column_split = rep(c("C", "D"), 12))
```

<img src="/software/ComplexHeatmap_files/figure-html/unnamed-chunk-4-1.png" width="768" />

加入热图注释：


``` r
set.seed(123)
mat = matrix(rnorm(100), 10)
rownames(mat) = paste0("R", 1:10)
colnames(mat) = paste0("C", 1:10)
column_ha = HeatmapAnnotation(foo1 = runif(10), bar1 = anno_barplot(runif(10)))
row_ha = rowAnnotation(foo2 = runif(10), bar2 = anno_barplot(runif(10)))
Heatmap(mat, name = "mat", top_annotation = column_ha, right_annotation = row_ha)
```

<img src="/software/ComplexHeatmap_files/figure-html/unnamed-chunk-5-1.png" width="768" />


拼接多个热图：


``` r
set.seed(123)
mat1 = matrix(rnorm(80, 2), 8, 10)
mat1 = rbind(mat1, matrix(rnorm(40, -2), 4, 10))
rownames(mat1) = paste0("R", 1:12)
colnames(mat1) = paste0("C", 1:10)

mat2 = matrix(runif(60, max = 3, min = 1), 6, 10)
mat2 = rbind(mat2, matrix(runif(60, max = 2, min = 0), 6, 10))
rownames(mat2) = paste0("R", 1:12)
colnames(mat2) = paste0("C", 1:10)

le = sample(letters[1:3], 12, replace = TRUE)
names(le) = paste0("R", 1:12)

ind = sample(12, 12)
mat1 = mat1[ind, ]
mat2 = mat2[ind, ]
le = le[ind]

ht1 = Heatmap(mat1, name = "rnorm")
ht2 = Heatmap(mat2, name = "runif")
ht3 = Heatmap(le, name = "letters")

ht1 + ht2 + ht3
```

<img src="/software/ComplexHeatmap_files/figure-html/unnamed-chunk-6-1.png" width="768" />

<script>
$( function() {
	$("table thead").css("display", "none");
} );
</script>
