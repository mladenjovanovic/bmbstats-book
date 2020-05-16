# (PART) Part One {-}
# Introduction {#introduction}

The *real* world is very complex and uncertain. In order to help in understanding it and to predict its behavior, we create maps and models [@pageModelThinkerWhat2018; @weinbergSuperThinkingBig2019]. One such tool are statistical models, representing a simplification of the complex and ultimately uncertain *reality*, in the hope of describing it, understanding it, predicting its behavior, and help in making decisions and interventions [@hernanSecondChanceGet2019; @langGettingNullStatistical2017; @mcelreathStatisticalRethinkingBayesian2015; @pearlBookWhyNew2018]. In the outstanding statistics book "Statistical Rethinking" [@mcelreathStatisticalRethinkingBayesian2015, pp. 19], the author stresses the distinction between *Large World* and *Small World*, described initially by Leonard Savage [@binmoreRationalDecisions2011; @gigerenzerHeuristicsFoundationsAdaptive2015; @savageFoundationsStatistics1972]:

>"All statistical modeling has these same two frames: the small world of the model itself and the large world we hope to deploy the model in. Navigating between these two worlds remains a central challenge of statistical modeling. The challenge is aggravated by forgetting the distinction. 

>The small world is the self-contained logical world of the model. Within the small world, all possibilities are nominated. There are no pure surprises, like the existence of a huge continent between Europe and Asia. Within the small world of the model, it is important to be able to verify the model's logic, making sure that it performs as expected under favorable assumptions. Bayesian models have some advantages in this regard, as they have reasonable claims to optimality: No alternative model could make better use of the information in the data and support better decisions, assuming the small world is an accurate description of the real world.

>The large world is the broader context in which one deploys a model. In the large world, there may be events that were not imagined in the small world. Moreover, the model is always an incomplete representation of the large world, and so will make mistakes, even if all kinds of events have been properly nominated. The logical consistency of a model in the small world is no guarantee that it will be optimal in the large world. But it is certainly a warm comfort."

Creating "Small Worlds" relies heavily on making and accepting numerous assumptions, both known and unknown, as well as *prior* expert knowledge, which is ultimately incomplete and fallible. Because all statistical models require subjective choices [@gelmanSubjectiveObjectiveStatistics2017], there is no *objective* approach to make "Large World" inferences. It means that it must be us who make the inference, and claims about the "Large World" will always be uncertain. Additionally, we should treat statistical models and statistical results as being much more incomplete and uncertain than the current norm [@amrheinInferentialStatisticsDescriptive2019]. 

We must accept the *pluralism* of statistical models and models in general [@mitchellUnsimpleTruthsScience2012; @mitchellIntegrativePluralism2002], move beyond subjective-objective dichotomy by replacing it with virtues such as *transparency*, *consensus*, *impartiality*, *correspondence to observable reality*, *awareness of multiple perspectives*, *awareness of context-dependence*, and *investigation of stability* [@gelmanSubjectiveObjectiveStatistics2017]. Finally, we need to accept that we must act based on *cumulative knowledge* rather than solely rely on single studies or even single lines of research [@amrheinInferentialStatisticsDescriptive2019]. 

This discussion is the topic of epistemology, scientific inference, and philosophy of science, thus far beyond the scope of the present book (and the author). Nonetheless, it was essential to convey that statistical modeling is a process of creating the "Small Worlds" and deploying it in the "Large World". There are three main classes of tasks that the statistical model is hoping to achieve: *description*, *prediction*, and *causal inference* [@hernanSecondChanceGet2019]. 

The following example will help in differentiating between these three classes of tasks. Consider a king who is facing a drought who must decide whether to invest resources in rain dances. The queen, upon seeing some rain clouds in the sky, must decide on whether to carry her umbrella or not. Young prince, who likes to gamble during his hunting sessions, is interested in knowing what region of his father's vast Kingdom receives the most rain. All three would benefit from an empirical study of rain, but they have different requirements of the statistical model. The king requires *causality*: Do rain dances cause rain? The queen requires *prediction*: Does it look likely enough to rain for me to ask my servants to get my umbrella? The prince requires simple quantitative summary *description*: have I put my bets on the correct region? 

The following sections will provide an overview of the three classes of tasks in the statistical modeling. Data can be classified as being on one of four scales: *nominal*, *ordinal*, *interval* or *ratio* and description, prediction and causal techniques differ depending on the scales utilized. For the sake of simplicity and big picture overview, only examples using ratio scale are to be considered in this book.  

