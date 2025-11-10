---
title: "Arrange links evenly along the sectors"
date: 2020-11-23
author: Zuguang Gu
---



People use `circos.link()` to visualize interactions/relations between sectors.
When one sector has more than one other sectors to interact with, it actually
becomes important of how to arrange links on that sector to make every link readable.

In the following example, I created a random interaction data frame `df`:


``` r
set.seed(123)
sectors = letters[1:20]
df = data.frame(from = sample(sectors, 40, replace = TRUE),
                to   = sample(sectors, 40, replace = TRUE))
df = unique(df)
df = df[df$from != df$to, ]
df
```

```
##    from to
## 1     o  a
## 2     s  f
## 3     n  o
## 4     c  i
## 5     j  o
## 6     r  p
## 7     k  t
## 8     e  f
## 9     t  k
## 10    n  h
## 11    e  g
## 12    s  p
## 13    i  q
## 14    c  r
## 15    h  q
## 16    g  b
## 17    j  d
## 18    i  m
## 19    s  e
## 20    d  s
## 21    n  t
## 22    q  n
## 23    k  c
## 24    g  h
## 25    l  p
## 26    o  l
## 27    j  n
## 28    m  c
## 29    g  n
## 30    i  g
## 31    i  c
## 33    g  e
## 34    f  h
## 35    b  s
## 36    e  j
## 37    h  r
## 38    l  j
## 39    m  l
## 40    r  b
```

I also created the corresponding circular plot with all the sectors. In the
simplest way, we might want to put all the links to the center of every
sector, which looks like follows:


``` r
library(circlize)
circos.initialize(sectors, xlim = c(0, 1))
circos.track(ylim = c(0, 1), panel.fun = function(x, y) {
    circos.text(CELL_META$xcenter, CELL_META$ycenter, CELL_META$sector.index)
})
for(i in seq_len(nrow(df))) {
    s1 = df[i, 1]
    s2 = df[i ,2]
    circos.link(s1, 0.5, s2, 0.5, directional = 1)
}
```

<img src="/lab-cn/post/2020-11-23-arrange-links-evenly-along-the-sectors_files/figure-html/unnamed-chunk-3-1.png" width="768" />

It looks nice, but since all the links, _e.g._ which start from or end in one
sector, are in a same position, it is rather difficult to tell which sector
has more links than the others.

To get rid of such link overlapping, we can assign random shift to every link
in the sector. In the following example, since the `xlim` for all sectors are
fixed in `c(0, 1)`, we use `runif(1)` to assign a random position between 0
and 1.


``` r
circos.initialize(sectors, xlim = c(0, 1))
circos.track(ylim = c(0, 1), panel.fun = function(x, y) {
    circos.text(CELL_META$xcenter, CELL_META$ycenter, CELL_META$sector.index)
})
for(i in seq_len(nrow(df))) {
    s1 = df[i, 1]
    s2 = df[i ,2]
    circos.link(s1, runif(1), s2, runif(1), directional = 1)
}
```

<img src="/lab-cn/post/2020-11-23-arrange-links-evenly-along-the-sectors_files/figure-html/unnamed-chunk-4-1.png" width="768" />

It already looks much nicer, however, since the positions are random, it is 
still not easy to tell which sector has more links because we need effort to 
carefully count the links if they are very close to each other (_e.g._, for sector c,
are there four or five links?).

From **circlize** version 0.4.12.1001, I added a new function
`arrange_links_evenly()` which can arrange the links on the sectors so that
the neighouring distance between links are evenly distributed. It also adjusts
positions of links to make the overall intersection of linkes minimal.
Additionally, it considers directional links, _i.e._, on each sector, the
starting links and the ending links are put into separate groups.


``` r
circos.initialize(sectors, xlim = c(0, 1))
circos.track(ylim = c(0, 1), panel.fun = function(x, y) {
    circos.text(CELL_META$xcenter, CELL_META$ycenter, CELL_META$sector.index)
})

df2 = arrange_links_evenly(df, directional = 1)

for(i in seq_len(nrow(df2))) {
    s1 = df$from[i]
    s2 = df$to[i]
    circos.link(df2[i, "sector1"], df2[i, "pos1"], 
                df2[i, "sector2"], df2[i, "pos2"],
                directional = 1)
}
```

<img src="/lab-cn/post/2020-11-23-arrange-links-evenly-along-the-sectors_files/figure-html/unnamed-chunk-5-1.png" width="768" />

Session info:


``` r
sessionInfo()
```

```
## R version 4.4.2 (2024-10-31)
## Platform: aarch64-apple-darwin20
## Running under: macOS 26.0.1
## 
## Matrix products: default
## BLAS:   /Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/lib/libRblas.0.dylib 
## LAPACK: /Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.0
## 
## locale:
## [1] C.UTF-8/UTF-8/C.UTF-8/C/C.UTF-8/C.UTF-8
## 
## time zone: Europe/Berlin
## tzcode source: internal
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] circlize_0.4.16  GetoptLong_1.0.5 knitr_1.50       colorout_1.3-2  
## 
## loaded via a namespace (and not attached):
##  [1] crayon_1.5.3        cli_3.6.4           rlang_1.1.5        
##  [4] xfun_0.51           jsonlite_1.9.0      rjson_0.2.23       
##  [7] colorspace_2.1-1    htmltools_0.5.8.1   GlobalOptions_0.1.2
## [10] sass_0.4.9          rmarkdown_2.29      grid_4.4.2         
## [13] evaluate_1.0.3      jquerylib_0.1.4     fastmap_1.2.0      
## [16] yaml_2.3.10         lifecycle_1.0.4     bookdown_0.44      
## [19] compiler_4.4.2      blogdown_1.19       digest_0.6.37      
## [22] R6_2.6.1            shape_1.4.6.1       bslib_0.9.0        
## [25] tools_4.4.2         cachem_1.1.0
```

