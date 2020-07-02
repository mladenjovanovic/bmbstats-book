--- 
title: "bmbstats: bootstrap magnitude-based statistics for sports scientists"
author: "Mladen Jovanovic"
date: "2020-07-02"
site: bookdown::bookdown_site
output: 
  bookdown::gitbook
documentclass: book
bibliography: ["citations/references.bib", "citations/r-references.bib"]
biblio-style: apalike
link-citations: yes
github-repo: mladenjovanovic/bmbstats-book
url: www.complementarytraining.net
twitter-handle: physical_prep
editor_options: 
  chunk_output_type: console
---


# Welcome {-}

<img src="figures/bmbstats-book-mockup-small.jpg" align="right" alt="Cover image" /></a>

The aim of this book is to provide an overview of the three classes of tasks in the statistical modeling: description, prediction and causal inference [@hernanSecondChanceGet2019]. Statistical inference is often required for all three tasks. Short introduction to frequentist null-hypothesis testing, Bayesian estimation and bootstrap are provided. Special attention is given to the practical significance with the introduction of magnitude-based estimators and statistical inference by using the concept of smallest effect size of interest (SESOI). Measurement error is discussed with the particular aim of interpreting individual change scores. In the second part of this book, common sport science problems are introduced and analyzed with the `bmbstats` package.

This book, as well as the `bmbstats` package are currently in development phase. Please be free to contribute pull request at GitHub

#### bmbstats package {-}

https://github.com/mladenjovanovic/bmbstats

#### bmbstats book {-}

https://github.com/mladenjovanovic/bmbstats-book

## R and R packages {-}

This book is fully reproducible and was written in R [Version 4.0.0; @R-base] and the R-packages *automatic* [@R-automatic], *bayestestR* [Version 0.6.0; @R-bayestestR], *bmbstats* [Version 0.0.0.9000; @R-bmbstats], *bookdown* [Version 0.18; @R-bookdown], *boot* [Version 1.3.25; @R-boot], *carData* [Version 3.0.3; @R-carData], *caret* [Version 6.0.86; @R-caret], *cowplot* [Version 1.0.0; @R-cowplot], *directlabels* [Version 2020.1.31; @R-directlabels], *dplyr* [Version 1.0.0; @R-dplyr], *effects* [Version 4.1.4; @R-effects_a; @R-effects_b; @R-effects_c], *forcats* [Version 0.5.0; @R-forcats], *ggplot2* [Version 3.3.2; @R-ggplot2], *ggridges* [Version 0.5.2; @R-ggridges], *ggstance* [Version 0.3.4; @R-ggstance], *hardhat* [Version 0.1.3; @R-hardhat], *kableExtra* [Version 1.1.0; @R-kableExtra], *knitr* [Version 1.28; @R-knitr], *lattice* [Version 0.20.41; @R-lattice], *markdown* [Version 1.1; @R-markdown], *Metrics* [Version 0.1.4; @R-Metrics], *minerva* [Version 1.5.8; @R-minerva], *mlr* [Version 2.17.1; @R-mlr; @R-mlr3; @R-mlrmbo], *mlr3* [Version 0.3.0; @R-mlr3], *mlrmbo* [@R-mlrmbo], *multilabel* [@R-multilabel], *openml* [@R-openml], *ParamHelpers* [Version 1.14; @R-ParamHelpers], *pdp* [Version 0.7.0; @R-pdp], *psych* [Version 1.9.12.31; @R-psych], *purrr* [Version 0.3.4; @R-purrr], *readr* [Version 1.3.1; @R-readr], *rpart* [Version 4.1.15; @R-rpart], *stringr* [Version 1.4.0; @R-stringr], *tibble* [Version 3.0.1; @R-tibble], *tidyr* [Version 1.1.0; @R-tidyr], *tidyverse* [Version 1.3.0; @R-tidyverse], *vip* [Version 0.2.2; @R-vip], and *visreg* [Version 2.6.1; @R-visreg].

## License {-}

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons Licence" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a>

This work, as a whole, is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.

The code contained in this book is simultaneously available under the [MIT license](https://opensource.org/licenses/MIT); this means that you are free to use it in your own packages, as long as you cite the source.
