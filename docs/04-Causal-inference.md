---
output: html_document
editor_options: 
  chunk_output_type: console
---

# Causal inference

Does playing basketball makes one taller? This is a an example of a causal question. Wrestling with the concept of causality, as a philosophical construct is outside the scope of this book (and the author too), but I will define it using the *counterfactual theory* or *potential outcomes* perspective [@hernanSecondChanceGet2019; @kleinbergWhyGuideFinding2015; @pearlBookWhyNew2018; @angristMasteringMetricsPath2015; @gelmanCausalityStatisticalLearning2011] that define causes in terms of how things would have been different had the cause not occurred, as well as from *causality-as-intervention* perspective [@gelmanCausalityStatisticalLearning2011], which necessitates clearly defined interventions [@hernanCWordScientificEuphemisms2018; @hernanDoesObesityShorten2008; @hernanDoesWaterKill2016]. In other words, would someone be shorter if basketball was never trained?

There are two broad classes of inferential questions that focus on *what if* and *why*: *forward causal inference* ("What might happen if we do *X*?") and *reverse causal inference* ("What causes *Y*? Why?") [@gelmanCausalityStatisticalLearning2011]. Forward causation is more clearly defined problem, where the goal is to quantify the causal effect of treatment. Questions of forward causation are most directly studied using *randomization* [@gelmanCausalityStatisticalLearning2011] and are answered from the above mentioned causality-as-intervention and counterfactual perspectives. Reverse causation is more complex and it is more related to *explaining* the causal chains using the *system-variable* approach.  Article by @gelmanCausalityStatisticalLearning2011 provides great overview of the most common causal perspectives, out of which I will mostly focus on forward causation.    

## Necessary versus sufficient causality

Furthermore, we also need to distinguish between four kinds of causation [@pearlBookWhyNew2018; @kleinbergWhyGuideFinding2015]: *necessary causation*, *sufficient causation* and neither or both. For example, if someone says that A causes B, then:

- If A is *necessary* for B, it means that if A never happened (counterfactual reasoning), then B will never happen. Or, in other words, B can never happen without A. But sufficient causality also means that A can happen without B happening. 
- If A is *sufficient* for B, it means that if you have A, you will *always* have B. In other words, B always follows A. However, sometimes B can happen without A
- If A is *neither sufficient nor necessary* for B, then sometimes when A happens B will happen. B can also happen without A.
- If A is both necessary and sufficient for B, then B will always happen after A, and B will never happen without A. 

Table \@ref(tab:four-causes-table) contains summary of the above necessary and sufficient causality. In all four types of causation, the concept of counterfactual reasoning is invoked. 

(ref:four-causes-table-caption) **Four kinds of causation**

