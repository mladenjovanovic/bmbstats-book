---
output: html_document
editor_options: 
  chunk_output_type: console
---

# Bayesian perspective

Bayesian inference is reallocation of plausibility (credibility) across possibilities [@kruschkeBayesianDataAnalysis2018; @kruschkeBayesianNewStatistics2018; @mcelreathStatisticalRethinkingBayesian2015]. Kruschke and Liddell [@kruschkeBayesianDataAnalysis2018, pp. 156] wrote in their paper as follows: 

>"The main idea of Bayesian analysis is simple and intuitive. There are some data to be explained, and we have a set of candidate explanations. Before knowing the new data, the candidate explanations have some prior credibility of being the best explanation. Then, when given the new data, we shift credibility toward the candidate explanations that better account for the data, and we shift credibility away from the candidate explanations that do not account well for the data. A mathematically compelling way to reallocate credibility is called Bayes’ rule. The rest is just details."

The aim of this section is to provide the gross overview of the Bayesian inference using *grid approximation* method [@mcelreathStatisticalRethinkingBayesian2015], which is excellent teaching tool, but very limited for Bayesian analysis beyond simple mean and simple linear regression inference. More elaborate discussion on the Bayesian methods, such as Bayes factor, priors selection, model comparison, and *Markov Chain Monte Carlo* sampling is beyond the scope of this book. Interested readers are directed to the references provided and suggested readings at the end of this book.


## Grid approximation

