---
output: html_document
editor_options: 
  chunk_output_type: console
---


# RCT analysis and prediction in `bmbstats`

In this chapter I will demonstrate how to analyze simple randomized controlled trials (RCTs) from both explanatory and predictive perspectives using `bmbstats` package and functions. As a refresher, please consider re-reading [Causal inference] chapter. 

## Data Generating Process behind RCT

The following image is re-posted from the [Causal inference] chapter, outlining Treatment and Non-Treatment effects. 


\begin{center}\includegraphics[width=1\linewidth]{figures/treatment-and-non-treatment-effects} \end{center}

Let's consider the following RCT DGP. We have two group (Control and Treatment), each with N=10 athletes, measured twice (Pre-test and Post-test) on the vertical jump height, using a measuring device with a known measurement error (i.e. only instrumentation noise; see [Validity and Reliability] chapter for more info) estimated through validity and reliability studies and equal to 0.5cm. Control group are doing their normal training for 4 weeks, while Treatment group is doing EMS stimulation of their calf muscles on top of their normal training. 

Since this is DGP, we will assume there is no treatment effect nor non-treatment effects. Both Control and Treatment groups will experience normal biological variation in their jump height, which is equal to 1.5cm. Please refer to [Validity and Reliability] chapter for more info about the concepts of true score and measurement error. SESOI for the measured score will be ±5cm (since there is no proportional bias in the measurement, this will also be SESOI for the true score - see [Validity and Reliability] chapter for more information).


```r
require(tidyverse)
require(bmbstats)
require(cowplot)

set.seed(1667)

n_subjects <- 20


instrumentation_noise <- 0.5
biological_variation <- 1.5

# -------------------------
# Treatment effect
treatment_systematic <- 0
treatment_random <- 0

# Non-treatment effect
non_treatment_systematic <- 0
non_treatment_random <- 0
#-------------------------

RCT_data <- tibble(
  Athlete = paste(
    "Athlete",
    str_pad(
      string = seq(1, n_subjects),
      width = 2,
      pad = "0"
    )
  ),
  Group = rep(c("Treatment", "Control"), length.out = n_subjects),

  # True score
  True_score.Pre = rnorm(n_subjects, 45, 5),

  # Treatment effect
  Treatment_effect = rnorm(n = n_subjects, mean = treatment_systematic, sd = treatment_random),
  Non_treatment_effect = rnorm(n = n_subjects, mean = non_treatment_systematic, sd = non_treatment_random),

  # Calculate the change in true score
  True_score.Change = if_else(
    Group == "Treatment",
    # Treatment group is a sum of treatment and non-treatment effects
    Treatment_effect + Non_treatment_effect,
    # While control group only get non-treatment effects
    Non_treatment_effect
  ),
  True_score.Post = True_score.Pre + True_score.Change,

  # Manifested score
  Manifested_score.Pre = True_score.Pre + rnorm(n_subjects, 0, biological_variation),
  Manifested_score.Post = True_score.Post + rnorm(n_subjects, 0, biological_variation),
  Manifested_score.Change = Manifested_score.Post - Manifested_score.Pre,

  # Measured score
  Measured_score.Pre = Manifested_score.Pre + rnorm(n_subjects, 0, instrumentation_noise),
  Measured_score.Post = Manifested_score.Post + rnorm(n_subjects, 0, instrumentation_noise),
  Measured_score.Change = Measured_score.Post - Measured_score.Pre
)

# Make sure that the Group column is a factor
# This will not create issues with PDP+ICE and ICE plotting later
RCT_data$Group <- factor(RCT_data$Group)

head(RCT_data)
#> # A tibble: 6 x 13
#>   Athlete Group True_score.Pre Treatment_effect
#>   <chr>   <fct>          <dbl>            <dbl>
#> 1 Athlet~ Trea~           52.9                0
#> 2 Athlet~ Cont~           42.4                0
#> 3 Athlet~ Trea~           49.2                0
#> 4 Athlet~ Cont~           44.8                0
#> 5 Athlet~ Trea~           40.0                0
#> 6 Athlet~ Cont~           42.6                0
#> # ... with 9 more variables:
#> #   Non_treatment_effect <dbl>,
#> #   True_score.Change <dbl>, True_score.Post <dbl>,
#> #   Manifested_score.Pre <dbl>,
#> #   Manifested_score.Post <dbl>,
#> #   Manifested_score.Change <dbl>,
#> #   Measured_score.Pre <dbl>,
#> #   Measured_score.Post <dbl>,
#> #   Measured_score.Change <dbl>
```

Since we have generated this data, we know that there are no treatment nor non-treatment effects (neither systematic, nor random or variable effects). But let's plot the data.

First let's plot the Pre-test measured scores (vertical jump) distribution:


```r
bmbstats::plot_raincloud(RCT_data, value = "Measured_score.Pre", 
    groups = "Group")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-4-1} \end{center}

And the Post-test:


```r
bmbstats::plot_raincloud(RCT_data, value = "Measured_score.Post", 
    groups = "Group")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-5-1} \end{center}

And finally measured change scores:


```r
bmbstats::plot_raincloud_SESOI(RCT_data, value = "Measured_score.Change", 
    groups = "Group", SESOI_lower = -5, SESOI_upper = 5)
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-6-1} \end{center}

From these graphs we can see that there is no difference between group. We have also selected large SESOI taking into account our *a priori* knowledge about biological variation and measurement error in the vertical jump height. 

Let's plot the individual change fro athletes from the Treatment group:


```r
bmbstats::plot_pair_changes(group_a = RCT_data$Measured_score.Pre, 
    group_b = RCT_data$Measured_score.Post, group_a_label = "Measured Pre-test", 
    group_b_label = "Measured Post-test", SESOI_lower = -5, 
    SESOI_upper = 5)
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-7-1} \end{center}

## RCT analysis using `bmbstats::RCT_analysis` function

To perform RCT analysis explained in the [Causal inference] chapter, we will use `bmbstats::RCT_analysis` function. `bmbstats::RCT_analysis` function has three built-in estimator function: `bmbstats::RCT_estimators`, `bmbstats::RCT_estimators_simple`, and `bmbstats::RCT_estimators_lm`. `bmbstats::RCT_estimators` is more extensive and involves individual group analysis, while the `bmbstats::RCT_estimators_simple` only provides estimated treatment and non-treatment effects. `bmbstats::RCT_estimators_lm` will be explained in the next section. 


```r
extensive_RCT <- bmbstats::RCT_analysis(data = RCT_data, 
    group = "Group", treatment_label = "Treatment", control_label = "Control", 
    pre_test = "Measured_score.Pre", post_test = "Measured_score.Post", 
    SESOI_lower = -5, SESOI_upper = 5, control = model_control(seed = 1667))
#> [1] "All values of t are equal to  5 \n Cannot calculate confidence intervals"
#> [1] "All values of t are equal to  10 \n Cannot calculate confidence intervals"


extensive_RCT
#> Bootstrap with 2000 resamples and 95% bca confidence intervals.
#> 
#>                           estimator         value
#>                         SESOI lower -5.0000000000
#>                         SESOI upper  5.0000000000
#>                         SESOI range 10.0000000000
#>         Control Group Pre-test mean 45.5109521606
#>           Control Group Pre-test SD  3.9597464864
#>        Control Group Post-test mean 45.1257775214
#>          Control Group Post-test SD  3.5092078780
#>       Treatment Group Pre-test mean 42.6896373231
#>         Treatment Group Pre-test SD  6.7766398945
#>      Treatment Group Post-test mean 42.3426726375
#>        Treatment Group Post-test SD  6.8172485979
#>                  Pre-test pooled SD  5.5498847059
#>           Pre-test Group difference -2.8213148375
#>          Post-test Group difference -2.7831048839
#>           Control Group Change mean -0.3851746392
#>             Control Group Change SD  1.4244343846
#>             Control Group Cohen's d -0.0694022776
#>       Control Group Change to SESOI -0.0385174639
#>    Control Group Change SD to SESOI  0.1424434385
#>                Control Group pLower  0.0050812820
#>           Control Group pEquivalent  0.9927461183
#>               Control Group pHigher  0.0021725997
#>         Treatment Group Change mean -0.3469646855
#>           Treatment Group Change SD  1.7452275994
#>           Treatment Group Cohen's d -0.0625174583
#>     Treatment Group Change to SESOI -0.0346964686
#>  Treatment Group Change SD to SESOI  0.1745227599
#>              Treatment Group pLower  0.0128923459
#>         Treatment Group pEquivalent  0.9803630085
#>             Treatment Group pHigher  0.0067446456
#>                    Effect Cohen's d  0.0268246499
#>                   Systematic effect  0.0382099536
#>                       Random effect  1.0083680171
#>          Systematic effect to SESOI  0.0038209954
#>              SESOI to Random effect  9.9170142553
#>                              pLower  0.0003713043
#>                         pEquivalent  0.9992167407
#>                             pHigher  0.0004119550
#>          lower        upper
#>             NA           NA
#>             NA           NA
#>             NA           NA
#>   4.338522e+01  47.99500924
#>   2.821249e+00   5.39401519
#>   4.327530e+01  47.33738237
#>   2.612392e+00   4.59657735
#>   3.878113e+01  46.84572579
#>   4.783839e+00   8.92052081
#>   3.856045e+01  46.63546378
#>   4.880090e+00   8.96710016
#>   4.348937e+00   7.08556923
#>  -7.362312e+00   1.66624873
#>  -7.151974e+00   1.84048180
#>  -1.301390e+00   0.35428624
#>   9.592800e-01   2.04852176
#>  -2.627647e-01   0.08120665
#>  -1.301390e-01   0.03542862
#>   9.592800e-02   0.20485218
#>   3.123715e-04   0.04282747
#>   9.564951e-01   0.99950198
#>   2.037526e-04   0.01324039
#>  -1.363329e+00   0.72633527
#>   1.230571e+00   2.23150783
#>  -2.845506e-01   0.16106127
#>  -1.363329e-01   0.07263353
#>   1.230571e-01   0.22315078
#>   1.224420e-03   0.03986666
#>   9.469588e-01   0.99789556
#>   6.592220e-04   0.03469121
#>  -1.142476e+00   1.10911957
#>  -1.239017e+00   1.40527411
#>  -1.142340e+00   1.85676617
#>  -1.239017e-01   0.14052741
#>  -1.104973e+01 149.46811634
#>   1.345150e-12   0.99988780
#>  -9.960108e-01   1.00000000
#>   1.014997e-12   0.99983149
```

We can also plot the estimators bootstrap distributions:


```r
plot(extensive_RCT)
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-9-1} \end{center}

If we use `bmbstats::RCT_estimators_simple`, we will get much more condensed output: 


```r
simple_RCT <- bmbstats::RCT_analysis(data = RCT_data, group = "Group", 
    treatment_label = "Treatment", control_label = "Control", 
    pre_test = "Measured_score.Pre", post_test = "Measured_score.Post", 
    SESOI_lower = -5, SESOI_upper = 5, estimator_function = bmbstats::RCT_estimators_simple, 
    control = model_control(seed = 1667))
#> [1] "All values of t are equal to  5 \n Cannot calculate confidence intervals"
#> [1] "All values of t are equal to  10 \n Cannot calculate confidence intervals"


simple_RCT
#> Bootstrap with 2000 resamples and 95% bca confidence intervals.
#> 
#>                   estimator         value         lower
#>                 SESOI lower -5.0000000000            NA
#>                 SESOI upper  5.0000000000            NA
#>                 SESOI range 10.0000000000            NA
#>           Systematic effect  0.0382099536 -1.239017e+00
#>               Random effect  1.0083680171 -1.142340e+00
#>  Systematic effect to SESOI  0.0038209954 -1.239017e-01
#>      SESOI to Random effect  9.9170142553 -1.104973e+01
#>                      pLower  0.0003713043  1.345150e-12
#>                 pEquivalent  0.9992167407 -9.960108e-01
#>                     pHigher  0.0004119550  1.014997e-12
#>        upper
#>           NA
#>           NA
#>           NA
#>    1.4052741
#>    1.8567662
#>    0.1405274
#>  149.4681163
#>    0.9998878
#>    1.0000000
#>    0.9998315
```


```r
plot(simple_RCT)
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-11-1} \end{center}

As can be seen, the analysis correctly identified no treatment effect. There is an issue with random treatment effects estimation since is demonstrates distribution with two peaks. This effect is due to random treatment effect being zero and the way the root of the squared differences is calculated to avoid irrational numbers (i.e. taking root of negative number). 

There are additional graphs that can be produced. All graphs can take `control = plot_control` parameter to setup plotting options as explained in the previous chapters. 

Control group Pre- and Post-test distribution:


```r
plot(simple_RCT, type = "control-pre-post")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-12-1} \end{center}

Treatment group Pre- and Post-test distribution:


```r
plot(simple_RCT, type = "treatment-pre-post")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-13-1} \end{center}

Control change graph:


```r
plot(simple_RCT, type = "control-change")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-14-1} \end{center}

Treatment change graph:


```r
plot(simple_RCT, type = "treatment-change")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-15-1} \end{center}

Change graph:


```r
plot(simple_RCT, type = "change")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-16-1} \end{center}

Individual changes in the Control group:


```r
plot(simple_RCT, type = "control-paired-change")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-17-1} \end{center}

Individual changes in the Treatment group:


