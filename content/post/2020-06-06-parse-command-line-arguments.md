---
title: "Parse command-line arguments"
date: 2020-06-06
author: Zuguang Gu
---



<style>
pre.terminal {
	background: hsl(70, 0%, 15%);
	color: white;
}
pre.terminal .hljs {
	background: hsl(70, 0%, 15%);
	color: white;
}
</style>



There are already several R packages which parse command-line arguments such
as [**getopt**](https://CRAN.R-project.org/package=getopt),
[**optparse**](https://CRAN.R-project.org/package=optparse),
[**argparse**](https://CRAN.R-project.org/package=argparse),
[**docopt**](https://CRAN.R-project.org/package=docopt). Here
**GetoptLong** is another command-line argument parser (actually it was
developed very early. [The first CRAN
version](https://cran.r-project.org/src/contrib/Archive/GetoptLong/) was in
2013) which wraps the powerful Perl module
[`Getopt::Long`](https://metacpan.org/pod/Getopt::Long). **GetoptLong**
package also provides some adaptations for easier use in R.

Using **GetoptLong** is simple especially for users having Perl experience (Oops, age
exposed :)) because the specification is almost the same as in Perl. The
original website of
[`Getopt::Long`](https://metacpan.org/pod/Getopt::Long) is always
your best reference.

The documentation of the package is at http://jokergoo.github.io/GetoptLong/articles/GetoptLong.html. 
Here this post is a simplified version.

The **GetoptLong** package has not been udpated to CRAN yet, so you need to install it
from GitHub:

```r
devtools::install_github("jokergoo/GetoptLong")
```

## A quick example

### Specify as a vector

The following example gives you some feels of using **GetoptLong** package. The following
code is saved in to an R script named `foo.R`.


``` r
library(GetoptLong)

cutoff = 0.05
GetoptLong(
    "number=i", "Number of items.",
    "cutoff=f", "Cutoff for filtering results.",
    "verbose",  "Print message."
)
```

The R script can be executed as:

```terminal
~\> Rscript foo.R --number 4 --cutoff 0.01 --verbose
~\> Rscript foo.R --number=4 --cutoff=0.01 --verbose
~\> Rscript foo.R -n 4 -c 0.01 -v
~\> Rscript foo.R -n 4 --verbose
```

In this example, `number` is a mandatory option and it should only be in
integer mode (has a tab `i`). `cutoff` is numeric (tag `f`) and optional and
it already has a default value 0.05. `verbose` is a logical option. If parsing
is successful, two variables `number` and `verbose` will be imported into the
working environment with the specified values. Value for `cutoff` will be
updated if it is specified in command-line.

Data types are automatically checked. _E.g._, if `cutoff` is specified with a character,
an error will be thrown.

The option usage triggered by `--help` is automatically generated. There are
two styles:

The one-column style:


``` terminal
Usage: Rscript foo.R [options]

Options:
  --number, -n integer
    Number of items.
 
  --cutoff, -c numeric
    Cutoff for filtering results.
    [default: 0.05]
 
  --verbose
    Print message.
 
  --help, -h
    Print help message and exit.
 
  --version
    Print version information and exit.
 
```

Or the two-column style:


``` terminal
Usage: Rscript foo.R [options]

Options:
  --number, -n     Number of items.
    [type: int] 
  --cutoff, -c     Cutoff for filtering results.                 
    [type: num]    [default: 0.05] 
  --verbose        Print message. 
  --help, -h       Print help message and exit. 
  --version        Print version information and exit. 
```

You can find the short option names (in single letters, _e.g._, `-n`, `-c`,
`-h`) are automatically added. The information of default values is added as
well (_e.g._, `[default: 0.05]` for `cutoff` option).

### Specify as a template

The specification can also be set as a template where the specifications are marked
by `<>`.


``` r
library(GetoptLong)
spec = "
This is an example of using template to specify options.

Usage: Rscript foo.R [options]

Options:
  <number=i> Number of items.
  <cutoff=f> Cutoff for filtering results.               
  <verbose> Print messages.

Contact: name@address
"

GetoptLong(spec, template_control = list(opt_width = 23))
```

The parameter `opt_width` controls the maximal width of the option description
(_i.e._, `--number, -n integer`, `--cutoff, -c numeric` and `--verbose`).

Calling `Rscript foo.R --help` generates the following message:


``` terminal
This is an example of using template to specify options.

Usage: Rscript foo.R [options]

Options:
  --number, -n integer    Number of items.
  --cutoff, -c numeric    Cutoff for filtering results.               
  --verbose               Print messages.

Contact: name@address 
```

## Advantages

There are several advantages compared to other command-line argument parser
packages. The major advantage comes from the `Getopt::Long` Perl module which
actually parses the options. The `Getopt::Long` module provides a flexible,
smart and compact way for specifying command-line arguments. The major
features are:

1. Various formats of specifying options with values, such as

```terminal
-s 24 -s24
```

or 

```terminal
--size 24  --size=24 -size 24  -size=24
```

2. Single-letter options can be bundled:

```terminal
-a -b -c  -abs
```

3. Options with multiple names. With the following specification, `--length`,
   `--height` are the same.

```terminal
length|height=f
```

4. Automatically support single-letter options. If the first letter of an
   option is unique to all other options, the first letter can be used as an
   optional option name. For example, if `l` and `h` are unique, `--length`,
   `--height`, `-l` and `-h` set the same option.

```terminal
length|height=f  --length --height -l -h
```

5. Rich option data types, including scalar, vector (array in Perl), list (hash
   in Perl). For example:

```terminal
length=i     a single integer scalar
name=s       a single character scalar
```

can be specified as:

```terminal
--length 1 --name a
```

or

```terminal
length=i@       a integer vector
name=s@         a character vector
length=i{2,}    a integer vector, at least two elements
name=s{2,}      a character vector, at least two elements
```
can be specified as:

```terminal
--length 1 2 3 --name a b c
```

or

```terminal
length=i%    name-value pair, values should be integers
name=s%      name-value pair, values should be characters
```

to be specified as:

```terminal
--length foo=1 bar=3 --name foo=a bar=b
```

The features from R part are:

1. It automaticlly generates option usage in two styles. The data type and
   default value of options are automatically detected and included.

2. It supports specifying the usage in a template which allows more complex
   text of option usage.

3. It allows grouping options.

4. It provides a natural and convenient way to specify defaults.


## Help option

Option usage is automatically generated and can be retrieved by setting
`--help` in the command. In following example, I create an option
specification that contains all types of options (with long descriptions):


``` r
library(GetoptLong)
GetoptLong(
    "count=i",  paste("This is a count. This is a count. This is a count.",
                      "This is a count.  This is a count. This is a count."),
    "number=f", paste("This is a number. This is a number. This is a number.",
                      "This is a number. This is a number. This is a number."),
    "array=f@", paste("This is an array. This is an array. This is an array.",
                      "This is an array. This is an array. This is an array."),
    "hash=s%",  paste("This is a hash. This is a hash. This is a hash.",
                      "This is a hash. This is a hash. This is a hash."),
    "verbose!", "Whether show messages",
    "flag",     "a non-sense option"
)
```

The option usage is as follows. Here, for example, the single-letter option
`-c` for `--count` is automatically extracted while not for `--help` because `h`
matches two options.


``` terminal
Usage: Rscript foo.R [options]

Options:
  --count, -c integer
    This is a count. This is a count. This is a count. This is a count.  This is
    a count. This is a count.
 
  --number, -n numeric
    This is a number. This is a number. This is a number. This is a number. This
    is a number. This is a number.
 
  --array, -a [numeric, ...]
    This is an array. This is an array. This is an array. This is an array. This
    is an array. This is an array.
 
  --hash {name=character, ...}
    This is a hash. This is a hash. This is a hash. This is a hash. This is a
    hash. This is a hash.
 
  --verbose, -no-verbose
    Whether show messages
    [default: off]
 
  --flag, -f
    a non-sense option
 
  --help
    Print help message and exit.
 
  --version
    Print version information and exit.
 
```

If default values for options are provided, they are properly inserted to the
usage message.

```r
library(GetoptLong)
count = 1
number = 0.1
array = c(1, 2)
hash = list("foo" = "a", "bar" = "b")
verbose = TRUE

GetoptLong(
  ...
)
```



``` terminal
Usage: Rscript foo.R [options]

Options:
  --count, -c integer
    This is a count. This is a count. This is a count. This is a count.  This is
    a count. This is a count.
    [default: 1]
 
  --number, -n numeric
    This is a number. This is a number. This is a number. This is a number. This
    is a number. This is a number.
    [default: 0.1]
 
  --array, -a [numeric, ...]
    This is an array. This is an array. This is an array. This is an array. This
    is an array. This is an array.
    [default: 1, 2]
 
  --hash {name=character, ...}
    This is a hash. This is a hash. This is a hash. This is a hash. This is a
    hash. This is a hash.
    [default: foo=a, bar=b]
 
  --verbose, -no-verbose
    Whether show messages
    [default: on]
 
  --flag, -f
    a non-sense option
 
  --help
    Print help message and exit.
 
  --version
    Print version information and exit.
 
```


The global parameters `help_style` can be set to `two-column` to change
to another style:


``` r
library(GetoptLong)
GetoptLong.options(help_style = "two-column")
# specifying the defaults
...

GetoptLong{
    ...
}
```



``` terminal
Usage: Rscript foo.R [options]

Options:
  --count, -c                  This is a count. This is a count. This is a count.
    [type: int]                This is a count.  This is a count. This is a count.                             
                               [default: 1] 
  --number, -n                 This is a number. This is a number. This is a
    [type: num]                number. This is a number. This is a number. This is
                               a number.                             
                               [default: 0.1] 
  --array, -a                  This is an array. This is an array. This is an
    [type: [num, ...]]         array. This is an array. This is an array. This is
                               an array.                             
                               [default: 1, 2] 
  --hash                       This is a hash. This is a hash. This is a hash. This
    [type: {name=chr, ...}]    is a hash. This is a hash. This is a hash.                             
                               [default: foo=a, bar=b] 
  --verbose, -no-verbose       Whether show messages                             
                               [default: on] 
  --flag, -f                   a non-sense option 
  --help                       Print help message and exit. 
  --version                    Print version information and exit. 
```


The options in the usage text can be grouped by setting separator lines.
The separator line should contain two elements: the separator and the description.
The separator can be any character in `-+=#%` with any length.


``` r
library(GetoptLong)
count = 1
array = c(0.1, 0.2)
GetoptLong(
    "--------", "Binary options:",
    "verbose!", "Whether show messages",
    "flag",     "a non-sense option",

    "-------", "Single-value options:",
    "count=i",  paste("This is a count. This is a count. This is a count.",
                      "This is a count.  This is a count. This is a count."),
    "number=f", paste("This is a number. This is a number. This is a number.",
                      "This is a number. This is a number. This is a number."),
    
    "--------", paste("Multiple-vlaue options: long text long text long text",
                      " long text long text long text long text long text"),
    "array=f@", paste("This is an array. This is an array. This is an array.",
                      "This is an array. This is an array. This is an array."),
    "hash=s%",  paste("This is a hash. This is a hash. This is a hash.",
                      "This is a hash. This is a hash. This is a hash."),
    
    "-------", "Other options:"
)
```


``` terminal
Usage: Rscript foo.R [options]

Binary options:
  --verbose, -no-verbose
    Whether show messages
    [default: off]
 
  --flag, -f
    a non-sense option
 
Single-value options:
  --count, -c integer
    This is a count. This is a count. This is a count. This is a count.  This is
    a count. This is a count.
    [default: 1]
 
  --number, -n numeric
    This is a number. This is a number. This is a number. This is a number. This
    is a number. This is a number.
 
Multiple-vlaue options: long text long text long text long text long text long
text long text long text
  --array, -a [numeric, ...]
    This is an array. This is an array. This is an array. This is an array. This
    is an array. This is an array.
    [default: 0.1, 0.2]
 
  --hash {name=character, ...}
    This is a hash. This is a hash. This is a hash. This is a hash. This is a
    hash. This is a hash.
 
Other options:
  --help
    Print help message and exit.
 
  --version
    Print version information and exit.
 
```

And the two-column style for the grouped options.


``` r
library(GetoptLong)
GetoptLong.options(help_style = "two-column")
GetoptLong{
    ...
}
```


``` terminal
Usage: Rscript foo.R [options]

Binary options:
  --verbose, -no-verbose    Whether show messages                          
                            [default: off] 
  --flag, -f                a non-sense option 

Single-value options:
  --count, -c      This is a count. This is a count. This is a count. This is a
    [type: int]    count.  This is a count. This is a count.                 
                   [default: 1] 
  --number, -n     This is a number. This is a number. This is a number. This is
    [type: num]    a number. This is a number. This is a number. 

Multiple-vlaue options: long text long text long text long text long text long
text long text long text
  --array, -a                  This is an array. This is an array. This is an
    [type: [num, ...]]         array. This is an array. This is an array. This is
                               an array.                             
                               [default: 0.1, 0.2] 
  --hash                       This is a hash. This is a hash. This is a hash. This
    [type: {name=chr, ...}]    is a hash. This is a hash. This is a hash. 

Other options:
  --help       Print help message and exit. 
  --version    Print version information and exit. 
```

For more detailed explanationa, please go to [the web site of **GetoptLong**
package](http://jokergoo.github.io/GetoptLong/).

## Session info


``` r
sessionInfo()
```

``` NULL
R version 4.4.2 (2024-10-31)
Platform: aarch64-apple-darwin20
Running under: macOS 26.0.1

Matrix products: default
BLAS:   /Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/lib/libRblas.0.dylib 
LAPACK: /Library/Frameworks/R.framework/Versions/4.4-arm64/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.0

locale:
[1] C.UTF-8/UTF-8/C.UTF-8/C/C.UTF-8/C.UTF-8

time zone: Europe/Berlin
tzcode source: internal

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] GetoptLong_1.0.5 knitr_1.50       colorout_1.3-2  

loaded via a namespace (and not attached):
 [1] digest_0.6.37       R6_2.6.1            GlobalOptions_0.1.2
 [4] bookdown_0.44       fastmap_1.2.0       xfun_0.51          
 [7] blogdown_1.19       rjson_0.2.23        cachem_1.1.0       
[10] htmltools_0.5.8.1   rmarkdown_2.29      lifecycle_1.0.4    
[13] cli_3.6.4           sass_0.4.9          jquerylib_0.1.4    
[16] compiler_4.4.2      tools_4.4.2         evaluate_1.0.3     
[19] bslib_0.9.0         yaml_2.3.10         crayon_1.5.3       
[22] jsonlite_1.9.0      rlang_1.1.5        
```