To showcase the rationale behind Bayesian inference let's consider the same example used in [Frequentist perspective] chapter - the male height. The question we are asking is, given our data, what is the true average male height (`mean`; mu or Greek letter $\mu$) and `SD` (sigma or Greek letter $\sigma$). You can immediately notice the difference in the question asked. In the frequentist approach we are asking "What is the probability of observing the data[^data-estimator] (estimator, like `mean` or `Cohen's d`), given the null hypothesis?" 

[^data-estimator]: Personally, I found this confusing when I started my journey into inferential statistics. I prefer to state "What is the probability of observing value (i.e. estimate) of the selected **estimator** given the null hypothesis (null being estimator value)?", rather than using the term *data*. We are making inferences using the data estimator, not the data *per se*. For example, we are not inferring whether the groups differ (i.e. data), but whether the group `means` differ (estimator).

True average male height and true `SD` represents parameters, and with Bayesian inference we want to relocate credibility across possibilities of those parameters (given the data collected). For the sake of this simplistic example, let's consider the following possibilities for the `mean` height: 170, 175, 180cm, and for SD: 9, 10, 11cm. This gives us the following *grid* (Table \@ref(tab:bayes-height-grid)), which combines all possibilities in the parameters, hence the name grid approximation. Since we have three possibilities for each parameter, the grid consists of 9 total possibilities. 

(ref:bayes-height-grid-caption) **Parameter possibilities**

\begin{table}

\caption{(\#tab:bayes-height-grid)(ref:bayes-height-grid-caption)}
\centering
\begin{tabular}[t]{rr}
\toprule
mu & sigma\\
\midrule
170 & 9\\
175 & 9\\
180 & 9\\
170 & 10\\
175 & 10\\
\addlinespace
180 & 10\\
170 & 11\\
175 & 11\\
180 & 11\\
\bottomrule
\end{tabular}
\end{table}


## Priors

Before analyzing the collected data sample, with Bayesian inference we want to state the *prior* beliefs in parameter possibilities. For example, I might state that from previous data collected, I believe that the `mean` height is around 170 and 180cm, with a peak at 175cm (e.g. approximating normal curve). We will come back to topic of prior later on, but for now lets use *uniform* or *vague* prior, which assigns equal plausibility to all `mean` height and `SD` possibilities. Since each parameter has three possibilities, and since probabilities needs to sum up to 1, each possibility has probability of 1/3 or 0.333. This is assigned to our grid in the Table \@ref(tab:bayes-height-grid-priors). 

(ref:bayes-height-grid-priors-caption) **Parameter possibilities with priors**

\begin{table}

\caption{(\#tab:bayes-height-grid-priors)(ref:bayes-height-grid-priors-caption)}
\centering
\begin{tabular}[t]{rrrr}
\toprule
mu & sigma & mu prior & sigma prior\\
\midrule
170 & 9 & 0.33 & 0.33\\
175 & 9 & 0.33 & 0.33\\
180 & 9 & 0.33 & 0.33\\
170 & 10 & 0.33 & 0.33\\
175 & 10 & 0.33 & 0.33\\
\addlinespace
180 & 10 & 0.33 & 0.33\\
170 & 11 & 0.33 & 0.33\\
175 & 11 & 0.33 & 0.33\\
180 & 11 & 0.33 & 0.33\\
\bottomrule
\end{tabular}
\end{table}

## Likelihood function

The sample height data we have collected for N=5 individuals is 167, 192, 183, 175, 177cm. From this sample we are interested in making inference to the true parameter values (i.e. `mean` and `SD`, or $\mu$ and $\sigma$). Without going into the *Bayes theorem* for *inverse probability*, the next major step is the *likelihood function*. Likelihood function gives us a likelihood of observing data, given parameters. Since we have 9 parameter possibilities, we are interested in calculating the likelihood of observing the data for each possibility. This is represented with a following Equation \@ref(eq:likelihood-function):


\begin{equation}
  L(x|\mu, \sigma) = \prod_{i=1}^{n}f(x_{i}, \mu, \sigma) 
  (\#eq:likelihood-function)
\end{equation}


The likelihood of observing the data is calculated by taking the *product* (indicated by $\prod_{i=1}^{n}$ sign in the Equation \@ref(eq:likelihood-function) of likelihood of observing individual scores. The likelihood function is normal *probability density function* (PDF)[^other-likelihood]:, whose parameters are $\mu$ and $\sigma$ (see Figure \@ref(fig:data-likelihood)). This function has the following Equation \@ref(eq:likelihood-equation):

[^other-likelihood]: There are other likelihood functions that one can use of course, similar to the various *loss functions* used in [Prediction] section. 


\begin{equation}
  f(x_{i}, \mu, \sigma) = \frac{e^{-(x - \mu)^{2}/(2\sigma^{2}) }} {\sigma\sqrt{2\pi}}
  (\#eq:likelihood-equation)
\end{equation}


Let's take a particular possibility of $\mu$ and $\sigma$, e.g. 175cm and 9cm, and calculate likelihoods for each observed score (Table \@ref(tab:bayes-height-grid-likelihood)).

(ref:bayes-height-grid-likelihood-caption) **Likelihoods of observing scores given $\mu$ and $\sigma$ equal to 175cm and 9cm**

\begin{table}

\caption{(\#tab:bayes-height-grid-likelihood)(ref:bayes-height-grid-likelihood-caption)}
\centering
\begin{tabular}[t]{rrrr}
\toprule
mu & sigma & x & likelihood\\
\midrule
175 & 9 & 167 & 0.03\\
175 & 9 & 192 & 0.01\\
175 & 9 & 183 & 0.03\\
175 & 9 & 175 & 0.04\\
175 & 9 & 177 & 0.04\\
\bottomrule
\end{tabular}
\end{table}

Now, to estimate likelihood of the sample, we need to take the product of each individual score likelihoods. However, now we have a problem, since the result will be very, very small number (\ensuremath{1.272648\times 10^{-8}}). To solve this issue, we take the log of the likelihood function. This is called *log likelihood* (LL) and it is easier to compute without the fear of losing digits. Table \@ref(tab:bayes-height-grid-log-likelihood) contains calculated log from the score likelihood. 

(ref:bayes-height-grid-log-likelihood-caption) **Likelihoods and log likelihoods of observing scores given $\mu$ and $\sigma$ equal to 175cm and 9cm**

\begin{table}

\caption{(\#tab:bayes-height-grid-log-likelihood)(ref:bayes-height-grid-log-likelihood-caption)}
\centering
\begin{tabular}[t]{rrrrr}
\toprule
mu & sigma & x & likelihood & LL\\
\midrule
175 & 9 & 167 & 0.03 & -3.51\\
175 & 9 & 192 & 0.01 & -4.90\\
175 & 9 & 183 & 0.03 & -3.51\\
175 & 9 & 175 & 0.04 & -3.12\\
175 & 9 & 177 & 0.04 & -3.14\\
\bottomrule
\end{tabular}
\end{table}

Rather than taking a product of the LL to calculate the overall likelihood of the sample, we take the sum. This is due the properties of the logarithmic algebra, where $\log{x_1\times x_2} = log{x_1} + log{x_2}$, which means that if we take the exponent of the sum of the log likelihoods, we will get the same result as taking the exponent of the product of likelihoods. Thus the overall log likelihood of observing the sample is equal to -18.18. If we take the exponent of this, we will get the same results as the product of individual likelihoods, which is equal to \ensuremath{1.272648\times 10^{-8}}. This *mathematical trick* is needed to prevent very small numbers and thus loosing precision. 

If we repeat the same procedure for every parameter possibility in our grid, we get the following log likelihoods (Table \@ref(tab:bayes-height-grid-log-likelihood-product)). This procedure is also visually represented in the Figure \@ref(fig:data-likelihood) for easier comprehension.

(ref:bayes-height-grid-log-likelihood-product-caption) **Sum of data log likelihoods for parameter possibilities**

\begin{table}

\caption{(\#tab:bayes-height-grid-log-likelihood-product)(ref:bayes-height-grid-log-likelihood-product-caption)}
\centering
\begin{tabular}[t]{rrrrr}
\toprule
mu & sigma & mu prior & sigma prior & LL\\
\midrule
170 & 9 & 0.33 & 0.33 & -20.12\\
175 & 9 & 0.33 & 0.33 & -18.18\\
180 & 9 & 0.33 & 0.33 & -17.78\\
170 & 10 & 0.33 & 0.33 & -19.79\\
175 & 10 & 0.33 & 0.33 & -18.21\\
\addlinespace
180 & 10 & 0.33 & 0.33 & -17.89\\
170 & 11 & 0.33 & 0.33 & -19.63\\
175 & 11 & 0.33 & 0.33 & -18.32\\
180 & 11 & 0.33 & 0.33 & -18.06\\
\bottomrule
\end{tabular}
\end{table}

\begin{figure}[!htb]

{\centering \includegraphics[width=0.9\linewidth]{07-Bayesian-perspective_files/figure-latex/data-likelihood-1} 

}

\caption{(ref:data-likelihood-caption)}(\#fig:data-likelihood)
\end{figure}

(ref:data-likelihood-caption) **Likelihood of data given parameters. **$\mu$ and $\sigma$ represent parameters for which we want to estimate likelihood of observing data collected

## Posterior probability

To get the *posterior* probabilities of parameter possibilities, likelihoods need to be multiplied with priors ($posterior = prior \times likelihood$). This is called *Bayesian updating*. Since we have log likelihoods, we need to sum the log likelihoods with log of priors instead ($\log{posterior} = \log{prior} + \log{likelihood}$). To get the posterior probability, after converting log posterior to posterior using exponent ($posterior = e^{\log{posterior}}$)[^mathematical_trick], we need to make sure that probabilities of parameter possibility sum to one. This is done by simply dividing probabilities for each parameter possibility by the sum of probabilities.   

[^mathematical_trick]: There is one more *mathematical trick* done to avoid very small numbers explained in @mcelreathStatisticalRethinkingBayesian2015 and it involves doing the following calculation to get the posterior probabilities: $posterior = e^{\log{posterior} - max(\log{posterior}))}$.

Table \@ref(tab:bayes-height-grid-posterior) contains the results of Bayesian inference. The posterior probabilities are called *joint probabilities* since they represent probability of a combination of particular $\mu$ and $\sigma$ possibility.  

(ref:bayes-height-grid-posterior-caption) **Estimated posterior probabilities for parameter possibilities given the data**

\begin{table}

\caption{(\#tab:bayes-height-grid-posterior)(ref:bayes-height-grid-posterior-caption)}
\centering
\begin{tabular}[t]{rrrrrr}
\toprule
mu & sigma & mu prior & sigma prior & LL & posterior\\
\midrule
170 & 9 & 0.33 & 0.33 & -20.12 & 0.02\\
175 & 9 & 0.33 & 0.33 & -18.18 & 0.14\\
180 & 9 & 0.33 & 0.33 & -17.78 & 0.20\\
170 & 10 & 0.33 & 0.33 & -19.79 & 0.03\\
175 & 10 & 0.33 & 0.33 & -18.21 & 0.13\\
\addlinespace
180 & 10 & 0.33 & 0.33 & -17.89 & 0.18\\
170 & 11 & 0.33 & 0.33 & -19.63 & 0.03\\
175 & 11 & 0.33 & 0.33 & -18.32 & 0.12\\
180 & 11 & 0.33 & 0.33 & -18.06 & 0.15\\
\bottomrule
\end{tabular}
\end{table}

Table \@ref(tab:bayes-height-grid-posterior) can be be converted into 3x3 matrix, with possibilities of $\mu$ in the columns, and possibilities of the $\sigma$ in the rows and posterior joint probabilities in the cells (Table \@ref(tab:bayes-height-grid-posterior-matrix)). The *sums* of the joint probabilities in the Table \@ref(tab:bayes-height-grid-posterior-matrix) margins represent *marginal probabilities* for parameters. 

(ref:bayes-height-grid-posterior-matrix-caption) **Joint distribution of the parameter possibilities. **Sums at the table margins represent marginal probabilities

\begin{table}

\caption{(\#tab:bayes-height-grid-posterior-matrix)(ref:bayes-height-grid-posterior-matrix-caption)}
\centering
\begin{tabular}[t]{lrrrr}
\toprule
  & 170 & 175 & 180 & Sum\\
\midrule
9 & 0.02 & 0.14 & 0.20 & 0.36\\
10 & 0.03 & 0.13 & 0.18 & 0.34\\
11 & 0.03 & 0.12 & 0.15 & 0.30\\
Sum & 0.08 & 0.38 & 0.54 & 1.00\\
\bottomrule
\end{tabular}
\end{table}

Since we have only two parameters, the joint probabilities can be represented with the *heat map*. Figure \@ref(fig:heat-map) is a visual representation of the Table \@ref(tab:bayes-height-grid-posterior-matrix).

\begin{figure}[!htb]

{\centering \includegraphics[width=0.9\linewidth]{07-Bayesian-perspective_files/figure-latex/heat-map-1} 

}

\caption{(ref:heat-map-caption)}(\#fig:heat-map)
\end{figure}

(ref:heat-map-caption) **Heat map of $\mu$ and $\sigma$ joint probabilities**

When we have more than 2 parameters, visualization of joint probabilities get's tricky and we rely on visualizing marginal posterior probabilities of each parameter instead. As explained, marginal probabilities are calculated by summing all joint probabilities for a particular parameter possibility (see Table \@ref(tab:bayes-height-grid-posterior-matrix)). Figure \@ref(fig:(marginal-prior-posterior) depicts marginal probabilities (including prior probabilities) for $\mu$ and $\sigma$.

\begin{figure}[!htb]

{\centering \includegraphics[width=0.9\linewidth]{07-Bayesian-perspective_files/figure-latex/marginal-prior-posterior-1} 

}

\caption{(ref:marginal-prior-posterior-caption)}(\#fig:marginal-prior-posterior)
\end{figure}

(ref:marginal-prior-posterior-caption) **Prior and posterior distributions resulting from simplified grid-approximation example**

As can be seen from the Figures \@ref(fig:heat-map) and \@ref(fig:marginal-prior-posterior), the most likely parameter possibilities, given the data, are $\mu$ of 180cm and $\sigma$ of 9cm. 

## Adding more possibilities

So far, we have made this very granular in order to be understood. However, since we are dealing with continuous parameters, performing grid approximation for more than 9 total parameter possibilities seems warranted. The calculus is exactly the same, as well as the sample collected, but now we will use the larger range for both $\mu$ (160-200cm) and $\sigma$ (1-30cm), each with 100 possibilities. We are estimating credibility for total of $100 \times 100 = 10,000$ parameter possibilities. Figure \@ref(fig:heat-map-100-100) depicts heat map for the joint probabilities, and Figure \@ref(fig:marginal-100-100) depicts prior and posterior marginal distributions for each parameter. 

\begin{figure}[!htb]

{\centering \includegraphics[width=0.9\linewidth]{07-Bayesian-perspective_files/figure-latex/heat-map-100-100-1} 

}

\caption{(ref:heat-map-100-100-caption)}(\#fig:heat-map-100-100)
\end{figure}

(ref:heat-map-100-100-caption) **Heat map of $\mu$ and $\sigma$ joint probabilities when $100\times 100$ grid-approximation is used**

\begin{figure}[!htb]

{\centering \includegraphics[width=0.9\linewidth]{07-Bayesian-perspective_files/figure-latex/marginal-100-100-1} 

}

\caption{(ref:marginal-100-100-caption)}(\#fig:marginal-100-100)
\end{figure}

(ref:marginal-100-100-caption) **Prior and posterior distributions resulting from $100\times 100$ grid-approximation example**

Grid approximation utilized here is great for educational purposes and very simple models, but as number of parameters increases, the number of total parameter possibility grow so large, that it might take millions of years for a single computer to compute the posterior distributions. For example, if we have linear regression model with two predictors, we will have 4 parameters to estimate (intercept $\beta_{0}$, predictor one $\beta_{1}$, predictor two $\beta_{2}$, and residual standard error $\sigma$), and if we use 100 possibilities for each parameter, we will get 10^8 total number of possibilities. 

This was the reason why Bayesian inference was not very practical. Until algorithms such as *Markov Chain Monte Carlo* (MCMC) emerged making Bayesian inference a walk in the park. Statistical Rethinking book by Richard McElreath is outstanding introduction into these topics. 

## Different prior

In this example we have used vague priors for both $\mu$ and $\sigma$. But let's see what happens when I strongly believe (before seeing the data), that $\mu$ is around 190cm (using normal distribution with mean 190 and SD of 2 to represent this prior), but I do not have a clue about $\sigma$ prior distribution and I choose to continue using uniform prior for this parameter. 

This prior belief is, of course, wrong, but maybe I am biased since I originate, let's say from Montenegro, country with one of the tallest men. Figure \@ref(fig:strong-prior) contains plotted prior and posterior distributions. As can be seen, using very strong prior for $\mu$ shifted the posterior distribution to the higher heights. In other words, the data collected were not enough to *overcome* my prior belief about average height.

\begin{figure}[!htb]

{\centering \includegraphics[width=0.9\linewidth]{07-Bayesian-perspective_files/figure-latex/strong-prior-1} 

}

\caption{(ref:strong-prior-caption)}(\#fig:strong-prior)
\end{figure}

(ref:strong-prior-caption) **Effects of very strong prior on posterior**

## More data

The sample height data we have collected for N=5 individuals (167, 192, 183, 175, 177cm) was not strong to overcome prior belief. However, what if we sampled N=100 males from known population of known mean height of 177.8 and SD of 10.16? Figure \@ref(fig:more-data) depicts prior and posterior distributions in this example. As can be seen, besides having narrower posterior distributions for $\mu$ and $\sigma$, more data was able to overcome my strong prior bias towards mean height of 190cm. 

\begin{figure}[!htb]

{\centering \includegraphics[width=0.9\linewidth]{07-Bayesian-perspective_files/figure-latex/more-data-1} 

}

\caption{(ref:more-data-caption)}(\#fig:more-data)
\end{figure}

(ref:more-data-caption) **When larger sample is taken (N=100) as opposed to smaller sample (N=20), strong prior was not able to influence the posterior distribution**

## Summarizing prior and posterior distributions with MAP and HDI

In Bayesian statistics, the prior and posterior distributions are usually summarized using *highest maximum a posteriori* (MAP) and 90% or 95% *highest density interval* (HDI) [@kruschkeBayesianDataAnalysis2018; @kruschkeBayesianNewStatistics2018; @mcelreathStatisticalRethinkingBayesian2015]. MAP is simply a `mode`, or the most probable point estimate. In other words, a point in the distribution with the highest probability. With normal distribution, MAP, `mean` and `median` are identical. The problems arise with distributions that are not symmetrical. 

HDI is similar to frequentist CI, but represents an interval which contains all points within the interval that have higher probability density than points outside the interval [@makowskiBayestestRDescribingEffects2019; @makowskiUnderstandDescribeBayesian2019]. HDI is more computationally expensive to estimate, but compared to *equal-tailed interval* (ETI) or *percentile interval*, that typically excludes 2.5% or 5% from each tail of the distribution (for 95% or 90% confidence respectively), HDI is not equal-tailed and therefore always includes the mode(s) of posterior distributions [@makowskiBayestestRDescribingEffects2019; @makowskiUnderstandDescribeBayesian2019]. 

Figure \@ref(fig:map-hdi) depicts comparison between MAP and 90% HDI, `median` and 90% percentile interval or ETI, and `mean` and $\pm1.64 \times SD$ for 90% confidence interval. As can be seen from the Figure \@ref(fig:map-hdi), the distribution summaries differ since the distribution is asymmetrical and not-normal. Thus, in order to summarize prior or posterior distribution, MAP and HDI are most often used, apart from visual representation.

\begin{figure}[!htb]

{\centering \includegraphics[width=0.9\linewidth]{07-Bayesian-perspective_files/figure-latex/map-hdi-1} 

}

\caption{(ref:map-hdi-caption)}(\#fig:map-hdi)
\end{figure}
(ref:map-hdi-caption) **Summarizing prior and posterior distribution. A. **MAP and $90\%$ HDI. **B.** Median and $90\%$ ETI. **C.** Mean and $\pm1.64\times SD$

Using SESOI as a trivial range, or as a ROPE [@kruschkeBayesianDataAnalysis2018; @kruschkeBayesianNewStatistics2018], Bayesian equivalence test can be performed by quantifying proportion of posterior distribution inside the SESOI band [@kruschkeBayesianDataAnalysis2018; @kruschkeBayesianNewStatistics2018; @makowskiBayestestRDescribingEffects2019; @makowskiIndicesEffectExistence]. [Magnitude Based Inference] discussed in the the previous chapter, would also be valid way of describing the posterior distribution. 

Besides estimating using MAP and HDI, Bayesian analysis also allows hypothesis testing using *Bayes factor* or *MAP based p-value* [@kruschkeBayesianDataAnalysis2018; @kruschkeBayesianNewStatistics2018; @makowskiBayestestRDescribingEffects2019; @makowskiIndicesEffectExistence]. Discussing these concepts is out of the range of this book and interested readers can refer to references provided for more information.

## Comparison to NHST Type I errors

How do the Bayesian HDIs compare to frequentist CIs? What are the Type I error rates when the data is sampled from the null-hypothesis? To explore this question, I will repeat the simulation from [New Statistics: Confidence Intervals and Estimation] section, where 1,000 samples of N=20 observations are sampled from a population where the true mean height is equal to 177.8cm and SD is equal to 10.16cm. Type I error is committed when the the 95% CIs or 95% HDI intervals of the sample mean don't cross the true value in the population. Table \@ref(tab:bayes-type-i-error) contains Type I errors for frequentist and Bayesian estimation. 

(ref:bayes-type-i-error-caption) **Frequentist vs. Bayesian Type I errors**

\begin{table}

\caption{(\#tab:bayes-type-i-error)(ref:bayes-type-i-error-caption)}
\centering
\begin{tabular}[t]{lrrr}
\toprule
method & Sample & Correct \% & Type I Errors \%\\
\midrule
Bayesian & 1000 & 96.1 & 3.9\\
Frequentist & 1000 & 95.5 & 4.5\\
\bottomrule
\end{tabular}
\end{table}

As can be seen from the Table \@ref(tab:bayes-type-i-error), frequentist CI and Bayesian HDI Type I error rate are not identical (which could be due to the grid approximation method as well as due to only 1000 samples used). This is often a concern, since Bayesian methods do not control error rates [@kruschkeBayesianDataAnalysis2018]. Although frequentist methods revolve around limiting the probability of Type I errors, error rates are extremely difficult to pin down, particularly for complex models, and because they are based on sampling and testing intentions [@kruschkeBayesianDataAnalysis2018]. For more detailed discussion and comparison of Bayesian and frequentist methods regarding the error control see @kruschkeBayesianEstimationSupersedes2013; @wagenmakersPracticalSolutionPervasive2007; @moreyFallacyPlacingConfidence2016. Papers by Kristin Sainani [@sainaniMagnitudeBasedInference2019; @sainaniProblemMagnitudebasedInference2018] are also worth pondering about which will help in understanding estimation and comparison of Type I and Type II error rates between different inferential methods, particularly when magnitude-based inference using SESOI is considered.  

