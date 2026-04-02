---
title: "Multiple-group Chord diagram"
date: 2020-06-08
author: Zuguang Gu
---



From verion 0.4.10 of the **circlize** package, there is a new `group`
argument in `chordDiagram()` function which is very convenient for making
multiple-group Chord diagrams.

I first generate a random matrix where there are three groups (`A`, `B`, and `C`).
Note this new functionality works the same for the input as a data frame.


```r
library(circlize)
mat1 = matrix(rnorm(25), nrow = 5)
rownames(mat1) = paste0("A", 1:5)
colnames(mat1) = paste0("B", 1:5)

mat2 = matrix(rnorm(25), nrow = 5)
rownames(mat2) = paste0("A", 1:5)
colnames(mat2) = paste0("C", 1:5)

mat3 = matrix(rnorm(25), nrow = 5)
rownames(mat3) = paste0("B", 1:5)
colnames(mat3) = paste0("C", 1:5)

mat = matrix(0, nrow = 10, ncol = 10)
rownames(mat) = c(rownames(mat2), rownames(mat3))
colnames(mat) = c(colnames(mat1), colnames(mat2))
mat[rownames(mat1), colnames(mat1)] = mat1
mat[rownames(mat2), colnames(mat2)] = mat2
mat[rownames(mat3), colnames(mat3)] = mat3
mat
```

```
##        B1    B2    B3    B4    B5      C1     C2    C3    C4    C5
## A1 -0.983  0.96 -1.23 -0.29  0.33  0.8005  1.165  0.16  1.18 -1.51
## A2  0.027 -0.50  1.72  0.22 -0.68  0.7703  0.404 -0.91  1.45  0.07
## A3  1.351 -0.79  0.56 -0.44 -0.73  1.2659 -0.422  0.94 -0.55 -0.87
## A4 -0.387  0.14 -1.08 -0.89 -0.70  0.1082  0.709 -1.39 -0.81 -1.09
## A5  0.195 -1.42 -0.97  0.78 -0.77 -0.0082 -0.720 -0.28 -0.89  1.31
## B1  0.000  0.00  0.00  0.00  0.00  0.2846 -0.018  0.35  0.28 -1.80
## B2  0.000  0.00  0.00  0.00  0.00  0.9008 -0.148 -0.36 -0.42  0.75
## B3  0.000  0.00  0.00  0.00  0.00  0.7906  0.781  0.52  0.12  0.28
## B4  0.000  0.00  0.00  0.00  0.00  0.1782  1.093  0.24 -0.17  0.81
## B5  0.000  0.00  0.00  0.00  0.00  0.3083  0.591 -0.60  0.47  0.53
```

The main thing is to create "a grouping variable". The variable contains
the group labels and the sector names are used as the names in the vector.



```r
nm = unique(unlist(dimnames(mat)))
group = structure(gsub("\\d", "", nm), names = nm)
group
```

```
##  A1  A2  A3  A4  A5  B1  B2  B3  B4  B5  C1  C2  C3  C4  C5 
## "A" "A" "A" "A" "A" "B" "B" "B" "B" "B" "C" "C" "C" "C" "C"
```

Assign `group` variable to the `group` argument:


```r
grid.col = structure(c(rep(2, 5), rep(3, 5), rep(4, 5)),
                names = c(paste0("A", 1:5), paste0("B", 1:5), paste0("C", 1:5)))
chordDiagram(mat, group = group, grid.col = grid.col)
```

<img src="/lab-cn/post/2020-06-08-multiple-group-chord-diagram_files/figure-html/unnamed-chunk-4-1.png" width="768" style="display: block; margin: auto;" />

```r
circos.clear()
```

We can try another grouping:


```r
group = structure(gsub("^\\w", "", nm), names = nm)
group
```

```
##  A1  A2  A3  A4  A5  B1  B2  B3  B4  B5  C1  C2  C3  C4  C5 
## "1" "2" "3" "4" "5" "1" "2" "3" "4" "5" "1" "2" "3" "4" "5"
```

```r
chordDiagram(mat, group = group, grid.col = grid.col)
```

<img src="/lab-cn/post/2020-06-08-multiple-group-chord-diagram_files/figure-html/unnamed-chunk-5-1.png" width="768" style="display: block; margin: auto;" />

```r
circos.clear()
```

The order of `group` controls the sector orders and if `group` is set as a factor,
the order of levels controls the order of groups.


```r
group = structure(gsub("\\d", "", nm), names = nm)
group = factor(group[sample(length(group), length(group))], levels = c("C", "A", "B"))
group
```

```
## C2 B3 B1 A2 A1 C5 B5 A3 B4 A5 C3 C4 A4 B2 C1 
##  C  B  B  A  A  C  B  A  B  A  C  C  A  B  C 
## Levels: C A B
```

```r
chordDiagram(mat, group = group, grid.col = grid.col)
```

<img src="/lab-cn/post/2020-06-08-multiple-group-chord-diagram_files/figure-html/unnamed-chunk-6-1.png" width="768" style="display: block; margin: auto;" />

```r
circos.clear()
```

The gap between groups is controlled by `big.gap` argument and the gap between
sectors is controlled by `small.gap` argument.


```r
group = structure(gsub("\\d", "", nm), names = nm)
chordDiagram(mat, group = group, grid.col = grid.col, big.gap = 20, small.gap = 5)
```

<img src="/lab-cn/post/2020-06-08-multiple-group-chord-diagram_files/figure-html/unnamed-chunk-7-1.png" width="768" style="display: block; margin: auto;" />

```r
circos.clear()
```

As a normal Chord diagram, the labels and other tracks can be manually adjusted:


```r
group = structure(gsub("\\d", "", nm), names = nm)
chordDiagram(mat, group = group, grid.col = grid.col,
	annotationTrack = c("grid", "axis"),
    preAllocateTracks = list(
        track.height = mm_h(4),
        track.margin = c(mm_h(4), 0)
))
circos.track(track.index = 2, panel.fun = function(x, y) {
    sector.index = get.cell.meta.data("sector.index")
    xlim = get.cell.meta.data("xlim")
    ylim = get.cell.meta.data("ylim")
    circos.text(mean(xlim), mean(ylim), sector.index, cex = 0.6, niceFacing = TRUE)
}, bg.border = NA)

highlight.sector(rownames(mat1), track.index = 1, col = "red", 
    text = "A", cex = 0.8, text.col = "white", niceFacing = TRUE)
highlight.sector(colnames(mat1), track.index = 1, col = "green", 
    text = "B", cex = 0.8, text.col = "white", niceFacing = TRUE)
highlight.sector(colnames(mat2), track.index = 1, col = "blue", 
    text = "C", cex = 0.8, text.col = "white", niceFacing = TRUE)
```

<img src="/lab-cn/post/2020-06-08-multiple-group-chord-diagram_files/figure-html/unnamed-chunk-8-1.png" width="768" style="display: block; margin: auto;" />

```r
circos.clear()
```