```r
plot(simple_RCT, type = "treatment-paired-change")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-18-1} \end{center}

Distribution of the change scores:


```r
plot(simple_RCT, type = "change-distribution")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-19-1} \end{center}

Treatment effect distribution:


```r
plot(simple_RCT, type = "effect-distribution")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-20-1} \end{center}

And finally, adjusted treatment responses:


```r
plot(simple_RCT, type = "adjusted-treatment-responses")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-21-1} \end{center}

The adjusted treatment responses are calculated by deducting `mean` Control group change from individual change in the Treatment group (i.e. *adjusted change*). Error-bars represent 95% confidence intervals (i.e. `SDC`) using change `SD` of the Control group. 

The data used to create this graph can be found in the returned object:


```r
head(simple_RCT$extra$treatment_responses)
#>    id     group pre_test post_test     change      SDC
#> 11  1 Treatment 52.87665  53.06613  0.1894841 3.222294
#> 12  2 Treatment 48.86917  51.26538  2.3962116 3.222294
#> 13  3 Treatment 41.83908  39.31947 -2.5196029 3.222294
#> 14  4 Treatment 43.14467  40.80646 -2.3382079 3.222294
#> 15  5 Treatment 32.93471  33.26669  0.3319806 3.222294
#> 16  6 Treatment 34.17358  33.61544 -0.5581425 3.222294
#>    change_lower change_upper adjusted_change
#> 11   -3.0328104    3.4117785       0.5746587
#> 12   -0.8260828    5.6185061       2.7813863
#> 13   -5.7418974    0.7026915      -2.1344283
#> 14   -5.5605023    0.8840866      -1.9530332
#> 15   -2.8903138    3.5542751       0.7171553
#> 16   -3.7804369    2.6641520      -0.1729678
#>    adjusted_change_lower adjusted_change_upper
#> 11            -2.6476357              3.796953
#> 12            -0.4409082              6.003681
#> 13            -5.3567227              1.087866
#> 14            -5.1753277              1.269261
#> 15            -2.5051392              3.939450
#> 16            -3.3952623              3.049327
```

We can also plot the un-adjusted treatment responses:


```r
plot(simple_RCT, type = "treatment-responses")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-23-1} \end{center}

Let's re-create this graph using `bmbstats::observations_MET` function since that function also allows us to set Type I error rates and confidence for plotting. 


```r
treatment_group <- filter(
  RCT_data,
  Group == "Treatment"
)

control_group <- filter(
  RCT_data,
  Group == "Control"
)

treatment_responses <- bmbstats::observations_MET(
  observations = treatment_group$Measured_score.Change - mean(control_group$Measured_score.Change),
  observations_label = treatment_group$Athlete,

  # Use control group change as measurement error
  measurement_error = sd(control_group$Measured_score.Change),

  # Degrees of freedom from the reliability study. Use `Inf` for normal distribution
  df = nrow(control_group) - 1,
  SESOI_lower = -5,
  SESOI_upper = 5,

  # Will not use Bonferroni adjustment here
  alpha = 0.05,
  # No adjustment in CIs for plotting
  confidence = 0.95
)

plot(
  treatment_responses,
  true_observations = treatment_group$True_score.Change,
  control = plot_control(points_size = 5)
) +
  xlim(-9, 9)
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-24-1} \end{center}

This way, Control group is used as *sort-of* reliability study (see [Repeatability] section in the [Validity and Reliability] chapter) that provides source of information about the non-treatment effect (in this case 0 for both systematic and random components), biological variation and instrumentation noise. This helps us to provide uncertainty intervals around individual treatment (adjusted) effects.

## Linear Regression Perspective

RCT analysis performed with `bmbstats::RCT_analysis` is the method of differences (i.e. changes). This is similar to the method of differences explained in the [Validity and Reliability] chapter. Another approach is to utilize linear regression( explained in the [Prediction as a complement to causal inference] section of the [Causal inference] chapter). To understand this, let's depict this RCT data by using Group as predictor and Change score as outcome:


```r
ggplot(RCT_data, aes(x = Group, y = Measured_score.Change, 
    color = Group)) + theme_cowplot(8) + geom_jitter(width = 0.2) + 
    scale_color_manual(values = c(Treatment = "#FAA43A", 
        Control = "#5DA5DA"))
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-25-1} \end{center}

If we perform the linear regression, we will get the following:


```r
model1 <- lm(Measured_score.Change ~ Group, RCT_data)

summary(model1)
#> 
#> Call:
#> lm(formula = Measured_score.Change ~ Group, data = RCT_data)
#> 
#> Residuals:
#>     Min      1Q  Median      3Q     Max 
#> -2.6559 -0.9517  0.2315  0.7391  2.7432 
#> 
#> Coefficients:
#>                Estimate Std. Error t value Pr(>|t|)
#> (Intercept)    -0.38517    0.50373  -0.765    0.454
#> GroupTreatment  0.03821    0.71238   0.054    0.958
#> 
#> Residual standard error: 1.593 on 18 degrees of freedom
#> Multiple R-squared:  0.0001598,	Adjusted R-squared:  -0.05539 
#> F-statistic: 0.002877 on 1 and 18 DF,  p-value: 0.9578
```

Intercept in this case (-0.39cm) represents the `mean` change in the Control group, while slope (`GroupTreatment`; 0.04cm) represents estimate of the systematic treatment effect (i.e. difference in means). 

This can be easily explained visually:


```r
RCT_data$Group_num <- ifelse(RCT_data$Group == "Treatment", 
    1, 0)

ggplot(RCT_data, aes(x = Group_num, y = Measured_score.Change)) + 
    theme_cowplot(8) + geom_jitter(aes(color = Group), width = 0.2) + 
    geom_smooth(method = "lm", formula = y ~ x, se = TRUE) + 
    scale_color_manual(values = c(Treatment = "#FAA43A", 
        Control = "#5DA5DA")) + scale_x_continuous(name = "Group", 
    breaks = c(0, 1), labels = c("Control", "Treatment"))
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-27-1} \end{center}

Random components of the treatment and non-treatment effects can be seen as *residuals* (actually as `SD` of the residuals) around `mean` of the group changes. `RSE` of this model (1.59cm) represents *pooled* random errors of both Treatment and Control groups. If we perform `SD` of the residuals for each Group, we will get the following:


```r
SD_summary <- RCT_data %>% mutate(.resid = residuals(model1)) %>% 
    group_by(Group) %>% summarise(`Residual SD` = sd(.resid))

SD_summary
#> # A tibble: 2 x 2
#>   Group     `Residual SD`
#>   <fct>             <dbl>
#> 1 Control            1.42
#> 2 Treatment          1.75
```

Estimating random treatment effect is thus equal to $\sqrt{SD_{Treatment \;group}^2 - SD_{Control \; group}^2}$: 


```r
sqrt(SD_summary$`Residual SD`[2]^2 - SD_summary$`Residual SD`[1]^2)
#> [1] 1.008368
```

If you compare these regression estimates to those from the `bmbstats::RCT_analysis`, you will notice they are equal. 

But, as alluded in [Causal inference] chapter, one should avoid using Change scores and rather use Pre-test and Post-test scores. In this case, our model would look visually like this (I have added dashed identity line so Pre-test and Post-test comparison is easier):


```r
ggplot(RCT_data, aes(x = Measured_score.Pre, y = Measured_score.Post, 
    color = Group, fill = Group)) + theme_cowplot(8) + geom_abline(slope = 1, 
    linetype = "dashed") + geom_smooth(method = "lm", se = TRUE, 
    alpha = 0.2) + geom_point(alpha = 0.8) + scale_color_manual(values = c(Treatment = "#FAA43A", 
    Control = "#5DA5DA")) + scale_fill_manual(values = c(Treatment = "#FAA43A", 
    Control = "#5DA5DA"))
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-30-1} \end{center}

And estimated linear regression model:


```r
model2 <- lm(Measured_score.Post ~ Measured_score.Pre + Group, 
    RCT_data)

summary(model2)
#> 
#> Call:
#> lm(formula = Measured_score.Post ~ Measured_score.Pre + Group, 
#>     data = RCT_data)
#> 
#> Residuals:
#>      Min       1Q   Median       3Q      Max 
#> -2.60014 -1.01512  0.04426  0.93174  3.13880 
#> 
#> Coefficients:
#>                    Estimate Std. Error t value Pr(>|t|)
#> (Intercept)         2.52854    3.12937   0.808     0.43
#> Measured_score.Pre  0.93598    0.06786  13.793 1.16e-10
#> GroupTreatment     -0.14242    0.73977  -0.193     0.85
#>                       
#> (Intercept)           
#> Measured_score.Pre ***
#> GroupTreatment        
#> ---
#> Signif. codes:  
#> 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 1.598 on 17 degrees of freedom
#> Multiple R-squared:  0.9236,	Adjusted R-squared:  0.9146 
#> F-statistic: 102.7 on 2 and 17 DF,  p-value: 3.22e-10
```

In this model, Pre-test represent covariate. The estimated coefficient for this covariate is 0.94, or very close to 1. 

The systematic treatment effect (-0.14cm) can be interpreted as "everything else being equal, changing group from Control to Treatment will result in" effect on the Post-test. Graphically, this represent the *vertical gap* between the two lines. Please note that in the previous graph, each group is modeled separately, and in this model the lines are assumed to be parallel (i.e. no interaction between the lines - or no interaction between Group and Pre-test). Let us thus plot our model:


```r
RCT_data$.pred <- predict(model2, newdata = RCT_data)

ggplot(RCT_data, aes(x = Measured_score.Pre, y = Measured_score.Post, 
    color = Group, fill = Group)) + theme_cowplot(8) + geom_point(alpha = 0.8) + 
    geom_line(aes(y = .pred)) + scale_color_manual(values = c(Treatment = "#FAA43A", 
    Control = "#5DA5DA")) + scale_fill_manual(values = c(Treatment = "#FAA43A", 
    Control = "#5DA5DA"))
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-32-1} \end{center}

As can be seen from the figure, lines are almost identical, but more importantly, they are now parallel. 

To estimate random treatment effect, we can use residuals `SD` for each group yet again. 


```r
SD_summary <- RCT_data %>% mutate(.resid = residuals(model2)) %>% 
    group_by(Group) %>% summarise(`Residual SD` = sd(.resid))

SD_summary
#> # A tibble: 2 x 2
#>   Group     `Residual SD`
#>   <fct>             <dbl>
#> 1 Control            1.32
#> 2 Treatment          1.75
```


```r
sqrt(SD_summary$`Residual SD`[2]^2 - SD_summary$`Residual SD`[1]^2)
#> [1] 1.151716
```

This concept was a bit hard for me to wrap my head around as well. Residuals are something we cannot explain with our model (be it using simple `mean` with the method of differences, or using linear regression model with Group and Pre-test). Everything we can explain with the model can be thus seen as systematic effect. Thus, the *thing that is left* is unexplained variance. This variance is due to biological variation, instrumentation error and random non-treatment effects (which are zero in this example), as well as random treatment effects (which are also zero in this example). 

This approach is implemented in `bmbstats::RCT_estimators_lm` function that we can use in `bmbstats::RCT_analysis` to get bootstrap CIs:


```r
regression_RCT <- bmbstats::RCT_analysis(data = RCT_data, 
    group = "Group", treatment_label = "Treatment", control_label = "Control", 
    pre_test = "Measured_score.Pre", post_test = "Measured_score.Post", 
    SESOI_lower = -5, SESOI_upper = 5, estimator_function = bmbstats::RCT_estimators_lm, 
    control = model_control(seed = 1667))
#> [1] "All values of t are equal to  5 \n Cannot calculate confidence intervals"
#> [1] "All values of t are equal to  10 \n Cannot calculate confidence intervals"


regression_RCT
#> Bootstrap with 2000 resamples and 95% bca confidence intervals.
#> 
#>                   estimator         value         lower
#>                 SESOI lower -5.0000000000            NA
#>                 SESOI upper  5.0000000000            NA
#>                 SESOI range 10.0000000000            NA
#>           Systematic effect -0.1424169958 -1.545188e+00
#>               Random effect  1.1517164871 -8.277225e-01
#>  Systematic effect to SESOI -0.0142416996 -1.545188e-01
#>      SESOI to Random effect  8.6826924091 -2.122197e+01
#>                      pLower  0.0002330614  1.379717e-14
#>                 pEquivalent  0.9996342091 -9.999971e-01
#>                     pHigher  0.0001327295  1.787965e-15
#>       upper
#>          NA
#>          NA
#>          NA
#>   1.6146987
#>   1.9466856
#>   0.1614699
#>  39.5968395
#>   1.0000000
#>   1.0000000
#>   1.0000000
```

Let's now compare the results of the linear regression method with the method of differences (which uses Change score analysis):


