---
title: GlobalOptions
---




设置全局变量。

### 基本信息

<div id="soft-info">

软件包 | 链接 
:------ | :----------
编程语言 | R
CRAN | https://cran.r-project.org/package=GlobalOptions
GitHub | https://github.com/jokergoo/GlobalOptions
文档 | https://jokergoo.github.io/GlobalOptions/

</div>

### 例子


``` r
library(GlobalOptions)
opt = set_opt(
    "a" = 1,
    "b" = "text"
)
```

然后可以通过下面方式设置或者获取参数值。

```r
opt()
opt("a")
opt$a
opt[["a"]]
opt(c("a", "b"))
opt("a", "b")
opt("a" = 2)
opt$a = 2
opt("a" = 2, "b" = "new_text")
```



<script>
$( function() {
    $("table thead").css("display", "none");
} );
</script>
