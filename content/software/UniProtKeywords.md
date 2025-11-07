---
title: UniProtKeywords
---




UniProt 数据库[关键词](https://www.uniprot.org/keywords/)数据。

### 基本信息

<div id="soft-info">

软件包 | 链接 
:------ | :----------
编程语言 | R
Bioconductor | https://bioconductor.org/packages/UniProtKeywords/ 
GitHub | https://github.com/jokergoo/UniProtKeywords
文档 | https://jokergoo.github.io/UniProtKeywords/

</div>

### 例子


``` r
library(UniProtKeywords)
data(kw_terms)
kw_terms[["Cell cycle"]]
```

```
## $Identifier
## [1] "Cell cycle"
## 
## $Accession
## [1] "KW-0131"
## 
## $Description
## [1] "Protein involved in the complex series of events by which the cell duplicates its contents and divides into two. The eukaryotic cell cycle can be divided in four phases termed G1 (first gap period), S (synthesis, phase during which the DNA is replicated), G2 (second gap period) and M (mitosis). The prokaryotic cell cycle typically involves a period of growth followed by DNA replication, partition of chromosomes, formation of septum and division into two similar or identical daughter cells."
## 
## $Gene_ontology
## [1] "GO:0007049; cell cycle"
## 
## $Hierarchy
## [1] "Biological process: Cell cycle"
## 
## $Category
## [1] "Biological process"
```


<script>
$( function() {
    $("table thead").css("display", "none");
} );
</script>