```r
compare_methods <- rbind(data.frame(method = "differences", 
    simple_RCT$estimators), data.frame(method = "linear regression", 
    regression_RCT$estimators))


ggplot(compare_methods, aes(y = method, x = value)) + theme_bw(8) + 
    geom_errorbarh(aes(xmax = upper, xmin = lower), color = "black", 
        height = 0) + geom_point() + xlab("") + ylab("") + 
    facet_wrap(~estimator, scales = "free_x")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-36-1} \end{center}

Which method should be used? For simple designs, these provide almost identical results. We could perform simulations as we have done in the [Validity and Reliability] chapter to see the behavior of the estimates, but I will leave that to you as an exercise. I would generally follow the advice by [Frank Harrell](https://www.fharrell.com/post/errmed/#change) and avoid the use of the change scores, particularly for more complex designs involving covariates and extra parameters of the treatment (i.e. when treatment is not only TRUE/FALSE but can have a continuous membership function, or some type of the loading parameter, like number of jumps performed and so forth). 

## Prediction perspective 1

Using simple linear regression function brings us to the prediction perspective of modeling the RCT data. Rather than estimating DGP parameters, we are interested in predicting individual responses on the unseen data. We can thus use `bmbstats::cv_model` function to estimate predictive performance of our simple linear regression model. One thing to keep in mind, is that now we are using SESOI to judge the residuals magnitudes, not observed scores (i.e. measured Post-test). Please note that I have used Group column to setup the CV strata - this results in same number of CV observations in each group.  


```r
model3 <- cv_model(Measured_score.Post ~ Measured_score.Pre + 
    Group, RCT_data, SESOI_lower = -5, SESOI_upper = 5, control = model_control(seed = 1667, 
    cv_folds = 3, cv_repeats = 10, cv_strata = factor(RCT_data$Group)))

model3
#> Training data consists of 3 predictors and 20 observations. Cross-Validation of the model was performed using 10 repeats of 3 folds.
#> 
#> Model performance:
#> 
#>         metric      training training.pooled
#>            MBE  2.202681e-14    1.918475e-15
#>            MAE  1.176009e+00    1.125490e+00
#>           RMSE  1.473109e+00    1.403919e+00
#>           PPER  9.963039e-01    9.995798e-01
#>  SESOI to RMSE  6.788364e+00    7.122918e+00
#>      R-squared  9.235673e-01    9.305786e-01
#>         MinErr -3.138804e+00   -3.623411e+00
#>         MaxErr  2.600139e+00    2.890624e+00
#>      MaxAbsErr  3.138804e+00    3.623411e+00
#>  testing.pooled        mean         SD        min
#>     -0.04123424 -0.06466644 0.91228266 -2.0716103
#>      1.47603175  1.47790175 0.33700044  0.8701076
#>      1.82619034  1.79036050 0.37125297  1.1312614
#>      0.99312088  0.96151334 0.02661372  0.8929713
#>      5.47588047  5.82060839 1.20914378  3.7299209
#>      0.88259682  0.86160357 0.10805679  0.5866306
#>     -5.03757174 -2.56189890 1.14780901 -5.0375717
#>      3.53991399  2.08918814 0.96885433 -0.4470821
#>      5.03757174  3.08675364 0.76498989  1.7111147
#>        max
#>  1.8762924
#>  2.0982105
#>  2.6810220
#>  0.9939017
#>  8.8396899
#>  0.9743506
#>  0.3235147
#>  3.5399140
#>  5.0375717
```

As can be seen from the performance results, we have pretty good prediction of the individual responses since our SESOI is pretty large and we do not have any treatment nor non-treatment effects. 

`bmbstats` package comes with additional function `bmbstats::RCT_predict` that uses returned object by `bmbstats::cv_model` and analyze is from RCT perspective: 


```r
prediction_RCT <- RCT_predict(model3, new_data = RCT_data, 
    outcome = "Measured_score.Post", group = "Group", treatment_label = "Treatment", 
    control_label = "Control", subject_label = RCT_data$Athlete)

prediction_RCT
#> Training data consists of 3 predictors and 20 observations. Cross-Validation of the model was performed using 10 repeats of 3 folds.
#> 
#> Model performance:
#> 
#>         metric      training training.pooled
#>            MBE  2.202681e-14    1.918475e-15
#>            MAE  1.176009e+00    1.125490e+00
#>           RMSE  1.473109e+00    1.403919e+00
#>           PPER  9.963039e-01    9.995798e-01
#>  SESOI to RMSE  6.788364e+00    7.122918e+00
#>      R-squared  9.235673e-01    9.305786e-01
#>         MinErr -3.138804e+00   -3.623411e+00
#>         MaxErr  2.600139e+00    2.890624e+00
#>      MaxAbsErr  3.138804e+00    3.623411e+00
#>  testing.pooled        mean         SD        min
#>     -0.04123424 -0.06466644 0.91228266 -2.0716103
#>      1.47603175  1.47790175 0.33700044  0.8701076
#>      1.82619034  1.79036050 0.37125297  1.1312614
#>      0.99312088  0.96151334 0.02661372  0.8929713
#>      5.47588047  5.82060839 1.20914378  3.7299209
#>      0.88259682  0.86160357 0.10805679  0.5866306
#>     -5.03757174 -2.56189890 1.14780901 -5.0375717
#>      3.53991399  2.08918814 0.96885433 -0.4470821
#>      5.03757174  3.08675364 0.76498989  1.7111147
#>        max
#>  1.8762924
#>  2.0982105
#>  2.6810220
#>  0.9939017
#>  8.8396899
#>  0.9743506
#>  0.3235147
#>  3.5399140
#>  5.0375717
#> 
#> Individual model results:
#> 
#>     subject     group observed predicted    residual
#>  Athlete 01 Treatment 53.06613  51.87749 -1.18864415
#>  Athlete 02   Control 41.74203  42.17581  0.43378581
#>  Athlete 03 Treatment 51.26538  48.12658 -3.13880386
#>  Athlete 04   Control 44.89588  44.04977 -0.84610959
#>  Athlete 05 Treatment 39.31947  41.54657  2.22709299
#>  Athlete 06   Control 41.15527  42.16271  1.00744225
#>  Athlete 07 Treatment 40.80646  42.76857  1.96211098
#>  Athlete 08   Control 48.68788  48.15176 -0.53612109
#>  Athlete 09 Treatment 33.26669  33.21228 -0.05441276
#>  Athlete 10   Control 45.90508  44.34223 -1.56285495
#>  Athlete 11 Treatment 33.61544  34.37183  0.75639501
#>  Athlete 12   Control 43.34150  45.94164  2.60013908
#>  Athlete 13 Treatment 40.88270  38.87404 -2.00866163
#>  Athlete 14   Control 50.96896  50.99231  0.02334441
#>  Athlete 15 Treatment 42.08253  41.84993 -0.23260068
#>  Athlete 16   Control 49.26936  50.30751  1.03815067
#>  Athlete 17 Treatment 40.00091  39.96681 -0.03410111
#>  Athlete 18   Control 41.32829  39.57284 -1.75545843
#>  Athlete 19 Treatment 49.12101  50.83263  1.71162522
#>  Athlete 20   Control 43.96351  43.56119 -0.40231815
#>   magnitude counterfactual      pITE pITE_magnitude
#>  Equivalent       52.01990  0.142417     Equivalent
#>  Equivalent       42.03340 -0.142417     Equivalent
#>  Equivalent       48.26899  0.142417     Equivalent
#>  Equivalent       43.90736 -0.142417     Equivalent
#>  Equivalent       41.68898  0.142417     Equivalent
#>  Equivalent       42.02030 -0.142417     Equivalent
#>  Equivalent       42.91099  0.142417     Equivalent
#>  Equivalent       48.00934 -0.142417     Equivalent
#>  Equivalent       33.35469  0.142417     Equivalent
#>  Equivalent       44.19981 -0.142417     Equivalent
#>  Equivalent       34.51425  0.142417     Equivalent
#>  Equivalent       45.79923 -0.142417     Equivalent
#>  Equivalent       39.01645  0.142417     Equivalent
#>  Equivalent       50.84989 -0.142417     Equivalent
#>  Equivalent       41.99235  0.142417     Equivalent
#>  Equivalent       50.16510 -0.142417     Equivalent
#>  Equivalent       40.10923  0.142417     Equivalent
#>  Equivalent       39.43042 -0.142417     Equivalent
#>  Equivalent       50.97505  0.142417     Equivalent
#>  Equivalent       43.41878 -0.142417     Equivalent
#> 
#> Summary of residuals per RCT group:
#> 
#>      group         mean       SD
#>    Control 1.634246e-14 1.322097
#>  Treatment 2.771120e-14 1.753394
#> 
#> Summary of counterfactual effects of RCT group:
#> 
#>      group      pATE pVTE
#>  Treatment  0.142417    0
#>    Control -0.142417    0
#>     pooled  0.142417    0
#> 
#> Treatment effect summary
#> 
#> Average Treatment effect:  0.142417
#> Variable Treatment effect:  0
#> Random Treatment effect:  1.151716
```

The results of `bmbstats::RCT_predict` contain (1) model performance (also returned from `bmbstats::cv_model`), (2) individual model results (which contains individual model predictions, as well as counterfactual predictions assuming Group changes from Control to Treatment and *vice versa*), (3) residuals summary per group (these are our random effects), and (4) summary of counterfactual effects (please refer to [Causal inference] chapter for more information about these concepts). The *extra* details that `bmbstats::RCT_predict` adds on top of `bmbstats::cv_model` can be found in the `prediction_RCT$extra`. 

Now that we have the more info about the underlying RCT, we can do various plots. Let's plot the residuals first:


```r
plot(prediction_RCT, "residuals")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-39-1} \end{center}

To plot individual model predictions use the following:


```r
plot(prediction_RCT, "prediction")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-40-1} \end{center}

Circlets or dots represent observed (i.e. outcome or target variable), and vertical line represent model predictions. Residual between the two is color coded based on the provided SESOI threshold. 

By default, prediction plot uses `metric = "RMSE"` and `metric_cv = "testing.pooled"` parameters to plot confidence intervals. We can use some other metric returned from `bmbstats::cv_model`. Let's use `MaxAbsErr` (maximum absolute prediction error) from mean testing CV column: 


```r
plot(prediction_RCT, "prediction", metric = "MaxAbsErr", 
    metric_cv = "mean")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-41-1} \end{center}

To plot individual bias-variance error decomposition thorough testing CV folds use:


```r
plot(prediction_RCT, "bias-variance")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-42-1} \end{center}

Here we can see which athletes are prediction outliers and generally present issues for the predictive model. Together with the individual predictions, we can use this plot and data to gain more info regarding individual reactions to intervention (i.e. who jumps out from the model prediction).

To gain understanding into counterfactual prediction, we could use PDP and ICE plots. The default variable to be used is the Group, which we can change later:


```r
plot(prediction_RCT, "pdp+ice")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-43-1} \end{center}

This plot gives us insights into model prediction for each athlete when the Group variable changes, while keeping all other variables the same. Since this is RCT, this plot can be given counterfactual interpretation. The PDP line (thick red line) represent the average of these individual prediction (ICE lines), and as can be seen, the counterfactual effects of changing group is zero (since the line is parallel) and thus represents *expected* or systematic effect of the treatment. 

Let's do that for out other variable in the model (with addition of the dashed identity line):


```r
plot(prediction_RCT, "pdp+ice", predictor = "Measured_score.Pre") + 
    geom_abline(slope = 1, linetype = "dashed")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-44-1} \end{center}

To plot these individual ICE line for each athlete we can use counterfactual plot:


```r
plot(prediction_RCT, "counterfactual")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-45-1} \end{center}

Since the systematic treatment effect is zero, these are very small. The mean of these individual counterfactual prediction effect is presented in the object printout in the last table as `pATE` (predicted average treatment effect) and `SD` of these effects as `pVTE` (predicted variable treatment effect). In this case, due simple model, the predicted treatment effects are the same, thus the `pVTE` is equal to zero. 

Different way to plot these is to have *trellis* plot for each individual:


```r
plot(prediction_RCT, "ice")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-46-1} \end{center}

These plots represent strong tool for understanding predictive model performance for the RCT data and study designs. 

## Adding some effects

The previous example contained no treatment nor non-treatment effects, only biological variation and instrumentation noise. Let's now consider different treatment - plyometric training that has systematic effect of 5cm (`mean` or expected change) and random effect of 5cm. But, since this study is done after the off-season, all athletes experienced systematic effect of 2.5cm increase and random effect of 1cm only by normal training. This represents non-treatment effect. 

Biological variation (1.5cm) and instrumentation noise (0.5cm) are still involved in the measured scores. 

This is the code to generate the data (i.e. DGP):


```r
set.seed(16)

n_subjects <- 20

# These stay the same
instrumentation_noise <- 0.5
biological_variation <- 1.5

# -------------------------
# Treatment effect
treatment_systematic <- 5
treatment_random <- 5

# Non-treatment effect
non_treatment_systematic <- 2.5
non_treatment_random <- 1
#-------------------------

RCT_data <- tibble(
  Athlete = paste(
    "Athlete",
    str_pad(
      string = seq(1, n_subjects),
      width = 2,
      pad = "0"
    )
  ),
  Group = rep(c("Treatment", "Control"), length.out = n_subjects),

  # True score
  True_score.Pre = rnorm(n_subjects, 45, 5),

  # Treatment effect
  Treatment_effect = rnorm(n = n_subjects, mean = treatment_systematic, sd = treatment_random),
  Non_treatment_effect = rnorm(n = n_subjects, mean = non_treatment_systematic, sd = non_treatment_random),

  # Calculate the change in true score
  True_score.Change = if_else(
    Group == "Treatment",
    # Treatment group is a sum of treatment and non-treatment effects
    Treatment_effect + Non_treatment_effect,
    # While control group only get non-treatment effects
    Non_treatment_effect
  ),
  True_score.Post = True_score.Pre + True_score.Change,

  # Manifested score
  Manifested_score.Pre = True_score.Pre + rnorm(n_subjects, 0, biological_variation),
  Manifested_score.Post = True_score.Post + rnorm(n_subjects, 0, biological_variation),
  Manifested_score.Change = Manifested_score.Post - Manifested_score.Pre,

  # Measured score
  Measured_score.Pre = Manifested_score.Pre + rnorm(n_subjects, 0, instrumentation_noise),
  Measured_score.Post = Manifested_score.Post + rnorm(n_subjects, 0, instrumentation_noise),
  Measured_score.Change = Measured_score.Post - Measured_score.Pre
)

