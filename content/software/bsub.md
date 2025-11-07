---
title: bsub
---




发送 R 代码至 LSF 集群。

### 基本信息

<div id="soft-info">

软件包 | 链接 
:------ | :----------
编程语言 | R
CRAN | https://CRAN.R-project.org/package=bsub
GitHub | https://github.com/jokergoo/bsub
文档 | https://jokergoo.github.io/bsub/

</div>

### 例子

发送一段 R 代码至 LSF 集群：

```r
library(bsub)

# R code
bsub_chunk(name = "example", memory = 10, hours = 10, cores = 4, 
{
    fit = NMF::nmf(...)
    saveRDS(fit, file = "/path/of/fit.rds")
})
```


<script>
$( function() {
    $("table thead").css("display", "none");
} );
</script>

