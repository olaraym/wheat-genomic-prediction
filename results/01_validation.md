# Step 1: reproducing Crossa et al. (2010), Table 3

Pass criterion: mean predictive ability over 10 random 10-fold replicates within +/-0.05 of the published value.
`r_published_folds` uses the fold partition shipped with the data (`wheat.sets`).

| model | env | r_crossa_2010 | r_published_folds | r_mean | r_sd | difference | pass |
| --- | --- | --- | --- | --- | --- | --- | --- |
| gblup_check | E1 |   NA | 0.524 | 0.529 | 0.006 |   NA | internal check |
| gblup_check | E2 |   NA | 0.465 | 0.496 | 0.008 |   NA | internal check |
| gblup_check | E3 |   NA | 0.391 | 0.389 | 0.010 |   NA | internal check |
| gblup_check | E4 |   NA | 0.452 | 0.454 | 0.005 |   NA | internal check |
| marker_blup | E1 | 0.480 | 0.524 | 0.529 | 0.006 | 0.049 | PASS |
| marker_blup | E2 | 0.488 | 0.465 | 0.496 | 0.008 | 0.008 | PASS |
| marker_blup | E3 | 0.355 | 0.391 | 0.389 | 0.010 | 0.034 | PASS |
| marker_blup | E4 | 0.464 | 0.452 | 0.454 | 0.005 | -0.010 | PASS |
| pedigree_blup | E1 | 0.448 | 0.415 | 0.429 | 0.013 | -0.019 | PASS |
| pedigree_blup | E2 | 0.417 | 0.404 | 0.408 | 0.006 | -0.009 | PASS |
| pedigree_blup | E3 | 0.417 | 0.406 | 0.396 | 0.008 | -0.021 | PASS |
| pedigree_blup | E4 | 0.449 | 0.432 | 0.447 | 0.008 | -0.002 | PASS |

**Result: benchmark reproduced in every environment. Gate passed.**

GBLUP (`gblup_check`) matched marker ridge BLUP in every fit (correlation of predictions > 0.9999).

Run time: 923 s.