RCT_data$Group <- factor(RCT_data$Group)

head(RCT_data)
#> # A tibble: 6 x 13
#>   Athlete Group True_score.Pre Treatment_effect
#>   <chr>   <fct>          <dbl>            <dbl>
#> 1 Athlet~ Trea~           47.4           -3.24 
#> 2 Athlet~ Cont~           44.4            3.43 
#> 3 Athlet~ Trea~           50.5            4.09 
#> 4 Athlet~ Cont~           37.8           12.4  
#> 5 Athlet~ Trea~           50.7            0.671
#> 6 Athlet~ Cont~           42.7           12.6  
#> # ... with 9 more variables:
#> #   Non_treatment_effect <dbl>,
#> #   True_score.Change <dbl>, True_score.Post <dbl>,
#> #   Manifested_score.Pre <dbl>,
#> #   Manifested_score.Post <dbl>,
#> #   Manifested_score.Change <dbl>,
#> #   Measured_score.Pre <dbl>,
#> #   Measured_score.Post <dbl>,
#> #   Measured_score.Change <dbl>
```

Let's plot the data using Pre-test as predictor (x-axis) and Post-test as the outcome (y-axis). Please remember that this plot provide simple linear regression for each group independently. I will add identity line for easier comparison:


```r
ggplot(RCT_data, aes(x = Measured_score.Pre, y = Measured_score.Post, 
    color = Group, fill = Group)) + theme_cowplot(8) + geom_abline(slope = 1, 
    linetype = "dashed") + geom_smooth(method = "lm", se = TRUE, 
    alpha = 0.2) + geom_point(alpha = 0.8) + scale_color_manual(values = c(Treatment = "#FAA43A", 
    Control = "#5DA5DA")) + scale_fill_manual(values = c(Treatment = "#FAA43A", 
    Control = "#5DA5DA"))
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-48-1} \end{center}

We can see that both Control and Treatment group demonstrated improvements since both lines are above the dashed identity line. 

Using simple linear regression we get the following coefficients:


```r
model4 <- lm(Measured_score.Post ~ Measured_score.Pre + Group, 
    RCT_data)

summary(model4)
#> 
#> Call:
#> lm(formula = Measured_score.Post ~ Measured_score.Pre + Group, 
#>     data = RCT_data)
#> 
#> Residuals:
#>     Min      1Q  Median      3Q     Max 
#> -6.5827 -3.5413  0.3856  2.3547  7.9219 
#> 
#> Coefficients:
#>                    Estimate Std. Error t value Pr(>|t|)
#> (Intercept)         13.1094     8.5876   1.527 0.145262
#> Measured_score.Pre   0.7774     0.1902   4.088 0.000767
#> GroupTreatment       4.9265     1.9679   2.503 0.022784
#>                       
#> (Intercept)           
#> Measured_score.Pre ***
#> GroupTreatment     *  
#> ---
#> Signif. codes:  
#> 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 4.294 on 17 degrees of freedom
#> Multiple R-squared:  0.6289,	Adjusted R-squared:  0.5853 
#> F-statistic: 14.41 on 2 and 17 DF,  p-value: 0.000219
```

Now the simple linear regression estimated systematic treatment effect of 4.93cm, which is very close to our DGP systematic treatment effect of 5cm. 

To estimate random treatment effect, we can use residuals `SD` for each group: 


```r
SD_summary <- RCT_data %>% mutate(.resid = residuals(model4)) %>% 
    group_by(Group) %>% summarise(`Residual SD` = sd(.resid))

SD_summary
#> # A tibble: 2 x 2
#>   Group     `Residual SD`
#>   <fct>             <dbl>
#> 1 Control            2.41
#> 2 Treatment          5.39
```


```r
sqrt(SD_summary$`Residual SD`[2]^2 - SD_summary$`Residual SD`[1]^2)
#> [1] 4.816519
```

Using `bmbstats::RCT_estimators_lm` estimator function and `bmbstats::RCT_analysis` functions, let's perform the analysis and generate 95% bootstrap confidence intervals:


```r
regression_RCT <- bmbstats::RCT_analysis(data = RCT_data, 
    group = "Group", treatment_label = "Treatment", control_label = "Control", 
    pre_test = "Measured_score.Pre", post_test = "Measured_score.Post", 
    SESOI_lower = -5, SESOI_upper = 5, estimator_function = bmbstats::RCT_estimators_lm, 
    control = model_control(seed = 1667))
#> [1] "All values of t are equal to  5 \n Cannot calculate confidence intervals"
#> [1] "All values of t are equal to  10 \n Cannot calculate confidence intervals"


regression_RCT
#> Bootstrap with 2000 resamples and 95% bca confidence intervals.
#> 
#>                   estimator       value         lower
#>                 SESOI lower -5.00000000            NA
#>                 SESOI upper  5.00000000            NA
#>                 SESOI range 10.00000000            NA
#>           Systematic effect  4.92654585   1.082956784
#>               Random effect  4.81651919   3.443713578
#>  Systematic effect to SESOI  0.49265458   0.108295678
#>      SESOI to Random effect  2.07618814 -21.118934945
#>                      pLower  0.02663292   0.001106225
#>                 pEquivalent  0.47937140   0.097391976
#>                     pHigher  0.49399568   0.117750794
#>      upper
#>         NA
#>         NA
#>         NA
#>  8.7715046
#>  6.3838094
#>  0.8771505
#>  2.9121218
#>  0.2469677
#>  0.8405754
#>  0.8878213
```

Here is the estimators bootstrap distribution:


```r
plot(regression_RCT)
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-53-1} \end{center}

As can be seen from the results, both systematic and random components of the treatment effects were estimated correctly. 

Let's plot the Pre- and Post-Test results for each group (I will let you play and plot other figures as explained in the previous sections):


```r
plot(regression_RCT, type = "control-paired-change")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-54-1} \end{center}


```r
plot(regression_RCT, type = "treatment-paired-change")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-55-1} \end{center}

Let's now plot individual treatment responses with uncertainty intervals: 


```r
plot(regression_RCT, type = "treatment-responses")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-56-1} \end{center}

As explained previously, this type of analysis and plot, uses Control group change score as some type of a *proxy* to quantify the uncertainty around observed treatment group change scores. Please note that even though we have used linear regression approach to estimate treatment effects, the plots still rely on the change scores. 

To check if this plot make sense, we can add the true treatment effects from the DGP using `bmbstats::observations_MET` function (we can also use `bmbstats::observations_MBI` function for plotting): 

```r
treatment_group <- filter(
  RCT_data,
  Group == "Treatment"
)

control_group <- filter(
  RCT_data,
  Group == "Control"
)

treatment_responses <- bmbstats::observations_MET(
  observations = treatment_group$Measured_score.Change,
  observations_label = treatment_group$Athlete,

  # Use control group change as measurement error
  measurement_error = sd(control_group$Measured_score.Change),

  # Degrees of freedom from the reliability study. Use `Inf` for normal distribution
  df = nrow(control_group) - 1,
  SESOI_lower = -5,
  SESOI_upper = 5,

  # Will not use Bonferroni adjustment here
  alpha = 0.05,
  # No adjustment in CIs for plotting
  confidence = 0.95
)

plot(
  treatment_responses,
  true_observations = treatment_group$True_score.Change,
  control = plot_control(points_size = 5)
) +
  xlim(-10, 28)
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-57-1} \end{center}

Adjusted treatment response would deduct `mean` change from the Control group and would show individual effect ONLY with treatment effect (without non-treatment effect). We can use our DGP generated data frame to generate that graph (or to recreate it) and plot true treatment effects:


```r
treatment_responses <- bmbstats::observations_MET(

  # Adjustment
  observations = treatment_group$Measured_score.Change - mean(control_group$Measured_score.Change),
  observations_label = treatment_group$Athlete,

  # Use control group change as measurement error
  measurement_error = sd(control_group$Measured_score.Change),

  # Degrees of freedom from the reliability study. Use `Inf` for normal distribution
  df = nrow(control_group) - 1,
  SESOI_lower = -5,
  SESOI_upper = 5,

  # Will not use Bonferroni adjustment here
  alpha = 0.05,
  # No adjustment in CIs for plotting
  confidence = 0.95
)

plot(
  treatment_responses,
  # The true observation now is the DGP Treatment effect only
  true_observations = treatment_group$Treatment_effect,
  control = plot_control(points_size = 5)
) +
  xlim(-10, 28)
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-58-1} \end{center}

## What goes inside the *measurement error* (or Control group change or residuals `SD`)?

As already explained, Control group serves as a counter-factual proxy of what would happen to the treatment group if not-receiving the treatment. `SD` of Control group change is used to represent an estimate of uncertainty around individual responses. In our RCT data, `SD` of the Control group measured change is equal to 2.23cm. This is equal to the root of squared sums of non-treatment random effect, biological variation and instrumentation noise. Since biological variation and instrumentation affects the change score twice (at Pre- and Post-test) we get the following:

\begin{equation}
  SD_{control\;change} = \sqrt{2\times biological\;variation^2 + 2\times instrumentation\;noise^2 + non\;treatment\;random\;effect^2}
\end{equation}

If we plug our DGP values, we get the following expected `SD` of the Control group change: 2.45cm. If there is no non-treatment random effect, then `SD` for the control group would only consist of measurement error. 

This measurement error decomposition belongs to the method of differences, but the same error decomposition happens in the `SD` of the residuals with the linear regression approach. 

To demonstrate this, consider random treatment effect estimated using the measured Pre-test and Post-test scores, versus using True scores. 


```r
model_true <- lm(True_score.Post ~ True_score.Pre + Group, 
    RCT_data)

summary(model_true)
#> 
#> Call:
#> lm(formula = True_score.Post ~ True_score.Pre + Group, data = RCT_data)
#> 
#> Residuals:
#>    Min     1Q Median     3Q    Max 
#> -8.945 -1.128  0.299  1.822  6.053 
#> 
#> Coefficients:
#>                Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)     13.7253     8.2176   1.670 0.113184    
#> True_score.Pre   0.7578     0.1801   4.208 0.000591 ***
#> GroupTreatment   4.6334     1.7272   2.683 0.015736 *  
#> ---
#> Signif. codes:  
#> 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 3.764 on 17 degrees of freedom
#> Multiple R-squared:  0.6497,	Adjusted R-squared:  0.6085 
#> F-statistic: 15.76 on 2 and 17 DF,  p-value: 0.0001342
```

The model with measured scores is the model we have used so far (`model4`), but I am repeating it here for the sake of easier comprehension:


```r
model_measured <- lm(Measured_score.Post ~ Measured_score.Pre + 
    Group, RCT_data)

summary(model_measured)
#> 
#> Call:
#> lm(formula = Measured_score.Post ~ Measured_score.Pre + Group, 
#>     data = RCT_data)
#> 
#> Residuals:
#>     Min      1Q  Median      3Q     Max 
#> -6.5827 -3.5413  0.3856  2.3547  7.9219 
#> 
#> Coefficients:
#>                    Estimate Std. Error t value Pr(>|t|)
#> (Intercept)         13.1094     8.5876   1.527 0.145262
#> Measured_score.Pre   0.7774     0.1902   4.088 0.000767
#> GroupTreatment       4.9265     1.9679   2.503 0.022784
#>                       
#> (Intercept)           
#> Measured_score.Pre ***
#> GroupTreatment     *  
#> ---
#> Signif. codes:  
#> 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 4.294 on 17 degrees of freedom
#> Multiple R-squared:  0.6289,	Adjusted R-squared:  0.5853 
#> F-statistic: 14.41 on 2 and 17 DF,  p-value: 0.000219
```

Estimate random treatment effect for each model are the following, we can use residuals `SD` for each group: 


```r
SD_summary_true <- RCT_data %>% mutate(.resid = residuals(model_true)) %>% 
    group_by(Group) %>% summarise(`Residual SD` = sd(.resid))

SD_summary_true
#> # A tibble: 2 x 2
#>   Group     `Residual SD`
#>   <fct>             <dbl>
#> 1 Control            1.47
#> 2 Treatment          4.96
```

The `SD` of the Control group residuals using the True scores should only involve random non-treatment effect, which is in our case equal to 1cm, and `SD` of the Treatment group residuals should be 5cm.

Let's see whats the case with the model that uses Measured scores:


```r
SD_summary_measured <- RCT_data %>% mutate(.resid = residuals(model_measured)) %>% 
    group_by(Group) %>% summarise(`Residual SD` = sd(.resid))


SD_summary_measured
#> # A tibble: 2 x 2
#>   Group     `Residual SD`
#>   <fct>             <dbl>
#> 1 Control            2.41
#> 2 Treatment          5.39
```

