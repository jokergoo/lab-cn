---
title: "Package dependencies in your session"
date: 2023-11-16
author: Zuguang Gu
---

<link href="/lab-cn/rmarkdown-libs/htmltools-fill/fill.css" rel="stylesheet" />
<script src="/lab-cn/rmarkdown-libs/htmlwidgets/htmlwidgets.js"></script>

<script src="/lab-cn/rmarkdown-libs/viz/viz.js"></script>

<link href="/lab-cn/rmarkdown-libs/DiagrammeR-styles/styles.css" rel="stylesheet" />
<script src="/lab-cn/rmarkdown-libs/grViz-binding/grViz.js"></script>

<link href="/lab-cn/rmarkdown-libs/htmltools-fill/fill.css" rel="stylesheet" />
<script src="/lab-cn/rmarkdown-libs/htmlwidgets/htmlwidgets.js"></script>

<script src="/lab-cn/rmarkdown-libs/viz/viz.js"></script>

<link href="/lab-cn/rmarkdown-libs/DiagrammeR-styles/styles.css" rel="stylesheet" />
<script src="/lab-cn/rmarkdown-libs/grViz-binding/grViz.js"></script>

<link href="/lab-cn/rmarkdown-libs/htmltools-fill/fill.css" rel="stylesheet" />
<script src="/lab-cn/rmarkdown-libs/htmlwidgets/htmlwidgets.js"></script>

<script src="/lab-cn/rmarkdown-libs/viz/viz.js"></script>

<link href="/lab-cn/rmarkdown-libs/DiagrammeR-styles/styles.css" rel="stylesheet" />
<script src="/lab-cn/rmarkdown-libs/grViz-binding/grViz.js"></script>

<link href="/lab-cn/rmarkdown-libs/htmltools-fill/fill.css" rel="stylesheet" />
<script src="/lab-cn/rmarkdown-libs/htmlwidgets/htmlwidgets.js"></script>

<script src="/lab-cn/rmarkdown-libs/viz/viz.js"></script>

<link href="/lab-cn/rmarkdown-libs/DiagrammeR-styles/styles.css" rel="stylesheet" />
<script src="/lab-cn/rmarkdown-libs/grViz-binding/grViz.js"></script>

<link href="/lab-cn/rmarkdown-libs/htmltools-fill/fill.css" rel="stylesheet" />
<script src="/lab-cn/rmarkdown-libs/htmlwidgets/htmlwidgets.js"></script>

<script src="/lab-cn/rmarkdown-libs/viz/viz.js"></script>

<link href="/lab-cn/rmarkdown-libs/DiagrammeR-styles/styles.css" rel="stylesheet" />
<script src="/lab-cn/rmarkdown-libs/grViz-binding/grViz.js"></script>

It has almost been a standard to put `sessionInfo()` to the end of the R markdown document to keep track
of the environment where the analysis is done. `sessionInfo()` prints a list of packages that are loaded to the
R session directly or indirectly. But how about the dependency relations among those packages? In this blog post,
let’s check it out.

Let’s open a new R session and only load the **ggplot2** package:

``` r
library(ggplot2)
```

Next we obtain the session info by the `sessionInfo()` function:

``` r
x1 = sessionInfo()
```

Let’s print `x1`:

``` r
x1
```

    ## R version 4.3.1 (2023-06-16)
    ## Platform: x86_64-apple-darwin20 (64-bit)
    ## Running under: macOS Ventura 13.2.1
    ## 
    ## Matrix products: default
    ## BLAS:   /Library/Frameworks/R.framework/Versions/4.3-x86_64/Resources/lib/libRblas.0.dylib 
    ## LAPACK: /Library/Frameworks/R.framework/Versions/4.3-x86_64/Resources/lib/libRlapack.dylib;  LAPACK version 3.11.0
    ## 
    ## locale:
    ## [1] C/UTF-8/C/C/C/C
    ## 
    ## time zone: Europe/Berlin
    ## tzcode source: internal
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ## [1] ggplot2_3.4.4
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] utf8_1.2.3       R6_2.5.1         tidyselect_1.2.0 magrittr_2.0.3   gtable_0.3.4    
    ##  [6] glue_1.6.2       tibble_3.2.1     pkgconfig_2.0.3  generics_0.1.3   dplyr_1.1.3     
    ## [11] lifecycle_1.0.3  cli_3.6.1        fansi_1.0.5      scales_1.2.1     grid_4.3.1      
    ## [16] vctrs_0.6.4      withr_2.5.1      compiler_4.3.1   munsell_0.5.0    pillar_1.9.0    
    ## [21] colorspace_2.1-0 rlang_1.1.1

It seems only a few packages are loaded in the session.

`x1` is an R object as a list with several elements that correspond to the packages that are loaded directly
or indirectly. Packages in session are put into three groups:

- base packages: Base packages shipped with R, e.g. **grid**, **methods**. Note packages like **lattice** or **MASS**, although
  also shipped with R, they are “recommended packages”.
- other packages: Other packages e.g. which you load by `library()`. They will be visible on the search path (by `search()`).
- loaded packages: Other packages which are also loaded into the R session by “other packages”, but not visible on the search path.

``` r
base_pkgs = x1$basePkgs
other_pkgs = sapply(x1$otherPkgs, function(x) x$Package)
loaded_pkgs = sapply(x1$loadedOnly, function(x) x$Package)
```

For the packages in session, we need to know their dependency relations. Here we use the **pkgndep** package.
All the packages installed locally are used as the “package database” for querying dependencies.

``` r
library(pkgndep)
db = reformat_db(installed.packages())
```

    ## prepare dependency table...
    ## prepare reverse dependency table...

Now we go through every “other packages” and obtain its direct and remote dependencies. Here we only use
the “strong” dependencies, i.e. the packages with dependency relations of “Depends”, “Imports” and “LinkingTo”.

``` r
mat = matrix(nrow = 0, ncol = 3)

for(pkg in other_pkgs) {
    mat = rbind(mat, db$package_dependencies(pkg, recursive = TRUE, which = "strong"))
}
mat = unique(mat)
```

Base packages are bound to R, so we remove the dependency relation from base packages. And
we only restrict the packages to “other packages” and “loaded packages”.

``` r
all_pkgs = c(other_pkgs, loaded_pkgs)
mat = mat[mat[, 1] %in% all_pkgs & mat[, 2] %in% all_pkgs, , drop = FALSE]
mat = mat[!mat[, 1] %in% pkgndep:::BASE_PKGS | mat[, 2] %in% pkgndep:::BASE_PKGS, , drop = FALSE]
head(mat)
```

    ##      package   dependency  dep_fields
    ## [1,] "ggplot2" "cli"       "Imports" 
    ## [2,] "ggplot2" "glue"      "Imports" 
    ## [3,] "ggplot2" "grid"      "Imports" 
    ## [4,] "ggplot2" "gtable"    "Imports" 
    ## [5,] "ggplot2" "lifecycle" "Imports" 
    ## [6,] "ggplot2" "rlang"     "Imports"

Next we use the **DiagrammeR** package to visualize the dependency diagram. We first generate the DOT code:

``` r
all_nodes = unique(c(mat[, 1], mat[, 2], other_pkgs, loaded_pkgs))
node_col = rep("black", length(all_nodes))
node_col[all_nodes %in% other_pkgs] = "red"
node_col[all_nodes %in% loaded_pkgs] = "blue"

library(glue)
nodes = glue("  \"{all_nodes}\" [color=\"{node_col}\"];", collapse = FALSE)

dep_col = c(2, 4, 3, 5, 6)
dep_col = rgb(t(col2rgb(dep_col)), max = 255)
names(dep_col) = c("Depends", "Imports", "LinkingTo", "Suggests", "Enhances")

edges = glue("  \"{mat[, 1]}\" -> \"{mat[, 2]}\" [color=\"{dep_col[mat[, 3]]}\"];", collapse = FALSE)

dot = paste(
    c("digraph {",
      "  nodesep=0.05",
      "  rankdir=LR;", 
      "  graph [overlap = true];",
      "  node[shape = box];",
      nodes,
      edges,
      "}"),
    collapse = "\n"
)
cat(dot)
```

    ## digraph {
    ##   nodesep=0.05
    ##   rankdir=LR;
    ##   graph [overlap = true];
    ##   node[shape = box];
    ##   "ggplot2" [color="red"];
    ##   "gtable" [color="blue"];
    ##   "lifecycle" [color="blue"];
    ##   "scales" [color="blue"];
    ##   "tibble" [color="blue"];
    ##   "vctrs" [color="blue"];
    ##   "munsell" [color="blue"];
    ##   "pillar" [color="blue"];
    ##   "cli" [color="blue"];
    ##   "glue" [color="blue"];
    ##   "grid" [color="blue"];
    ##   "rlang" [color="blue"];
    ##   "withr" [color="blue"];
    ##   "R6" [color="blue"];
    ##   "fansi" [color="blue"];
    ##   "magrittr" [color="blue"];
    ##   "pkgconfig" [color="blue"];
    ##   "colorspace" [color="blue"];
    ##   "utf8" [color="blue"];
    ##   "tidyselect" [color="blue"];
    ##   "generics" [color="blue"];
    ##   "dplyr" [color="blue"];
    ##   "compiler" [color="blue"];
    ##   "ggplot2" -> "cli" [color="#2297E6"];
    ##   "ggplot2" -> "glue" [color="#2297E6"];
    ##   "ggplot2" -> "grid" [color="#2297E6"];
    ##   "ggplot2" -> "gtable" [color="#2297E6"];
    ##   "ggplot2" -> "lifecycle" [color="#2297E6"];
    ##   "ggplot2" -> "rlang" [color="#2297E6"];
    ##   "ggplot2" -> "scales" [color="#2297E6"];
    ##   "ggplot2" -> "tibble" [color="#2297E6"];
    ##   "ggplot2" -> "vctrs" [color="#2297E6"];
    ##   "ggplot2" -> "withr" [color="#2297E6"];
    ##   "gtable" -> "cli" [color="#2297E6"];
    ##   "gtable" -> "glue" [color="#2297E6"];
    ##   "gtable" -> "grid" [color="#2297E6"];
    ##   "gtable" -> "lifecycle" [color="#2297E6"];
    ##   "gtable" -> "rlang" [color="#2297E6"];
    ##   "lifecycle" -> "cli" [color="#2297E6"];
    ##   "lifecycle" -> "glue" [color="#2297E6"];
    ##   "lifecycle" -> "rlang" [color="#2297E6"];
    ##   "scales" -> "cli" [color="#2297E6"];
    ##   "scales" -> "glue" [color="#2297E6"];
    ##   "scales" -> "lifecycle" [color="#2297E6"];
    ##   "scales" -> "munsell" [color="#2297E6"];
    ##   "scales" -> "R6" [color="#2297E6"];
    ##   "scales" -> "rlang" [color="#2297E6"];
    ##   "tibble" -> "fansi" [color="#2297E6"];
    ##   "tibble" -> "lifecycle" [color="#2297E6"];
    ##   "tibble" -> "magrittr" [color="#2297E6"];
    ##   "tibble" -> "pillar" [color="#2297E6"];
    ##   "tibble" -> "pkgconfig" [color="#2297E6"];
    ##   "tibble" -> "rlang" [color="#2297E6"];
    ##   "tibble" -> "vctrs" [color="#2297E6"];
    ##   "vctrs" -> "cli" [color="#2297E6"];
    ##   "vctrs" -> "glue" [color="#2297E6"];
    ##   "vctrs" -> "lifecycle" [color="#2297E6"];
    ##   "vctrs" -> "rlang" [color="#2297E6"];
    ##   "munsell" -> "colorspace" [color="#2297E6"];
    ##   "pillar" -> "cli" [color="#2297E6"];
    ##   "pillar" -> "glue" [color="#2297E6"];
    ##   "pillar" -> "lifecycle" [color="#2297E6"];
    ##   "pillar" -> "rlang" [color="#2297E6"];
    ##   "pillar" -> "utf8" [color="#2297E6"];
    ##   "pillar" -> "vctrs" [color="#2297E6"];
    ## }

