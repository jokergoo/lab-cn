---
title: "Rasterization in ComplexHeatmap"
date: 2020-06-30
author: Zuguang Gu
---



Guillaume Devailly recently wrote [an
article](https://gdevailly.netlify.app/post/plotting-big-matrices-in-r/) on
image rasterization to efficiently visualize huge matrices in R, as well as
comparing several R functions that support image rasterization. In this post, I
discusse the support for raster image in **ComplexHeatmap** in more details.

When we produce so-called "high quality figures", normally we save the figures
as [vector graphics](https://en.wikipedia.org/wiki/Vector_graphics) in the
format of _e.g._ pdf or svg. The vector graphics basically store details of
every single graphic elements, thus, if a heatmap made from a very huge matrix is
saved as vector graphics, the final file size would be very big. On the other
hand, when visualizing _e.g._ the pdf file on the screen, multiple grids from
the heatmap actually only map to single pixels, due to the limited size of the
screen. Thus, there need some ways to effectively reduce the original image and
it is not necessary to store the complete matrix for the heatmap.

Rasterization is a way to covnert the vector graphics into a matrix of colors.
In this case, an image is represented as a matrix of RGB values, which is
called a [raster image](https://en.wikipedia.org/wiki/Raster_graphics). If the
heatmap is larger than the size of the screen or the pixels that current
graphics devices can support, we can convert the heatmap and reduce it, by
saving it in a form of a color matrix with the same dimension as the device.

Let's assume a matrix has `\(n_r\)` rows and `\(n_c\)` columns. When it is drawn on a
certain graphics device, _e.g._ an on-screen device, the corresponding heatmap
body has `\(p_r\)` and `\(p_c\)` pixels (or points) for the rows and columns,
respectively. When `\(n_r > p_r\)` and/or `\(n_c > p_c\)`, multiple values in the
matrix are mapped to single pixels. Here we need to reduce `\(n_r\)` and/or `\(n_c\)`
if they are larger than `\(p_r\)` and/or `\(p_c\)`.

To make it simple, I assume both `\(n_r > p_r\)` and `\(n_c > p_c\)`. The
principle is basically the same for the scenarios where only one dimension of
the matrix is larger than the device.

In **ComplexHeatmap** version 2.5.4, there are following implementations for
image rasterization. Note the implementation is a little bit different from
the earlier versions (of course, better than the earlier versions).

1. First an image
   (in a specific format, _e.g._ png or jpeg) with $(p_r \cdot a) \times (p_c
   \cdot a)$ resolution is saved into a temporary file where `\(a\)` is a zooming
   factor, next it is read back as a `raster` object by _e.g._
   `png::readPNG()` or `jpeg::readJPEG()`, and later the raster object is
   filled into the heatmap body by `grid::grid.raster()`. So we can say, the 
   rasterization is done by the raster image devices (`png()` or `jpeg()`).

   This type of rasterization is automatically turned on (**if magick package is
   not installed**) when the number of rows or columns exceeds 2000 (You will
   see a message. It won't happen silently). It can also be manually
   controlled by setting the `use_raster` argument:


``` r
Heatmap(..., use_raster = TRUE)
```

   The zooming factor is controlled by `raster_quality` argument. A value larger
   than 1 generates files with larger size.


``` r
Heatmap(..., use_raster = TRUE, raster_quality = 5)
```

2. Simply reduce the original matrix to `\(p_r \times p_c\)` where now each single values can
   correspond to single pixels. In the reduction, a user-defined function is applied to summarize
   the sub-matrices.

   This can be set by `raster_resize_mat` argument:


``` r
# the default summary function is mean()
Heatmap(..., use_raster = TRUE, raster_resize_mat = TRUE)
# use max() as the summary function
Heatmap(..., use_raster = TRUE, raster_resize_mat = max)
# randomly pick one
Heatmap(..., use_raster = TRUE, raster_resize_mat = function(x) sample(x, 1))
```

3. A temporary image with resolution `\(n_r \times n_c\)` is first generated, here
   `magick::image_resize()` is used to reduce the image to size $p_r \times
   p_c$. Finally the reduced image is read as a `raster` object and filled into
   the heatmap body. **magick** provides a lot of methods for
   "resizing"/"scaling" the image, which is called the "filtering methods"
   under the term of **magick**. [All filtering
   methods](https://www.imagemagick.org/Magick++/Enumerations.html#FilterTypes)
   can be obtained by `magick::filter_types()`.

   This type of rasterization can be truned on by setting `raster_by_magick = TRUE` 
   and choosing a proper `raster_magick_filter`.


``` r
Heatmap(..., use_raster = TRUE, raster_by_magick = TRUE)
Heatmap(..., use_raster = TRUE, raster_by_magick = TRUE, raster_magick_filter = ...)
```

In the following parts of this post, I will compare the visual difference
between different image rasterization methods.



## Example 1

The first example is from [Guillaume Devailly's simulated
data](https://gdevailly.netlify.app/post/plotting-big-matrices-in-r/) but with
small adaptation. This example shows an enrichment pattern to the top center of the plot.


``` r
mat = matrix(nrow = 5000, ncol = 50)
for(i in 1:5000) {
    mat[i, ] = runif(50) + c(sort(abs(rnorm(50)))[1:25], rev(sort(abs(rnorm(50)))[1:25]))  * i/1000
}
mat = mat[nrow(mat):1, ]
col_fun = colorRamp2(seq(quantile(mat, 0.01), quantile(mat, 0.99), len = 11), rev(brewer.pal(11, "Spectral")))
```

In the folowing examples, I won't show the code for making heatmaps because there are too many heatmaps
and the specific settings is already written as the row title of each heatmap.

I set the same color mapping for all heatmaps, so that you can see how different rasterizations change
the original patterns.

For the comparison, I generated many heatmaps. They can be categoried into three groups, as corresponded to the 
three rasterization methods I mentioned previously.

- `by png()`: Rasterization method 1. 
- `raster_resize_mat = *`: Rasterization method 2, with different summary methods.
- `filter = *`: Rasterization method 3, with different filterring method. The string `filter`
  should be `raster_magick_filter`. It is truncated so that the row title won't be cut by the plot regions.

<img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-8-1.png" width="163.2" style="display: block; margin: auto;" />

<img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-9-1.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-9-2.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-9-3.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-9-4.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-9-5.png" width="163.2" style="display: block; margin: auto;" />

<img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-1.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-2.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-3.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-4.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-5.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-6.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-7.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-8.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-9.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-10.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-11.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-12.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-13.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-14.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-15.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-16.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-17.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-18.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-19.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-20.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-21.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-22.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-23.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-24.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-25.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-26.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-27.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-28.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-29.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-30.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-31.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-32.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-33.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-10-34.png" width="163.2" style="display: block; margin: auto;" />


## Example 2

Here we generate a random matrix from uniform distribution. The color mapping function
linearly intepolation colors between 0 and 1 in the sRGB color space.



``` r
set.seed(123)
mat = matrix(runif(2000*100), nrow = 2000)
col_fun = colorRamp2(c(0, 1), c("white", "black"), space = "sRGB")
```

<img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-12-1.png" width="163.2" style="display: block; margin: auto;" />

<img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-13-1.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-13-2.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-13-3.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-13-4.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-13-5.png" width="163.2" style="display: block; margin: auto;" />

<img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-1.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-2.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-3.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-4.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-5.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-6.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-7.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-8.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-9.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-10.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-11.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-12.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-13.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-14.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-15.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-16.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-17.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-18.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-19.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-20.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-21.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-22.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-23.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-24.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-25.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-26.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-27.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-28.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-29.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-30.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-31.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-32.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-33.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-14-34.png" width="163.2" style="display: block; margin: auto;" />

## Example 3

This example shows heatmaps with more local patterns. These heatmaps visualize the distance of points
in a [2D Hilbert curve](https://www.bioconductor.org/packages/release/bioc/html/HilbertCurve.html).


``` r
pos = HilbertVis::hilbertCurve(5)
mat = as.matrix(dist(pos))
dimnames(mat) = NULL
col_fun = colorRamp2(c(min(mat), median(mat), max(mat)), c("blue", "white", "red"))
```

<img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-16-1.png" width="163.2" style="display: block; margin: auto;" />

<img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-17-1.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-17-2.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-17-3.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-17-4.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-17-5.png" width="163.2" style="display: block; margin: auto;" />

<img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-1.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-2.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-3.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-4.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-5.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-6.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-7.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-8.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-9.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-10.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-11.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-12.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-13.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-14.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-15.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-16.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-17.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-18.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-19.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-20.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-21.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-22.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-23.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-24.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-25.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-26.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-27.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-28.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-29.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-30.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-31.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-32.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-33.png" width="163.2" style="display: block; margin: auto;" /><img src="/lab-cn/post/2020-06-30-rasterization-in-complex-heatmap_files/figure-html/unnamed-chunk-18-34.png" width="163.2" style="display: block; margin: auto;" />



## Conclusion

According to all these examples that have been shown, I would say
rasterization by **magick** package performs better, thus, by default, in
**ComplexHeatmap**, the rasterization is done by **magick** (with `"Lanczos"`
as the default filter method) and if **magick** is not installed, it uses
`png()` and a friendly message is printed to suggest users to install
**magick**.

<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>

<script>
  $(document).ready(function(){
  $("img").css("display", "inline");
  $("main.content").css("max-width", "1000px");
});
</script>

