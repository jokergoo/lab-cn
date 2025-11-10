---
title: "Dynamic graphical object in grid, part 2"
date: 2023-09-25
author: Zuguang Gu
---



I have introduced how to define a dynamic grob by setting its `makeContext()` method. In this post,
I will demonstrate two other ways, which are either identical to the previous method, or very similar to it.

Again, the plotting task: drawing two circles at `(1, 0)` and `(-1, 0)` with both radius of 1, and 
we want the two circles fill the plotting region as much as possible no matter how the graphical device is resized.


```r
theta = seq(0, 2*pi, length = 50)

x1 = cos(theta) + 1
y1 = sin(theta)

x2 = cos(theta) - 1
y2 = sin(theta)
```


In the first method, we use the `grid.delay()` function, which accepts an
expression and it will be evaluated when the image is redrawn (e.g. by
resizing the graphical device).

This method is idential to the use of `makeContext()`/`makeContent()` hook functions.
`grid.delay()`/`delayGrob()` generates a grob in the `delayGrob` class, and the
corresponding S3 method `grid:::makeContent.delayedgrob()` evaluates the
expression.

```r
library(grid)
grid.newpage()

vp = viewport(xscale = c(-2, 2), yscale = c(-1, 1))
x = grobTree(linesGrob(x1, y1, default.units = "native"), 
             linesGrob(x2, y2, default.units = "native"),
             vp = vp)

grid.delay({
    vp_width = convertWidth(x$vp$width, "in", valueOnly = TRUE)
    vp_height = convertHeight(x$vp$height, "in", valueOnly = TRUE)

    if(vp_width > 2*vp_height) {
        x$vp$width = unit(2*vp_height, "in")
        x$vp$height = unit(vp_height, "in")
    } else {
        x$vp$width = unit(vp_width, "in")
        x$vp$height = unit(vp_width/2, "in")
    }
    x
}, list())
```

Besides `makeContext()`/`makeContent()` that define what to do when drawing
the graphical object, another set of hook functions (the old style)
`preDrawDetails()`/`drawDetails()`/`postDrawDetails()` can also be used. Similar to `grid.delay()`,
`grid.record()` is a helper function which internally calls the three hook functions. The first argument
for `grid.record()` is also an expression. The difference is, in the expression for `grid.delay()`, it must
return a grob object, while in `grid.record()` you can put `grid.*()` plotting functions there.

```r
grid.record({
    pushViewport(viewport())
    vp = current.viewport()
    vp_width = convertWidth(vp$width, "in", valueOnly = TRUE)
    vp_height = convertHeight(vp$height, "in", valueOnly = TRUE)

    if(vp_width > 2*vp_height) {
        w = unit(2*vp_height, "in")
        h = unit(vp_height, "in")
    } else {
        w = unit(vp_width, "in")
        h = unit(vp_width/2, "in")
    }
    pushViewport(viewport(xscale = c(-2, 2), yscale = c(-1, 1), width = w, height = h))
    grid.lines(x1, y1, default.units = "native")
    grid.lines(x2, y2, default.units = "native")
    upViewport()
}, list())
```
