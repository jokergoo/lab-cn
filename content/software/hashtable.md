---
title: hashtable
---



哈希表和哈希集

### 基本信息

<div id="soft-info">

软件包 | 链接 
:------ | :----------
编程语言 | R
CRAN | https://cran.r-project.org/package=hashtable
GitHub | https://github.com/jokergoo/hashtable
文档 | https://jokergoo.github.io/hashtable/

</div>


### 例子

生成哈希表：


``` r
library(hashtable)
h = hash_table(letters, 1:26)
h
```

```
## A hash table [hash_unordered_map] with 26 key-value (integer) pairs
##   z => 26
##   y => 25
##   x => 24
##   ......
##   b => 2
##   k => 11
##   a => 1
```

获得全部的键：


``` r
hash_keys(h)
```

```
##  [1] "z" "y" "x" "v" "u" "t" "q" "p" "o" "n" "l" "j" "s" "i" "h" "g" "w" "f" "e"
## [20] "d" "m" "c" "r" "b" "k" "a"
```

获得全部的值：


``` r
hash_values(h)
```

```
##  [1] 26 25 24 22 21 20 17 16 15 14 12 10 19  9  8  7 23  6  5  4 13  3 18  2 11
## [26]  1
```

获得一部分键值：


``` r
hash_values(h, c("a", "b", "c"))
```

```
## [1] 1 2 3
```

使用下标 `$`、`[[` 或者 `[` 获取单个键值：


``` r
h$a
```

```
## [1] 1
```

``` r
h[["a"]]
```

```
## [1] 1
```

``` r
h[c("a", "b")]
```

```
## [1] 1 2
```

检查键是否存在于哈希表中：


``` r
hash_exists(h, c("a", "b", "foo"))
```

```
## [1]  TRUE  TRUE FALSE
```

删除键值对：


``` r
hash_delete(h, c("a", "b"))
hash_exists(h, c("a", "b"))
```

```
## [1] FALSE FALSE
```

插入新的键值对，或者修改已存在的键值对：


``` r
hash_insert(h, "c", 100L); h$c
```

```
## [1] 100
```

``` r
hash_insert(h, "c", -1L); h$c
```

```
## [1] -1
```

``` r
hash_insert(h, "foo", 0L); h$foo
```

```
## [1] 0
```

使用 `$<-`，`[[<-` 或 `[<-`进行插入或者删除键值对：


``` r
h$a = 20L; h$a
```

```
## [1] 20
```

``` r
h[["bar"]] = -100L; h$bar
```

```
## [1] -100
```

``` r
h[c("c", "d", "e")] = c(-1L, -2L, -3L); h[c("c", "d", "e")]
```

```
## [1] -1 -2 -3
```



<script>
$( function() {
    $("table thead").css("display", "none");
} );
</script>

