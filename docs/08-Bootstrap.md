---
output: html_document
editor_options: 
  chunk_output_type: console
---


# Bootstrap

As already stated, some estimators have unknown sampling distribution, particularly those that might have more practical use and answer predictive questions by the practitioners (e.g. "what is the proportion of athletes I can expect to demonstrate beneficial response due to this treatment?"). Hence, the frequentist approach is very hard to use. With the Bayesian approach, some estimators might be really hard to be modeled and represented, researchers might be confused with the priors and likelihood function selections, there is knowledge needed to understand and diagnose sampling chains from MCMC algorithms and so forth.  

*Bootstrap* comes for the rescue [@cantyBootBootstrapSPlus2017; @davisonBootstrapMethodsTheir1997; @efronComputerAgeStatistical2016; @hesterbergWhatTeachersShould2015; @rousseletPercentileBootstrapTeaser2019; @rousseletPracticalIntroductionBootstrap2019]. Bootstrap is very simple and intuitive technique that is very easy to carry out. Let's take an example to demonstrate simplicity of the bootstrap. Continuing with the height example, let's assume that the following sample is collected for N=10 individuals: 167, 175, 175, 176, 177, 181, 188, 190, 197, 211cm. We are interested in estimating the true `mean` in the population, `SD` in the population, and proportion of individuals taller than 185cm (`prop185`; using algebraic method and estimated `SD`). The first step, as explained in the [Description] section of this book, is to estimate those parameters using sample. But how do we estimate the uncertainty around the sample estimates? 

Bootstrap involves *resampling* from the sample itself and then recalculating estimates of interest. If we have N=10 observations in the collected sample, for each bootstrap resample we are going to draw 10x1 observations. Some observations might be drawn multiple times, while some might not be drawn at all. This is then repeated numerous times, e.g., 2,000-10,000 times and for each bootstrap resample the estimators of interest are estimated. Table \@ref(tab:bootstrap-example) contains 10 bootstrap resamples with calculated estimators of interest. Bootstrap resample of number 0 represents the original sample. 

