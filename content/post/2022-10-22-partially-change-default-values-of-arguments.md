---
title: "Partially change default values of arguments"
date: 2022-10-22
author: Zuguang Gu
---



This is the problem I have. For example, in the `Heatmap()` function in the **ComplexHeatmap** package, one of its argument `row_title_gp` has a default value `gpar(fontsize = 13.2)`:

```r
Heatmap = function(..., row_title_gp = gpar(fontsize = 13.2), ...) {
    ...
}
```

Here `row_title_gp` controls the graphics parameters for the row title and it accepts a list of other parameters, such as `col` and `fontfamily`.
Now the problem is when users set `row_title_gp` with other parameters, e.g. to set the color of text, they must also set `fontsize` with its default value, 
even though when they only want to set the color. If they do not set `fontsize`, it will not use the default value of 13.2, while it will use the "global default" which is 12 (try `get.gpar("fontsize")`).

```r
Heatmap(..., row_title_gp = gpar(fontsize = 13.2,  col = "red"))
```

This is tedious and user-unfriendly. 

The good thing is, in the function arguments, explictely coding as `row_title_gp = gpar(fontsize = 13.2)` helps users to know that a specific default is set
to the argument `row_title_gp` which is not the system-default one. But the bad thing is, users might forget to set `fontsize` at the same time if they set other parameters.

Now the question is: can the default paramters which are not modified by users be automatically saved? In the prevous example, when we set `Heatmap(..., row_title_gp = gpar(col = "red"))`, 
can `row_title_gp` still use `fontsize = 13.2`?

One widely-used solution is to write a "control" function which controls the default parameters. For example, in the `Mclust()` function from the **mclust** package:


```r
Mclust = function (..., control = emControl(), ...) {
    ...
}
```

There is a `emControl()` function which takes care of the default values.


``` r
library(mclust)
emControl()
```

```
## $eps
## [1] 2.220446e-16
## 
## $tol
## [1] 1.000000e-05 1.490116e-08
## 
## $itmax
## [1] 2147483647 2147483647
## 
## $equalPro
## [1] FALSE
```

And if only change one parameter, default values for other parameters are still used:


``` r
emControl(eps = 1e-10)
```

```
## $eps
## [1] 1e-10
## 
## $tol
## [1] 1.000000e-05 1.490116e-08
## 
## $itmax
## [1] 2147483647 2147483647
## 
## $equalPro
## [1] FALSE
```

Similarly, in **ComplexHeatmap**, to control the graphics parameters for axes, there is also a "control-like" function `default_axis_param()` which takes care of
the default graphics parameters for axes.


Writing a "control" or "default_param" function is very helpful when the default parameter list is long. The drawback is also obvous. Users neeed to execute the "control"
functions or go to the documentations to see the exact default values.

Now my question is, if the default parameters are still hard coded in the argument of the function, can we still keep the default parameters if they are not specified by users?

The solution is not difficult. If default parameters are coded in the argument, just extract them. Let's take the argument `row_title_gp` in `Heatmap()` as an example.


**Step 1:** Get the new value of `row_title_gp` which is specified by users.

```r
Heatmap = function(..., row_title_gp = gpar(fontsize = 13.2), ...) {
    new = row_title_gp
    ...
}
```

**Step 2:** Get the default value of `row_title_gp` which is coded in the function definition.

This is a little bit tricky. If users have specified `row_title_gp`, its the default value is overwritten and not seeable in `Heatmap()`. Nevertheless,
we can use `sys.function()` to get the function that was called by users (which is `Heatmap()`), next with the `formals` functions
to obtain the argument lists, and finally evaluate the argument (with `eval()`) to obtain the default value of `row_title_gp`.

```r
Heatmap = function(..., row_title_gp = gpar(fontsize = 13.2), ...) {
    new = row_title_gp
    fml = formals(sys.function(sys.parent(1)))
    default = eval(fml[["row_title_gp"]])
    ...
}
```

**Step 3:** Merge the new value and default value.

The new code is very straightforward.

```r
Heatmap = function(..., row_title_gp = gpar(fontsize = 13.2), ...) {
    new = row_title_gp
    fml = formals(sys.function(sys.parent(1)))
    default = eval(fml[["row_title_gp"]])

    dnm = setdiff(names(default), names(new))
    if(length(dnm) > 0) {
        for(n in dnm) lt[[n]] = default[[n]]
    }
    row_title_gp = new
    ...
}
```

Next we want to make this functionality more general. The following utility function `mark_default()` can be used
inside any function which "marks" arguments to automatically reuse the default parameters.


``` r
mark_default = function(arg) {
    e = parent.frame()
    new = get(arg, envir = e)
    fml = formals(sys.function(sys.parent(1)))
    default = eval(fml[[arg]])

    lt = new
    dnm = setdiff(names(default), names(new))
    if(length(dnm) > 0) {
        for(n in dnm) lt[[n]] = default[[n]]
    }

    assign(arg, lt, envir = e)
    invisible(lt)
}
```

Let me show you some simple experiments of `mark_default()`. 

In the first experiment, there are two default parameters for `gp` which are `col` and `lty`.
As you can see, if only `col` is set, `lty` is lost.


``` r
library(grid)
draw_sth = function(gp = gpar(col = "red", lty = 2)) {
    print(gp)
}
draw_sth(gp = gpar(col = "black"))
```

```
## $col
## [1] "black"
```


Next, we simply add `mark_default()` inside `draw_sth()` and mark the argument `gp`. Now the default `gpar(col = "red", lty = 2)`
can be reused.


``` r
draw_sth = function(gp = gpar(col = "red", lty = 2)) {
    mark_default("gp")
    print(gp)
}
draw_sth(gp = gpar(col = "black"))
```

```
## $col
## [1] "black"
## 
## $lty
## [1] 2
```

``` r
draw_sth(gp = gpar(lwd = 3))
```

```
## $lwd
## [1] 3
## 
## $col
## [1] "red"
## 
## $lty
## [1] 2
```


<!-- 
f = function(x, y = gpar(a = 1, b = 2)) {
    mark_default("y")
    
    print(y)
    y
}

mark_default = function(arg, merge_fun = merge_fun_list) {
    e = parent.frame()
    value = get(arg, envir = e)
    fml = formals(sys.function(sys.parent(1)))
    oe = try(dft <- eval(fml[[arg]]), silent = TRUE)
    if(inherits(oe, "try-error")) {
        if(grepl("argument is missing, with no default", oe)) {
            stop("Argument '", arg, "' has no default.")
        } else {
            stop(oe)
        }
    }

    lt = merge_fun(dft, value)
    assign(arg, lt, envir = e)
    invisible(lt)
}

merge_fun_list = function(default, new) {
    lt = new
    dnm = setdiff(names(default), names(new))
    if(length(dnm) > 0) {
        for(n in dnm) lt[[n]] = default[[n]]
    }
    lt
}
 -->
