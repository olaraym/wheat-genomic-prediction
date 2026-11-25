# Step 2: single-environment model comparison

Fold sets: published, seed_2027, seed_2028, seed_2029, seed_2030, seed_2031. MCMC: 12000 iterations, 2000 burn-in. 10 workers; run time 101.1 min.

## Mean metrics over fold sets

`pearson` = predictive ability; `top20` = share of the truly top 20% lines also in the predicted top 20%.

| model | env | pearson_mean | pearson_sd | spearman | top20 | mse |
| --- | --- | --- | --- | --- | --- | --- |
| rkhs | E1 | 0.598 | 0.008 | 0.554 | 0.360 | 0.644 |
| pedigree_markers | E1 | 0.551 | 0.008 | 0.505 | 0.381 | 0.696 |
| gblup | E1 | 0.530 | 0.007 | 0.476 | 0.314 | 0.718 |
| bayes_lasso | E1 | 0.527 | 0.007 | 0.475 | 0.317 | 0.721 |
| bayes_b | E1 | 0.523 | 0.008 | 0.472 | 0.317 | 0.726 |
| pedigree_blup | E1 | 0.424 | 0.012 | 0.405 | 0.394 | 0.821 |
| pedigree_markers | E2 | 0.497 | 0.014 | 0.493 | 0.421 | 0.752 |
| rkhs | E2 | 0.497 | 0.016 | 0.486 | 0.417 | 0.756 |
| gblup | E2 | 0.493 | 0.015 | 0.479 | 0.428 | 0.756 |
| bayes_lasso | E2 | 0.491 | 0.015 | 0.476 | 0.424 | 0.759 |
| bayes_b | E2 | 0.487 | 0.018 | 0.472 | 0.428 | 0.762 |
| pedigree_blup | E2 | 0.409 | 0.005 | 0.444 | 0.378 | 0.832 |
| pedigree_markers | E3 | 0.434 | 0.014 | 0.465 | 0.449 | 0.811 |
| rkhs | E3 | 0.431 | 0.010 | 0.457 | 0.390 | 0.813 |
| pedigree_blup | E3 | 0.399 | 0.008 | 0.434 | 0.444 | 0.840 |
| bayes_lasso | E3 | 0.391 | 0.010 | 0.408 | 0.382 | 0.846 |
| gblup | E3 | 0.390 | 0.009 | 0.407 | 0.390 | 0.848 |
| bayes_b | E3 | 0.390 | 0.011 | 0.406 | 0.390 | 0.849 |
| rkhs | E4 | 0.514 | 0.003 | 0.497 | 0.536 | 0.736 |
| pedigree_markers | E4 | 0.492 | 0.006 | 0.487 | 0.544 | 0.757 |
| gblup | E4 | 0.454 | 0.005 | 0.452 | 0.526 | 0.793 |
| bayes_lasso | E4 | 0.454 | 0.005 | 0.451 | 0.531 | 0.793 |
| bayes_b | E4 | 0.452 | 0.007 | 0.449 | 0.531 | 0.795 |
| pedigree_blup | E4 | 0.441 | 0.008 | 0.440 | 0.450 | 0.804 |

## Paired differences from GBLUP (predictive ability)

Rule fixed in advance: a difference counts only if |mean| >= 0.02 and at least five-sixths of fold sets (5 of 6 in the full run) agree in sign.

| model | env | mean_diff | min_diff | max_diff | verdict_vs_gblup |
| --- | --- | --- | --- | --- | --- |
| bayes_b | E1 | -0.008 | -0.010 | -0.006 | no meaningful difference |
| bayes_b | E2 | -0.006 | -0.014 | -0.004 | no meaningful difference |
| bayes_b | E3 | -0.000 | -0.003 | 0.006 | no meaningful difference |
| bayes_b | E4 | -0.002 | -0.009 | 0.005 | no meaningful difference |
| bayes_lasso | E1 | -0.003 | -0.004 | -0.003 | no meaningful difference |
| bayes_lasso | E2 | -0.002 | -0.003 | -0.001 | no meaningful difference |
| bayes_lasso | E3 | 0.002 | -0.000 | 0.003 | no meaningful difference |
| bayes_lasso | E4 | -0.000 | -0.003 | 0.002 | no meaningful difference |
| pedigree_blup | E1 | -0.106 | -0.130 | -0.091 | worse |
| pedigree_blup | E2 | -0.084 | -0.103 | -0.061 | worse |
| pedigree_blup | E3 | 0.009 | -0.009 | 0.015 | no meaningful difference |
| pedigree_blup | E4 | -0.013 | -0.020 | -0.004 | no meaningful difference |
| pedigree_markers | E1 | 0.021 | 0.012 | 0.031 | better |
| pedigree_markers | E2 | 0.004 | -0.002 | 0.009 | no meaningful difference |
| pedigree_markers | E3 | 0.044 | 0.033 | 0.049 | better |
| pedigree_markers | E4 | 0.038 | 0.035 | 0.042 | better |
| rkhs | E1 | 0.067 | 0.060 | 0.072 | better |
| rkhs | E2 | 0.003 | 0.001 | 0.006 | no meaningful difference |
| rkhs | E3 | 0.041 | 0.036 | 0.052 | better |
| rkhs | E4 | 0.060 | 0.056 | 0.062 | better |

## Hypotheses

- H1 (markers beat pedigree): NOT fully supported: GBLUP beats pedigree BLUP meaningfully in 2 of 4 environments
- H2 (Bayesian models ~ GBLUP): SUPPORTED: BayesB and Bayesian LASSO are within 0.02 of GBLUP in every environment

## Time per fit on this computer

| model | seconds_per_fit |
| --- | --- |
| bayes_b | 46.43 |
| bayes_lasso | 81.10 |
| gblup | 2.92 |
| pedigree_blup | 2.99 |
| pedigree_markers | 76.29 |
| rkhs | 39.18 |