(ref:bootstrap-example-caption) **Bootstrap resamples**

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>(\#tab:bootstrap-example)(ref:bootstrap-example-caption)</caption>
 <thead>
  <tr>
   <th style="text-align:right;"> Boot resample </th>
   <th style="text-align:left;"> Observations </th>
   <th style="text-align:right;"> mean </th>
   <th style="text-align:right;"> SD </th>
   <th style="text-align:right;"> prop185 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> 167 175 175 176 177 181 188 190 197 211 </td>
   <td style="text-align:right;"> 183.7 </td>
   <td style="text-align:right;"> 13.00 </td>
   <td style="text-align:right;"> 0.46 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 167 167 167 177 188 188 188 188 197 197 </td>
   <td style="text-align:right;"> 182.4 </td>
   <td style="text-align:right;"> 11.98 </td>
   <td style="text-align:right;"> 0.41 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> 175 175 175 181 181 181 181 190 197 197 </td>
   <td style="text-align:right;"> 183.3 </td>
   <td style="text-align:right;"> 8.49 </td>
   <td style="text-align:right;"> 0.42 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> 175 175 177 177 181 181 188 188 188 190 </td>
   <td style="text-align:right;"> 182.0 </td>
   <td style="text-align:right;"> 5.98 </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> 167 181 181 181 181 188 188 197 197 197 </td>
   <td style="text-align:right;"> 185.8 </td>
   <td style="text-align:right;"> 9.61 </td>
   <td style="text-align:right;"> 0.53 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> 167 176 176 177 181 188 190 190 211 211 </td>
   <td style="text-align:right;"> 186.7 </td>
   <td style="text-align:right;"> 14.71 </td>
   <td style="text-align:right;"> 0.55 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:left;"> 167 167 167 175 177 177 188 188 190 211 </td>
   <td style="text-align:right;"> 180.7 </td>
   <td style="text-align:right;"> 13.88 </td>
   <td style="text-align:right;"> 0.38 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> 175 175 175 176 177 177 181 181 188 190 </td>
   <td style="text-align:right;"> 179.5 </td>
   <td style="text-align:right;"> 5.50 </td>
   <td style="text-align:right;"> 0.16 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:left;"> 175 175 175 176 177 181 188 190 190 190 </td>
   <td style="text-align:right;"> 181.7 </td>
   <td style="text-align:right;"> 6.96 </td>
   <td style="text-align:right;"> 0.32 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:left;"> 176 176 177 181 190 190 190 190 197 211 </td>
   <td style="text-align:right;"> 187.8 </td>
   <td style="text-align:right;"> 10.97 </td>
   <td style="text-align:right;"> 0.60 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> 167 167 175 175 175 176 176 177 177 188 </td>
   <td style="text-align:right;"> 175.3 </td>
   <td style="text-align:right;"> 5.83 </td>
   <td style="text-align:right;"> 0.05 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:left;"> 175 177 181 181 181 188 190 197 197 211 </td>
   <td style="text-align:right;"> 187.8 </td>
   <td style="text-align:right;"> 11.21 </td>
   <td style="text-align:right;"> 0.60 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> 175 175 175 176 176 177 181 188 190 211 </td>
   <td style="text-align:right;"> 182.4 </td>
   <td style="text-align:right;"> 11.47 </td>
   <td style="text-align:right;"> 0.41 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 13 </td>
   <td style="text-align:left;"> 175 175 177 181 181 188 190 190 211 211 </td>
   <td style="text-align:right;"> 187.9 </td>
   <td style="text-align:right;"> 13.43 </td>
   <td style="text-align:right;"> 0.59 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 14 </td>
   <td style="text-align:left;"> 167 175 175 176 177 177 188 190 211 211 </td>
   <td style="text-align:right;"> 184.7 </td>
   <td style="text-align:right;"> 15.34 </td>
   <td style="text-align:right;"> 0.49 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:left;"> 175 177 177 181 181 188 188 190 211 211 </td>
   <td style="text-align:right;"> 187.9 </td>
   <td style="text-align:right;"> 13.21 </td>
   <td style="text-align:right;"> 0.59 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 16 </td>
   <td style="text-align:left;"> 167 175 175 175 177 177 181 188 190 197 </td>
   <td style="text-align:right;"> 180.2 </td>
   <td style="text-align:right;"> 8.92 </td>
   <td style="text-align:right;"> 0.30 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 17 </td>
   <td style="text-align:left;"> 175 175 175 176 177 177 181 190 190 197 </td>
   <td style="text-align:right;"> 181.3 </td>
   <td style="text-align:right;"> 8.04 </td>
   <td style="text-align:right;"> 0.32 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:left;"> 167 175 175 175 176 177 177 188 188 188 </td>
   <td style="text-align:right;"> 178.6 </td>
   <td style="text-align:right;"> 7.07 </td>
   <td style="text-align:right;"> 0.18 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 19 </td>
   <td style="text-align:left;"> 167 167 175 177 181 188 190 197 197 211 </td>
   <td style="text-align:right;"> 185.0 </td>
   <td style="text-align:right;"> 14.24 </td>
   <td style="text-align:right;"> 0.50 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> 167 167 175 175 176 176 177 181 197 211 </td>
   <td style="text-align:right;"> 180.2 </td>
   <td style="text-align:right;"> 13.66 </td>
   <td style="text-align:right;"> 0.36 </td>
  </tr>
</tbody>
</table>

If we repeat this procedure 10,000 times, we can visualize bootstrap distribution of the estimators (Figure \@ref(fig:bootstrap-distribution)). 

<div class="figure" style="text-align: center">
<img src="08-Bootstrap_files/figure-html/bootstrap-distribution-1.png" alt="(ref:bootstrap-distribution-caption)" width="90%" />
<p class="caption">(\#fig:bootstrap-distribution)(ref:bootstrap-distribution-caption)</p>
</div>

(ref:bootstrap-distribution-caption) **Bootstrap distribution of the estimators using 10,000 resamples**

How should this bootstrap distribution be interpreted? In "Elements of Statistical Learning", the following quote regarding bootstrap distribution can be found [@hastieElementsStatisticalLearning2009,  pp. 272]: 

>"In this sense, the bootstrap distribution represents an (approximate) nonparametric, noninformative posterior distribution for our parameter. But this bootstrap distribution is obtained painlessly — without having to formally specify a prior and without having to sample from the posterior distribution. Hence we might think of the bootstrap distribution as a “poor man’s” Bayes posterior. By perturbing the data, the bootstrap approximates the Bayesian effect of perturbing the parameters, and is typically much simpler to carry out"

Although the bootstrap was originally developed as a purely frequentist device [@efronBayesiansFrequentistsScientists2005], as per the quote above, it can be treated as “poor man’s” Bayes posterior.

## Summarizing bootstrap distribution

Bootstrap allows for both estimation and hypothesis testing. When it comes to estimations, point estimate of the bootstrap distribution is the sample parameter estimate. Confidence intervals around sample estimate are usually calculated using percentile approach (or ETI), or other approaches such as *adjusted bootstrap percentile* (BCa) [@cantyBootBootstrapSPlus2017; @davisonBootstrapMethodsTheir1997; @efronComputerAgeStatistical2016; @hesterbergWhatTeachersShould2015; @rousseletPercentileBootstrapTeaser2019; @rousseletPracticalIntroductionBootstrap2019], or even HDI as used with Bayesian posterior distributions. In this book I will utilize BCa intervals unless otherwise stated.  

Hypothesis testing using the bootstrap distribution is possible through calculated p-value [@rousseletPercentileBootstrapTeaser2019; @rousseletPracticalIntroductionBootstrap2019]. This not only allows for bootstrap NHST, but also all other MET, as well as MBI estimates (which assumes Bayesian interpretation of the bootstrap distributions). This is simply done by counting bootstrap sample estimates that are below or above particular threshold (i.e. null-hypothesis or SESOI). The R code [@rcoreteamLanguageEnvironmentStatistical2018; @rstudioteamRStudioIntegratedDevelopment2016] below demonstrates how two-way NHST can be performed as well as probability of lower, equivalent, and higher effect given the SESOI thresholds.  


```r
null_hypothesis <- 0 # Value for the null

SESOI_lower <- -1 # threshold for the 'lower' effect magnitude
SESOI_upper <- 1 # threshold for the 'upper' effect magnitude

# Calculation of the p-value
# where boot.estimator is the boostrap resample values for the estimator
# of interest
p_value <- mean(boot.estimator > null_hypothesis)
p_value <- p_value + 0.5 * mean(boot.estimator == null_hypothesis)
p_value <- 2 * min(c(p_value, 1 - p_value)) # Two-way p-value

# Calculate probability of lower, equivalent and higher effect magnitude
lower <- mean(boot.estimator < SESOI_lower)
higher <- mean(boot.estimator > SESOI_upper)
equivalent <- 1 - (lower + higher)
```

## Bootstrap Type I errors

As we already did with the frequentist and Bayesian inference, let's get estimates of Type I errors for bootstrap method (10,000 bootstrap resamples) by drawing 1,000 samples of N=20 observations from the population where the true `mean` height is equal to 177.8cm and `SD` is equal to 10.16cm. Besides estimating Type I error for the sample `mean`, we can also estimate Type I errors for sample `SD` and `prop185`, since the true population values are known. In the case of `prop185`, the true population value is equal to 0.24. Type I error is committed when the the 95% bootstrap CIs of the sample estimate don't cross the true value in the population. Figure \@ref(fig:bootstrap-type-i) depicts the first 100 samples out of the total of 1,000, taken from the population with calculated 95% bootstrap CIs. CIs that missed the true population parameter value are depicted in red. Table \@ref(tab:bootstrap-type-i-summary) contains the summary for this simulation.

<div class="figure" style="text-align: center">
<img src="08-Bootstrap_files/figure-html/bootstrap-type-i-1.png" alt="(ref:bootstrap-type-i-caption)" width="90%" />
<p class="caption">(\#fig:bootstrap-type-i)(ref:bootstrap-type-i-caption)</p>
</div>

(ref:bootstrap-type-i-caption) **Bootstrap $95\%$confidence intervals.** Intervals not capturing the true population parameter are colored in red

(ref:bootstrap-type-i-summary-caption) **Bootstrap Type I errors**

<table>
<caption>(\#tab:bootstrap-type-i-summary)(ref:bootstrap-type-i-summary-caption)</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> parameter </th>
   <th style="text-align:right;"> Sample </th>
   <th style="text-align:right;"> Correct % </th>
   <th style="text-align:right;"> Type I Errors % </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> mean </td>
   <td style="text-align:right;"> 1000 </td>
   <td style="text-align:right;"> 92.7 </td>
   <td style="text-align:right;"> 7.3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sd </td>
   <td style="text-align:right;"> 1000 </td>
   <td style="text-align:right;"> 89.9 </td>
   <td style="text-align:right;"> 10.1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> prop185 </td>
   <td style="text-align:right;"> 1000 </td>
   <td style="text-align:right;"> 93.1 </td>
   <td style="text-align:right;"> 6.9 </td>
  </tr>
</tbody>
</table>

As can be seen from the Table \@ref(tab:bootstrap-type-i-summary), Type I error for the $\sigma$ parameter is larger than expected. This could be due to the non-symmetrical bootstrap distribution that might not be perfectly represented with the BCa approach of calculating CIs. 

I am not hiding my preference for the bootstrap methods due to their intuitive nature and simple usage for generating inferences for any estimator.

However, bootstrap is not panacea and there are caveats especially for the small samples sizes [@rousseletPercentileBootstrapTeaser2019; @rousseletPracticalIntroductionBootstrap2019; @wilcoxDataAnalysesWhen2018; @wilcoxGuideRobustStatistical2017]. 
