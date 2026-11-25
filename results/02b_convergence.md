# Step 2b: MCMC convergence of the Bayesian models

Chain: residual variance, 12000 iterations, 2000 burn-in (Bayesian LASSO: twice both), every 5th sample kept.
Pass: effective sample size >= 100 and the two halves of the chain differ by less than 10%.

| model | env | samples | mean_varE | ess | half_change_pct | pass |
| --- | --- | --- | --- | --- | --- | --- |
| bayes_b | E1 | 2000.000 | 0.546 | 502.415 | 0.058 | PASS |
| bayes_lasso | E1 | 4000.000 | 0.541 | 170.587 | 0.327 | PASS |
| rkhs | E1 | 2000.000 | 0.352 | 869.505 | 0.478 | PASS |
| pedigree_markers | E1 | 2000.000 | 0.434 | 681.734 | 0.137 | PASS |
| bayes_b | E2 | 2000.000 | 0.579 | 445.678 | 1.297 | PASS |
| bayes_lasso | E2 | 4000.000 | 0.588 | 224.967 | 0.363 | PASS |
| rkhs | E2 | 2000.000 | 0.485 | 732.049 | 0.532 | PASS |
| pedigree_markers | E2 | 2000.000 | 0.508 | 724.983 | 1.327 | PASS |
| bayes_b | E3 | 2000.000 | 0.623 | 271.076 | 0.674 | PASS |
| bayes_lasso | E3 | 4000.000 | 0.627 | 210.211 | 0.843 | PASS |
| rkhs | E3 | 2000.000 | 0.407 | 586.429 | 0.990 | PASS |
| pedigree_markers | E3 | 2000.000 | 0.469 | 561.312 | 1.679 | PASS |
| bayes_b | E4 | 2000.000 | 0.609 | 628.106 | 1.907 | PASS |
| bayes_lasso | E4 | 4000.000 | 0.616 | 180.076 | 1.362 | PASS |
| rkhs | E4 | 2000.000 | 0.419 | 729.333 | 0.345 | PASS |
| pedigree_markers | E4 | 2000.000 | 0.473 | 604.441 | 1.579 | PASS |

**All chains pass.**
