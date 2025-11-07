---
title: sfcurve
---




`\(n \times n\)` 空间填充曲线

### 基本信息

<div id="soft-info">

软件包 | 链接 
:------ | :----------
编程语言 | R, C++
CRAN | https://cran.r-project.org/package=sfcurve
GitHub | https://github.com/jokergoo/sfcurve
文档 | https://jokergoo.github.io/sfcurve/
论文| Zuguang Gu, [Construction, Transformation and Structures of 2x2 Space-Filling Curves](https://doi.org/10.48550/arXiv.2412.16962). _arXiv_ 2024.


</div>

### 例子

2x2曲线


``` r
library(sfcurve)
p = sfc_2x2("I", "2222", rot = 270)
p
```

```
## An sfc_2x2 object.
##   Increase mode: 2 x 2
##   Level: 4
##   Expansion rule: 2x2 
## 
## A sequence of 256 base patterns.
##   I(270)L(270)L(0)R(90)   I(0)R(0)R(270)L(180)
##   L(270)R(0)R(270)I(180)  R(180)L(90)L(180)I(270)
##   .... other 28 lines ....
##   I(270)L(270)L(0)R(90)   I(0)R(0)R(270)L(180)
##   L(270)R(0)R(270)I(180)  R(180)L(90)L(180)I(270)
## 
## Seed: A sequence of 1 base pattern.
##   I(270)
```

``` r
plot(p)
```

<img src="/software/sfcurve_files/figure-html/unnamed-chunk-2-1.png" width="768" />

3x3 Peano曲线


``` r
p = sfc_3x3_peano("I", "1111")
plot(p)
```

<img src="/software/sfcurve_files/figure-html/unnamed-chunk-3-1.png" width="768" />

以一条初级曲线作为起始的曲线


``` r
p = sfc_seed("LLLILILIILIILIIILIIILIIII")
p2 = sfc_2x2(p, "1111")
plot(p2)
```

<img src="/software/sfcurve_files/figure-html/unnamed-chunk-4-1.png" width="768" />

<script>
$( function() {
    $("table thead").css("display", "none");
} );
</script>