The `SD` of the Control group residuals using the measured scores should now involve random non-treatment effect (1cm), 2 x biological variation (1.5cm) and 2 x instrumentation noise (0.5cm), which is around $\sqrt{1^2 + 2*1.5^2 + 2*0.5^2}$, or 2.45cm. 

The `SD` of the Treatment group residuals using the measured scores should now involve random non-treatment effect (1cm), 2 x biological variation (1.5cm), 2 x instrumentation noise (0.5cm), and additional random treatment effect (5cm) which is around $\sqrt{1^2 + 2*1.5^2 + 2*0.5^2 + 5^2}$, or 5.57cm. 

Estimated random treatment effects:


```r
sqrt(SD_summary_true$`Residual SD`[2]^2 - SD_summary_true$`Residual SD`[1]^2)
#> [1] 4.738641
```


```r
sqrt(SD_summary_measured$`Residual SD`[2]^2 - SD_summary_measured$`Residual SD`[1]^2)
#> [1] 4.816519
```

As can be seen, these are exactly the same. So, using measures scores and `SD` of control group change or residuals can *recover* true random treatment effect value.  

## Prediction perspective 2

Let's see what happens when we run this RCT through predictive model. 


```r
model5 <- cv_model(Measured_score.Post ~ Measured_score.Pre + 
    Group, RCT_data, SESOI_lower = -5, SESOI_upper = 5, control = model_control(seed = 1667, 
    cv_folds = 3, cv_repeats = 10, cv_strata = factor(RCT_data$Group)))

prediction_RCT <- RCT_predict(model5, new_data = RCT_data, 
    outcome = "Measured_score.Post", group = "Group", treatment_label = "Treatment", 
    control_label = "Control", subject_label = RCT_data$Athlete)

prediction_RCT
#> Training data consists of 3 predictors and 20 observations. Cross-Validation of the model was performed using 10 repeats of 3 folds.
#> 
#> Model performance:
#> 
#>         metric      training training.pooled
#>            MBE -9.947541e-15    3.055367e-15
#>            MAE  3.175698e+00    3.037705e+00
#>           RMSE  3.959134e+00    3.786361e+00
#>           PPER  7.666283e-01    8.120334e-01
#>  SESOI to RMSE  2.525805e+00    2.641058e+00
#>      R-squared  6.289308e-01    6.606104e-01
#>         MinErr -7.921899e+00   -1.032365e+01
#>         MaxErr  6.582672e+00    8.806128e+00
#>      MaxAbsErr  7.921899e+00    1.032365e+01
#>  testing.pooled        mean         SD         min
#>      -0.1404122 -0.02732047 2.12193361  -3.5145897
#>       3.8691755  3.90512133 0.93683875   2.6186933
#>       4.7871794  4.73835660 0.85876892   3.4284211
#>       0.7012521  0.63888951 0.07928795   0.4413183
#>       2.0889127  2.17362777 0.37022957   1.3710286
#>       0.4579491  0.21880124 0.64551950  -1.5780914
#>     -10.0942651 -6.76317807 2.33015461 -10.0942651
#>       9.2485263  6.05923474 2.11053360   0.1401500
#>      10.0942651  8.02937811 1.17919840   5.5787979
#>         max
#>   3.3371789
#>   6.8884587
#>   7.2937938
#>   0.7862394
#>   2.9167945
#>   0.7986431
#>  -2.7453015
#>   9.2485263
#>  10.0942651
#> 
#> Individual model results:
#> 
#>     subject     group observed predicted   residual
#>  Athlete 01 Treatment 47.54084  54.12352  6.5826720
#>  Athlete 02   Control 50.47892  47.33454 -3.1443811
#>  Athlete 03 Treatment 58.19673  57.64224 -0.5544865
#>  Athlete 04   Control 39.83268  40.93613  1.1034457
#>  Athlete 05 Treatment 52.43478  56.13132  3.6965427
#>  Athlete 06   Control 45.34422  45.12752 -0.2166979
#>  Athlete 07 Treatment 53.97310  48.13585 -5.8372501
#>  Athlete 08   Control 48.35425  47.34404 -1.0102111
#>  Athlete 09 Treatment 65.05732  58.93766 -6.1196617
#>  Athlete 10   Control 46.69332  50.18284  3.4895230
#>  Athlete 11 Treatment 57.82698  58.90031  1.0733333
#>  Athlete 12   Control 49.16140  48.36452 -0.7968803
#>  Athlete 13 Treatment 46.24005  50.92561  4.6855567
#>  Athlete 14   Control 57.44395  54.26840 -3.1755549
#>  Athlete 15 Treatment 50.02857  56.51530  6.4867253
#>  Athlete 16   Control 37.56101  41.57384  4.0128333
#>  Athlete 17 Treatment 59.95868  52.03678 -7.9218991
#>  Athlete 18   Control 49.31810  48.42968 -0.8884198
#>  Athlete 19 Treatment 53.26809  51.17656 -2.0915325
#>  Athlete 20   Control 53.52199  54.14833  0.6263431
#>   magnitude counterfactual      pITE pITE_magnitude
#>      Higher       49.19697 -4.926546     Equivalent
#>  Equivalent       52.26108  4.926546     Equivalent
#>  Equivalent       52.71569 -4.926546     Equivalent
#>  Equivalent       45.86267  4.926546     Equivalent
#>  Equivalent       51.20477 -4.926546     Equivalent
#>  Equivalent       50.05407  4.926546     Equivalent
#>       Lower       43.20931 -4.926546     Equivalent
#>  Equivalent       52.27059  4.926546     Equivalent
#>       Lower       54.01111 -4.926546     Equivalent
#>  Equivalent       55.10938  4.926546     Equivalent
#>  Equivalent       53.97377 -4.926546     Equivalent
#>  Equivalent       53.29107  4.926546     Equivalent
#>  Equivalent       45.99907 -4.926546     Equivalent
#>  Equivalent       59.19494  4.926546     Equivalent
#>      Higher       51.58875 -4.926546     Equivalent
#>  Equivalent       46.50039  4.926546     Equivalent
#>       Lower       47.11023 -4.926546     Equivalent
#>  Equivalent       53.35623  4.926546     Equivalent
#>  Equivalent       46.25001 -4.926546     Equivalent
#>  Equivalent       59.07488  4.926546     Equivalent
#> 
#> Summary of residuals per RCT group:
#> 
#>      group          mean       SD
#>    Control -9.237121e-15 2.411836
#>  Treatment -1.065814e-14 5.386633
#> 
#> Summary of counterfactual effects of RCT group:
#> 
#>      group      pATE pVTE
#>  Treatment -4.926546    0
#>    Control  4.926546    0
#>     pooled  4.926546    0
#> 
#> Treatment effect summary
#> 
#> Average Treatment effect:  4.926546
#> Variable Treatment effect:  0
#> Random Treatment effect:  4.816519
```

The prediction performance in this case is much worse (compared to previous RCT example), since now there are systematic and random treatment and non-treatment effects. Although we can *explain* the RCT components, we cannot use it to predict individual responses. 

Let's check the individual predictions:


```r
plot(prediction_RCT, "prediction")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-66-1} \end{center}

We can now see that certain residuals are larger than SESOI (indicated by green or red color on the figure). 

Here is the PDP+ICE plot:


```r
plot(prediction_RCT, "pdp+ice")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-67-1} \end{center}

Parallel lines indicate that we predict that each individual will have same treatment effect (indicated by `pVTE` as well as with the arrows of same length in the counterfactual plot that follows). If we plot PDP+ICE for the measured Pre-test, we will get the following figure:


```r
plot(prediction_RCT, "pdp+ice", predictor = "Measured_score.Pre") + 
    geom_abline(slope = 1, linetype = "dashed")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-68-1} \end{center}

Two thin lines indicate two groups and the gap between them represents the systematic treatment effect. 

Estimating individual counterfactual effects when switching group:


```r
plot(prediction_RCT, "counterfactual")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-69-1} \end{center}

As can be seen, counterfactual plot depicts same treatment effect for every individual. 

## Making it more complex by adding covariate

To make this more complex, let's assume that besides randomizing athletes to Treatment and Control group, we have also measured their lower body strength using relative back squat 1RM. This variable represents our covariate, and we can expect (i.e. we hypothesize) that individuals with higher relative strength will manifest bigger improvements from the plyometric intervention. 

The following code represented DGP, where the effects of the training intervention depend on the 1RM squat (i.e. the higher the relative squat, the higher the training intervention). But on top of that, we are going to reduce the improvement based on the initial jump height (i.e. the higher someone jumps, the less improvement over time). It is assumed that squat 1RM and Pre-training jump height are unrelated (independent). Random components of the treatment and non-treatment effects are zero, and the only variance in the measured scores is due to biological noise and instrumentation error. 


```r
set.seed(16)

n_subjects <- 20

# These stay the same
instrumentation_noise <- 0.5
biological_variation <- 1.5

# -------------------------
# These are not used in this DGP
# Treatment effect
treatment_systematic <- 0
treatment_random <- 0

# Non-treatment effect
non_treatment_systematic <- 0
non_treatment_random <- 0
#-------------------------

RCT_data <- tibble(
  Athlete = paste(
    "Athlete",
    str_pad(
      string = seq(1, n_subjects),
      width = 2,
      pad = "0"
    )
  ),
  Group = rep(c("Treatment", "Control"), length.out = n_subjects),

  # Strength covariate
  Squat_1RM_relative = rnorm(n_subjects, 1, 0.4),
  # True score
  True_score.Pre = rnorm(n_subjects, 45, 5),

  # Treatment effect
  Treatment_effect = (10 - 0.002 * True_score.Pre^2 + 1) * Squat_1RM_relative,
  Non_treatment_effect = 15 - 0.005 * True_score.Pre^2,

  # Calculate the change in true score
  True_score.Change = if_else(
    Group == "Treatment",
    # Treatment group is a sum of treatment and non-treatment effects
    Treatment_effect + Non_treatment_effect,
    # While control group only get non-treatment effects
    Non_treatment_effect
  ),

  True_score.Post = True_score.Pre + True_score.Change,

  # Manifested score
  Manifested_score.Pre = True_score.Pre + rnorm(n_subjects, 0, biological_variation),
  Manifested_score.Post = True_score.Post + rnorm(n_subjects, 0, biological_variation),
  Manifested_score.Change = Manifested_score.Post - Manifested_score.Pre,

  # Measured score
  Measured_score.Pre = Manifested_score.Pre + rnorm(n_subjects, 0, instrumentation_noise),
  Measured_score.Post = Manifested_score.Post + rnorm(n_subjects, 0, instrumentation_noise),
  Measured_score.Change = Measured_score.Post - Measured_score.Pre
)

RCT_data$Group <- factor(RCT_data$Group)

head(RCT_data)
#> # A tibble: 6 x 14
#>   Athlete Group Squat_1RM_relat~ True_score.Pre
#>   <chr>   <fct>            <dbl>          <dbl>
#> 1 Athlet~ Trea~            1.19            36.8
#> 2 Athlet~ Cont~            0.950           43.4
#> 3 Athlet~ Trea~            1.44            44.1
#> 4 Athlet~ Cont~            0.422           52.4
#> 5 Athlet~ Trea~            1.46            40.7
#> 6 Athlet~ Cont~            0.813           52.6
#> # ... with 10 more variables: Treatment_effect <dbl>,
#> #   Non_treatment_effect <dbl>,
#> #   True_score.Change <dbl>, True_score.Post <dbl>,
#> #   Manifested_score.Pre <dbl>,
#> #   Manifested_score.Post <dbl>,
#> #   Manifested_score.Change <dbl>,
#> #   Measured_score.Pre <dbl>,
#> #   Measured_score.Post <dbl>,
#> #   Measured_score.Change <dbl>
```

Let's plot before we jump into the analysis. In the next plot we will depict measured Post-test (y-axis) and measured Pre-test (x-axis) per group.


```r
ggplot(RCT_data, aes(x = Measured_score.Pre, y = Measured_score.Post, 
    color = Group, fill = Group)) + theme_cowplot(8) + geom_abline(slope = 1, 
    linetype = "dashed") + geom_smooth(method = "lm", se = TRUE, 
    alpha = 0.2) + geom_point(alpha = 0.8) + scale_color_manual(values = c(Treatment = "#FAA43A", 
    Control = "#5DA5DA")) + scale_fill_manual(values = c(Treatment = "#FAA43A", 
    Control = "#5DA5DA"))
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-71-1} \end{center}

Might be also usable to plot the change score:


```r
ggplot(RCT_data, aes(x = Measured_score.Pre, y = Measured_score.Change, 
    color = Group, fill = Group)) + theme_cowplot(8) + geom_smooth(method = "lm", 
    se = TRUE, alpha = 0.2) + geom_hline(yintercept = 0, 
    linetype = "dashed", alpha = 0.5) + geom_point(alpha = 0.8) + 
    scale_color_manual(values = c(Treatment = "#FAA43A", 
        Control = "#5DA5DA")) + scale_fill_manual(values = c(Treatment = "#FAA43A", 
    Control = "#5DA5DA"))
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-72-1} \end{center}

From these two graph we can see that as one has higher Pre-test, change scores gets smaller (i.e. effect decreases). 

Let's plot the 1RM strength relationship to Post-test:


