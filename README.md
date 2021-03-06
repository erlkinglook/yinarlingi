
<!-- README.md is generated from README.Rmd. Please edit that file -->

# yinarlingi <img src="man/figures/yinarlingi.png" align="right" width="100px" />

## Overview

The purpose of yinarlingi is to provide a set of convenience functions
for validating Warlpiri dictionary data. Essentially, it pre-configures
various functions from the [tidylex](https://coedl.github.io/tidylex/)
and [tidyverse](https://www.tidyverse.org/) packages with parameters
specific to the Warlpiri dictionary data, so that those within the
Warlpiri dictionary project can quickly run and re-run frequently used
routines (e.g. data validation, derived views), and also so that these
tests can be run in a Continuous Testing/Continuous Deployment
environment such as [GitLab pipelines](https://docs.gitlab.com/ee/ci/):

![](man/figures/pipeline.png)

Yinarlingi is a Warlpiri word for echidna.

## Installation

You can install yinarlingi from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("CoEDL/yinarlingi")
```

## Examples

### Test that a Warlpiri dictionary entry’s data lines are well-ordered

The Warlpiri dictionary consists of a large plain text file of the form
(where `\me` stands for main entry; see [full list of
codes](https://github.com/CoEDL/yinarlingi/blob/master/inst/structures/wlp_code-definitions.csv)):

    \me jampaly(pa) (N) (PV): (La,Wi,Y)
    \dm spatial: tactile: \edm
    \gl sharp, pointed \egl
    \rv sharp \erv
    \eg
    \we Karlangu ka karri jampalypa ngulaju yiri-nyayirni. \[@@]
    \et The digging stick is sharp, that is very sharp pointed. \ewe
    \eeg
    \ant jampilypa, munju \eant
    \cf jaarn-karri-mi, lirra jampalypa \ecf
    \syn jalkarra, larrilpi, yiri \esyn
    \eme
    \sse jampaly-pi-nyi (V):
    \def xERG cause y to come to be sharp (<jampalypa>) \edef
    \gl sharpen, trim to ^point \egl
    \rv sharpen \erv
    \eg
    \we Jampaly-pungulpalu wangkinypa, yangka kuja munju-jarrija. \[@@]
    \et They sharpened the stone-axe which had became blunt. \ewe
    \we Karlangulu jampalypa-pungu. \[Tiger Jakamarra]
    \et They sharpened the points of the digging sticks. \ewe
    \eeg
    \csl YSL#1336, YSL#313 \ecsl
    \syn yiri-ma-ni \esyn
    \esse
    
    ...

A well-structured Warlpiri entry is defined as a
[Nearley](https://nearley.js.org/) grammar (see full grammar
[here](https://github.com/CoEDL/yinarlingi/blob/master/inst/structures/wlp_skeleton-simple.ne)),
of which a snippet is shown below:

``` nearley
entryBlock       -> "org":? "dm":* "def":? "lat":? "gl":? "rv":? "cm":*
                      (exampleBlock:+ | paradigmExample:+):?
                      crossRefs
```

We can see here that a semantic domain line `dm` must come *before* the
gloss line `gl`. So, the following data (provided in
`wlp-lexicon_invalid-sequence.txt`) clearly does not satisfy this
requirement:

<pre>
\me jampaly(pa) (N) (PV): (La,Wi,Y)
<span style="color:red">\gl sharp, pointed \egl</span>
\dm spatial: tactile: \edm
...
</pre>

The yinarlingi test suite uses the `test_code1_ordered()` function to
catch such cases (notice `code1_ok` is `FALSE` on the third line):

``` r
library(yinarlingi)

# Get local path to the yinarlingi-provided file, 'wlp-lexicon_invalid-sequence.txt'
invalid_lexicon_path <- system.file("extdata/wlp-lexicon_invalid-sequence.txt", package = "yinarlingi")

test_code1_ordered(invalid_lexicon_path) %>%
    knitr::kable() # For pretty display of table
```

| me\_start                           | line | data                                                      | code1 | code1\_ok | error            |
| :---------------------------------- | ---: | :-------------------------------------------------------- | :---- | :-------- | :--------------- |
| 1 : jampaly(pa) (N) (PV): (La,Wi,Y) |    1 | jampaly(pa) (N) (PV): (La,Wi,Y)                           | me    | TRUE      | NA               |
|                                     |    2 | sharp, pointed                                            | gl    | TRUE      | NA               |
|                                     |    3 | spatial: tactile:                                         | dm    | FALSE     | Unexpected code1 |
|                                     |    4 | sharp                                                     | rv    | NA        | NA               |
|                                     |    5 |                                                           | eg    | NA        | NA               |
|                                     |    6 | Karlangu ka karri jampalypa ngulaju yiri-nyayirni. \[@@\] | we    | NA        | NA               |
