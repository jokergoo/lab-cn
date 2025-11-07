---
title: spiralize
---




[阿基米德螺线](https://en.wikipedia.org/wiki/Archimedean_spiral)（Archimedean spiral）可视化。

### 基本信息

<div id="soft-info">

软件包 | 链接 
:------ | :----------
编程语言 | R
CRAN | https://cran.r-project.org/package=spiralize
GitHub | https://github.com/jokergoo/spiralize
文档 | https://jokergoo.github.io/spiralize/
论文 | Zuguang Gu, et al., [spiralize: an R package for visualizing data on spirals](https://doi.org/10.1093/bioinformatics/btab778). _Bioinformatics_ 2022.


</div>

### 例子

全球气温在近20年间的变化


``` r
library(spiralize)
df = readRDS(system.file("extdata", "global_temperature.rds", package = "spiralize"))
df = df[df$Source == "GCAG", ]

spiral_initialize_by_time(xlim = range(df$Date), unit_on_axis = "months", period = "year",
    period_per_loop = 20, polar_lines_by = 360/20, vp_param = list(x = unit(0, "npc"), just = "left"))
spiral_track()
lt = spiral_horizon(df$Date, df$Mean, use_bar = TRUE)

spiral_text("1880-01-01", 0.5, "1880", gp = gpar(fontsize = 8))
spiral_text("1900-01-01", 0.5, "1900", gp = gpar(fontsize = 8))
spiral_text("1920-01-01", 0.5, "1920", gp = gpar(fontsize = 8))
spiral_text("1940-01-01", 0.5, "1940", gp = gpar(fontsize = 8))
spiral_text("1960-01-01", 0.5, "1960", gp = gpar(fontsize = 8))
spiral_text("1980-01-01", 0.5, "1980", gp = gpar(fontsize = 8))
spiral_text("2000-01-01", 0.5, "2000", gp = gpar(fontsize = 8))
```

<img src="/software/spiralize_files/figure-html/unnamed-chunk-2-1.png" width="768" />


<script>
$( function() {
    $("table thead").css("display", "none");
} );
</script>