```r
ggplot(RCT_data, aes(x = Squat_1RM_relative, y = Measured_score.Post, 
    color = Group, fill = Group)) + theme_cowplot(8) + geom_smooth(method = "lm", 
    se = TRUE, alpha = 0.2) + geom_point(alpha = 0.8) + scale_color_manual(values = c(Treatment = "#FAA43A", 
    Control = "#5DA5DA")) + scale_fill_manual(values = c(Treatment = "#FAA43A", 
    Control = "#5DA5DA"))
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-73-1} \end{center}

As can be seen from the figure, there is interaction between 1RM and group (the lines are not parallel). Let's check with the change score:


```r
ggplot(RCT_data, aes(x = Squat_1RM_relative, y = Measured_score.Change, 
    color = Group, fill = Group)) + theme_cowplot(8) + geom_smooth(method = "lm", 
    se = TRUE, alpha = 0.2) + geom_hline(yintercept = 0, 
    linetype = "dashed", alpha = 0.5) + geom_point(alpha = 0.8) + 
    scale_color_manual(values = c(Treatment = "#FAA43A", 
        Control = "#5DA5DA")) + scale_fill_manual(values = c(Treatment = "#FAA43A", 
    Control = "#5DA5DA"))
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-74-1} \end{center}

With change score we have *controlled* for Pre-test, which gives us information that the stronger someone is, the higher the improvement. This is even more evident for the Treatment group. 

Let's do the usual analysis and check the effects. Let's first perform the method of the differences (which uses change score `mean` and `SD`):


```r
simple_RCT <- bmbstats::RCT_analysis(data = RCT_data, group = "Group", 
    treatment_label = "Treatment", control_label = "Control", 
    pre_test = "Measured_score.Pre", post_test = "Measured_score.Post", 
    SESOI_lower = -5, SESOI_upper = 5, estimator_function = bmbstats::RCT_estimators_simple, 
    control = model_control(seed = 1667))
#> [1] "All values of t are equal to  5 \n Cannot calculate confidence intervals"
#> [1] "All values of t are equal to  10 \n Cannot calculate confidence intervals"


simple_RCT
#> Bootstrap with 2000 resamples and 95% bca confidence intervals.
#> 
#>                   estimator       value      lower
#>                 SESOI lower -5.00000000         NA
#>                 SESOI upper  5.00000000         NA
#>                 SESOI range 10.00000000         NA
#>           Systematic effect  9.60660366 5.36900820
#>               Random effect  5.39012073 3.51072089
#>  Systematic effect to SESOI  0.96066037 0.53690082
#>      SESOI to Random effect  1.85524601 1.43972066
#>                      pLower  0.01200102 0.00037884
#>                 pEquivalent  0.19545959 0.02005083
#>                     pHigher  0.79253939 0.46809992
#>        upper
#>           NA
#>           NA
#>           NA
#>  13.44947544
#>   6.92558325
#>   1.34494754
#>   3.06650272
#>   0.05838599
#>   0.46036640
#>   0.97792031
```

From our DGP we know that there is no random treatment effect, but only systematic treatment effect depending on the Pre-test and relative strength levels. But with this analysis we do not know that and we use only `mean` change to estimate treatment effects, and all the residuals around the `mean` (i.e. total variance) are assumed to be random error. This is *unexplained* variance (by this model). But we do know we can explain this variance with better model specification. 

If we use linear regression model (using `bmbstats::RCT_estimators_lm`), we will address the effect of the Pre-test on the Post-test. But before, let's just show model coefficients:


```r
model6 <- lm(Measured_score.Post ~ Measured_score.Pre + Group, 
    RCT_data)

summary(model6)
#> 
#> Call:
#> lm(formula = Measured_score.Post ~ Measured_score.Pre + Group, 
#>     data = RCT_data)
#> 
#> Residuals:
#>     Min      1Q  Median      3Q     Max 
#> -3.3819 -1.7924  0.4125  1.3648  4.9797 
#> 
#> Coefficients:
#>                    Estimate Std. Error t value Pr(>|t|)
#> (Intercept)         42.6606     5.2220   8.169 2.74e-07
#> Measured_score.Pre   0.1584     0.1099   1.441    0.168
#> GroupTreatment       7.5994     1.0578   7.184 1.53e-06
#>                       
#> (Intercept)        ***
#> Measured_score.Pre    
#> GroupTreatment     ***
#> ---
#> Signif. codes:  
#> 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 2.291 on 17 degrees of freedom
#> Multiple R-squared:  0.7527,	Adjusted R-squared:  0.7236 
#> F-statistic: 25.87 on 2 and 17 DF,  p-value: 6.963e-06
```

Visually, this model looks like this:


```r
RCT_data$.pred <- predict(model6, newdata = RCT_data)

ggplot(RCT_data, aes(x = Measured_score.Pre, y = Measured_score.Post, 
    color = Group, fill = Group)) + theme_cowplot(8) + geom_abline(slope = 1, 
    linetype = "dashed") + geom_point(alpha = 0.8) + geom_line(aes(y = .pred)) + 
    scale_color_manual(values = c(Treatment = "#FAA43A", 
        Control = "#5DA5DA")) + scale_fill_manual(values = c(Treatment = "#FAA43A", 
    Control = "#5DA5DA"))
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-77-1} \end{center}

Estimated random treatment effect is equal to:


```r
SD_summary <- RCT_data %>% mutate(.resid = residuals(model6)) %>% 
    group_by(Group) %>% summarise(`Residual SD` = sd(.resid))


sqrt(SD_summary$`Residual SD`[2]^2 - SD_summary$`Residual SD`[1]^2)
#> [1] 2.521028
```

Now, let's run this model using the `bmbstats::RCT_estimators_lm` and `bmbstats::RCT_analysis`:


```r
regression_RCT <- bmbstats::RCT_analysis(data = RCT_data, 
    group = "Group", treatment_label = "Treatment", control_label = "Control", 
    pre_test = "Measured_score.Pre", post_test = "Measured_score.Post", 
    SESOI_lower = -5, SESOI_upper = 5, estimator_function = bmbstats::RCT_estimators_lm, 
    control = model_control(seed = 1667))
#> [1] "All values of t are equal to  5 \n Cannot calculate confidence intervals"
#> [1] "All values of t are equal to  10 \n Cannot calculate confidence intervals"


regression_RCT
#> Bootstrap with 2000 resamples and 95% bca confidence intervals.
#> 
#>                   estimator         value         lower
#>                 SESOI lower -5.000000e+00            NA
#>                 SESOI upper  5.000000e+00            NA
#>                 SESOI range  1.000000e+01            NA
#>           Systematic effect  7.599370e+00  5.559460e+00
#>               Random effect  2.521028e+00  1.281688e+00
#>  Systematic effect to SESOI  7.599370e-01  5.559460e-01
#>      SESOI to Random effect  3.966636e+00 -2.288091e+01
#>                      pLower  3.995354e-05  7.377399e-10
#>                 pEquivalent  1.576864e-01  2.068126e-03
#>                     pHigher  8.422736e-01  3.994218e-05
#>       upper
#>          NA
#>          NA
#>          NA
#>  10.4054050
#>   3.7842396
#>   1.0405405
#>   9.9649843
#>   1.0000000
#>   0.4686692
#>   0.9902346
```

Let's plot the estimated from the method of differences and linear regression model for easier comparison:


```r
compare_methods <- rbind(data.frame(method = "differences", 
    simple_RCT$estimators), data.frame(method = "linear regression", 
    regression_RCT$estimators))


ggplot(compare_methods, aes(y = method, x = value)) + theme_bw(8) + 
    geom_errorbarh(aes(xmax = upper, xmin = lower), color = "black", 
        height = 0) + geom_point() + xlab("") + ylab("") + 
    facet_wrap(~estimator, scales = "free_x")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-80-1} \end{center}

Please note that the estimated systematic treatment effect is smaller for the linear regression method compared to method of differences. It is the opposite for the random treatment effect estimate. This is because linear regression method estimates the effect of the group while controlling for the Pre-test.

Let's now add relative 1RM strength to the mix:


```r
model7 <- lm(Measured_score.Post ~ Measured_score.Pre + Squat_1RM_relative + 
    Group, RCT_data)

summary(model7)
#> 
#> Call:
#> lm(formula = Measured_score.Post ~ Measured_score.Pre + Squat_1RM_relative + 
#>     Group, data = RCT_data)
#> 
#> Residuals:
#>     Min      1Q  Median      3Q     Max 
#> -3.6732 -1.3602  0.1547  1.5569  3.7951 
#> 
#> Coefficients:
#>                    Estimate Std. Error t value Pr(>|t|)
#> (Intercept)         35.2743     6.7717   5.209 8.61e-05
#> Measured_score.Pre   0.2621     0.1231   2.128   0.0492
#> Squat_1RM_relative   2.4779     1.5351   1.614   0.1260
#> GroupTreatment       7.4215     1.0171   7.297 1.79e-06
#>                       
#> (Intercept)        ***
#> Measured_score.Pre *  
#> Squat_1RM_relative    
#> GroupTreatment     ***
#> ---
#> Signif. codes:  
#> 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 2.19 on 16 degrees of freedom
#> Multiple R-squared:  0.7873,	Adjusted R-squared:  0.7474 
#> F-statistic: 19.74 on 3 and 16 DF,  p-value: 1.259e-05
```

Please notice the slightly improved `RSE` of this model (indicating better model fit). Let's check the estimate random treatment effect:


```r
SD_summary <- RCT_data %>% mutate(.resid = residuals(model7)) %>% 
    group_by(Group) %>% summarise(`Residual SD` = sd(.resid))


sqrt(SD_summary$`Residual SD`[2]^2 - SD_summary$`Residual SD`[1]^2)
#> [1] 1.59975
```

This implies that with this model we were able to explain more of the treatment effect. But we do know there is interaction between Group and relative 1RM. We can model that: 


```r
model8 <- lm(
  Measured_score.Post ~ Measured_score.Pre + Squat_1RM_relative + Squat_1RM_relative:Group + Group,
  # OR we can specify the model with this
  # Measured_score.Post ~ Measured_score.Pre + Squat_1RM_relative * Group
  RCT_data
)

summary(model8)
#> 
#> Call:
#> lm(formula = Measured_score.Post ~ Measured_score.Pre + Squat_1RM_relative + 
#>     Squat_1RM_relative:Group + Group, data = RCT_data)
#> 
#> Residuals:
#>     Min      1Q  Median      3Q     Max 
#> -3.8832 -0.8725 -0.0257  0.9302  2.8875 
#> 
#> Coefficients:
#>                                   Estimate Std. Error
#> (Intercept)                       38.07464    5.35343
#> Measured_score.Pre                 0.26809    0.09618
#> Squat_1RM_relative                -0.56615    1.50382
#> GroupTreatment                    -0.20765    2.41029
#> Squat_1RM_relative:GroupTreatment  6.89774    2.05750
#>                                   t value Pr(>|t|)    
#> (Intercept)                         7.112 3.55e-06 ***
#> Measured_score.Pre                  2.787  0.01381 *  
#> Squat_1RM_relative                 -0.376  0.71183    
#> GroupTreatment                     -0.086  0.93248    
#> Squat_1RM_relative:GroupTreatment   3.352  0.00436 ** 
#> ---
#> Signif. codes:  
#> 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 1.71 on 15 degrees of freedom
#> Multiple R-squared:  0.8784,	Adjusted R-squared:  0.846 
#> F-statistic: 27.09 on 4 and 15 DF,  p-value: 1.039e-06
```

`RSE` of this model improved even further. Let's calculate the random treatment effect:


```r
SD_summary <- RCT_data %>% mutate(.resid = residuals(model8)) %>% 
    group_by(Group) %>% summarise(`Residual SD` = sd(.resid))


sqrt(SD_summary$`Residual SD`[2]^2 - SD_summary$`Residual SD`[1]^2)
#> [1] 1.476142
```

We managed to explain mode of the treatment effect (i.e. reduce the random component), but how do we not estimate the systematic effect? Now we have interaction term, and we introduced *indirect* effect of the `Group:1RM`, so we cannot simply quantify it with a single number. 

But maybe the predictive perspective can help?

## Prediction perspective 3

Before analyzing the most complex model specification, let's build from the ground-up again using *baseline* model first. This model predicts Post-test to be the same for everyone using Group as predictor. This model is useful since it gives us the worst prediction we can use to judge the other models. 

Since we are going to perform same modeling using different specification, to avoid repeating the code (which I have done on purpose thorough this book, but will avoid doing here), I will write down the function:


```r
model_RCT <- function(formula) {
    model <- cv_model(formula, RCT_data, SESOI_lower = -5, 
        SESOI_upper = 5, control = model_control(seed = 1667, 
            cv_folds = 5, cv_repeats = 10, cv_strata = factor(RCT_data$Group)))
    
    RCT <- RCT_predict(model, new_data = RCT_data, outcome = "Measured_score.Post", 
        group = "Group", treatment_label = "Treatment", control_label = "Control", 
        subject_label = RCT_data$Athlete)
    
    return(RCT)
}
```

Here is our baseline model:


