---
title: simona
---




生物本体论分析工具箱。

### 基本信息

<div id="soft-info">

软件包 | 链接 
:------ | :----------
编程语言 | R, C++
Bioconductor | https://bioconductor.org/packages/simona/ 
GitHub | https://github.com/jokergoo/simona
文档 | https://jokergoo.github.io/simona/
论文 | Zuguang Gu, [simona: a comprehensive R package for semantic similarity analysis on bio-ontologies](https://doi.org/10.1186/s12864-024-10759-4). _BMC genomics_ 2024.


</div>

### 例子


``` r
library(simona)
dag = create_ontology_DAG_from_GO_db("BP", org_db = "org.Hs.eg.db")
dag
```

```
## An ontology_DAG object:
##   Source: GO BP / GO.db package 3.20.0 
##   26552 terms / 51745 relations
##   Root: GO:0008150 
##   Terms: GO:0000001, GO:0000002, GO:0000011, GO:0000012, ...
##   Max depth: 18 
##   Avg number of parents: 1.95
##   Avg number of children: 1.83
##   Aspect ratio: 343.15:1 (based on the longest distance from root)
##                 756.89:1 (based on the shortest distance from root)
##   Relations: is_a, part_of
##   Annotations: 18986 items
##                291, 1890, 4205, 4358, ...
## 
## With the following columns in the metadata data frame:
##   id, name, definition
```


<script>
$( function() {
    $("table thead").css("display", "none");
} );
</script>
