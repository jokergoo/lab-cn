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


``` r
library(rGREAT)
gr = randomRegions(nr = 1000, genome = "hg19")
res = great(gr, "MSigDB:H", "TxDb.Hsapiens.UCSC.hg19.knownGene")
tb = getEnrichmentTable(res)
head(tb)
```

```
##                               id genome_fraction observed_region_hits
## 1     HALLMARK_PROTEIN_SECRETION     0.009545438                   15
## 2 HALLMARK_FATTY_ACID_METABOLISM     0.011573276                   17
## 3      HALLMARK_MTORC1_SIGNALING     0.016315292                   21
## 4 HALLMARK_XENOBIOTIC_METABOLISM     0.013694524                   17
## 5          HALLMARK_ADIPOGENESIS     0.014848629                   18
## 6           HALLMARK_COAGULATION     0.010231163                   12
##   fold_enrichment    p_value  p_adjust mean_tss_dist observed_gene_hits
## 1        1.691530 0.03660128 0.9728496        169434                 15
## 2        1.581164 0.04632617 0.9728496        167984                 14
## 3        1.385507 0.08795227 0.9906854        285079                 18
## 4        1.336246 0.14366715 0.9906854        220374                 13
## 5        1.304880 0.15683279 0.9906854        262996                 16
## 6        1.262527 0.24769378 0.9906854        206323                 10
##   gene_set_size fold_enrichment_hyper p_value_hyper p_adjust_hyper
## 1            95             2.0422886   0.006090193      0.2557881
## 2           157             1.1533944   0.328845663      0.9245430
## 3           200             1.1641045   0.284968109      0.9245430
## 4           197             0.8535453   0.762694041      0.9880034
## 5           200             1.0347596   0.481277540      0.9625551
## 6           136             0.9510658   0.612429803      0.9880034
```


<script>
$( function() {
    $("table thead").css("display", "none");
} );
</script>