```r
base_model <- model_RCT(Measured_score.Post ~ Group)

base_model
#> Training data consists of 2 predictors and 20 observations. Cross-Validation of the model was performed using 10 repeats of 5 folds.
#> 
#> Model performance:
#> 
#>         metric      training training.pooled
#>            MBE -4.618506e-15    1.634262e-15
#>            MAE  1.793742e+00    1.768937e+00
#>           RMSE  2.238021e+00    2.206270e+00
#>           PPER  9.577526e-01    9.762111e-01
#>  SESOI to RMSE  4.468233e+00    4.532536e+00
#>      R-squared  7.224490e-01    7.302684e-01
#>         MinErr -5.933469e+00   -6.532374e+00
#>         MaxErr  3.414524e+00    3.926733e+00
#>      MaxAbsErr  5.933469e+00    6.532374e+00
#>  testing.pooled          mean         SD        min
#>    1.634259e-15  1.634238e-15 1.33279182 -2.5926409
#>    1.997720e+00  1.997720e+00 0.55544631  1.0781811
#>    2.505740e+00  2.393620e+00 0.74868547  1.1928031
#>    9.520871e-01  8.549957e-01 0.08929827  0.6560171
#>    3.990837e+00  4.591613e+00 1.42736849  2.4405997
#>    6.520744e-01  6.595240e-01 0.32999136 -0.5542973
#>   -7.016430e+00 -2.794574e+00 2.16480138 -7.0164300
#>    4.141234e+00  2.385040e+00 1.21855651 -0.2376657
#>    7.016430e+00  3.768324e+00 1.58419875  1.4647768
#>        max
#>  2.7658984
#>  3.3474423
#>  4.0973536
#>  0.9718218
#>  8.3836132
#>  0.9646862
#>  2.0578483
#>  4.1412343
#>  7.0164300
#> 
#> Individual model results:
#> 
#>     subject     group observed predicted    residual
#>  Athlete 01 Treatment 53.92165  57.33617  3.41452429
#>  Athlete 02   Control 48.65099  50.11469  1.46369772
#>  Athlete 03 Treatment 60.06640  57.33617 -2.73022311
#>  Athlete 04   Control 51.66451  50.11469 -1.54981912
#>  Athlete 05 Treatment 56.88816  57.33617  0.44801588
#>  Athlete 06   Control 52.31237  50.11469 -2.19768413
#>  Athlete 07 Treatment 54.93702  57.33617  2.39915590
#>  Athlete 08   Control 51.29489  50.11469 -1.18019529
#>  Athlete 09 Treatment 63.26964  57.33617 -5.93346853
#>  Athlete 10   Control 50.28937  50.11469 -0.17467663
#>  Athlete 11 Treatment 59.39720  57.33617 -2.06102088
#>  Athlete 12   Control 50.02810  50.11469  0.08658834
#>  Athlete 13 Treatment 55.63766  57.33617  1.69851405
#>  Athlete 14   Control 46.82518  50.11469  3.28950733
#>  Athlete 15 Treatment 57.89749  57.33617 -0.56131425
#>  Athlete 16   Control 50.56725  50.11469 -0.45256087
#>  Athlete 17 Treatment 55.12290  57.33617  2.21327604
#>  Athlete 18   Control 48.30309  50.11469  1.81159973
#>  Athlete 19 Treatment 56.22363  57.33617  1.11254061
#>  Athlete 20   Control 51.21115  50.11469 -1.09645708
#>   magnitude counterfactual      pITE pITE_magnitude
#>  Equivalent       50.11469 -7.221484          Lower
#>  Equivalent       57.33617  7.221484         Higher
#>  Equivalent       50.11469 -7.221484          Lower
#>  Equivalent       57.33617  7.221484         Higher
#>  Equivalent       50.11469 -7.221484          Lower
#>  Equivalent       57.33617  7.221484         Higher
#>  Equivalent       50.11469 -7.221484          Lower
#>  Equivalent       57.33617  7.221484         Higher
#>       Lower       50.11469 -7.221484          Lower
#>  Equivalent       57.33617  7.221484         Higher
#>  Equivalent       50.11469 -7.221484          Lower
#>  Equivalent       57.33617  7.221484         Higher
#>  Equivalent       50.11469 -7.221484          Lower
#>  Equivalent       57.33617  7.221484         Higher
#>  Equivalent       50.11469 -7.221484          Lower
#>  Equivalent       57.33617  7.221484         Higher
#>  Equivalent       50.11469 -7.221484          Lower
#>  Equivalent       57.33617  7.221484         Higher
#>  Equivalent       50.11469 -7.221484          Lower
#>  Equivalent       57.33617  7.221484         Higher
#> 
#> Summary of residuals per RCT group:
#> 
#>      group          mean       SD
#>    Control -2.842214e-15 1.709932
#>  Treatment -6.394885e-15 2.864728
#> 
#> Summary of counterfactual effects of RCT group:
#> 
#>      group      pATE pVTE
#>  Treatment -7.221484    0
#>    Control  7.221484    0
#>     pooled  7.221484    0
#> 
#> Treatment effect summary
#> 
#> Average Treatment effect:  7.221484
#> Variable Treatment effect:  0
#> Random Treatment effect:  2.298433
```

Let's plot key model predictions (individual and counterfactual).


```r
plot(base_model, "prediction")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-87-1} \end{center}


```r
plot(base_model, "counterfactual")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-88-1} \end{center}

As can be seen, base model predict the same Post-test scores for each athlete (depending on the group).

Our next model is the one that uses Pre-test and Group. Let's call it `pre_test_model` (please note that this is the model used in `bmbstats::RCT_estimators_lm` function):


```r
pre_test_model <- model_RCT(Measured_score.Post ~ Group + 
    Measured_score.Pre)

pre_test_model
#> Training data consists of 3 predictors and 20 observations. Cross-Validation of the model was performed using 10 repeats of 5 folds.
#> 
#> Model performance:
#> 
#>         metric      training training.pooled
#>            MBE -1.385555e-14    3.774758e-15
#>            MAE  1.757354e+00    1.700865e+00
#>           RMSE  2.112647e+00    2.066468e+00
#>           PPER  9.675019e-01    9.841744e-01
#>  SESOI to RMSE  4.733399e+00    4.839174e+00
#>      R-squared  7.526750e-01    7.633690e-01
#>         MinErr -4.979659e+00   -5.620519e+00
#>         MaxErr  3.381897e+00    4.723784e+00
#>      MaxAbsErr  4.979659e+00    5.620519e+00
#>  testing.pooled        mean         SD        min
#>      0.03197143  0.03197143 1.25159476 -2.5288076
#>      2.04500207  2.04500207 0.53059190  0.8621495
#>      2.51137986  2.43165066 0.63415044  1.0726499
#>      0.95158915  0.84684948 0.07383527  0.6842390
#>      3.98187473  4.44664689 1.40990552  2.5812789
#>      0.65056316  0.63480891 0.32450934 -0.7834415
#>     -6.48925129 -2.73668942 1.95426062 -6.4892513
#>      4.36811806  2.71096150 1.23032364 -0.6916705
#>      6.48925129  3.85285271 1.30595427  1.9061280
#>        max
#>  2.8367663
#>  3.2662051
#>  3.8740486
#>  0.9746472
#>  9.3227066
#>  0.9507508
#>  1.9406012
#>  4.3681181
#>  6.4892513
#> 
#> Individual model results:
#> 
#>     subject     group observed predicted    residual
#>  Athlete 01 Treatment 53.92165  55.89316  1.97150648
#>  Athlete 02   Control 48.65099  50.11805  1.46705656
#>  Athlete 03 Treatment 60.06640  57.39899 -2.66741213
#>  Athlete 04   Control 51.66451  50.83931 -0.82520345
#>  Athlete 05 Treatment 56.88816  56.54332 -0.34484151
#>  Athlete 06   Control 52.31237  51.05577 -1.25660375
#>  Athlete 07 Treatment 54.93702  58.31892  3.38189720
#>  Athlete 08   Control 51.29489  50.73095 -0.56393813
#>  Athlete 09 Treatment 63.26964  58.28998 -4.97965920
#>  Athlete 10   Control 50.28937  49.75682 -0.53254676
#>  Athlete 11 Treatment 59.39720  56.86111 -2.53609024
#>  Athlete 12   Control 50.02810  50.09865  0.07054839
#>  Athlete 13 Treatment 55.63766  57.37036  1.73269990
#>  Athlete 14   Control 46.82518  49.28717  2.46198498
#>  Athlete 15 Treatment 57.89749  56.20799 -1.68949873
#>  Athlete 16   Control 50.56725  50.08713 -0.48012312
#>  Athlete 17 Treatment 55.12290  58.14891  3.02601000
#>  Athlete 18   Control 48.30309  49.65954  1.35644850
#>  Athlete 19 Treatment 56.22363  58.32902  2.10538825
#>  Athlete 20   Control 51.21115  49.51352 -1.69762322
#>   magnitude counterfactual     pITE pITE_magnitude
#>  Equivalent       48.29379 -7.59937          Lower
#>  Equivalent       57.71742  7.59937         Higher
#>  Equivalent       49.79962 -7.59937          Lower
#>  Equivalent       58.43868  7.59937         Higher
#>  Equivalent       48.94395 -7.59937          Lower
#>  Equivalent       58.65514  7.59937         Higher
#>  Equivalent       50.71955 -7.59937          Lower
#>  Equivalent       58.33032  7.59937         Higher
#>  Equivalent       50.69061 -7.59937          Lower
#>  Equivalent       57.35619  7.59937         Higher
#>  Equivalent       49.26174 -7.59937          Lower
#>  Equivalent       57.69802  7.59937         Higher
#>  Equivalent       49.77099 -7.59937          Lower
#>  Equivalent       56.88654  7.59937         Higher
#>  Equivalent       48.60862 -7.59937          Lower
#>  Equivalent       57.68650  7.59937         Higher
#>  Equivalent       50.54954 -7.59937          Lower
#>  Equivalent       57.25891  7.59937         Higher
#>  Equivalent       50.72965 -7.59937          Lower
#>  Equivalent       57.11289  7.59937         Higher
#> 
#> Summary of residuals per RCT group:
#> 
#>      group          mean       SD
#>    Control -1.136866e-14 1.334693
#>  Treatment -1.634257e-14 2.852540
#> 
#> Summary of counterfactual effects of RCT group:
#> 
#>      group     pATE         pVTE
#>  Treatment -7.59937 5.246187e-15
#>    Control  7.59937 2.254722e-15
#>     pooled  7.59937 3.992905e-15
#> 
#> Treatment effect summary
#> 
#> Average Treatment effect:  7.59937
#> Variable Treatment effect:  3.992905e-15
#> Random Treatment effect:  2.521028
```


```r
plot(pre_test_model, "prediction")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-90-1} \end{center}


```r
plot(pre_test_model, "counterfactual")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-91-1} \end{center}

Additional plot we can do is the PDP+ICE for group predictor (i.e. treatment effect):


```r
plot(pre_test_model, "pdp+ice")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-92-1} \end{center}

And also for the Pre-test predictor:


```r
plot(pre_test_model, "pdp+ice", predictor = "Measured_score.Pre")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-93-1} \end{center}

Next model adds additional predictor (covariate): relative squat 1RM:


