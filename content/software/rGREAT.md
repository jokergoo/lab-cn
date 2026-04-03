---
title: rGREAT
---




基于基因组区间的功能富集分析。

### 基本信息

<div id="soft-info">

软件包 | 链接 
:------ | :----------
编程语言 | R, C++
Bioconductor | https://bioconductor.org/packages/rGREAT/ 
GitHub | https://github.com/jokergoo/rGREAT
文档 | https://jokergoo.github.io/rGREAT/
论文 | Zuguang Gu, et al., [rGREAT: an R/bioconductor package for functional enrichment on genomic regions](https://doi.org/10.1093/bioinformatics/btac745). _Bioinformatics_ 2023.



</div>

### 例子


```r
library(rGREAT)
gr = randomRegions(nr = 1000, genome = "hg19")
res = great(gr, "MSigDB:H", "TxDb.Hsapiens.UCSC.hg19.knownGene")
tb = getEnrichmentTable(res)
head(tb)
```

```
##                                 id genome_fraction observed_region_hits
## 1              HALLMARK_GLYCOLYSIS      0.01939528                   33
## 2                 HALLMARK_HYPOXIA      0.02259297                   31
## 3       HALLMARK_KRAS_SIGNALING_UP      0.02807810                   35
## 4    HALLMARK_BILE_ACID_METABOLISM      0.01007710                   15
## 5 HALLMARK_IL6_JAK_STAT3_SIGNALING      0.00588037                    9
## 6  HALLMARK_ESTROGEN_RESPONSE_LATE      0.01976179                   24
##   fold_enrichment      p_value   p_adjust mean_tss_dist observed_gene_hits
## 1        1.849397 0.0007344439 0.03231553        183608                 30
## 2        1.491422 0.0201847210 0.44406386        258881                 26
## 3        1.354917 0.0467663453 0.55023294        262881                 30
## 4        1.617960 0.0500211761 0.55023294        133541                 13
## 5        1.663604 0.0975349984 0.74772933        134220                  9
## 6        1.320070 0.1070182007 0.74772933        214394                 20
##   gene_set_size fold_enrichment_hyper p_value_hyper p_adjust_hyper
## 1           199              2.016169  0.0001799407     0.00263913
## 2           199              1.747346  0.0038037314     0.04184105
## 3           197              2.036637  0.0001499209     0.00263913
## 4           112              1.552330  0.0748775119     0.34746615
## 5            81              1.485991  0.1501078147     0.47176742
## 6           198              1.350901  0.1043818323     0.35329236
```


<script>
$( function() {
    $("table thead").css("display", "none");
} );
</script>
