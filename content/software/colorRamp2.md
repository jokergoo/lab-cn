---
title: CePa
---




颜色映射。

### 基本信息

<div id="soft-info">

软件包 | 链接 
:------ | :----------
编程语言 | R
CRAN | https://cran.r-project.org/package=colorRamp2
GitHub | https://github.com/jokergoo/colorRamp2
文档 | https://cran.r-project.org/package=colorRamp2

</div>


### 例子


```r
library(colorRamp2)

col_fun = colorRamp2(c(0, 0.5, 1), c("blue", "white", "red"))
col_fun(seq(0, 1, length = 20))
```

```
##  [1] "#0000FFFF" "#522CFFFF" "#7448FFFF" "#8E61FFFF" "#A479FFFF" "#B891FFFF"
##  [7] "#C9A9FFFF" "#DAC1FFFF" "#E9DAFFFF" "#F8F3FFFF" "#FFF5F1FF" "#FFE1D6FF"
## [13] "#FFCDBBFF" "#FFB8A1FF" "#FFA388FF" "#FF8E6EFF" "#FF7756FF" "#FF5E3DFF"
## [19] "#FF3F23FF" "#FF0000FF"
```

```r
plot(NULL, xlim = c(0, 1), ylim = c(0, 1))
x = seq(0, 1, length = 20)
y = rep(0.5, 20)
points(x, y, pch = 16, col = col_fun(x), cex = 2)
```

<img src="/lab-cn/software/colorRamp2_files/figure-html/unnamed-chunk-2-1.png" width="768" />

从颜色还原到数值：


```r
x1 = runif(10)
col = col_fun(x1)
x2 = col2value(col, col_fun = col_fun)
cbind(origin = x1, recovered = x2)
```

```
##          origin recovered
##  [1,] 0.7290329 0.7150409
##  [2,] 0.5450717 0.5400161
##  [3,] 0.6891761 0.6746386
##  [4,] 0.5865087 0.5774311
##  [5,] 0.9823631 0.9814281
##  [6,] 0.3250850 0.3275266
##  [7,] 0.9888472 0.9882958
##  [8,] 0.4473103 0.4484167
##  [9,] 0.4163542 0.4193188
## [10,] 0.7438175 0.7298636
```


<script>
$( function() {
    $("table thead").css("display", "none");
} );
</script>