```r
covariate_model <- model_RCT(Measured_score.Post ~ Group + 
    Measured_score.Pre + Squat_1RM_relative)

covariate_model
#> Training data consists of 4 predictors and 20 observations. Cross-Validation of the model was performed using 10 repeats of 5 folds.
#> 
#> Model performance:
#> 
#>         metric      training training.pooled
#>            MBE -1.492140e-14    3.641497e-15
#>            MAE  1.609713e+00    1.560087e+00
#>           RMSE  1.959142e+00    1.895527e+00
#>           PPER  9.776803e-01    9.914518e-01
#>  SESOI to RMSE  5.104275e+00    5.275579e+00
#>      R-squared  7.873104e-01    8.008987e-01
#>         MinErr -3.795052e+00   -4.671246e+00
#>         MaxErr  3.673197e+00    4.356870e+00
#>      MaxAbsErr  3.795052e+00    4.671246e+00
#>  testing.pooled        mean         SD        min
#>     -0.04731864 -0.04731864 1.27184288 -2.4388220
#>      1.99431750  1.99431750 0.67386685  0.3458090
#>      2.51905179  2.40288524 0.76382791  0.4106030
#>      0.95090835  0.84667956 0.08174096  0.6970788
#>      3.96974768  5.02832487 3.49488784  2.6565400
#>      0.64849202  0.58513228 0.56466111 -1.9362660
#>     -6.30927941 -2.64672001 1.65641966 -6.3092794
#>      5.13611940  2.81303001 1.68991662 -0.2922030
#>      6.30927941  3.84840058 1.32366331  0.7157490
#>         max
#>   2.4598851
#>   3.4404583
#>   3.7642949
#>   0.9981811
#>  24.3544266
#>   0.9784156
#>   0.8127197
#>   5.1361194
#>   6.3092794
#> 
#> Individual model results:
#> 
#>     subject     group observed predicted   residual
#>  Athlete 01 Treatment 53.92165  54.96555  1.0439001
#>  Athlete 02   Control 48.65099  49.96562  1.3146319
#>  Athlete 03 Treatment 60.06640  58.07113 -1.9952645
#>  Athlete 04   Control 51.66451  49.85167 -1.8128409
#>  Athlete 05 Treatment 56.88816  56.70667 -0.1814903
#>  Athlete 06   Control 52.31237  51.17699 -1.1353824
#>  Athlete 07 Treatment 54.93702  57.50946  2.5724418
#>  Athlete 08   Control 51.29489  51.16688 -0.1280040
#>  Athlete 09 Treatment 63.26964  59.47459 -3.7950523
#>  Athlete 10   Control 50.28937  50.06036 -0.2290056
#>  Athlete 11 Treatment 59.39720  57.92560 -1.4715975
#>  Athlete 12   Control 50.02810  50.16875  0.1406476
#>  Athlete 13 Treatment 55.63766  56.19778  0.5601237
#>  Athlete 14   Control 46.82518  50.35886  3.5336766
#>  Athlete 15 Treatment 57.89749  55.72955 -2.1679347
#>  Athlete 16   Control 50.56725  48.39034 -2.1769094
#>  Athlete 17 Treatment 55.12290  58.79610  3.6731974
#>  Athlete 18   Control 48.30309  49.79992  1.4968326
#>  Athlete 19 Treatment 56.22363  57.98531  1.7616764
#>  Athlete 20   Control 51.21115  50.20750 -1.0036463
#>   magnitude counterfactual      pITE pITE_magnitude
#>  Equivalent       47.54404 -7.421514          Lower
#>  Equivalent       57.38714  7.421514         Higher
#>  Equivalent       50.64962 -7.421514          Lower
#>  Equivalent       57.27318  7.421514         Higher
#>  Equivalent       49.28515 -7.421514          Lower
#>  Equivalent       58.59851  7.421514         Higher
#>  Equivalent       50.08795 -7.421514          Lower
#>  Equivalent       58.58840  7.421514         Higher
#>  Equivalent       52.05308 -7.421514          Lower
#>  Equivalent       57.48188  7.421514         Higher
#>  Equivalent       50.50408 -7.421514          Lower
#>  Equivalent       57.59026  7.421514         Higher
#>  Equivalent       48.77627 -7.421514          Lower
#>  Equivalent       57.78037  7.421514         Higher
#>  Equivalent       48.30804 -7.421514          Lower
#>  Equivalent       55.81186  7.421514         Higher
#>  Equivalent       51.37458 -7.421514          Lower
#>  Equivalent       57.22144  7.421514         Higher
#>  Equivalent       50.56380 -7.421514          Lower
#>  Equivalent       57.62902  7.421514         Higher
#> 
#> Summary of residuals per RCT group:
#> 
#>      group          mean       SD
#>    Control -1.492135e-14 1.727747
#>  Treatment -1.492135e-14 2.354636
#> 
#> Summary of counterfactual effects of RCT group:
#> 
#>      group      pATE         pVTE
#>  Treatment -7.421514 5.617334e-15
#>    Control  7.421514 4.037713e-15
#>     pooled  7.421514 4.890290e-15
#> 
#> Treatment effect summary
#> 
#> Average Treatment effect:  7.421514
#> Variable Treatment effect:  4.89029e-15
#> Random Treatment effect:  1.59975
```


```r
plot(covariate_model, "prediction")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-95-1} \end{center}


```r
plot(covariate_model, "counterfactual")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-96-1} \end{center}


```r
plot(covariate_model, "pdp+ice")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-97-1} \end{center}


```r
plot(covariate_model, "pdp+ice", predictor = "Measured_score.Pre")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-98-1} \end{center}


```r
plot(covariate_model, "pdp+ice", predictor = "Squat_1RM_relative")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-99-1} \end{center}

And the final model is the interaction model:


```r
interaction_model <- model_RCT(Measured_score.Post ~ Group * 
    Squat_1RM_relative + Measured_score.Pre)

interaction_model
#> Training data consists of 5 predictors and 20 observations. Cross-Validation of the model was performed using 10 repeats of 5 folds.
#> 
#> Model performance:
#> 
#>         metric      training training.pooled
#>            MBE  2.486856e-15    5.107026e-15
#>            MAE  1.102035e+00    1.073541e+00
#>           RMSE  1.481278e+00    1.420252e+00
#>           PPER  9.961488e-01    9.995411e-01
#>  SESOI to RMSE  6.750926e+00    7.041003e+00
#>      R-squared  8.784129e-01    8.882249e-01
#>         MinErr -2.887520e+00   -3.387465e+00
#>         MaxErr  3.883197e+00    4.125618e+00
#>      MaxAbsErr  3.883197e+00    4.125618e+00
#>  testing.pooled        mean         SD         min
#>     -0.02897255 -0.02897255 0.96232473 -2.10791777
#>      1.51448758  1.51448758 0.62541112  0.42250638
#>      2.00731144  1.86964221 0.73799039  0.62520553
#>      0.98620762  0.90318747 0.07713261  0.73706941
#>      4.98178798  6.39845655 2.94071918  3.06196160
#>      0.77676962  0.72661171 0.39233243 -1.30891277
#>     -4.84781640 -2.22509568 1.45777723 -4.84781640
#>      5.22505955  2.04804580 1.57273644  0.03320484
#>      5.22505955  3.10011470 1.33675406  1.05228122
#>         max
#>   2.0771169
#>   2.9228564
#>   3.2658803
#>   0.9955572
#>  15.9947402
#>   0.9875223
#>   1.2235186
#>   5.2250596
#>   5.2250596
#> 
#> Individual model results:
#> 
#>     subject     group observed predicted    residual
#>  Athlete 01 Treatment 53.92165  54.93714  1.01549088
#>  Athlete 02   Control 48.65099  50.15570  1.50470919
#>  Athlete 03 Treatment 60.06640  59.05490 -1.01150268
#>  Athlete 04   Control 51.66451  51.67481  0.01030262
#>  Athlete 05 Treatment 56.88816  57.73773  0.84957368
#>  Athlete 06   Control 52.31237  51.82011 -0.49226674
#>  Athlete 07 Treatment 54.93702  55.28749  0.35047044
#>  Athlete 08   Control 51.29489  51.15000 -0.14488443
#>  Athlete 09 Treatment 63.26964  60.38212 -2.88752039
#>  Athlete 10   Control 50.28937  49.38628 -0.90309058
#>  Athlete 11 Treatment 59.39720  60.04667  0.64947349
#>  Athlete 12   Control 50.02810  50.06914  0.04103265
#>  Athlete 13 Treatment 55.63766  54.34070 -1.29696009
#>  Athlete 14   Control 46.82518  48.34585  1.52066587
#>  Athlete 15 Treatment 57.89749  56.09115 -1.80634311
#>  Athlete 16   Control 50.56725  50.45161 -0.11564089
#>  Athlete 17 Treatment 55.12290  59.00610  3.88319663
#>  Athlete 18   Control 48.30309  49.24440  0.94130869
#>  Athlete 19 Treatment 56.22363  56.47776  0.25412115
#>  Athlete 20   Control 51.21115  48.84901 -2.36213638
#>   magnitude counterfactual       pITE pITE_magnitude
#>  Equivalent       46.93258  -8.004564          Lower
#>  Equivalent       56.49986   6.344157         Higher
#>  Equivalent       49.34023  -9.714660          Lower
#>  Equivalent       54.38014   2.705324     Equivalent
#>  Equivalent       47.88067  -9.857066          Lower
#>  Equivalent       57.21781   5.397698         Higher
#>  Equivalent       51.37291  -3.914577     Equivalent
#>  Equivalent       58.01547   6.865468         Higher
#>  Equivalent       50.86403  -9.518092          Lower
#>  Equivalent       57.65772   8.271448         Higher
#>  Equivalent       48.26002 -11.786649          Lower
#>  Equivalent       57.06806   6.998928         Higher
#>  Equivalent       49.70900  -4.631703     Equivalent
#>  Equivalent       59.61112  11.265266         Higher
#>  Equivalent       47.40976  -8.681390          Lower
#>  Equivalent       52.55310   2.101491     Equivalent
#>  Equivalent       50.72701  -8.279084          Lower
#>  Equivalent       57.23888   7.994484         Higher
#>  Equivalent       51.28511  -5.192643          Lower
#>  Equivalent       58.65050   9.801492         Higher
#> 
#> Summary of residuals per RCT group:
#> 
#>      group         mean       SD
#>    Control 7.105211e-16 1.161243
#>  Treatment 4.263218e-15 1.878159
#> 
#> Summary of counterfactual effects of RCT group:
#> 
#>      group      pATE     pVTE
#>  Treatment -7.958043 2.570647
#>    Control  6.774576 2.859555
#>     pooled  7.366309 2.715167
#> 
#> Treatment effect summary
#> 
#> Average Treatment effect:  7.366309
#> Variable Treatment effect:  2.715167
#> Random Treatment effect:  1.476142
```


```r
plot(interaction_model, "prediction")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-101-1} \end{center}


```r
plot(interaction_model, "counterfactual")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-102-1} \end{center}


```r
plot(interaction_model, "pdp+ice")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-103-1} \end{center}


```r
plot(interaction_model, "pdp+ice", predictor = "Measured_score.Pre")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-104-1} \end{center}


```r
plot(interaction_model, "pdp+ice", predictor = "Squat_1RM_relative")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-105-1} \end{center}

For the sake of comparisson between the models, let's pull out estimated average, random, and variable treatment effects. Average treatment effect (`pATE`) is estimated using the `mean` of the pooled (absolute) counterfactual effects (see the previous model print summaries). Variable treatment effect (`pVTE`) is estimated using the `SD` of the pooled (absolute) counterfactual effects. Random treatment effect (`RTE`) is estimated using the group residuals as explained thorough this chapter. 


```r
model_estimates <- rbind(data.frame(model = "base", pATE = base_model$extra$average_treatment_effect, 
    pVTE = base_model$extra$variable_treatment_effect, RTE = base_model$extra$random_treatment_effect), 
    data.frame(model = "pre-test", pATE = pre_test_model$extra$average_treatment_effect, 
        pVTE = pre_test_model$extra$variable_treatment_effect, 
        RTE = pre_test_model$extra$random_treatment_effect), 
    data.frame(model = "covariate", pATE = covariate_model$extra$average_treatment_effect, 
        pVTE = covariate_model$extra$variable_treatment_effect, 
        RTE = covariate_model$extra$random_treatment_effect), 
    data.frame(model = "interaction", pATE = interaction_model$extra$average_treatment_effect, 
        pVTE = interaction_model$extra$variable_treatment_effect, 
        RTE = interaction_model$extra$random_treatment_effect))

model_estimates
#>         model     pATE         pVTE      RTE
#> 1        base 7.221484 0.000000e+00 2.298433
#> 2    pre-test 7.599370 3.992905e-15 2.521028
#> 3   covariate 7.421514 4.890290e-15 1.599750
#> 4 interaction 7.366309 2.715167e+00 1.476142
```

Using counterfactual prediction, which is estimated by changing the group (and also group interaction with the squat 1RM), allows us to estimate average treatment effect (i.e. systematic or expected treatment effect) from the model with interactions. 

Let's plot the model predictive performance to compare the models. Let's check the training performance (using training CV folds, where error bars represent `min` and `max` across training folds):


```r
model_performace <- rbind(data.frame(model = "base", base_model$cross_validation$performance$summary$training), 
    data.frame(model = "pre-test", pre_test_model$cross_validation$performance$summary$training), 
    data.frame(model = "covariate", covariate_model$cross_validation$performance$summary$training), 
    data.frame(model = "interaction", interaction_model$cross_validation$performance$summary$training))

model_performace$model <- factor(model_performace$model, 
    levels = rev(c("base", "pre-test", "covariate", "interaction")))

ggplot(model_performace, aes(y = model, x = mean)) + theme_bw(8) + 
    geom_errorbarh(aes(xmax = min, xmin = max), color = "black", 
        height = 0) + geom_point() + xlab("") + ylab("") + 
    facet_wrap(~metric, scales = "free_x")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-107-1} \end{center}

As can be seen from the figure, interaction model has the best training folds predictive performance. What about performance on the testing CV folds?


```r
model_performace <- rbind(data.frame(model = "base", base_model$cross_validation$performance$summary$testing), 
    data.frame(model = "pre-test", pre_test_model$cross_validation$performance$summary$testing), 
    data.frame(model = "covariate", covariate_model$cross_validation$performance$summary$testing), 
    data.frame(model = "interaction", interaction_model$cross_validation$performance$summary$testing))

model_performace$model <- factor(model_performace$model, 
    levels = rev(c("base", "pre-test", "covariate", "interaction")))

ggplot(model_performace, aes(y = model, x = mean)) + theme_bw(8) + 
    geom_errorbarh(aes(xmax = min, xmin = max), color = "black", 
        height = 0) + geom_point() + xlab("") + ylab("") + 
    facet_wrap(~metric, scales = "free_x")
```



\begin{center}\includegraphics[width=0.9\linewidth]{16-RCT-analysis-prediction_files/figure-latex/unnamed-chunk-108-1} \end{center}

Interaction model is better, but not drastically better. Mean testing `PPER` is pretty good, over 0.9 indicating good practical predictive performance of this model. 

Although the simple differences method or linear regression model helped us to *explain* overall treatment effects, predictive approach can tell us if we are able to predict individual responses, but also help in interpreting model counterfactually, particularly when there is interaction terms in the model. 

We have used linear regression as out predictive model, but we could use any other model for that matter. Having RCT design allows us the interpret certain effect causally. Discussing these topics further is beyond the scope of this book (and the author) and the reader is directed to the references provided. 