<table>
<caption>(\#tab:four-causes-table)(ref:four-causes-table-caption)</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Cause </th>
   <th style="text-align:left;"> Necessary </th>
   <th style="text-align:left;"> Sufficient </th>
   <th style="text-align:left;"> Neither </th>
   <th style="text-align:left;"> Both </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> A happens </td>
   <td style="text-align:left;"> B might happen </td>
   <td style="text-align:left;"> B always happen </td>
   <td style="text-align:left;"> B might happen </td>
   <td style="text-align:left;"> B always happen </td>
  </tr>
  <tr>
   <td style="text-align:left;"> A doesn't happen </td>
   <td style="text-align:left;"> B never happens </td>
   <td style="text-align:left;"> B might happen </td>
   <td style="text-align:left;"> B might happen </td>
   <td style="text-align:left;"> B never happens </td>
  </tr>
</tbody>
</table>

Although the causal inference is a broad area of research, philosophical discussion and conflicts, there are a few key concepts that need to be introduced to get the big picture and understand the basics behind the aims of causal inference. Let’s start with an example involving the aforementioned question whether playing basketball makes one taller.

## Observational data

In order to answer this question, we have collected height data (expressed in cm) for the total of N=30 athletes, of which N=15 play basketball, and N=15 don’t play basketball (Table \@ref(tab:basketball-data)). Playing basketball can be considered *intervention* or *treatment*, in which causal effect we are interested in. Basketball players are considered *intervention group* or *treatment group* and those without the treatment are considered *comparison group* or *control group*

(ref:basketball-data-caption) **Height in the treatment and control groups**

<table class="table" style="font-size: 10px; margin-left: auto; margin-right: auto;">
<caption style="font-size: initial !important;">(\#tab:basketball-data)(ref:basketball-data-caption)</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Athlete </th>
   <th style="text-align:left;"> Treatment </th>
   <th style="text-align:right;"> Height (cm) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Athlete 27 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 214 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 01 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 214 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 25 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 211 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 19 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 210 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 03 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 207 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 21 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 200 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 23 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 199 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 15 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 198 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 17 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 193 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 07 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 192 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 29 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 192 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 13 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 191 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 05 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 191 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 11 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 184 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 09 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 180 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 02 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 189 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 28 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 183 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 06 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 181 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 14 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 180 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 04 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 179 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 12 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 176 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 18 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 176 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 08 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 173 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 26 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 173 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 24 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 170 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 30 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 168 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 20 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 168 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 16 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 165 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 10 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 165 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 22 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 163 </td>
  </tr>
</tbody>
</table>

Using descriptive estimators introduced in the [Description] section, one can quickly calculate the group `mean` and `SD` as well as their difference (Table \@ref(tab:descriptive-group-analysis)). But does mean difference between basketball and control represent *average causal effect* (ACE)[^ACE_ATE]? No, unfortunately not!

[^ACE_ATE]: Another term used is *average treatment effect* (ATE)

(ref:descriptive-group-analysis-caption) **Descriptive analysis of the groups**

<table>
<caption>(\#tab:descriptive-group-analysis)(ref:descriptive-group-analysis-caption)</caption>
 <thead>
  <tr>
   <th style="text-align:left;">  </th>
   <th style="text-align:right;"> Mean (cm) </th>
   <th style="text-align:right;"> SD (cm) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 198.59 </td>
   <td style="text-align:right;"> 10.86 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 174.04 </td>
   <td style="text-align:right;"> 7.54 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Difference </td>
   <td style="text-align:right;"> 24.55 </td>
   <td style="text-align:right;"> 13.22 </td>
  </tr>
</tbody>
</table>

## Potential outcomes or counterfactuals

To explain why this is the case, we need to imagine *alternate counterfactual reality*. What is needed are two potential outcomes: $Height_{0}$, which represents height of the person if one doesn't train basketball, and $Height_{1}$ which represents height of the person if basketball is being played (Table \@ref(tab:basketball-counterfactuals)). As can be guessed, the Basketball group has known $Height_{1}$, but unknown $Height_{0}$ and *vice versa* for the Control group.

(ref:basketball-counterfactuals-caption) **Counterfactuals of potential outcomes that are unknown**

<table class="table" style="font-size: 10px; margin-left: auto; margin-right: auto;">
<caption style="font-size: initial !important;">(\#tab:basketball-counterfactuals)(ref:basketball-counterfactuals-caption)</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Athlete </th>
   <th style="text-align:left;"> Treatment </th>
   <th style="text-align:right;"> Height_0 (cm) </th>
   <th style="text-align:right;"> Height_1 (cm) </th>
   <th style="text-align:right;"> Height (cm) </th>
   <th style="text-align:left;"> Causal Effect (cm) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Athlete 27 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 214 </td>
   <td style="text-align:right;"> 214 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 01 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 214 </td>
   <td style="text-align:right;"> 214 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 25 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 211 </td>
   <td style="text-align:right;"> 211 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 19 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 210 </td>
   <td style="text-align:right;"> 210 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 03 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 207 </td>
   <td style="text-align:right;"> 207 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 21 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 200 </td>
   <td style="text-align:right;"> 200 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 23 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 199 </td>
   <td style="text-align:right;"> 199 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 15 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 198 </td>
   <td style="text-align:right;"> 198 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 17 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 193 </td>
   <td style="text-align:right;"> 193 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 07 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 192 </td>
   <td style="text-align:right;"> 192 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 29 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 192 </td>
   <td style="text-align:right;"> 192 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 13 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 191 </td>
   <td style="text-align:right;"> 191 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 05 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 191 </td>
   <td style="text-align:right;"> 191 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 11 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 184 </td>
   <td style="text-align:right;"> 184 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 09 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 180 </td>
   <td style="text-align:right;"> 180 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 02 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 189 </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 189 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 28 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 183 </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 183 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 06 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 181 </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 181 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 14 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 180 </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 180 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 04 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 179 </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 179 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 12 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 176 </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 176 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 18 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 176 </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 176 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 08 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 173 </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 173 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 26 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 173 </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 173 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 24 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 170 </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 170 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 30 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 168 </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 168 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 20 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 168 </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 168 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 16 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 165 </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 165 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 10 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 165 </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 165 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 22 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 163 </td>
   <td style="text-align:right;"> ??? </td>
   <td style="text-align:right;"> 163 </td>
   <td style="text-align:left;"> ??? </td>
  </tr>
</tbody>
</table>

Unfortunately, these potential outcomes are unknown, and thus individual causal effects are unknown as well. We just do not know what might have happened to individual outcomes in counterfactual world (i.e. alternate reality). A good control group serves as a *proxy* to reveal what might have happened *on average* to the treated group in the counterfactual world where they are not treated. Since the basketball data is simulated, the exact DGP is known (the *true* systematic or main causal effect of playing basketball on height is exactly zero), which again demonstrates the use of simulations as a great learning tool, in this case understanding the underlying causal mechanisms (Table \@ref(tab:table-counterfactuals-simulated)). Individual causal effect in this case is the difference between two potential outcomes: $Height_{1}$ and $Height_{0}$. 

(ref:table-counterfactuals-simulated-caption) **Simulated causal effects and known counterfactuals**

<table class="table" style="font-size: 10px; margin-left: auto; margin-right: auto;">
<caption style="font-size: initial !important;">(\#tab:table-counterfactuals-simulated)(ref:table-counterfactuals-simulated-caption)</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Athlete </th>
   <th style="text-align:left;"> Treatment </th>
   <th style="text-align:right;"> Height_0 (cm) </th>
   <th style="text-align:right;"> Height_1 (cm) </th>
   <th style="text-align:right;"> Height (cm) </th>
   <th style="text-align:right;"> Causal Effect (cm) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Athlete 27 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 214 </td>
   <td style="text-align:right;"> 214 </td>
   <td style="text-align:right;"> 214 </td>
   <td style="text-align:right;"> 0.12 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 01 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 214 </td>
   <td style="text-align:right;"> 214 </td>
   <td style="text-align:right;"> 214 </td>
   <td style="text-align:right;"> 0.00 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 25 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 212 </td>
   <td style="text-align:right;"> 211 </td>
   <td style="text-align:right;"> 211 </td>
   <td style="text-align:right;"> -1.10 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 19 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 210 </td>
   <td style="text-align:right;"> 210 </td>
   <td style="text-align:right;"> 210 </td>
   <td style="text-align:right;"> 0.90 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 03 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 208 </td>
   <td style="text-align:right;"> 207 </td>
   <td style="text-align:right;"> 207 </td>
   <td style="text-align:right;"> -0.07 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 21 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 200 </td>
   <td style="text-align:right;"> 200 </td>
   <td style="text-align:right;"> 200 </td>
   <td style="text-align:right;"> 0.20 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 23 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 198 </td>
   <td style="text-align:right;"> 199 </td>
   <td style="text-align:right;"> 199 </td>
   <td style="text-align:right;"> 0.57 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 15 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 198 </td>
   <td style="text-align:right;"> 198 </td>
   <td style="text-align:right;"> 198 </td>
   <td style="text-align:right;"> 0.18 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 17 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 193 </td>
   <td style="text-align:right;"> 193 </td>
   <td style="text-align:right;"> 193 </td>
   <td style="text-align:right;"> 0.44 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 07 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 193 </td>
   <td style="text-align:right;"> 192 </td>
   <td style="text-align:right;"> 192 </td>
   <td style="text-align:right;"> -0.09 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 29 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 193 </td>
   <td style="text-align:right;"> 192 </td>
   <td style="text-align:right;"> 192 </td>
   <td style="text-align:right;"> -0.40 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 13 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 192 </td>
   <td style="text-align:right;"> 191 </td>
   <td style="text-align:right;"> 191 </td>
   <td style="text-align:right;"> -0.36 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 05 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 191 </td>
   <td style="text-align:right;"> 191 </td>
   <td style="text-align:right;"> 191 </td>
   <td style="text-align:right;"> -0.15 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 11 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 183 </td>
   <td style="text-align:right;"> 184 </td>
   <td style="text-align:right;"> 184 </td>
   <td style="text-align:right;"> 0.46 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 09 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 179 </td>
   <td style="text-align:right;"> 180 </td>
   <td style="text-align:right;"> 180 </td>
   <td style="text-align:right;"> 0.72 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 02 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 189 </td>
   <td style="text-align:right;"> 189 </td>
   <td style="text-align:right;"> 189 </td>
   <td style="text-align:right;"> 0.06 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 28 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 183 </td>
   <td style="text-align:right;"> 184 </td>
   <td style="text-align:right;"> 183 </td>
   <td style="text-align:right;"> 0.41 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 06 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 181 </td>
   <td style="text-align:right;"> 181 </td>
   <td style="text-align:right;"> 181 </td>
   <td style="text-align:right;"> 0.42 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 14 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 180 </td>
   <td style="text-align:right;"> 180 </td>
   <td style="text-align:right;"> 180 </td>
   <td style="text-align:right;"> -0.66 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 04 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 179 </td>
   <td style="text-align:right;"> 179 </td>
   <td style="text-align:right;"> 179 </td>
   <td style="text-align:right;"> 0.10 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 12 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 176 </td>
   <td style="text-align:right;"> 176 </td>
   <td style="text-align:right;"> 176 </td>
   <td style="text-align:right;"> -0.39 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 18 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 176 </td>
   <td style="text-align:right;"> 175 </td>
   <td style="text-align:right;"> 176 </td>
   <td style="text-align:right;"> -0.31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 08 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 173 </td>
   <td style="text-align:right;"> 173 </td>
   <td style="text-align:right;"> 173 </td>
   <td style="text-align:right;"> -0.55 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 26 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 173 </td>
   <td style="text-align:right;"> 174 </td>
   <td style="text-align:right;"> 173 </td>
   <td style="text-align:right;"> 0.77 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 24 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 170 </td>
   <td style="text-align:right;"> 170 </td>
   <td style="text-align:right;"> 170 </td>
   <td style="text-align:right;"> 0.02 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 30 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 168 </td>
   <td style="text-align:right;"> 168 </td>
   <td style="text-align:right;"> 168 </td>
   <td style="text-align:right;"> 0.27 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 20 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 168 </td>
   <td style="text-align:right;"> 168 </td>
   <td style="text-align:right;"> 168 </td>
   <td style="text-align:right;"> -0.03 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 16 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 165 </td>
   <td style="text-align:right;"> 165 </td>
   <td style="text-align:right;"> 165 </td>
   <td style="text-align:right;"> -0.01 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 10 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 165 </td>
   <td style="text-align:right;"> 164 </td>
   <td style="text-align:right;"> 165 </td>
   <td style="text-align:right;"> -0.81 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 22 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 163 </td>
   <td style="text-align:right;"> 163 </td>
   <td style="text-align:right;"> 163 </td>
   <td style="text-align:right;"> 0.00 </td>
  </tr>
</tbody>
</table>

From Table \@ref(tab:table-counterfactuals-simulated), we can state that the mean difference between the groups consists of two components: *average causal effect* and the *selection bias* [@angristMasteringMetricsPath2015] (Equation \@ref(eq:mean-causal-effect)).

$$
\begin{equation}
  \begin{split}
    mean_{difference} &= Average \; causal\; effect + Selection\; bias \\
    Average \; causal\; effect &= \frac{1}{N_{Basketball}}\Sigma_{i=1}^{n}(Height_{1i} - Height_{0i}) \\
    Selection\; bias &= \frac{1}{N_{Basketball}}\Sigma_{i=1}^{n}Height_{0i} - \frac{1}{N_{Control}}\Sigma_{i=1}^{n}Height_{0i}
  \end{split}
  (\#eq:mean-causal-effect)
\end{equation}
$$



The mean group difference we have observed (24.55cm) is due to average causal effect (0.1cm) and selection bias (24.46cm). In other words, observed mean group difference can be explained solely by selection bias. Since we know the DGP behind the basketball data, we know that there is no systematic causal effect of playing basketball on height.  

On top of the selection bias involved in the example above, other *confounders* might be involved, such as age, sex, race, experience and others, some of which can be measured and some might be unknown. These are also referred to as the *third variable* which confounds the causal relationship between treatment and the outcome. In this example, all subjects from the Basketball group might be older males, whereas all the subjects from the Control group might be be younger females, and this can explain the group differences, rather than causal effect of playing basketball. 

## *Ceteris paribus* and the biases

It is important to understand that, in order to have causal interpretation, comparisons need to be made under *ceteris paribus* conditions [@angristMasteringMetricsPath2015], which is Latin for *other things equal*. In the basketball example above, we cannot make causal claim that playing basketball makes one taller, since comparison between the groups is not done in the *ceteris paribus* conditions due to the selection bias involved. We also know this since we know the DGP behind the observed data. 

Causal inference thus aims to achieve *ceteris paribus* conditions needed to make causal interpretations by careful considerations of the known and unknown biases involved [@angristMasteringMetricsPath2015; @hernanCausalDiagramsDraw2017; @hernanCausalInference2019; @hernanDoesWaterKill2016; @hernanSecondChanceGet2019; @ledererControlConfoundingReporting2019; @rohrerThinkingClearlyCorrelations2018; @shrierReducingBiasDirected2008].

According to Hernan *et al.* [@hernanCausalDiagramsDraw2017; @hernanCausalInference2019], there are three types of biases involved in causal inference: *confounding*, *selection bias* and *measurement bias*. 

Confounding is the bias that arises when treatment and outcome share causes. This is because treatment was not randomly assigned [@hernanCausalDiagramsDraw2017; @hernanCausalInference2019]. For example, athletes that are naturally taller might be choosing to play basketball due to success and enjoyment over their shorter peers. On the other hand, it might be some hidden confounder that motivates *to-be-tall* athletes to choose basketball. Known and measured confounders from the observational studies can be taken into account to create *ceteris paribus* conditions when estimating causal effects [@angristMasteringMetricsPath2015; @hernanCausalDiagramsDraw2017; @hernanCausalInference2019; @ledererControlConfoundingReporting2019; @rohrerThinkingClearlyCorrelations2018; @shrierReducingBiasDirected2008]. 

### Randomization

The first line of defence against confounding and selection bias is to randomly assign athletes to treatment, otherwise known as *randomized trial* or *randomized experiment*. Random assignment makes comparison between groups *ceteris paribus* providing the sample is large enough to ensure that differences in the individual characteristics such as age, sex, experience and other potential confounders are *washed out* [@angristMasteringMetricsPath2015]. In other words, random assignment works not by eliminating individual differences but rather by ensuring that the mix of the individuals being compared is the same, including the ways we cannot easily measure or observe [@angristMasteringMetricsPath2015]. 

In case the individuals from the basketball example were randomly assigned, given the known causal DGP, then the mean difference between the groups would be more indicative of the causal effect of playing basketball on height (Table \@ref(tab:randomized-basketball-data)). 

(ref:randomized-basketball-data-caption) **Randomized participants**

<table class="table" style="font-size: 10px; margin-left: auto; margin-right: auto;">
<caption style="font-size: initial !important;">(\#tab:randomized-basketball-data)(ref:randomized-basketball-data-caption)</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Athlete </th>
   <th style="text-align:left;"> Treatment </th>
   <th style="text-align:right;"> Height (cm) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Athlete 01 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 214 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 25 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 211 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 19 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 210 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 03 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 207 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 23 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 199 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 15 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 198 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 13 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 191 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 02 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 189 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 28 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 184 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 14 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 180 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 04 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 179 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 12 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 176 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 26 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 174 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 24 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 170 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 16 </td>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 165 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 27 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 214 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 21 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 200 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 29 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 193 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 07 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 193 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 17 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 193 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 05 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 191 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 11 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 183 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 06 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 181 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 09 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 179 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 18 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 176 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 08 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 173 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 30 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 168 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 20 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 168 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 10 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 165 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 22 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 163 </td>
  </tr>
</tbody>
</table>

If we calculate the mean differences in this randomly assigned basketball treatment (Table \@ref(tab:basketball-randomized-summary)), we can quickly notice that random assignment washed out selection bias involved with the observational study, and that the mean difference is closer to the known systematic (or average or *expected*) causal effect. The difference between estimated systematic causal effect using mean group difference from the randomized trial and the true causal effect is due to the *sampling error* which will be explained in the [Statistical inference] section. 

(ref:basketball-randomized-summary-caption) **Descriptive summary of randomized participants**

<table>
<caption>(\#tab:basketball-randomized-summary)(ref:basketball-randomized-summary-caption)</caption>
 <thead>
  <tr>
   <th style="text-align:left;">  </th>
   <th style="text-align:right;"> Mean (cm) </th>
   <th style="text-align:right;"> SD (cm) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Basketball </td>
   <td style="text-align:right;"> 189.91 </td>
   <td style="text-align:right;"> 16.15 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 182.65 </td>
   <td style="text-align:right;"> 14.44 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Difference </td>
   <td style="text-align:right;"> 7.25 </td>
   <td style="text-align:right;"> 21.66 </td>
  </tr>
</tbody>
</table>

Apart from creating *ceteris paribus* conditions, randomization generates a good control group that serves as a *proxy* to reveal what might have happened to the treated group in the counterfactual world where they are not treated, since $Height_0$ is not known for the basketball group. Creating those conditions with randomized trial demands careful considerations and *balance checking* since biases can *crawl* inside the causal interpretation. The logic of randomized trial is simple, yet the logistics can be quite complex. For example, a sample of sufficient size might not be practically feasible, and imbalances in the known confounders can be still found in the groups, thus demanding further control and adjustment in the analysis (e.g. using ANCOVA instead of ANOVA, adjusting for confounders in the linear regression by introducing them as interactions) in order to create *ceteris paribus* conditions needed to evaluate causal claims. Belief effect can sneak in, for example, if the treatment group *knows* they are being treated, or if researchers motivate treatment groups harder, since they expect and hope for better outcomes.  For this reason, *blinding* both the subjects and researches can be considered, as well as providing *placebo* treatment to the Control group. In sport science research blinding and providing placebo can be problematic. For example, if our intervention is a novel training method or a technology, both researchers and subjects will expect better outcomes which can bias causal interpretations. 

## Subject matter knowledge

One of the main problems with randomized trials is that it cannot be done in most real life settings, either due to the ethical or practical reasons. For example, if studying effects of smoking on baby mortality and birth defects, which parent would accept being in the treatment group. Or if studying effects of resistance training on injury risk in football players, which professional organization would allow random assignment to the treatment that is lesser than the known best practices and can predispose athletes to the injuries or sub-par preparation?

For this reason, reliance on observation studies is the best we can do. However, in order to create *ceteris paribus* conditions necessary to minimize bias in the causal interpretations, expert subject-matter knowledge is needed, not only to describe the causal structure of the system under study, but also to specify the causal questions and identify relevant data sources [@hernanSecondChanceGet2019]. Imagine asking the following causal question: "Does training load lead to overuse injuries in professional sports". It takes expert subject matter knowledge to specify the treatment construct (i.e. "training load"), to figure out how should be measured, as well as to quantify the measurement error which can induce *measurement bias*, to state over which time period the treatment is done, as well as to specify the outcome construct (i.e. "overuse-injuries"), and to define the variables and constructs that confound and define the causal network underlying such a question. This subject matter is fallible of course, and the constructs, variables and the causal network can be represented with pluralistic models that represents "Small World" maps of the complex "Large World", in which we are hoping to deploy the findings (please refer to the [Introduction] for more information about this concept). Drawing assumptions that underly causal structure using *direct acyclical graphs* (DAGs) [@hernanCausalDiagramsDraw2017; @hernanCausalInference2019; @pearlBookWhyNew2018; @rohrerThinkingClearlyCorrelations2018; @saddikiPrimerCausalityData2018; @shrierReducingBiasDirected2008; @textorRobustCausalInference2017] represents a step forward in acknowledging the issues above, by providing transparency of the assumptions involved and bridging the subjective - objective dichotomy.

## Example of randomized control trial

Let's consider the following example. We are interested in estimating causal effect of the plyometric training on the vertical jump height. To estimate causal effect, *randomized control trial* (RCT) is utilized. RCT utilizes two groups: Treatment (N=15) and Control (N=15), measured two times: Pre-test and Post-test. Treatment group received plyometric training over the course of three months, while Control group continued with *normal* training. The results of RCT study can be found in the Table \@ref(tab:rct-vj-data). To estimate practical significance of the treatment effect, SESOI of ±2.5cm is selected to indicate minimal change of the practical value. It is important to have "well defined interventions" [@hernanCWordScientificEuphemisms2018; @hernanDoesObesityShorten2008; @hernanDoesWaterKill2016], thus the question that should be answered is as follows: "Does plyometric training added to normal training improves vertical jump height over period of three months?"

(ref:rct-vj-data-caption) **Randomized control trial data**

<table class="table" style="font-size: 10px; margin-left: auto; margin-right: auto;">
<caption style="font-size: initial !important;">(\#tab:rct-vj-data)(ref:rct-vj-data-caption)</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Athlete </th>
   <th style="text-align:left;"> Group </th>
   <th style="text-align:right;"> Pre-test (cm) </th>
   <th style="text-align:right;"> Post-test (cm) </th>
   <th style="text-align:right;"> Change (cm) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Athlete 19 </td>
   <td style="text-align:left;"> Treatment </td>
   <td style="text-align:right;"> 45.86 </td>
   <td style="text-align:right;"> 60.74 </td>
   <td style="text-align:right;"> 14.88 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 27 </td>
   <td style="text-align:left;"> Treatment </td>
   <td style="text-align:right;"> 44.67 </td>
   <td style="text-align:right;"> 59.04 </td>
   <td style="text-align:right;"> 14.37 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 01 </td>
   <td style="text-align:left;"> Treatment </td>
   <td style="text-align:right;"> 37.98 </td>
   <td style="text-align:right;"> 52.27 </td>
   <td style="text-align:right;"> 14.29 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 03 </td>
   <td style="text-align:left;"> Treatment </td>
   <td style="text-align:right;"> 41.36 </td>
   <td style="text-align:right;"> 52.70 </td>
   <td style="text-align:right;"> 11.35 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 25 </td>
   <td style="text-align:left;"> Treatment </td>
   <td style="text-align:right;"> 39.99 </td>
   <td style="text-align:right;"> 50.09 </td>
   <td style="text-align:right;"> 10.09 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 23 </td>
   <td style="text-align:left;"> Treatment </td>
   <td style="text-align:right;"> 47.84 </td>
   <td style="text-align:right;"> 57.35 </td>
   <td style="text-align:right;"> 9.51 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 21 </td>
   <td style="text-align:left;"> Treatment </td>
   <td style="text-align:right;"> 36.94 </td>
   <td style="text-align:right;"> 46.20 </td>
   <td style="text-align:right;"> 9.26 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 15 </td>
   <td style="text-align:left;"> Treatment </td>
   <td style="text-align:right;"> 46.51 </td>
   <td style="text-align:right;"> 54.85 </td>
   <td style="text-align:right;"> 8.33 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 17 </td>
   <td style="text-align:left;"> Treatment </td>
   <td style="text-align:right;"> 44.37 </td>
   <td style="text-align:right;"> 51.33 </td>
   <td style="text-align:right;"> 6.96 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 07 </td>
   <td style="text-align:left;"> Treatment </td>
   <td style="text-align:right;"> 41.12 </td>
   <td style="text-align:right;"> 46.59 </td>
   <td style="text-align:right;"> 5.47 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 05 </td>
   <td style="text-align:left;"> Treatment </td>
   <td style="text-align:right;"> 38.07 </td>
   <td style="text-align:right;"> 42.84 </td>
   <td style="text-align:right;"> 4.77 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 29 </td>
   <td style="text-align:left;"> Treatment </td>
   <td style="text-align:right;"> 43.17 </td>
   <td style="text-align:right;"> 47.74 </td>
   <td style="text-align:right;"> 4.58 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 13 </td>
   <td style="text-align:left;"> Treatment </td>
   <td style="text-align:right;"> 50.02 </td>
   <td style="text-align:right;"> 54.07 </td>
   <td style="text-align:right;"> 4.05 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 11 </td>
   <td style="text-align:left;"> Treatment </td>
   <td style="text-align:right;"> 44.80 </td>
   <td style="text-align:right;"> 48.27 </td>
   <td style="text-align:right;"> 3.47 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 09 </td>
   <td style="text-align:left;"> Treatment </td>
   <td style="text-align:right;"> 46.89 </td>
   <td style="text-align:right;"> 49.38 </td>
   <td style="text-align:right;"> 2.49 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 18 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 42.88 </td>
   <td style="text-align:right;"> 43.55 </td>
   <td style="text-align:right;"> 0.67 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 02 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 49.57 </td>
   <td style="text-align:right;"> 50.11 </td>
   <td style="text-align:right;"> 0.54 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 12 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 42.95 </td>
   <td style="text-align:right;"> 43.47 </td>
   <td style="text-align:right;"> 0.52 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 28 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 46.65 </td>
   <td style="text-align:right;"> 46.90 </td>
   <td style="text-align:right;"> 0.25 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 08 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 41.66 </td>
   <td style="text-align:right;"> 41.64 </td>
   <td style="text-align:right;"> -0.01 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 22 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 36.52 </td>
   <td style="text-align:right;"> 36.20 </td>
   <td style="text-align:right;"> -0.32 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 04 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 44.42 </td>
   <td style="text-align:right;"> 43.33 </td>
   <td style="text-align:right;"> -1.09 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 16 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 37.64 </td>
   <td style="text-align:right;"> 36.44 </td>
   <td style="text-align:right;"> -1.20 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 10 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 37.58 </td>
   <td style="text-align:right;"> 36.35 </td>
   <td style="text-align:right;"> -1.23 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 20 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 38.98 </td>
   <td style="text-align:right;"> 37.31 </td>
   <td style="text-align:right;"> -1.67 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 30 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 39.07 </td>
   <td style="text-align:right;"> 37.31 </td>
   <td style="text-align:right;"> -1.76 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 14 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 45.18 </td>
   <td style="text-align:right;"> 43.35 </td>
   <td style="text-align:right;"> -1.83 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 06 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 45.54 </td>
   <td style="text-align:right;"> 42.84 </td>
   <td style="text-align:right;"> -2.70 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 26 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 41.54 </td>
   <td style="text-align:right;"> 38.69 </td>
   <td style="text-align:right;"> -2.85 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Athlete 24 </td>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:right;"> 40.13 </td>
   <td style="text-align:right;"> 36.82 </td>
   <td style="text-align:right;"> -3.31 </td>
  </tr>
</tbody>
</table>

Descriptive summary statistics for Treatment and Control groups are enlisted in the Table \@ref(tab:rct-summary), and visually depicted in the Figure \@ref(fig:rct-groups). 

(ref:rct-summary-caption) **RCT summary using mean ± SD**

<table>
<caption>(\#tab:rct-summary)(ref:rct-summary-caption)</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Group </th>
   <th style="text-align:left;"> Pre-test (cm) </th>
   <th style="text-align:left;"> Post-test (cm) </th>
   <th style="text-align:left;"> Change (cm) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Treatment </td>
   <td style="text-align:left;"> 43.31 ± 3.93 </td>
   <td style="text-align:left;"> 51.56 ± 5.03 </td>
   <td style="text-align:left;"> 8.26 ± 4.16 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Control </td>
   <td style="text-align:left;"> 42.02 ± 3.77 </td>
   <td style="text-align:left;"> 40.95 ± 4.31 </td>
   <td style="text-align:left;"> -1.07 ± 1.31 </td>
  </tr>
</tbody>
</table>

<div class="figure" style="text-align: center">
<img src="04-Causal-inference_files/figure-html/rct-groups-1.png" alt="(ref:rct-groups-caption)" width="90%" />
<p class="caption">(\#fig:rct-groups)(ref:rct-groups-caption)</p>
</div>

(ref:rct-groups-caption) **Visual analysis of RCT using Treatment and Control groups. A and B. **Raincloud plot of the Pre-test and Post-test scores for Treatment and Control groups. Blue color indicates Control group and orange color indicates Treatment group.  **C and D.** Raincloud plot of the change scores for the Treatment and Control groups. SESOI is indicated with a grey band

Further analysis might involve separate dependent groups analysis for both Treatment and Control (Table \@ref(tab:rct-change)), or in other words, the analysis of the change scores. To estimate `Cohen's d`, `pooled SD` of the Pre-test scores in both Treatment and Control is utilized. (see Equation \@ref(eq:cohen-diff-equation)). 

(ref:rct-change-caption) **Descriptive analysis of the change scores for Treatment and Control groups independently**

<table>
<caption>(\#tab:rct-change)(ref:rct-change-caption)</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Estimator </th>
   <th style="text-align:right;"> Treatment </th>
   <th style="text-align:right;"> Control </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Mean change (cm) </td>
   <td style="text-align:right;"> 8.26 </td>
   <td style="text-align:right;"> -1.07 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SDchange (cm) </td>
   <td style="text-align:right;"> 4.16 </td>
   <td style="text-align:right;"> 1.31 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SDpre-test pooled (cm) </td>
   <td style="text-align:right;"> 3.85 </td>
   <td style="text-align:right;"> 3.85 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Cohen's d </td>
   <td style="text-align:right;"> 2.14 </td>
   <td style="text-align:right;"> -0.28 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SESOI lower (cm) </td>
   <td style="text-align:right;"> -2.50 </td>
   <td style="text-align:right;"> -2.50 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SESOI upper (cm) </td>
   <td style="text-align:right;"> 2.50 </td>
   <td style="text-align:right;"> 2.50 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Change to SESOI </td>
   <td style="text-align:right;"> 1.65 </td>
   <td style="text-align:right;"> -0.21 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SDchange to SESOI </td>
   <td style="text-align:right;"> 0.83 </td>
   <td style="text-align:right;"> 0.26 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> pLower </td>
   <td style="text-align:right;"> 0.00 </td>
   <td style="text-align:right;"> 0.14 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> pEquivalent </td>
   <td style="text-align:right;"> 0.08 </td>
   <td style="text-align:right;"> 0.86 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> pHigher </td>
   <td style="text-align:right;"> 0.92 </td>
   <td style="text-align:right;"> 0.00 </td>
  </tr>
</tbody>
</table>

Figure \@ref(fig:rct-paired-change) depicts same information as Figure \@ref(fig:rct-groups) but organized differently and conveying different comparison.  

<div class="figure" style="text-align: center">
<img src="04-Causal-inference_files/figure-html/rct-paired-change-1.png" alt="(ref:rct-paired-change-caption)" width="90%" />
<p class="caption">(\#fig:rct-paired-change)(ref:rct-paired-change-caption)</p>
</div>
(ref:rct-paired-change-caption) **Visual analysis of RCT using Treatment and Control groups. A and B. **Scatter plot of Pre-test and Post-test scores for Treatment and Control groups. Green line indicates change higher than SESOI upper, grey line indicates change within SESOI band, and red line indicates negative change lower than SESOI lower. **C. ** Distribution of the change scores for Treatment (orange) and Control (blue) groups. Grey rectangle indicates SESOI band.  

But we are not that interested in independent analysis of Treatment and Control groups, but rather on their differences and understanding of the causal effect of the treatment (i.e. understanding and estimating parameters of the underlying DGP). As stated, treatment effect consists of two components: systematic component or main effect (i.e. expected or average causal effect), and stochastic component or random effect (i.e. that varies between individuals) (see Figure \@ref(fig:te-and-nte-diagram)). As already explained, Control group serves as a proxy to what might have happened to the Treatment group in the counterfactual world, and thus allows for casual interpretation of the treatment effect. There are two effects at play with this RCT design: *treatment effect* and *non-treatment effect*. The latter captures all effects not directly controlled by a treatment, but assumes it affects both groups equally (Figure \@ref(fig:te-and-nte-diagram)). For example, if we are treating kids for longer period of time, non-treatment effect might be related to the growth and associated effects. Another non-treatment effect is *measurement error* (discussed in more details in [Measurement Error] section). 

<div class="figure" style="text-align: center">
<img src="figures/treatment-and-non-treatment-effects.png" alt="(ref:te-and-nte-diagram-caption)" width="100%" />
<p class="caption">(\#fig:te-and-nte-diagram)(ref:te-and-nte-diagram-caption)</p>
</div>
(ref:te-and-nte-diagram-caption) **Treatment and Non-treatment effects of intervention.** Both treatment and non-treatment effects consists of two components: systematic and random. Treatment group experiences both treatment and non-treatment effects, while Control group experiences only non-treatment effects. 

The following equation captures the essence of estimating Treatment effects from Pre-test and Post-test scores in the Treatment and Control groups (Equation \@ref(eq:te-and-nte-equation)):

$$
\begin{equation}
  \begin{split}
    Treatment_{post} &= Treatment_{pre} + Treatment \; Effect + NonTreatment \; Effect \\
    Control_{post} &= Control_{pre} + NonTreatment \; Effect \\
\\
    NonTreatment \; Effect &= Control_{post} - Control_{pre} \\
    Treatment \; Effect &= Treatment_{post} - Treatment_{pre} - NonTreatment \; Effect \\
\\
    Treatment \; Effect &= (Treatment_{post} - Treatment_{pre}) - (Control_{post} - Control_{pre}) \\
    Treatment \; Effect &= Treatment_{change} - Control_{change}
  \end{split}
  (\#eq:te-and-nte-equation)
\end{equation}
$$

From the Equation \@ref(eq:te-and-nte-equation), the differences between the changes in Treatment and Control groups can be interpreted as the estimate of the causal effect of the treatment. More precisely, average causal effect or expected causal effect represent systematic treatment effect. This is estimated using difference between `mean` Treatment change and `mean` Control change.

Table \@ref(tab:rct-te-estimates) contains descriptive statistics of the change score differences. Panel C in the Figure \@ref(fig:rct-paired-change) depicts distribution of the change scores and reflect the calculus in the Table \@ref(tab:rct-te-estimates) graphically. 

(ref:rct-te-estimates-caption) **Descriptive statistics of the change score differences**

<table>
<caption>(\#tab:rct-te-estimates)(ref:rct-te-estimates-caption)</caption>
 <thead>
  <tr>
   <th style="text-align:right;"> Mean difference (cm) </th>
   <th style="text-align:right;"> Cohen's d </th>
   <th style="text-align:right;"> Difference to SESOI </th>
   <th style="text-align:right;"> pLower diff </th>
   <th style="text-align:right;"> pEquivalent diff </th>
   <th style="text-align:right;"> pHigher diff </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 9.32 </td>
   <td style="text-align:right;"> 7.14 </td>
   <td style="text-align:right;"> 1.86 </td>
   <td style="text-align:right;"> -0.13 </td>
   <td style="text-align:right;"> -0.78 </td>
   <td style="text-align:right;"> 0.91 </td>
  </tr>
</tbody>
</table>

`Cohen's d` in the Table \@ref(tab:rct-te-estimates) is calculated by using the Equation \@ref(eq:te-nte-cohen) and it estimates standardized difference between change scores in Treatment and the Control groups.

$$
\begin{equation}
Cohen's\;d = \frac{mean_{treatment\; group \; change} - mean_{control\; group \;change}}{SD_{control\; group \; change}}
(\#eq:te-nte-cohen)
\end{equation}
$$

Besides estimating systematic component of the treatment (i.e. the difference between the mean change in Treatment and Control groups), we might be interested in estimating random component and proportions of lower, equivalent and higher effects compared to SESOI (`pLower`, `pEquivalent`, and `pHigher`). Unfortunately, differences in `pLower`, `pEquivalent`, and `pHigher` from Table \@ref(tab:rct-te-estimates) don't answer this question, but rather the expected difference in proportions compared to Control (e.g. the expected improvement of 0.91 in observing proportion of higher change outcomes compared to Control).

Since the changes in Treatment group are due both to the treatment and non-treatment effects (equation 29), the average treatment effect (systematic component) represents the difference between the `mean` changes in Treatment and Control groups (Table \@ref(tab:rct-te-estimates)). In the same manner, the `variance` of the change scores in the Treatment group are due to the random component of the treatment and non-treatment effects. Assuming normal (Gaussian) distribution of the random components, the *SD of the treatment effects* ($SD_{TE}$)[^SD_IR_comment] is estimated using the following Equation \@ref(eq:sd-te-equation).   

$$
\begin{equation}
  \begin{split}
    \epsilon_{treatment \;group \;change} &= \epsilon_{treatment \; effect} + \epsilon_{nontreatment \; effect} \\
    \epsilon_{control \;group \;change} &= \epsilon_{nontreatment \; effect} \\
    \epsilon_{treatment \; effect} &= \epsilon_{treatment \;group \;change} - \epsilon_{control \;group \;change} \\
    \\
    \epsilon_{treatment \; effect}  &\sim \mathcal{N}(0,\,SD_{TE}) \\
    \epsilon_{nontreatment \; effect}  &\sim \mathcal{N}(0,\,SD_{NTE}) \\
    \epsilon_{treatment \;group \;change} &\sim \mathcal{N}(0,\,SD_{treatment \;group \;change}) \\
    \epsilon_{control \;group \;change} &\sim \mathcal{N}(0,\,SD_{control \;group \;change}) \\
    \\
    SD_{TE} &= \sqrt{SD_{treatment \;group \;change}^2 - SD_{control \;group \;change}^2}
  \end{split}
  (\#eq:sd-te-equation)
\end{equation}
$$

[^SD_IR_comment]: Also referred to as $SD_{IR}$ or standard deviation of the intervention responses [@hopkinsIndividualResponsesMade2015; @swintonStatisticalFrameworkInterpret2018]. $SD_{IR}$ or $SD_{TE}$ represent estimate of treatment effect heterogeneity, also referred to as *variable treatment effect* (VTE)

This neat mathematical solution is due to assumption of Gaussian error, assumption that random treatment and non-treatment effects are equal across subjects (see [Ergodicity] section for more details about this assumption), and the use of squared errors. This is one beneficial property of using squared errors that I alluded to in the section [Cross-Validation] section. 

Thus, the estimated parameters of the causal treatment effects in the underlying DGP are are summarized with the following Equation \@ref(eq:treatment-effects-estimates). This treatment effect is graphically depicted in the Figure \@ref(fig:te-effects). 

$$
\begin{equation}
  \begin{split}
    Treatment \; effect &\sim \mathcal{N}(Mean_{TE},\,SD_{TE}) \\
    \\
    Mean_{TE} &= Mean_{treatment \;group \;change} - Mean_{control \;group \;change} \\ 
    \\
    SD_{TE} &= \sqrt{SD_{treatment \;group \;change}^2 - SD_{control \; group \; change}^2}
  \end{split}
  (\#eq:treatment-effects-estimates)
\end{equation}
$$


<div class="figure" style="text-align: center">
<img src="04-Causal-inference_files/figure-html/te-effects-1.png" alt="(ref:te-effects-caption)" width="90%" />
<p class="caption">(\#fig:te-effects)(ref:te-effects-caption)</p>
</div>

(ref:te-effects-caption) **Graphical representation of the causal Treatment effect.** Green area indicates proportion of higher than SESOI treatment effects, red indicates proportion of negative and lower than SESOI treatment effects, and grey indicates treatment effects that are within SESOI. `Mean` of treatment effect distribution represents average (or expected) causal effect or systematic treatment effect. `SD` of treatment effect distribution represents random systematic effect or $SD_{TE}$

Using SESOI, one can also estimate the proportion of lower, equivalent and higher changes (responses) caused by treatment. The estimates of the causal treatment effects, with accompanying proportions of responses are enlisted in the Table \@ref(tab:te-effects-estimates).

(ref:te-effects-estimates-caption) **Estimates of the causal treatment effects**

<table>
<caption>(\#tab:te-effects-estimates)(ref:te-effects-estimates-caption)</caption>
 <thead>
  <tr>
   <th style="text-align:right;"> Average causal effect (cm) </th>
   <th style="text-align:right;"> Random effect (cm) </th>
   <th style="text-align:left;"> SESOI (cm) </th>
   <th style="text-align:right;"> Average causal effect to SESOI </th>
   <th style="text-align:right;"> SESOI to random effect </th>
   <th style="text-align:right;"> pLower </th>
   <th style="text-align:right;"> pEquivalent </th>
   <th style="text-align:right;"> pHigher </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 9.32 </td>
   <td style="text-align:right;"> 3.95 </td>
   <td style="text-align:left;"> ±2.5 </td>
   <td style="text-align:right;"> 1.86 </td>
   <td style="text-align:right;"> 1.27 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.04 </td>
   <td style="text-align:right;"> 0.96 </td>
  </tr>
</tbody>
</table>

Therefore, we can conclude that plyometric training over three months period, on top of the normal training, cause improvements in vertical jump height (in the sample collected; *generalizations* beyond sample are discussed in the [Statistical inference] section). The expected improvement (i.e. average causal effect or systematic effect) is equal to 9.32cm, with 0, 4, and 96% of athletes having lower, trivial and higher improvements. 
