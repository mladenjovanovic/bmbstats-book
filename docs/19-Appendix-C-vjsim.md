---
output: html_document
editor_options: 
  chunk_output_type: console
---



# Appendix C: `vjsim` package

<img src="figures/vjsim-logo.png" align="right" width="200" />

`vjsim` [@R-vjsim] is R package that simulates vertical jump with the aim of teaching basic biomechanical principles, FV profiling, and exploring assumptions of FV optimization models. 

## `vjsim` Installation

You can install the development version from [GitHub](https://github.com/mladenjovanovic/vjsim) with:

``` r
# install.packages("devtools")
devtools::install_github("mladenjovanovic/vjsim")

require(vjsim)
```

## `vjsim` Usage

Please read accompanying vignettes for examples and usage of the `vjsim` package


### [Introduction to vjsim](https://mladenjovanovic.github.io/vjsim/articles/introduction-vjsim.html)

This vignette discusses the basic mechanical representation of the vertical jump system. Please read this to understand the overall setup. Access it by clicking the above link or running the following code:

``` r
vignette("introduction-vjsim")
```

### [Simulation](https://mladenjovanovic.github.io/vjsim/articles/simulation-vjsim.html)

This vignette continues the [Introduction](https://mladenjovanovic.github.io/vjsim/articles/introduction-vjsim.html) vignette and expands on the topic of simulation and how vertical jump is simulated. Access it by clicking the above link or running the following code:

``` r
vignette("simulation-vjsim")
```

### [Profiling](https://mladenjovanovic.github.io/vjsim/articles/profiling-vjsim.html)

Once you understand how the [Simulation](https://mladenjovanovic.github.io/vjsim/articles/simulation-vjsim.html) works, we can start playing with profiling. Force-Velocity (FV), Load-Velocity (LV), and other profiles are discussed. Access it by clicking the above link or running the following code:

``` r
vignette("profiling-vjsim")
```

### [Optimization](https://mladenjovanovic.github.io/vjsim/articles/optimization-vjsim.html)

In this vignette I will introduce few optimization models, influenced by the work of Pierre Samozino and Jean-Benoit Morin. Access it by clicking the above link or running the following code:

``` r
vignette("optimization-vjsim")
```

### [Exploring](https://mladenjovanovic.github.io/vjsim/articles/exploring-vjsim.html)

In this vignette we are going to explore various assumptions of the model, "optimal" FV profiles and some other interesting questions. Access it by clicking the above link or running the following code:

``` r
vignette("exploring-vjsim")
```

### [Modeling](https://mladenjovanovic.github.io/vjsim/articles/modeling-vjsim.html)

In this vignette I am going to show you how you can use `vjsim` to create athlete profiles from collected data

``` r
vignette("modeling-vjsim")
```


## [Shiny App](https://athletess.shinyapps.io/shiny-simulator/)

To run the Shiny app, use the following code, or by clicking on the above link (this will take you to the *shinyapps.io*)
``` r
# install.packages(c("shiny", "plotly", "DT"))
run_simulator()
```

## `vjsim` Example

`vjsim` comes with an example data (`testing_data`) that can be used to demonstrate the profiling:


```r
require(vjsim)
require(tidyverse)

data("testing_data")

testing_data
#>    athlete bodyweight push_off_distance external_load
#> 1     John        100              0.45             0
#> 2     John        100              0.45            20
#> 3     John        100              0.45            40
#> 4     John        100              0.45            60
#> 5     John        100              0.45            80
#> 6     Jack         85              0.35             0
#> 7     Jack         85              0.35            20
#> 8     Jack         85              0.35            40
#> 9     Jack         85              0.35            60
#> 10   Peter         95              0.50             0
#> 11   Peter         95              0.50            20
#> 12   Peter         95              0.50            40
#> 13   Peter         95              0.50            60
#> 14   Peter         95              0.50           100
#> 15    Jane         55              0.30             0
#> 16    Jane         55              0.30            10
#> 17    Jane         55              0.30            20
#> 18    Jane         55              0.30            30
#> 19    Jane         55              0.30            40
#> 20   Chris         75                NA             0
#> 21   Chris         75                NA            20
#> 22   Chris         75                NA            40
#> 23   Chris         75                NA            60
#> 24   Chris         75                NA            80
#>    aerial_time
#> 1    0.5393402
#> 2    0.4692551
#> 3    0.4383948
#> 4    0.3869457
#> 5    0.3383155
#> 6    0.4991416
#> 7    0.4188160
#> 8    0.3664766
#> 9    0.2746293
#> 10   0.6908913
#> 11   0.5973635
#> 12   0.5546890
#> 13   0.4896103
#> 14   0.4131987
#> 15   0.4589603
#> 16   0.4310090
#> 17   0.3717250
#> 18   0.3354157
#> 19   0.3197858
#> 20   0.4943675
#> 21   0.4618711
#> 22   0.4318388
#> 23   0.4013240
#> 24   0.3696963
```

As can be seen from the above listing, `testing_data` contains data for N=5 athletes. Each athlete performed progressive squat jumps (external load is indicated in `external_load` column; weight are in kg) and the flight time (`aerial_time`) in seconds is measured using the jump mat. Some measuring devices will return *peak velocity* (PV), *take-off velocity* (TOV), or calculated *jump height* (height) which is the most common. 

We will select Jack and show his *Load-Velocity* (LV) profile using `vsim` function `vjsim::make_load_profile`[^omit_vjsim]: 

[^omit_vjsim]: You can omit typing `vjsim::` in the code. I use it here to indicate functions from the `vjsim` package).


```r
# Filter only Jack's data
jack_data <- filter(testing_data, athlete == "Jack")

# Make a LV profile Here we have used `with` command to
# simplify the code If not we need to use:
# vjsim::make_load_profile( bodyweight =
# jack_data$bodyweight, external_load =
# jack_data$external_load, aerial_time =
# jack_data$aerial_time, plot = TRUE )

jack_LV_profile <- with(jack_data, vjsim::make_load_profile(bodyweight = bodyweight, 
    external_load = external_load, aerial_time = aerial_time, 
    plot = TRUE))
```



\begin{center}\includegraphics[width=0.9\linewidth]{19-Appendix-C-vjsim_files/figure-latex/unnamed-chunk-3-1} \end{center}

Velocity, in this case TOV, is calculated by first calculating jump height from the `aerial_time` using `vjsim::get_height_from_aerial_time` function inside the `vjsim::make_load_profile`, which is later converted to TOV using ballistic equations. 

This LV profile has the following parameters:


```r
jack_LV_profile
#> $L0
#> [1] 222.3918
#> 
#> $L0_rel
#> [1] 2.616374
#> 
#> $TOV0
#> [1] 3.959045
#> 
#> $Sltv
#> [1] -56.17309
#> 
#> $Sltv_rel
#> [1] -0.6608599
#> 
#> $RSE
#> [1] 0.0560288
#> 
#> $R_squared
#> [1] 0.9901916
```

To perform optimization *Force-Velocity* (FV) profile using Samozino *et al.* approach [@jimenez-reyesEffectivenessIndividualizedTraining2017; @jimenez-reyesOptimizedTrainingJumping2019; @samozinoJumpingAbilityTheoretical2010; @samozinoOptimalForceVelocity2012; @samozinoOptimalForceVelocityProfile2018; @samozinoSimpleMethodMeasuring2008; @samozinoSimpleMethodMeasuring2018; @samozinoSimpleMethodMeasuring2018a] use `vjsim::make_samozino_profile`:


```r
jack_FV_profile <- with(jack_data, vjsim::make_samozino_profile(bodyweight = bodyweight, 
    push_off_distance = push_off_distance, external_load = external_load, 
    aerial_time = aerial_time, plot = TRUE))
```



\begin{center}\includegraphics[width=0.9\linewidth]{19-Appendix-C-vjsim_files/figure-latex/unnamed-chunk-5-1} \end{center}

Here are the parameters estimated:


```r
jack_FV_profile
#> $F0
#> [1] 2235.995
#> 
#> $F0_rel
#> [1] 26.30583
#> 
#> $V0
#> [1] 4.037337
#> 
#> $Pmax
#> [1] 2256.867
#> 
#> $Pmax_rel
#> [1] 26.55137
#> 
#> $Sfv
#> [1] -553.8293
#> 
#> $Sfv_rel
#> [1] -6.515638
#> 
#> $take_off_velocity
#> [1] 2.444065
#> 
#> $height
#> [1] 0.3044574
#> 
#> $optimal_F0
#> [1] 3389.95
#> 
#> $optimal_F0_rel
#> [1] 39.88176
#> 
#> $optimal_V0
#> [1] 2.663009
#> 
#> $optimal_height
#> [1] 0.3614484
#> 
#> $optimal_height_diff
#> [1] 0.05699097
#> 
#> $optimal_height_ratio
#> [1] 1.187189
#> 
#> $optimal_Pmax
#> [1] 2256.867
#> 
#> $optimal_Pmax_rel
#> [1] 26.55137
#> 
#> $optimal_take_off_velocity
#> [1] 2.663009
#> 
#> $optimal_take_off_velocity_diff
#> [1] 0.2189439
#> 
#> $optimal_take_off_velocity_ratio
#> [1] 1.089582
#> 
#> $optimal_Sfv
#> [1] -1272.977
#> 
#> $optimal_Sfv_rel
#> [1] -14.9762
#> 
#> $Sfv_perc
#> [1] 43.50661
#> 
#> $FV_imbalance
#> [1] 56.49339
#> 
#> $probe_IMB
#> [1] 42.45125
#> 
#> $RSE
#> [1] 0.1172931
#> 
#> $R_squared
#> [1] 0.8280585
```

In the case that you need to make analysis for multiple athletes, rather than doing one-by-one, use the following `tidyverse` wrapper:


```r
make_samozino_profile_wrapper <- function(data) {
    profile <- with(data, vjsim::make_samozino_profile(bodyweight = bodyweight, 
        push_off_distance = push_off_distance, external_load = external_load, 
        aerial_time = aerial_time, plot = FALSE))
    
    return(data.frame(F0 = profile$F0, V0 = profile$V0, height = profile$height, 
        optimal_F0 = profile$optimal_F0, optimal_V0 = profile$optimal_V0, 
        optimal_height = profile$optimal_height, Sfv_perc = profile$Sfv_perc))
}
```

We can now apply this wrapper function to get FV profile for all athletes in the `testing_data` data set:


```r
athlete_profiles <- testing_data %>% group_by(athlete) %>% 
    do(make_samozino_profile_wrapper(.))


athlete_profiles
#> # A tibble: 5 x 8
#> # Groups:   athlete [5]
#>   athlete    F0    V0 height optimal_F0 optimal_V0
#>   <fct>   <dbl> <dbl>  <dbl>      <dbl>      <dbl>
#> 1 John    3373.  2.72  0.351      3495.       2.63
#> 2 Jack    2236.  4.04  0.304      3390.       2.66
#> 3 Peter   3772.  3.49  0.562      3964.       3.32
#> 4 Jane    1961.  2.31  0.259      2011.       2.25
#> 5 Chris     NA  NA    NA            NA       NA   
#> # ... with 2 more variables: optimal_height <dbl>,
#> #   Sfv_perc <dbl>
```

