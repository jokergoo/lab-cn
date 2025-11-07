---
title: pkgndep
---




R 包依赖重量（dependency heaviness）分析。

### 基本信息

<div id="soft-info">

软件包 | 链接 
:------ | :----------
编程语言 | R
CRAN | https://cran.r-project.org/package=pkgndep
GitHub | https://github.com/jokergoo/pkgndep
文档 | https://jokergoo.github.io/pkgndep/
论文 | Zuguang Gu, [On the dependency heaviness of CRAN/Bioconductor ecosystem](https://doi.org/10.1016/j.jss.2023.111610). _JSS_ 2023. <br> Zuguang Gu, et al., [Pkgndep: a tool for analyzing dependency heaviness of R packages](https://doi.org/10.1093/bioinformatics/btac449). _Bioinformatics_ 2022.


</div>


### 例子


``` r
library(pkgndep)
x = pkgndep("circlize")
```

```
## retrieve package database from CRAN/Bioconductor (3.19)...
##   - 26125 remote packages on CRAN/Bioconductor.
##   - 485 packages installed locally.
## prepare dependency table...
## prepare reverse dependency table...
```

``` r
x
```

```
## 'circlize', version 0.4.16
## - 9 packages are required for installing 'circlize'.
## - 94 packages are required if installing packages listed in all fields in DESCRIPTION.
```

``` r
heaviness(x)
```

```
##       graphics      grDevices          utils           grid          stats 
##              0              0              0              1              0 
##          shape        methods  GlobalOptions     colorspace            png 
##              1              0              1              1              1 
##         bezier       gridBase       markdown          knitr           covr 
##              1              1              4              6             16 
## ComplexHeatmap      rmarkdown     dendextend 
##             22             27             32
```

``` r
plot(x, fix = FALSE)
```

<img src="/software/pkgndep_files/figure-html/unnamed-chunk-2-1.png" width="95%" />


<script>
$( function() {
    $("table thead").css("display", "none");
} );
</script>

