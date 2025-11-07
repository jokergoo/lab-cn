---
title: simplifyEnrichment
---




Gene Ontology富集结果的简化。

### 基本信息

<div id="soft-info">

软件包 | 链接 
:------ | :----------
编程语言 | R
Bioconductor | https://bioconductor.org/packages/simplifyEnrichment/ 
GitHub | https://github.com/jokergoo/simplifyEnrichment
文档 | https://jokergoo.github.io/simplifyEnrichment/
论文 | Zuguang Gu, et al., [simplifyEnrichment: A Bioconductor Package for Clustering and Visualizing Functional Enrichment Results](https://doi.org/10.1016/j.gpb.2022.04.008). _Genomics, Proteomics & Bioinformatics_ 2023.


</div>

### 例子


``` r
library(simplifyEnrichment)
set.seed(888)
go_id = random_GO(500)
simplifyGO(go_id)
```

<img src="/software/simplifyEnrichment_files/figure-html/unnamed-chunk-2-1.png" width="816" />


<script>
$( function() {
    $("table thead").css("display", "none");
} );
</script>