Then we send the DOT code to `grViz()` function.

``` r
DiagrammeR::grViz(dot)
```

<div class="grViz html-widget html-fill-item" id="htmlwidget-1" style="width:480px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"diagram":"digraph {\n  nodesep=0.05\n  rankdir=LR;\n  graph [overlap = true];\n  node[shape = box];\n  \"ggplot2\" [color=\"red\"];\n  \"gtable\" [color=\"blue\"];\n  \"lifecycle\" [color=\"blue\"];\n  \"scales\" [color=\"blue\"];\n  \"tibble\" [color=\"blue\"];\n  \"vctrs\" [color=\"blue\"];\n  \"munsell\" [color=\"blue\"];\n  \"pillar\" [color=\"blue\"];\n  \"cli\" [color=\"blue\"];\n  \"glue\" [color=\"blue\"];\n  \"grid\" [color=\"blue\"];\n  \"rlang\" [color=\"blue\"];\n  \"withr\" [color=\"blue\"];\n  \"R6\" [color=\"blue\"];\n  \"fansi\" [color=\"blue\"];\n  \"magrittr\" [color=\"blue\"];\n  \"pkgconfig\" [color=\"blue\"];\n  \"colorspace\" [color=\"blue\"];\n  \"utf8\" [color=\"blue\"];\n  \"tidyselect\" [color=\"blue\"];\n  \"generics\" [color=\"blue\"];\n  \"dplyr\" [color=\"blue\"];\n  \"compiler\" [color=\"blue\"];\n  \"ggplot2\" -> \"cli\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"glue\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"grid\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"gtable\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"rlang\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"scales\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"tibble\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"withr\" [color=\"#2297E6\"];\n  \"gtable\" -> \"cli\" [color=\"#2297E6\"];\n  \"gtable\" -> \"glue\" [color=\"#2297E6\"];\n  \"gtable\" -> \"grid\" [color=\"#2297E6\"];\n  \"gtable\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"gtable\" -> \"rlang\" [color=\"#2297E6\"];\n  \"lifecycle\" -> \"cli\" [color=\"#2297E6\"];\n  \"lifecycle\" -> \"glue\" [color=\"#2297E6\"];\n  \"lifecycle\" -> \"rlang\" [color=\"#2297E6\"];\n  \"scales\" -> \"cli\" [color=\"#2297E6\"];\n  \"scales\" -> \"glue\" [color=\"#2297E6\"];\n  \"scales\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"scales\" -> \"munsell\" [color=\"#2297E6\"];\n  \"scales\" -> \"R6\" [color=\"#2297E6\"];\n  \"scales\" -> \"rlang\" [color=\"#2297E6\"];\n  \"tibble\" -> \"fansi\" [color=\"#2297E6\"];\n  \"tibble\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"tibble\" -> \"magrittr\" [color=\"#2297E6\"];\n  \"tibble\" -> \"pillar\" [color=\"#2297E6\"];\n  \"tibble\" -> \"pkgconfig\" [color=\"#2297E6\"];\n  \"tibble\" -> \"rlang\" [color=\"#2297E6\"];\n  \"tibble\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"vctrs\" -> \"cli\" [color=\"#2297E6\"];\n  \"vctrs\" -> \"glue\" [color=\"#2297E6\"];\n  \"vctrs\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"vctrs\" -> \"rlang\" [color=\"#2297E6\"];\n  \"munsell\" -> \"colorspace\" [color=\"#2297E6\"];\n  \"pillar\" -> \"cli\" [color=\"#2297E6\"];\n  \"pillar\" -> \"glue\" [color=\"#2297E6\"];\n  \"pillar\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"pillar\" -> \"rlang\" [color=\"#2297E6\"];\n  \"pillar\" -> \"utf8\" [color=\"#2297E6\"];\n  \"pillar\" -> \"vctrs\" [color=\"#2297E6\"];\n}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}</script>

It looks like the dependency relations are complicated than
simply listing the packages. There are also isolated packages in the diagram
that are not connected to **ggplot2**, e.g. **dplyr**. They
are loaded to the R session as “weak dependencies” indirectly by **ggplot2**
or its upstream packages.

We wrap the code as a function which we will use repeatedly. Internally, we call `library(pkg)` in a
fresh R session by using the **callr** package.

``` r
loaded_pkgs = function(pkg) {
    for(i in seq_along(pkg)) {
        library(pkg[i], character.only=TRUE)
    }
    session_info = sessionInfo()

    base_pkgs = session_info$basePkgs
    other_pkgs = sapply(session_info$otherPkgs, function(x)x$Package)
    loaded_pkgs = sapply(session_info$loadedOnly, function(x)x$Package)

    lt = list(base_pkgs = base_pkgs,
              other_pkgs = other_pkgs,
              loaded_pkgs = loaded_pkgs)

    jsonlite::toJSON(lt)
}

dep_in_session = function(pkg, db, dep_group = "strong", rankdir = "LR") {

    session_info = jsonlite::fromJSON(callr::r(loaded_pkgs, args = list(pkg = pkg)))

    base_pkgs = session_info$base_pkgs
    other_pkgs = session_info$other_pkgs
    loaded_pkgs = session_info$loaded_pkgs

    mat = matrix(nrow = 0, ncol = 3)

    for(pkg in other_pkgs) {
        mat = rbind(mat, db$package_dependencies(pkg, recursive = TRUE, which = dep_group))
    }
    mat = unique(mat)
    mat = mat[!mat[, 1] %in% pkgndep:::BASE_PKGS | mat[, 2] %in% pkgndep:::BASE_PKGS, , drop = FALSE]

    all_pkgs = c(other_pkgs, loaded_pkgs)
    mat = mat[mat[, 1] %in% all_pkgs & mat[, 2] %in% all_pkgs, , drop = FALSE]

    all_nodes = unique(c(mat[, 1], mat[, 2], other_pkgs, loaded_pkgs))
    node_col = rep("black", length(all_nodes))
    node_col[all_nodes %in% other_pkgs] = "red"
    node_col[all_nodes %in% loaded_pkgs] = "blue"

    nodes = glue::glue("  \"{all_nodes}\" [color=\"{node_col}\"];", collapse = FALSE)

    dep_col = c(2, 4, 3, 5, 6)
    dep_col = rgb(t(col2rgb(dep_col)), max = 255)
    names(dep_col) = c("Depends", "Imports", "LinkingTo", "Suggests", "Enhances")

    edges = glue::glue("  \"{mat[, 1]}\" -> \"{mat[, 2]}\" [color=\"{dep_col[mat[, 3]]}\"];", collapse = FALSE)

    dot = paste(
        c("digraph {",
          "  nodesep=0.05",
          glue::glue("  rankdir={rankdir};"), 
          "  graph [overlap = true];",
          "  node[shape = box];",
          nodes,
          edges,
          "}"),
        collapse = "\n"
    )

    DiagrammeR::grViz(dot)
}
```

In the previous example, we only consider “strong dependency relations” upstream of **ggplot2**.
What if we include all dependency relations?

``` r
dep_in_session("ggplot2", db = db, dep_group = "all")
```

<div class="grViz html-widget html-fill-item" id="htmlwidget-2" style="width:1152px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-2">{"x":{"diagram":"digraph {\n  nodesep=0.05\n  rankdir=LR;\n  graph [overlap = true];\n  node[shape = box];\n  \"ggplot2\" [color=\"red\"];\n  \"cli\" [color=\"blue\"];\n  \"glue\" [color=\"blue\"];\n  \"gtable\" [color=\"blue\"];\n  \"lifecycle\" [color=\"blue\"];\n  \"rlang\" [color=\"blue\"];\n  \"scales\" [color=\"blue\"];\n  \"tibble\" [color=\"blue\"];\n  \"vctrs\" [color=\"blue\"];\n  \"withr\" [color=\"blue\"];\n  \"dplyr\" [color=\"blue\"];\n  \"munsell\" [color=\"blue\"];\n  \"magrittr\" [color=\"blue\"];\n  \"pillar\" [color=\"blue\"];\n  \"generics\" [color=\"blue\"];\n  \"tidyselect\" [color=\"blue\"];\n  \"colorspace\" [color=\"blue\"];\n  \"grid\" [color=\"blue\"];\n  \"R6\" [color=\"blue\"];\n  \"pkgconfig\" [color=\"blue\"];\n  \"compiler\" [color=\"blue\"];\n  \"ggplot2\" -> \"cli\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"glue\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"grid\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"gtable\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"rlang\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"scales\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"tibble\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"withr\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"dplyr\" [color=\"#28E2E5\"];\n  \"ggplot2\" -> \"munsell\" [color=\"#28E2E5\"];\n  \"cli\" -> \"glue\" [color=\"#28E2E5\"];\n  \"cli\" -> \"rlang\" [color=\"#28E2E5\"];\n  \"cli\" -> \"tibble\" [color=\"#28E2E5\"];\n  \"cli\" -> \"withr\" [color=\"#28E2E5\"];\n  \"glue\" -> \"dplyr\" [color=\"#28E2E5\"];\n  \"glue\" -> \"magrittr\" [color=\"#28E2E5\"];\n  \"glue\" -> \"rlang\" [color=\"#28E2E5\"];\n  \"glue\" -> \"vctrs\" [color=\"#28E2E5\"];\n  \"glue\" -> \"withr\" [color=\"#28E2E5\"];\n  \"gtable\" -> \"cli\" [color=\"#2297E6\"];\n  \"gtable\" -> \"glue\" [color=\"#2297E6\"];\n  \"gtable\" -> \"grid\" [color=\"#2297E6\"];\n  \"gtable\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"gtable\" -> \"rlang\" [color=\"#2297E6\"];\n  \"gtable\" -> \"ggplot2\" [color=\"#28E2E5\"];\n  \"lifecycle\" -> \"cli\" [color=\"#2297E6\"];\n  \"lifecycle\" -> \"glue\" [color=\"#2297E6\"];\n  \"lifecycle\" -> \"rlang\" [color=\"#2297E6\"];\n  \"lifecycle\" -> \"tibble\" [color=\"#28E2E5\"];\n  \"lifecycle\" -> \"vctrs\" [color=\"#28E2E5\"];\n  \"lifecycle\" -> \"withr\" [color=\"#28E2E5\"];\n  \"rlang\" -> \"cli\" [color=\"#28E2E5\"];\n  \"rlang\" -> \"glue\" [color=\"#28E2E5\"];\n  \"rlang\" -> \"magrittr\" [color=\"#28E2E5\"];\n  \"rlang\" -> \"pillar\" [color=\"#28E2E5\"];\n  \"rlang\" -> \"tibble\" [color=\"#28E2E5\"];\n  \"rlang\" -> \"vctrs\" [color=\"#28E2E5\"];\n  \"rlang\" -> \"withr\" [color=\"#28E2E5\"];\n  \"scales\" -> \"cli\" [color=\"#2297E6\"];\n  \"scales\" -> \"glue\" [color=\"#2297E6\"];\n  \"scales\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"scales\" -> \"munsell\" [color=\"#2297E6\"];\n  \"scales\" -> \"R6\" [color=\"#2297E6\"];\n  \"scales\" -> \"rlang\" [color=\"#2297E6\"];\n  \"scales\" -> \"ggplot2\" [color=\"#28E2E5\"];\n  \"tibble\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"tibble\" -> \"magrittr\" [color=\"#2297E6\"];\n  \"tibble\" -> \"pillar\" [color=\"#2297E6\"];\n  \"tibble\" -> \"pkgconfig\" [color=\"#2297E6\"];\n  \"tibble\" -> \"rlang\" [color=\"#2297E6\"];\n  \"tibble\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"tibble\" -> \"cli\" [color=\"#28E2E5\"];\n  \"tibble\" -> \"dplyr\" [color=\"#28E2E5\"];\n  \"tibble\" -> \"ggplot2\" [color=\"#28E2E5\"];\n  \"tibble\" -> \"withr\" [color=\"#28E2E5\"];\n  \"vctrs\" -> \"cli\" [color=\"#2297E6\"];\n  \"vctrs\" -> \"glue\" [color=\"#2297E6\"];\n  \"vctrs\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"vctrs\" -> \"rlang\" [color=\"#2297E6\"];\n  \"vctrs\" -> \"dplyr\" [color=\"#28E2E5\"];\n  \"vctrs\" -> \"generics\" [color=\"#28E2E5\"];\n  \"vctrs\" -> \"pillar\" [color=\"#28E2E5\"];\n  \"vctrs\" -> \"tibble\" [color=\"#28E2E5\"];\n  \"vctrs\" -> \"withr\" [color=\"#28E2E5\"];\n  \"withr\" -> \"rlang\" [color=\"#28E2E5\"];\n  \"dplyr\" -> \"cli\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"generics\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"glue\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"magrittr\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"pillar\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"R6\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"rlang\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"tibble\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"tidyselect\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"ggplot2\" [color=\"#28E2E5\"];\n  \"dplyr\" -> \"withr\" [color=\"#28E2E5\"];\n  \"munsell\" -> \"colorspace\" [color=\"#2297E6\"];\n  \"munsell\" -> \"ggplot2\" [color=\"#28E2E5\"];\n  \"magrittr\" -> \"rlang\" [color=\"#28E2E5\"];\n  \"pillar\" -> \"cli\" [color=\"#2297E6\"];\n  \"pillar\" -> \"glue\" [color=\"#2297E6\"];\n  \"pillar\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"pillar\" -> \"rlang\" [color=\"#2297E6\"];\n  \"pillar\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"pillar\" -> \"dplyr\" [color=\"#28E2E5\"];\n  \"pillar\" -> \"ggplot2\" [color=\"#28E2E5\"];\n  \"pillar\" -> \"scales\" [color=\"#28E2E5\"];\n  \"pillar\" -> \"tibble\" [color=\"#28E2E5\"];\n  \"pillar\" -> \"withr\" [color=\"#28E2E5\"];\n  \"generics\" -> \"tibble\" [color=\"#28E2E5\"];\n  \"generics\" -> \"withr\" [color=\"#28E2E5\"];\n  \"tidyselect\" -> \"cli\" [color=\"#2297E6\"];\n  \"tidyselect\" -> \"glue\" [color=\"#2297E6\"];\n  \"tidyselect\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"tidyselect\" -> \"rlang\" [color=\"#2297E6\"];\n  \"tidyselect\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"tidyselect\" -> \"withr\" [color=\"#2297E6\"];\n  \"tidyselect\" -> \"dplyr\" [color=\"#28E2E5\"];\n  \"tidyselect\" -> \"magrittr\" [color=\"#28E2E5\"];\n  \"tidyselect\" -> \"tibble\" [color=\"#28E2E5\"];\n  \"colorspace\" -> \"ggplot2\" [color=\"#28E2E5\"];\n  \"colorspace\" -> \"dplyr\" [color=\"#28E2E5\"];\n  \"colorspace\" -> \"scales\" [color=\"#28E2E5\"];\n  \"colorspace\" -> \"grid\" [color=\"#28E2E5\"];\n}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}</script>

It becomes much more complicated! Especially we can see there are many bi-directional dependencies,
e.g. `A <-> B` where A is a strong dependency of B, and B is a weak dependency of A.

Next let’s check a Bioconductor package **DESeq2**.

We first only consider the strong dependencies upstream of **DESeq2**.

``` r
dep_in_session("DESeq2", db = db, dep_group = "strong")
```

<div class="grViz html-widget html-fill-item" id="htmlwidget-3" style="width:960px;height:768px;"></div>
<script type="application/json" data-for="htmlwidget-3">{"x":{"diagram":"digraph {\n  nodesep=0.05\n  rankdir=LR;\n  graph [overlap = true];\n  node[shape = box];\n  \"DESeq2\" [color=\"red\"];\n  \"S4Vectors\" [color=\"red\"];\n  \"IRanges\" [color=\"red\"];\n  \"GenomicRanges\" [color=\"red\"];\n  \"SummarizedExperiment\" [color=\"red\"];\n  \"Biobase\" [color=\"red\"];\n  \"BiocParallel\" [color=\"blue\"];\n  \"locfit\" [color=\"blue\"];\n  \"ggplot2\" [color=\"blue\"];\n  \"MatrixGenerics\" [color=\"red\"];\n  \"GenomeInfoDb\" [color=\"red\"];\n  \"XVector\" [color=\"blue\"];\n  \"Matrix\" [color=\"blue\"];\n  \"S4Arrays\" [color=\"blue\"];\n  \"DelayedArray\" [color=\"blue\"];\n  \"parallel\" [color=\"blue\"];\n  \"lattice\" [color=\"blue\"];\n  \"gtable\" [color=\"blue\"];\n  \"lifecycle\" [color=\"blue\"];\n  \"scales\" [color=\"blue\"];\n  \"tibble\" [color=\"blue\"];\n  \"vctrs\" [color=\"blue\"];\n  \"UCSC.utils\" [color=\"blue\"];\n  \"SparseArray\" [color=\"blue\"];\n  \"munsell\" [color=\"blue\"];\n  \"pillar\" [color=\"blue\"];\n  \"httr\" [color=\"blue\"];\n  \"BiocGenerics\" [color=\"red\"];\n  \"matrixStats\" [color=\"red\"];\n  \"Rcpp\" [color=\"blue\"];\n  \"tools\" [color=\"blue\"];\n  \"codetools\" [color=\"blue\"];\n  \"cli\" [color=\"blue\"];\n  \"glue\" [color=\"blue\"];\n  \"grid\" [color=\"blue\"];\n  \"rlang\" [color=\"blue\"];\n  \"GenomeInfoDbData\" [color=\"blue\"];\n  \"zlibbioc\" [color=\"blue\"];\n  \"abind\" [color=\"blue\"];\n  \"crayon\" [color=\"blue\"];\n  \"compiler\" [color=\"blue\"];\n  \"R6\" [color=\"blue\"];\n  \"magrittr\" [color=\"blue\"];\n  \"pkgconfig\" [color=\"blue\"];\n  \"jsonlite\" [color=\"blue\"];\n  \"colorspace\" [color=\"blue\"];\n  \"dplyr\" [color=\"blue\"];\n  \"tidyselect\" [color=\"blue\"];\n  \"generics\" [color=\"blue\"];\n  \"DESeq2\" -> \"S4Vectors\" [color=\"#DF536B\"];\n  \"DESeq2\" -> \"IRanges\" [color=\"#DF536B\"];\n  \"DESeq2\" -> \"GenomicRanges\" [color=\"#DF536B\"];\n  \"DESeq2\" -> \"SummarizedExperiment\" [color=\"#DF536B\"];\n  \"DESeq2\" -> \"BiocGenerics\" [color=\"#2297E6\"];\n  \"DESeq2\" -> \"Biobase\" [color=\"#2297E6\"];\n  \"DESeq2\" -> \"BiocParallel\" [color=\"#2297E6\"];\n  \"DESeq2\" -> \"matrixStats\" [color=\"#2297E6\"];\n  \"DESeq2\" -> \"locfit\" [color=\"#2297E6\"];\n  \"DESeq2\" -> \"ggplot2\" [color=\"#2297E6\"];\n  \"DESeq2\" -> \"Rcpp\" [color=\"#2297E6\"];\n  \"DESeq2\" -> \"MatrixGenerics\" [color=\"#2297E6\"];\n  \"DESeq2\" -> \"Rcpp\" [color=\"#61D04F\"];\n  \"S4Vectors\" -> \"BiocGenerics\" [color=\"#DF536B\"];\n  \"IRanges\" -> \"BiocGenerics\" [color=\"#DF536B\"];\n  \"IRanges\" -> \"S4Vectors\" [color=\"#DF536B\"];\n  \"IRanges\" -> \"S4Vectors\" [color=\"#61D04F\"];\n  \"GenomicRanges\" -> \"BiocGenerics\" [color=\"#DF536B\"];\n  \"GenomicRanges\" -> \"S4Vectors\" [color=\"#DF536B\"];\n  \"GenomicRanges\" -> \"IRanges\" [color=\"#DF536B\"];\n  \"GenomicRanges\" -> \"GenomeInfoDb\" [color=\"#DF536B\"];\n  \"GenomicRanges\" -> \"XVector\" [color=\"#2297E6\"];\n  \"GenomicRanges\" -> \"S4Vectors\" [color=\"#61D04F\"];\n  \"GenomicRanges\" -> \"IRanges\" [color=\"#61D04F\"];\n  \"SummarizedExperiment\" -> \"MatrixGenerics\" [color=\"#DF536B\"];\n  \"SummarizedExperiment\" -> \"GenomicRanges\" [color=\"#DF536B\"];\n  \"SummarizedExperiment\" -> \"Biobase\" [color=\"#DF536B\"];\n  \"SummarizedExperiment\" -> \"tools\" [color=\"#2297E6\"];\n  \"SummarizedExperiment\" -> \"Matrix\" [color=\"#2297E6\"];\n  \"SummarizedExperiment\" -> \"BiocGenerics\" [color=\"#2297E6\"];\n  \"SummarizedExperiment\" -> \"S4Vectors\" [color=\"#2297E6\"];\n  \"SummarizedExperiment\" -> \"IRanges\" [color=\"#2297E6\"];\n  \"SummarizedExperiment\" -> \"GenomeInfoDb\" [color=\"#2297E6\"];\n  \"SummarizedExperiment\" -> \"S4Arrays\" [color=\"#2297E6\"];\n  \"SummarizedExperiment\" -> \"DelayedArray\" [color=\"#2297E6\"];\n  \"Biobase\" -> \"BiocGenerics\" [color=\"#DF536B\"];\n  \"BiocParallel\" -> \"parallel\" [color=\"#2297E6\"];\n  \"BiocParallel\" -> \"codetools\" [color=\"#2297E6\"];\n  \"locfit\" -> \"lattice\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"cli\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"glue\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"grid\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"gtable\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"rlang\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"scales\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"tibble\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"MatrixGenerics\" -> \"matrixStats\" [color=\"#DF536B\"];\n  \"GenomeInfoDb\" -> \"BiocGenerics\" [color=\"#DF536B\"];\n  \"GenomeInfoDb\" -> \"S4Vectors\" [color=\"#DF536B\"];\n  \"GenomeInfoDb\" -> \"IRanges\" [color=\"#DF536B\"];\n  \"GenomeInfoDb\" -> \"UCSC.utils\" [color=\"#2297E6\"];\n  \"GenomeInfoDb\" -> \"GenomeInfoDbData\" [color=\"#2297E6\"];\n  \"XVector\" -> \"BiocGenerics\" [color=\"#DF536B\"];\n  \"XVector\" -> \"S4Vectors\" [color=\"#DF536B\"];\n  \"XVector\" -> \"IRanges\" [color=\"#DF536B\"];\n  \"XVector\" -> \"tools\" [color=\"#2297E6\"];\n  \"XVector\" -> \"zlibbioc\" [color=\"#2297E6\"];\n  \"XVector\" -> \"BiocGenerics\" [color=\"#2297E6\"];\n  \"XVector\" -> \"S4Vectors\" [color=\"#2297E6\"];\n  \"XVector\" -> \"IRanges\" [color=\"#2297E6\"];\n  \"XVector\" -> \"S4Vectors\" [color=\"#61D04F\"];\n  \"XVector\" -> \"IRanges\" [color=\"#61D04F\"];\n  \"Matrix\" -> \"grid\" [color=\"#2297E6\"];\n  \"Matrix\" -> \"lattice\" [color=\"#2297E6\"];\n  \"S4Arrays\" -> \"Matrix\" [color=\"#DF536B\"];\n  \"S4Arrays\" -> \"abind\" [color=\"#DF536B\"];\n  \"S4Arrays\" -> \"BiocGenerics\" [color=\"#DF536B\"];\n  \"S4Arrays\" -> \"S4Vectors\" [color=\"#DF536B\"];\n  \"S4Arrays\" -> \"IRanges\" [color=\"#DF536B\"];\n  \"S4Arrays\" -> \"crayon\" [color=\"#2297E6\"];\n  \"S4Arrays\" -> \"S4Vectors\" [color=\"#61D04F\"];\n  \"DelayedArray\" -> \"Matrix\" [color=\"#DF536B\"];\n  \"DelayedArray\" -> \"BiocGenerics\" [color=\"#DF536B\"];\n  \"DelayedArray\" -> \"MatrixGenerics\" [color=\"#DF536B\"];\n  \"DelayedArray\" -> \"S4Vectors\" [color=\"#DF536B\"];\n  \"DelayedArray\" -> \"IRanges\" [color=\"#DF536B\"];\n  \"DelayedArray\" -> \"S4Arrays\" [color=\"#DF536B\"];\n  \"DelayedArray\" -> \"SparseArray\" [color=\"#DF536B\"];\n  \"DelayedArray\" -> \"S4Vectors\" [color=\"#61D04F\"];\n  \"parallel\" -> \"tools\" [color=\"#2297E6\"];\n  \"parallel\" -> \"compiler\" [color=\"#2297E6\"];\n  \"lattice\" -> \"grid\" [color=\"#2297E6\"];\n  \"gtable\" -> \"cli\" [color=\"#2297E6\"];\n  \"gtable\" -> \"glue\" [color=\"#2297E6\"];\n  \"gtable\" -> \"grid\" [color=\"#2297E6\"];\n  \"gtable\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"gtable\" -> \"rlang\" [color=\"#2297E6\"];\n  \"lifecycle\" -> \"cli\" [color=\"#2297E6\"];\n  \"lifecycle\" -> \"glue\" [color=\"#2297E6\"];\n  \"lifecycle\" -> \"rlang\" [color=\"#2297E6\"];\n  \"scales\" -> \"cli\" [color=\"#2297E6\"];\n  \"scales\" -> \"glue\" [color=\"#2297E6\"];\n  \"scales\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"scales\" -> \"munsell\" [color=\"#2297E6\"];\n  \"scales\" -> \"R6\" [color=\"#2297E6\"];\n  \"scales\" -> \"rlang\" [color=\"#2297E6\"];\n  \"tibble\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"tibble\" -> \"magrittr\" [color=\"#2297E6\"];\n  \"tibble\" -> \"pillar\" [color=\"#2297E6\"];\n  \"tibble\" -> \"pkgconfig\" [color=\"#2297E6\"];\n  \"tibble\" -> \"rlang\" [color=\"#2297E6\"];\n  \"tibble\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"vctrs\" -> \"cli\" [color=\"#2297E6\"];\n  \"vctrs\" -> \"glue\" [color=\"#2297E6\"];\n  \"vctrs\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"vctrs\" -> \"rlang\" [color=\"#2297E6\"];\n  \"UCSC.utils\" -> \"httr\" [color=\"#2297E6\"];\n  \"UCSC.utils\" -> \"jsonlite\" [color=\"#2297E6\"];\n  \"UCSC.utils\" -> \"S4Vectors\" [color=\"#2297E6\"];\n  \"SparseArray\" -> \"Matrix\" [color=\"#DF536B\"];\n  \"SparseArray\" -> \"BiocGenerics\" [color=\"#DF536B\"];\n  \"SparseArray\" -> \"MatrixGenerics\" [color=\"#DF536B\"];\n  \"SparseArray\" -> \"S4Vectors\" [color=\"#DF536B\"];\n  \"SparseArray\" -> \"S4Arrays\" [color=\"#DF536B\"];\n  \"SparseArray\" -> \"matrixStats\" [color=\"#2297E6\"];\n  \"SparseArray\" -> \"IRanges\" [color=\"#2297E6\"];\n  \"SparseArray\" -> \"XVector\" [color=\"#2297E6\"];\n  \"SparseArray\" -> \"S4Vectors\" [color=\"#61D04F\"];\n  \"SparseArray\" -> \"IRanges\" [color=\"#61D04F\"];\n  \"SparseArray\" -> \"XVector\" [color=\"#61D04F\"];\n  \"munsell\" -> \"colorspace\" [color=\"#2297E6\"];\n  \"pillar\" -> \"cli\" [color=\"#2297E6\"];\n  \"pillar\" -> \"glue\" [color=\"#2297E6\"];\n  \"pillar\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"pillar\" -> \"rlang\" [color=\"#2297E6\"];\n  \"pillar\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"httr\" -> \"jsonlite\" [color=\"#2297E6\"];\n  \"httr\" -> \"R6\" [color=\"#2297E6\"];\n}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}</script>

It is already very complicated, but still interesting that **DESeq2**’s
dependencies can be nicely separated into two groups. The first group is related
to Bioconductor packages and a lot of them are directly attached to the search
path (red box: visible in search path; red link: the “Depends” relation);
while the second group is mainly related to **ggplot2** and its upstream packages,
which all are loaded indirectly into the R session (blue link: the “Imports” relation).

And what if we include all dependency types? Now we need to change the layout to “top-bottom” style.
As we can see, a simple command `library(DESeq2)` brings a dependency monster to your R session.

``` r
dep_in_session("DESeq2", db = db, dep_group = "all", rankdir = "TB")
```

<div class="grViz html-widget html-fill-item" id="htmlwidget-4" style="width:768px;height:1536px;"></div>
<script type="application/json" data-for="htmlwidget-4">{"x":{"diagram":"digraph {\n  nodesep=0.05\n  rankdir=TB;\n  graph [overlap = true];\n  node[shape = box];\n  \"DESeq2\" [color=\"red\"];\n  \"S4Vectors\" [color=\"red\"];\n  \"IRanges\" [color=\"red\"];\n  \"GenomicRanges\" [color=\"red\"];\n  \"SummarizedExperiment\" [color=\"red\"];\n  \"BiocGenerics\" [color=\"red\"];\n  \"Biobase\" [color=\"red\"];\n  \"BiocParallel\" [color=\"blue\"];\n  \"matrixStats\" [color=\"red\"];\n  \"locfit\" [color=\"blue\"];\n  \"ggplot2\" [color=\"blue\"];\n  \"MatrixGenerics\" [color=\"red\"];\n  \"Matrix\" [color=\"blue\"];\n  \"DelayedArray\" [color=\"blue\"];\n  \"XVector\" [color=\"blue\"];\n  \"GenomeInfoDb\" [color=\"red\"];\n  \"S4Arrays\" [color=\"blue\"];\n  \"jsonlite\" [color=\"blue\"];\n  \"SparseArray\" [color=\"blue\"];\n  \"parallel\" [color=\"blue\"];\n  \"lattice\" [color=\"blue\"];\n  \"cli\" [color=\"blue\"];\n  \"glue\" [color=\"blue\"];\n  \"gtable\" [color=\"blue\"];\n  \"lifecycle\" [color=\"blue\"];\n  \"rlang\" [color=\"blue\"];\n  \"scales\" [color=\"blue\"];\n  \"tibble\" [color=\"blue\"];\n  \"vctrs\" [color=\"blue\"];\n  \"dplyr\" [color=\"blue\"];\n  \"munsell\" [color=\"blue\"];\n  \"magrittr\" [color=\"blue\"];\n  \"UCSC.utils\" [color=\"blue\"];\n  \"httr\" [color=\"blue\"];\n  \"colorspace\" [color=\"blue\"];\n  \"pillar\" [color=\"blue\"];\n  \"generics\" [color=\"blue\"];\n  \"tidyselect\" [color=\"blue\"];\n  \"Rcpp\" [color=\"blue\"];\n  \"tools\" [color=\"blue\"];\n  \"codetools\" [color=\"blue\"];\n  \"grid\" [color=\"blue\"];\n  \"zlibbioc\" [color=\"blue\"];\n  \"GenomeInfoDbData\" [color=\"blue\"];\n  \"abind\" [color=\"blue\"];\n  \"crayon\" [color=\"blue\"];\n  \"compiler\" [color=\"blue\"];\n  \"R6\" [color=\"blue\"];\n  \"pkgconfig\" [color=\"blue\"];\n  \"DESeq2\" -> \"S4Vectors\" [color=\"#DF536B\"];\n  \"DESeq2\" -> \"IRanges\" [color=\"#DF536B\"];\n  \"DESeq2\" -> \"GenomicRanges\" [color=\"#DF536B\"];\n  \"DESeq2\" -> \"SummarizedExperiment\" [color=\"#DF536B\"];\n  \"DESeq2\" -> \"BiocGenerics\" [color=\"#2297E6\"];\n  \"DESeq2\" -> \"Biobase\" [color=\"#2297E6\"];\n  \"DESeq2\" -> \"BiocParallel\" [color=\"#2297E6\"];\n  \"DESeq2\" -> \"matrixStats\" [color=\"#2297E6\"];\n  \"DESeq2\" -> \"locfit\" [color=\"#2297E6\"];\n  \"DESeq2\" -> \"ggplot2\" [color=\"#2297E6\"];\n  \"DESeq2\" -> \"Rcpp\" [color=\"#2297E6\"];\n  \"DESeq2\" -> \"MatrixGenerics\" [color=\"#2297E6\"];\n  \"DESeq2\" -> \"Rcpp\" [color=\"#61D04F\"];\n  \"S4Vectors\" -> \"BiocGenerics\" [color=\"#DF536B\"];\n  \"S4Vectors\" -> \"IRanges\" [color=\"#28E2E5\"];\n  \"S4Vectors\" -> \"GenomicRanges\" [color=\"#28E2E5\"];\n  \"S4Vectors\" -> \"SummarizedExperiment\" [color=\"#28E2E5\"];\n  \"S4Vectors\" -> \"Matrix\" [color=\"#28E2E5\"];\n  \"S4Vectors\" -> \"DelayedArray\" [color=\"#28E2E5\"];\n  \"IRanges\" -> \"BiocGenerics\" [color=\"#DF536B\"];\n  \"IRanges\" -> \"S4Vectors\" [color=\"#DF536B\"];\n  \"IRanges\" -> \"S4Vectors\" [color=\"#61D04F\"];\n  \"IRanges\" -> \"XVector\" [color=\"#28E2E5\"];\n  \"IRanges\" -> \"GenomicRanges\" [color=\"#28E2E5\"];\n  \"GenomicRanges\" -> \"BiocGenerics\" [color=\"#DF536B\"];\n  \"GenomicRanges\" -> \"S4Vectors\" [color=\"#DF536B\"];\n  \"GenomicRanges\" -> \"IRanges\" [color=\"#DF536B\"];\n  \"GenomicRanges\" -> \"GenomeInfoDb\" [color=\"#DF536B\"];\n  \"GenomicRanges\" -> \"XVector\" [color=\"#2297E6\"];\n  \"GenomicRanges\" -> \"S4Vectors\" [color=\"#61D04F\"];\n  \"GenomicRanges\" -> \"IRanges\" [color=\"#61D04F\"];\n  \"GenomicRanges\" -> \"Matrix\" [color=\"#28E2E5\"];\n  \"GenomicRanges\" -> \"Biobase\" [color=\"#28E2E5\"];\n  \"GenomicRanges\" -> \"SummarizedExperiment\" [color=\"#28E2E5\"];\n  \"GenomicRanges\" -> \"DESeq2\" [color=\"#28E2E5\"];\n  \"SummarizedExperiment\" -> \"MatrixGenerics\" [color=\"#DF536B\"];\n  \"SummarizedExperiment\" -> \"GenomicRanges\" [color=\"#DF536B\"];\n  \"SummarizedExperiment\" -> \"Biobase\" [color=\"#DF536B\"];\n  \"SummarizedExperiment\" -> \"tools\" [color=\"#2297E6\"];\n  \"SummarizedExperiment\" -> \"Matrix\" [color=\"#2297E6\"];\n  \"SummarizedExperiment\" -> \"BiocGenerics\" [color=\"#2297E6\"];\n  \"SummarizedExperiment\" -> \"S4Vectors\" [color=\"#2297E6\"];\n  \"SummarizedExperiment\" -> \"IRanges\" [color=\"#2297E6\"];\n  \"SummarizedExperiment\" -> \"GenomeInfoDb\" [color=\"#2297E6\"];\n  \"SummarizedExperiment\" -> \"S4Arrays\" [color=\"#2297E6\"];\n  \"SummarizedExperiment\" -> \"DelayedArray\" [color=\"#2297E6\"];\n  \"SummarizedExperiment\" -> \"jsonlite\" [color=\"#28E2E5\"];\n  \"SummarizedExperiment\" -> \"SparseArray\" [color=\"#28E2E5\"];\n  \"BiocGenerics\" -> \"Biobase\" [color=\"#28E2E5\"];\n  \"BiocGenerics\" -> \"S4Vectors\" [color=\"#28E2E5\"];\n  \"BiocGenerics\" -> \"IRanges\" [color=\"#28E2E5\"];\n  \"BiocGenerics\" -> \"S4Arrays\" [color=\"#28E2E5\"];\n  \"BiocGenerics\" -> \"SparseArray\" [color=\"#28E2E5\"];\n  \"BiocGenerics\" -> \"DelayedArray\" [color=\"#28E2E5\"];\n  \"BiocGenerics\" -> \"GenomicRanges\" [color=\"#28E2E5\"];\n  \"BiocGenerics\" -> \"DESeq2\" [color=\"#28E2E5\"];\n  \"Biobase\" -> \"BiocGenerics\" [color=\"#DF536B\"];\n  \"Biobase\" -> \"tools\" [color=\"#28E2E5\"];\n  \"BiocParallel\" -> \"parallel\" [color=\"#2297E6\"];\n  \"BiocParallel\" -> \"codetools\" [color=\"#2297E6\"];\n  \"BiocParallel\" -> \"BiocGenerics\" [color=\"#28E2E5\"];\n  \"BiocParallel\" -> \"tools\" [color=\"#28E2E5\"];\n  \"BiocParallel\" -> \"GenomicRanges\" [color=\"#28E2E5\"];\n  \"matrixStats\" -> \"ggplot2\" [color=\"#28E2E5\"];\n  \"locfit\" -> \"lattice\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"cli\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"glue\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"grid\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"gtable\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"rlang\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"scales\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"tibble\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"dplyr\" [color=\"#28E2E5\"];\n  \"ggplot2\" -> \"munsell\" [color=\"#28E2E5\"];\n  \"MatrixGenerics\" -> \"matrixStats\" [color=\"#DF536B\"];\n  \"MatrixGenerics\" -> \"Matrix\" [color=\"#28E2E5\"];\n  \"MatrixGenerics\" -> \"SparseArray\" [color=\"#28E2E5\"];\n  \"MatrixGenerics\" -> \"DelayedArray\" [color=\"#28E2E5\"];\n  \"MatrixGenerics\" -> \"SummarizedExperiment\" [color=\"#28E2E5\"];\n  \"Matrix\" -> \"grid\" [color=\"#2297E6\"];\n  \"Matrix\" -> \"lattice\" [color=\"#2297E6\"];\n  \"Matrix\" -> \"tools\" [color=\"#28E2E5\"];\n  \"DelayedArray\" -> \"Matrix\" [color=\"#DF536B\"];\n  \"DelayedArray\" -> \"BiocGenerics\" [color=\"#DF536B\"];\n  \"DelayedArray\" -> \"MatrixGenerics\" [color=\"#DF536B\"];\n  \"DelayedArray\" -> \"S4Vectors\" [color=\"#DF536B\"];\n  \"DelayedArray\" -> \"IRanges\" [color=\"#DF536B\"];\n  \"DelayedArray\" -> \"S4Arrays\" [color=\"#DF536B\"];\n  \"DelayedArray\" -> \"SparseArray\" [color=\"#DF536B\"];\n  \"DelayedArray\" -> \"S4Vectors\" [color=\"#61D04F\"];\n  \"DelayedArray\" -> \"BiocParallel\" [color=\"#28E2E5\"];\n  \"DelayedArray\" -> \"SummarizedExperiment\" [color=\"#28E2E5\"];\n  \"XVector\" -> \"BiocGenerics\" [color=\"#DF536B\"];\n  \"XVector\" -> \"S4Vectors\" [color=\"#DF536B\"];\n  \"XVector\" -> \"IRanges\" [color=\"#DF536B\"];\n  \"XVector\" -> \"tools\" [color=\"#2297E6\"];\n  \"XVector\" -> \"zlibbioc\" [color=\"#2297E6\"];\n  \"XVector\" -> \"BiocGenerics\" [color=\"#2297E6\"];\n  \"XVector\" -> \"S4Vectors\" [color=\"#2297E6\"];\n  \"XVector\" -> \"IRanges\" [color=\"#2297E6\"];\n  \"XVector\" -> \"S4Vectors\" [color=\"#61D04F\"];\n  \"XVector\" -> \"IRanges\" [color=\"#61D04F\"];\n  \"GenomeInfoDb\" -> \"BiocGenerics\" [color=\"#DF536B\"];\n  \"GenomeInfoDb\" -> \"S4Vectors\" [color=\"#DF536B\"];\n  \"GenomeInfoDb\" -> \"IRanges\" [color=\"#DF536B\"];\n  \"GenomeInfoDb\" -> \"UCSC.utils\" [color=\"#2297E6\"];\n  \"GenomeInfoDb\" -> \"GenomeInfoDbData\" [color=\"#2297E6\"];\n  \"GenomeInfoDb\" -> \"GenomicRanges\" [color=\"#28E2E5\"];\n  \"S4Arrays\" -> \"Matrix\" [color=\"#DF536B\"];\n  \"S4Arrays\" -> \"abind\" [color=\"#DF536B\"];\n  \"S4Arrays\" -> \"BiocGenerics\" [color=\"#DF536B\"];\n  \"S4Arrays\" -> \"S4Vectors\" [color=\"#DF536B\"];\n  \"S4Arrays\" -> \"IRanges\" [color=\"#DF536B\"];\n  \"S4Arrays\" -> \"crayon\" [color=\"#2297E6\"];\n  \"S4Arrays\" -> \"S4Vectors\" [color=\"#61D04F\"];\n  \"S4Arrays\" -> \"BiocParallel\" [color=\"#28E2E5\"];\n  \"S4Arrays\" -> \"SparseArray\" [color=\"#28E2E5\"];\n  \"S4Arrays\" -> \"DelayedArray\" [color=\"#28E2E5\"];\n  \"jsonlite\" -> \"httr\" [color=\"#28E2E5\"];\n  \"jsonlite\" -> \"vctrs\" [color=\"#28E2E5\"];\n  \"SparseArray\" -> \"Matrix\" [color=\"#DF536B\"];\n  \"SparseArray\" -> \"BiocGenerics\" [color=\"#DF536B\"];\n  \"SparseArray\" -> \"MatrixGenerics\" [color=\"#DF536B\"];\n  \"SparseArray\" -> \"S4Vectors\" [color=\"#DF536B\"];\n  \"SparseArray\" -> \"S4Arrays\" [color=\"#DF536B\"];\n  \"SparseArray\" -> \"matrixStats\" [color=\"#2297E6\"];\n  \"SparseArray\" -> \"IRanges\" [color=\"#2297E6\"];\n  \"SparseArray\" -> \"XVector\" [color=\"#2297E6\"];\n  \"SparseArray\" -> \"S4Vectors\" [color=\"#61D04F\"];\n  \"SparseArray\" -> \"IRanges\" [color=\"#61D04F\"];\n  \"SparseArray\" -> \"XVector\" [color=\"#61D04F\"];\n  \"parallel\" -> \"tools\" [color=\"#2297E6\"];\n  \"parallel\" -> \"compiler\" [color=\"#2297E6\"];\n  \"lattice\" -> \"grid\" [color=\"#2297E6\"];\n  \"lattice\" -> \"colorspace\" [color=\"#28E2E5\"];\n  \"cli\" -> \"crayon\" [color=\"#28E2E5\"];\n  \"cli\" -> \"glue\" [color=\"#28E2E5\"];\n  \"cli\" -> \"rlang\" [color=\"#28E2E5\"];\n  \"cli\" -> \"tibble\" [color=\"#28E2E5\"];\n  \"glue\" -> \"crayon\" [color=\"#28E2E5\"];\n  \"glue\" -> \"dplyr\" [color=\"#28E2E5\"];\n  \"glue\" -> \"magrittr\" [color=\"#28E2E5\"];\n  \"glue\" -> \"rlang\" [color=\"#28E2E5\"];\n  \"glue\" -> \"vctrs\" [color=\"#28E2E5\"];\n  \"gtable\" -> \"cli\" [color=\"#2297E6\"];\n  \"gtable\" -> \"glue\" [color=\"#2297E6\"];\n  \"gtable\" -> \"grid\" [color=\"#2297E6\"];\n  \"gtable\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"gtable\" -> \"rlang\" [color=\"#2297E6\"];\n  \"gtable\" -> \"ggplot2\" [color=\"#28E2E5\"];\n  \"lifecycle\" -> \"cli\" [color=\"#2297E6\"];\n  \"lifecycle\" -> \"glue\" [color=\"#2297E6\"];\n  \"lifecycle\" -> \"rlang\" [color=\"#2297E6\"];\n  \"lifecycle\" -> \"crayon\" [color=\"#28E2E5\"];\n  \"lifecycle\" -> \"tibble\" [color=\"#28E2E5\"];\n  \"lifecycle\" -> \"tools\" [color=\"#28E2E5\"];\n  \"lifecycle\" -> \"vctrs\" [color=\"#28E2E5\"];\n  \"rlang\" -> \"cli\" [color=\"#28E2E5\"];\n  \"rlang\" -> \"crayon\" [color=\"#28E2E5\"];\n  \"rlang\" -> \"glue\" [color=\"#28E2E5\"];\n  \"rlang\" -> \"magrittr\" [color=\"#28E2E5\"];\n  \"rlang\" -> \"pillar\" [color=\"#28E2E5\"];\n  \"rlang\" -> \"tibble\" [color=\"#28E2E5\"];\n  \"rlang\" -> \"vctrs\" [color=\"#28E2E5\"];\n  \"scales\" -> \"cli\" [color=\"#2297E6\"];\n  \"scales\" -> \"glue\" [color=\"#2297E6\"];\n  \"scales\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"scales\" -> \"munsell\" [color=\"#2297E6\"];\n  \"scales\" -> \"R6\" [color=\"#2297E6\"];\n  \"scales\" -> \"rlang\" [color=\"#2297E6\"];\n  \"scales\" -> \"ggplot2\" [color=\"#28E2E5\"];\n  \"tibble\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"tibble\" -> \"magrittr\" [color=\"#2297E6\"];\n  \"tibble\" -> \"pillar\" [color=\"#2297E6\"];\n  \"tibble\" -> \"pkgconfig\" [color=\"#2297E6\"];\n  \"tibble\" -> \"rlang\" [color=\"#2297E6\"];\n  \"tibble\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"tibble\" -> \"cli\" [color=\"#28E2E5\"];\n  \"tibble\" -> \"crayon\" [color=\"#28E2E5\"];\n  \"tibble\" -> \"dplyr\" [color=\"#28E2E5\"];\n  \"tibble\" -> \"ggplot2\" [color=\"#28E2E5\"];\n  \"vctrs\" -> \"cli\" [color=\"#2297E6\"];\n  \"vctrs\" -> \"glue\" [color=\"#2297E6\"];\n  \"vctrs\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"vctrs\" -> \"rlang\" [color=\"#2297E6\"];\n  \"vctrs\" -> \"crayon\" [color=\"#28E2E5\"];\n  \"vctrs\" -> \"dplyr\" [color=\"#28E2E5\"];\n  \"vctrs\" -> \"generics\" [color=\"#28E2E5\"];\n  \"vctrs\" -> \"pillar\" [color=\"#28E2E5\"];\n  \"vctrs\" -> \"tibble\" [color=\"#28E2E5\"];\n  \"dplyr\" -> \"cli\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"generics\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"glue\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"magrittr\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"pillar\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"R6\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"rlang\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"tibble\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"tidyselect\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"ggplot2\" [color=\"#28E2E5\"];\n  \"munsell\" -> \"colorspace\" [color=\"#2297E6\"];\n  \"munsell\" -> \"ggplot2\" [color=\"#28E2E5\"];\n  \"magrittr\" -> \"rlang\" [color=\"#28E2E5\"];\n  \"UCSC.utils\" -> \"httr\" [color=\"#2297E6\"];\n  \"UCSC.utils\" -> \"jsonlite\" [color=\"#2297E6\"];\n  \"UCSC.utils\" -> \"S4Vectors\" [color=\"#2297E6\"];\n  \"UCSC.utils\" -> \"GenomeInfoDb\" [color=\"#28E2E5\"];\n  \"httr\" -> \"jsonlite\" [color=\"#2297E6\"];\n  \"httr\" -> \"R6\" [color=\"#2297E6\"];\n  \"colorspace\" -> \"ggplot2\" [color=\"#28E2E5\"];\n  \"colorspace\" -> \"dplyr\" [color=\"#28E2E5\"];\n  \"colorspace\" -> \"scales\" [color=\"#28E2E5\"];\n  \"colorspace\" -> \"grid\" [color=\"#28E2E5\"];\n  \"pillar\" -> \"cli\" [color=\"#2297E6\"];\n  \"pillar\" -> \"glue\" [color=\"#2297E6\"];\n  \"pillar\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"pillar\" -> \"rlang\" [color=\"#2297E6\"];\n  \"pillar\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"pillar\" -> \"dplyr\" [color=\"#28E2E5\"];\n  \"pillar\" -> \"ggplot2\" [color=\"#28E2E5\"];\n  \"pillar\" -> \"scales\" [color=\"#28E2E5\"];\n  \"pillar\" -> \"tibble\" [color=\"#28E2E5\"];\n  \"generics\" -> \"tibble\" [color=\"#28E2E5\"];\n  \"tidyselect\" -> \"cli\" [color=\"#2297E6\"];\n  \"tidyselect\" -> \"glue\" [color=\"#2297E6\"];\n  \"tidyselect\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"tidyselect\" -> \"rlang\" [color=\"#2297E6\"];\n  \"tidyselect\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"tidyselect\" -> \"crayon\" [color=\"#28E2E5\"];\n  \"tidyselect\" -> \"dplyr\" [color=\"#28E2E5\"];\n  \"tidyselect\" -> \"magrittr\" [color=\"#28E2E5\"];\n  \"tidyselect\" -> \"tibble\" [color=\"#28E2E5\"];\n}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}</script>

Last, let’s check when freshly loading a very heavy package **Seurat**.

``` r
dep_in_session("Seurat", db = db, dep_group = "strong")
```

<div class="grViz html-widget html-fill-item" id="htmlwidget-5" style="width:768px;height:1536px;"></div>
<script type="application/json" data-for="htmlwidget-5">{"x":{"diagram":"digraph {\n  nodesep=0.05\n  rankdir=LR;\n  graph [overlap = true];\n  node[shape = box];\n  \"Seurat\" [color=\"red\"];\n  \"SeuratObject\" [color=\"red\"];\n  \"cowplot\" [color=\"blue\"];\n  \"fastDummies\" [color=\"blue\"];\n  \"fitdistrplus\" [color=\"blue\"];\n  \"future\" [color=\"blue\"];\n  \"future.apply\" [color=\"blue\"];\n  \"ggplot2\" [color=\"blue\"];\n  \"ggrepel\" [color=\"blue\"];\n  \"ggridges\" [color=\"blue\"];\n  \"httr\" [color=\"blue\"];\n  \"igraph\" [color=\"blue\"];\n  \"irlba\" [color=\"blue\"];\n  \"lifecycle\" [color=\"blue\"];\n  \"lmtest\" [color=\"blue\"];\n  \"Matrix\" [color=\"blue\"];\n  \"miniUI\" [color=\"blue\"];\n  \"patchwork\" [color=\"blue\"];\n  \"pbapply\" [color=\"blue\"];\n  \"plotly\" [color=\"blue\"];\n  \"progressr\" [color=\"blue\"];\n  \"RcppAnnoy\" [color=\"blue\"];\n  \"RcppHNSW\" [color=\"blue\"];\n  \"reticulate\" [color=\"blue\"];\n  \"RSpectra\" [color=\"blue\"];\n  \"Rtsne\" [color=\"blue\"];\n  \"scales\" [color=\"blue\"];\n  \"scattermore\" [color=\"blue\"];\n  \"sctransform\" [color=\"blue\"];\n  \"shiny\" [color=\"blue\"];\n  \"spatstat.explore\" [color=\"blue\"];\n  \"spatstat.geom\" [color=\"blue\"];\n  \"tibble\" [color=\"blue\"];\n  \"uwot\" [color=\"blue\"];\n  \"sp\" [color=\"red\"];\n  \"spam\" [color=\"blue\"];\n  \"gtable\" [color=\"blue\"];\n  \"stringr\" [color=\"blue\"];\n  \"survival\" [color=\"blue\"];\n  \"globals\" [color=\"blue\"];\n  \"parallel\" [color=\"blue\"];\n  \"parallelly\" [color=\"blue\"];\n  \"vctrs\" [color=\"blue\"];\n  \"mime\" [color=\"blue\"];\n  \"zoo\" [color=\"blue\"];\n  \"lattice\" [color=\"blue\"];\n  \"htmltools\" [color=\"blue\"];\n  \"htmlwidgets\" [color=\"blue\"];\n  \"tidyr\" [color=\"blue\"];\n  \"dplyr\" [color=\"blue\"];\n  \"purrr\" [color=\"blue\"];\n  \"promises\" [color=\"blue\"];\n  \"munsell\" [color=\"blue\"];\n  \"reshape2\" [color=\"blue\"];\n  \"gridExtra\" [color=\"blue\"];\n  \"httpuv\" [color=\"blue\"];\n  \"later\" [color=\"blue\"];\n  \"spatstat.data\" [color=\"blue\"];\n  \"spatstat.univar\" [color=\"blue\"];\n  \"spatstat.random\" [color=\"blue\"];\n  \"nlme\" [color=\"blue\"];\n  \"spatstat.sparse\" [color=\"blue\"];\n  \"pillar\" [color=\"blue\"];\n  \"stringi\" [color=\"blue\"];\n  \"tidyselect\" [color=\"blue\"];\n  \"plyr\" [color=\"blue\"];\n  \"cluster\" [color=\"blue\"];\n  \"generics\" [color=\"blue\"];\n  \"grid\" [color=\"blue\"];\n  \"ica\" [color=\"blue\"];\n  \"jsonlite\" [color=\"blue\"];\n  \"KernSmooth\" [color=\"blue\"];\n  \"MASS\" [color=\"blue\"];\n  \"matrixStats\" [color=\"blue\"];\n  \"png\" [color=\"blue\"];\n  \"RANN\" [color=\"blue\"];\n  \"RColorBrewer\" [color=\"blue\"];\n  \"Rcpp\" [color=\"blue\"];\n  \"rlang\" [color=\"blue\"];\n  \"ROCR\" [color=\"blue\"];\n  \"tools\" [color=\"blue\"];\n  \"data.table\" [color=\"blue\"];\n  \"digest\" [color=\"blue\"];\n  \"listenv\" [color=\"blue\"];\n  \"cli\" [color=\"blue\"];\n  \"glue\" [color=\"blue\"];\n  \"R6\" [color=\"blue\"];\n  \"magrittr\" [color=\"blue\"];\n  \"pkgconfig\" [color=\"blue\"];\n  \"farver\" [color=\"blue\"];\n  \"viridisLite\" [color=\"blue\"];\n  \"lazyeval\" [color=\"blue\"];\n  \"xtable\" [color=\"blue\"];\n  \"fastmap\" [color=\"blue\"];\n  \"spatstat.utils\" [color=\"blue\"];\n  \"goftest\" [color=\"blue\"];\n  \"abind\" [color=\"blue\"];\n  \"deldir\" [color=\"blue\"];\n  \"polyclip\" [color=\"blue\"];\n  \"dotCall64\" [color=\"blue\"];\n  \"splines\" [color=\"blue\"];\n  \"codetools\" [color=\"blue\"];\n  \"compiler\" [color=\"blue\"];\n  \"colorspace\" [color=\"blue\"];\n  \"tensor\" [color=\"blue\"];\n  \"Seurat\" -> \"SeuratObject\" [color=\"#DF536B\"];\n  \"Seurat\" -> \"cluster\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"cowplot\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"fastDummies\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"fitdistrplus\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"future\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"future.apply\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"generics\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"ggplot2\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"ggrepel\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"ggridges\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"grid\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"httr\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"ica\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"igraph\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"irlba\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"jsonlite\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"KernSmooth\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"lmtest\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"MASS\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"Matrix\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"matrixStats\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"miniUI\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"patchwork\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"pbapply\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"plotly\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"png\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"progressr\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"RANN\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"RColorBrewer\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"Rcpp\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"RcppAnnoy\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"RcppHNSW\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"reticulate\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"rlang\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"ROCR\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"RSpectra\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"Rtsne\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"scales\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"scattermore\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"sctransform\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"shiny\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"spatstat.explore\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"spatstat.geom\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"tibble\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"tools\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"uwot\" [color=\"#2297E6\"];\n  \"Seurat\" -> \"Rcpp\" [color=\"#61D04F\"];\n  \"SeuratObject\" -> \"sp\" [color=\"#DF536B\"];\n  \"SeuratObject\" -> \"future\" [color=\"#2297E6\"];\n  \"SeuratObject\" -> \"future.apply\" [color=\"#2297E6\"];\n  \"SeuratObject\" -> \"generics\" [color=\"#2297E6\"];\n  \"SeuratObject\" -> \"grid\" [color=\"#2297E6\"];\n  \"SeuratObject\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"SeuratObject\" -> \"Matrix\" [color=\"#2297E6\"];\n  \"SeuratObject\" -> \"progressr\" [color=\"#2297E6\"];\n  \"SeuratObject\" -> \"Rcpp\" [color=\"#2297E6\"];\n  \"SeuratObject\" -> \"rlang\" [color=\"#2297E6\"];\n  \"SeuratObject\" -> \"spam\" [color=\"#2297E6\"];\n  \"SeuratObject\" -> \"tools\" [color=\"#2297E6\"];\n  \"SeuratObject\" -> \"Rcpp\" [color=\"#61D04F\"];\n  \"cowplot\" -> \"ggplot2\" [color=\"#2297E6\"];\n  \"cowplot\" -> \"grid\" [color=\"#2297E6\"];\n  \"cowplot\" -> \"gtable\" [color=\"#2297E6\"];\n  \"cowplot\" -> \"rlang\" [color=\"#2297E6\"];\n  \"cowplot\" -> \"scales\" [color=\"#2297E6\"];\n  \"fastDummies\" -> \"data.table\" [color=\"#2297E6\"];\n  \"fastDummies\" -> \"tibble\" [color=\"#2297E6\"];\n  \"fastDummies\" -> \"stringr\" [color=\"#2297E6\"];\n  \"fitdistrplus\" -> \"MASS\" [color=\"#DF536B\"];\n  \"fitdistrplus\" -> \"survival\" [color=\"#DF536B\"];\n  \"fitdistrplus\" -> \"rlang\" [color=\"#2297E6\"];\n  \"future\" -> \"digest\" [color=\"#2297E6\"];\n  \"future\" -> \"globals\" [color=\"#2297E6\"];\n  \"future\" -> \"listenv\" [color=\"#2297E6\"];\n  \"future\" -> \"parallel\" [color=\"#2297E6\"];\n  \"future\" -> \"parallelly\" [color=\"#2297E6\"];\n  \"future.apply\" -> \"future\" [color=\"#DF536B\"];\n  \"future.apply\" -> \"globals\" [color=\"#2297E6\"];\n  \"future.apply\" -> \"parallel\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"cli\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"glue\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"grid\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"gtable\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"MASS\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"rlang\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"scales\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"tibble\" [color=\"#2297E6\"];\n  \"ggplot2\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"ggrepel\" -> \"ggplot2\" [color=\"#DF536B\"];\n  \"ggrepel\" -> \"grid\" [color=\"#2297E6\"];\n  \"ggrepel\" -> \"Rcpp\" [color=\"#2297E6\"];\n  \"ggrepel\" -> \"rlang\" [color=\"#2297E6\"];\n  \"ggrepel\" -> \"scales\" [color=\"#2297E6\"];\n  \"ggrepel\" -> \"Rcpp\" [color=\"#61D04F\"];\n  \"ggridges\" -> \"ggplot2\" [color=\"#2297E6\"];\n  \"ggridges\" -> \"grid\" [color=\"#2297E6\"];\n  \"ggridges\" -> \"scales\" [color=\"#2297E6\"];\n  \"httr\" -> \"jsonlite\" [color=\"#2297E6\"];\n  \"httr\" -> \"mime\" [color=\"#2297E6\"];\n  \"httr\" -> \"R6\" [color=\"#2297E6\"];\n  \"igraph\" -> \"cli\" [color=\"#2297E6\"];\n  \"igraph\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"igraph\" -> \"magrittr\" [color=\"#2297E6\"];\n  \"igraph\" -> \"Matrix\" [color=\"#2297E6\"];\n  \"igraph\" -> \"pkgconfig\" [color=\"#2297E6\"];\n  \"igraph\" -> \"rlang\" [color=\"#2297E6\"];\n  \"igraph\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"irlba\" -> \"Matrix\" [color=\"#DF536B\"];\n  \"irlba\" -> \"Matrix\" [color=\"#61D04F\"];\n  \"lifecycle\" -> \"cli\" [color=\"#2297E6\"];\n  \"lifecycle\" -> \"glue\" [color=\"#2297E6\"];\n  \"lifecycle\" -> \"rlang\" [color=\"#2297E6\"];\n  \"lmtest\" -> \"zoo\" [color=\"#DF536B\"];\n  \"Matrix\" -> \"grid\" [color=\"#2297E6\"];\n  \"Matrix\" -> \"lattice\" [color=\"#2297E6\"];\n  \"miniUI\" -> \"shiny\" [color=\"#2297E6\"];\n  \"miniUI\" -> \"htmltools\" [color=\"#2297E6\"];\n  \"patchwork\" -> \"ggplot2\" [color=\"#2297E6\"];\n  \"patchwork\" -> \"gtable\" [color=\"#2297E6\"];\n  \"patchwork\" -> \"grid\" [color=\"#2297E6\"];\n  \"patchwork\" -> \"rlang\" [color=\"#2297E6\"];\n  \"patchwork\" -> \"cli\" [color=\"#2297E6\"];\n  \"patchwork\" -> \"farver\" [color=\"#2297E6\"];\n  \"pbapply\" -> \"parallel\" [color=\"#2297E6\"];\n  \"plotly\" -> \"ggplot2\" [color=\"#DF536B\"];\n  \"plotly\" -> \"tools\" [color=\"#2297E6\"];\n  \"plotly\" -> \"scales\" [color=\"#2297E6\"];\n  \"plotly\" -> \"httr\" [color=\"#2297E6\"];\n  \"plotly\" -> \"jsonlite\" [color=\"#2297E6\"];\n  \"plotly\" -> \"magrittr\" [color=\"#2297E6\"];\n  \"plotly\" -> \"digest\" [color=\"#2297E6\"];\n  \"plotly\" -> \"viridisLite\" [color=\"#2297E6\"];\n  \"plotly\" -> \"htmltools\" [color=\"#2297E6\"];\n  \"plotly\" -> \"htmlwidgets\" [color=\"#2297E6\"];\n  \"plotly\" -> \"tidyr\" [color=\"#2297E6\"];\n  \"plotly\" -> \"RColorBrewer\" [color=\"#2297E6\"];\n  \"plotly\" -> \"dplyr\" [color=\"#2297E6\"];\n  \"plotly\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"plotly\" -> \"tibble\" [color=\"#2297E6\"];\n  \"plotly\" -> \"lazyeval\" [color=\"#2297E6\"];\n  \"plotly\" -> \"rlang\" [color=\"#2297E6\"];\n  \"plotly\" -> \"purrr\" [color=\"#2297E6\"];\n  \"plotly\" -> \"data.table\" [color=\"#2297E6\"];\n  \"plotly\" -> \"promises\" [color=\"#2297E6\"];\n  \"progressr\" -> \"digest\" [color=\"#2297E6\"];\n  \"RcppAnnoy\" -> \"Rcpp\" [color=\"#2297E6\"];\n  \"RcppAnnoy\" -> \"Rcpp\" [color=\"#61D04F\"];\n  \"RcppHNSW\" -> \"Rcpp\" [color=\"#2297E6\"];\n  \"RcppHNSW\" -> \"Rcpp\" [color=\"#61D04F\"];\n  \"reticulate\" -> \"Matrix\" [color=\"#2297E6\"];\n  \"reticulate\" -> \"Rcpp\" [color=\"#2297E6\"];\n  \"reticulate\" -> \"jsonlite\" [color=\"#2297E6\"];\n  \"reticulate\" -> \"png\" [color=\"#2297E6\"];\n  \"reticulate\" -> \"rlang\" [color=\"#2297E6\"];\n  \"reticulate\" -> \"Rcpp\" [color=\"#61D04F\"];\n  \"RSpectra\" -> \"Matrix\" [color=\"#2297E6\"];\n  \"RSpectra\" -> \"Rcpp\" [color=\"#2297E6\"];\n  \"RSpectra\" -> \"Rcpp\" [color=\"#61D04F\"];\n  \"Rtsne\" -> \"Rcpp\" [color=\"#2297E6\"];\n  \"Rtsne\" -> \"Rcpp\" [color=\"#61D04F\"];\n  \"scales\" -> \"cli\" [color=\"#2297E6\"];\n  \"scales\" -> \"farver\" [color=\"#2297E6\"];\n  \"scales\" -> \"glue\" [color=\"#2297E6\"];\n  \"scales\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"scales\" -> \"munsell\" [color=\"#2297E6\"];\n  \"scales\" -> \"R6\" [color=\"#2297E6\"];\n  \"scales\" -> \"RColorBrewer\" [color=\"#2297E6\"];\n  \"scales\" -> \"rlang\" [color=\"#2297E6\"];\n  \"scales\" -> \"viridisLite\" [color=\"#2297E6\"];\n  \"scattermore\" -> \"ggplot2\" [color=\"#2297E6\"];\n  \"scattermore\" -> \"scales\" [color=\"#2297E6\"];\n  \"scattermore\" -> \"grid\" [color=\"#2297E6\"];\n  \"sctransform\" -> \"dplyr\" [color=\"#2297E6\"];\n  \"sctransform\" -> \"magrittr\" [color=\"#2297E6\"];\n  \"sctransform\" -> \"MASS\" [color=\"#2297E6\"];\n  \"sctransform\" -> \"Matrix\" [color=\"#2297E6\"];\n  \"sctransform\" -> \"future.apply\" [color=\"#2297E6\"];\n  \"sctransform\" -> \"future\" [color=\"#2297E6\"];\n  \"sctransform\" -> \"ggplot2\" [color=\"#2297E6\"];\n  \"sctransform\" -> \"reshape2\" [color=\"#2297E6\"];\n  \"sctransform\" -> \"rlang\" [color=\"#2297E6\"];\n  \"sctransform\" -> \"gridExtra\" [color=\"#2297E6\"];\n  \"sctransform\" -> \"matrixStats\" [color=\"#2297E6\"];\n  \"sctransform\" -> \"Rcpp\" [color=\"#61D04F\"];\n  \"shiny\" -> \"httpuv\" [color=\"#2297E6\"];\n  \"shiny\" -> \"mime\" [color=\"#2297E6\"];\n  \"shiny\" -> \"jsonlite\" [color=\"#2297E6\"];\n  \"shiny\" -> \"xtable\" [color=\"#2297E6\"];\n  \"shiny\" -> \"htmltools\" [color=\"#2297E6\"];\n  \"shiny\" -> \"R6\" [color=\"#2297E6\"];\n  \"shiny\" -> \"later\" [color=\"#2297E6\"];\n  \"shiny\" -> \"promises\" [color=\"#2297E6\"];\n  \"shiny\" -> \"tools\" [color=\"#2297E6\"];\n  \"shiny\" -> \"rlang\" [color=\"#2297E6\"];\n  \"shiny\" -> \"fastmap\" [color=\"#2297E6\"];\n  \"shiny\" -> \"glue\" [color=\"#2297E6\"];\n  \"shiny\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"spatstat.explore\" -> \"spatstat.data\" [color=\"#DF536B\"];\n  \"spatstat.explore\" -> \"spatstat.univar\" [color=\"#DF536B\"];\n  \"spatstat.explore\" -> \"spatstat.geom\" [color=\"#DF536B\"];\n  \"spatstat.explore\" -> \"spatstat.random\" [color=\"#DF536B\"];\n  \"spatstat.explore\" -> \"nlme\" [color=\"#DF536B\"];\n  \"spatstat.explore\" -> \"spatstat.utils\" [color=\"#2297E6\"];\n  \"spatstat.explore\" -> \"spatstat.sparse\" [color=\"#2297E6\"];\n  \"spatstat.explore\" -> \"goftest\" [color=\"#2297E6\"];\n  \"spatstat.explore\" -> \"Matrix\" [color=\"#2297E6\"];\n  \"spatstat.explore\" -> \"abind\" [color=\"#2297E6\"];\n  \"spatstat.geom\" -> \"spatstat.data\" [color=\"#DF536B\"];\n  \"spatstat.geom\" -> \"spatstat.univar\" [color=\"#DF536B\"];\n  \"spatstat.geom\" -> \"spatstat.utils\" [color=\"#2297E6\"];\n  \"spatstat.geom\" -> \"deldir\" [color=\"#2297E6\"];\n  \"spatstat.geom\" -> \"polyclip\" [color=\"#2297E6\"];\n  \"tibble\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"tibble\" -> \"magrittr\" [color=\"#2297E6\"];\n  \"tibble\" -> \"pillar\" [color=\"#2297E6\"];\n  \"tibble\" -> \"pkgconfig\" [color=\"#2297E6\"];\n  \"tibble\" -> \"rlang\" [color=\"#2297E6\"];\n  \"tibble\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"uwot\" -> \"Matrix\" [color=\"#DF536B\"];\n  \"uwot\" -> \"irlba\" [color=\"#2297E6\"];\n  \"uwot\" -> \"Rcpp\" [color=\"#2297E6\"];\n  \"uwot\" -> \"RcppAnnoy\" [color=\"#2297E6\"];\n  \"uwot\" -> \"RSpectra\" [color=\"#2297E6\"];\n  \"uwot\" -> \"Rcpp\" [color=\"#61D04F\"];\n  \"uwot\" -> \"RcppAnnoy\" [color=\"#61D04F\"];\n  \"sp\" -> \"lattice\" [color=\"#2297E6\"];\n  \"sp\" -> \"grid\" [color=\"#2297E6\"];\n  \"spam\" -> \"dotCall64\" [color=\"#2297E6\"];\n  \"spam\" -> \"grid\" [color=\"#2297E6\"];\n  \"spam\" -> \"Rcpp\" [color=\"#2297E6\"];\n  \"spam\" -> \"Rcpp\" [color=\"#61D04F\"];\n  \"gtable\" -> \"cli\" [color=\"#2297E6\"];\n  \"gtable\" -> \"glue\" [color=\"#2297E6\"];\n  \"gtable\" -> \"grid\" [color=\"#2297E6\"];\n  \"gtable\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"gtable\" -> \"rlang\" [color=\"#2297E6\"];\n  \"stringr\" -> \"cli\" [color=\"#2297E6\"];\n  \"stringr\" -> \"glue\" [color=\"#2297E6\"];\n  \"stringr\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"stringr\" -> \"magrittr\" [color=\"#2297E6\"];\n  \"stringr\" -> \"rlang\" [color=\"#2297E6\"];\n  \"stringr\" -> \"stringi\" [color=\"#2297E6\"];\n  \"stringr\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"survival\" -> \"Matrix\" [color=\"#2297E6\"];\n  \"survival\" -> \"splines\" [color=\"#2297E6\"];\n  \"globals\" -> \"codetools\" [color=\"#2297E6\"];\n  \"parallel\" -> \"tools\" [color=\"#2297E6\"];\n  \"parallel\" -> \"compiler\" [color=\"#2297E6\"];\n  \"parallelly\" -> \"parallel\" [color=\"#2297E6\"];\n  \"parallelly\" -> \"tools\" [color=\"#2297E6\"];\n  \"vctrs\" -> \"cli\" [color=\"#2297E6\"];\n  \"vctrs\" -> \"glue\" [color=\"#2297E6\"];\n  \"vctrs\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"vctrs\" -> \"rlang\" [color=\"#2297E6\"];\n  \"mime\" -> \"tools\" [color=\"#2297E6\"];\n  \"zoo\" -> \"lattice\" [color=\"#2297E6\"];\n  \"lattice\" -> \"grid\" [color=\"#2297E6\"];\n  \"htmltools\" -> \"digest\" [color=\"#2297E6\"];\n  \"htmltools\" -> \"fastmap\" [color=\"#2297E6\"];\n  \"htmltools\" -> \"rlang\" [color=\"#2297E6\"];\n  \"htmlwidgets\" -> \"htmltools\" [color=\"#2297E6\"];\n  \"htmlwidgets\" -> \"jsonlite\" [color=\"#2297E6\"];\n  \"tidyr\" -> \"cli\" [color=\"#2297E6\"];\n  \"tidyr\" -> \"dplyr\" [color=\"#2297E6\"];\n  \"tidyr\" -> \"glue\" [color=\"#2297E6\"];\n  \"tidyr\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"tidyr\" -> \"magrittr\" [color=\"#2297E6\"];\n  \"tidyr\" -> \"purrr\" [color=\"#2297E6\"];\n  \"tidyr\" -> \"rlang\" [color=\"#2297E6\"];\n  \"tidyr\" -> \"stringr\" [color=\"#2297E6\"];\n  \"tidyr\" -> \"tibble\" [color=\"#2297E6\"];\n  \"tidyr\" -> \"tidyselect\" [color=\"#2297E6\"];\n  \"tidyr\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"cli\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"generics\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"glue\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"magrittr\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"pillar\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"R6\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"rlang\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"tibble\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"tidyselect\" [color=\"#2297E6\"];\n  \"dplyr\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"purrr\" -> \"cli\" [color=\"#2297E6\"];\n  \"purrr\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"purrr\" -> \"magrittr\" [color=\"#2297E6\"];\n  \"purrr\" -> \"rlang\" [color=\"#2297E6\"];\n  \"purrr\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"purrr\" -> \"cli\" [color=\"#61D04F\"];\n  \"promises\" -> \"fastmap\" [color=\"#2297E6\"];\n  \"promises\" -> \"later\" [color=\"#2297E6\"];\n  \"promises\" -> \"magrittr\" [color=\"#2297E6\"];\n  \"promises\" -> \"R6\" [color=\"#2297E6\"];\n  \"promises\" -> \"Rcpp\" [color=\"#2297E6\"];\n  \"promises\" -> \"rlang\" [color=\"#2297E6\"];\n  \"promises\" -> \"later\" [color=\"#61D04F\"];\n  \"promises\" -> \"Rcpp\" [color=\"#61D04F\"];\n  \"munsell\" -> \"colorspace\" [color=\"#2297E6\"];\n  \"reshape2\" -> \"plyr\" [color=\"#2297E6\"];\n  \"reshape2\" -> \"Rcpp\" [color=\"#2297E6\"];\n  \"reshape2\" -> \"stringr\" [color=\"#2297E6\"];\n  \"reshape2\" -> \"Rcpp\" [color=\"#61D04F\"];\n  \"gridExtra\" -> \"gtable\" [color=\"#2297E6\"];\n  \"gridExtra\" -> \"grid\" [color=\"#2297E6\"];\n  \"httpuv\" -> \"later\" [color=\"#2297E6\"];\n  \"httpuv\" -> \"promises\" [color=\"#2297E6\"];\n  \"httpuv\" -> \"R6\" [color=\"#2297E6\"];\n  \"httpuv\" -> \"Rcpp\" [color=\"#2297E6\"];\n  \"httpuv\" -> \"later\" [color=\"#61D04F\"];\n  \"httpuv\" -> \"Rcpp\" [color=\"#61D04F\"];\n  \"later\" -> \"Rcpp\" [color=\"#2297E6\"];\n  \"later\" -> \"rlang\" [color=\"#2297E6\"];\n  \"later\" -> \"Rcpp\" [color=\"#61D04F\"];\n  \"spatstat.data\" -> \"spatstat.utils\" [color=\"#2297E6\"];\n  \"spatstat.data\" -> \"Matrix\" [color=\"#2297E6\"];\n  \"spatstat.univar\" -> \"spatstat.utils\" [color=\"#2297E6\"];\n  \"spatstat.random\" -> \"spatstat.data\" [color=\"#DF536B\"];\n  \"spatstat.random\" -> \"spatstat.univar\" [color=\"#DF536B\"];\n  \"spatstat.random\" -> \"spatstat.geom\" [color=\"#DF536B\"];\n  \"spatstat.random\" -> \"spatstat.utils\" [color=\"#2297E6\"];\n  \"nlme\" -> \"lattice\" [color=\"#2297E6\"];\n  \"spatstat.sparse\" -> \"Matrix\" [color=\"#DF536B\"];\n  \"spatstat.sparse\" -> \"abind\" [color=\"#DF536B\"];\n  \"spatstat.sparse\" -> \"tensor\" [color=\"#DF536B\"];\n  \"spatstat.sparse\" -> \"spatstat.utils\" [color=\"#2297E6\"];\n  \"pillar\" -> \"cli\" [color=\"#2297E6\"];\n  \"pillar\" -> \"glue\" [color=\"#2297E6\"];\n  \"pillar\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"pillar\" -> \"rlang\" [color=\"#2297E6\"];\n  \"pillar\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"stringi\" -> \"tools\" [color=\"#2297E6\"];\n  \"tidyselect\" -> \"cli\" [color=\"#2297E6\"];\n  \"tidyselect\" -> \"glue\" [color=\"#2297E6\"];\n  \"tidyselect\" -> \"lifecycle\" [color=\"#2297E6\"];\n  \"tidyselect\" -> \"rlang\" [color=\"#2297E6\"];\n  \"tidyselect\" -> \"vctrs\" [color=\"#2297E6\"];\n  \"plyr\" -> \"Rcpp\" [color=\"#2297E6\"];\n  \"plyr\" -> \"Rcpp\" [color=\"#61D04F\"];\n}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}</script>

And you can try the moster below. I will not execute it in this document.

``` r
dep_in_session("Seurat", db = db, dep_group = "all")
```
