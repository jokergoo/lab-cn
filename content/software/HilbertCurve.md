---
title: HilbertCurve
---




使用[希尔伯特曲线](https://en.wikipedia.org/wiki/Hilbert_curve)（Hilbert Curve）可视化基因组数据。

### 基本信息

<div id="soft-info">

软件包 | 链接 
:------ | :----------
编程语言 | R
Bioconductor | https://bioconductor.org/packages/HilbertCurve/ 
GitHub | https://github.com/jokergoo/HilbertCurve
文档 | https://jokergoo.github.io/HilbertCurve/
论文 | Zuguang Gu, et al., [HilbertCurve: an R/Bioconductor package for high-resolution visualization of genomic data](https://doi.org/10.1093/bioinformatics/btw161). _Bioinformatics_ 2016.


</div>

### 例子

人类染色体1上的基因分布。


``` r
library(GenomicRanges)
library(HilbertCurve)
library(circlize)
load(system.file("extdata", "refseq_chr1.RData", package = "HilbertCurve"))
hc = GenomicHilbertCurve(chr = "chr1", level = 5, reference = TRUE, 
    reference_gp = gpar(lty = 1, col = "grey"), arrow = FALSE)
hc_segments(hc, g, gp = gpar(lwd = 6, col = rand_color(length(g))))
```

<img src="/software/HilbertCurve_files/figure-html/unnamed-chunk-2-1.png" width="768" />


<script>
$( function() {
    $("table thead").css("display", "none");
} );
</script>

