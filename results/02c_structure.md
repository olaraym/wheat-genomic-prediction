# Step 2c: prediction across genetic groups

Groups from k-means (k = 2) on the first 5 marker principal components: 253 and 346 lines.
`r_across_groups`: train on one group, predict the other. `r_random_same_size`: random splits of the same sizes (mean of 10).
`drop` = how much accuracy is lost when training and test lines come from different groups.

| env | model | r_across_groups | r_random_same_size | r_random_sd | drop |
| --- | --- | --- | --- | --- | --- |
| E1 | pedigree_blup | 0.048 | 0.347 | 0.029 | 0.299 |
| E1 | gblup | 0.154 | 0.471 | 0.035 | 0.317 |
| E2 | pedigree_blup | 0.188 | 0.382 | 0.015 | 0.194 |
| E2 | gblup | 0.354 | 0.443 | 0.016 | 0.089 |
| E3 | pedigree_blup | 0.173 | 0.355 | 0.025 | 0.182 |
| E3 | gblup | 0.236 | 0.336 | 0.030 | 0.100 |
| E4 | pedigree_blup | 0.262 | 0.396 | 0.020 | 0.134 |
| E4 | gblup | 0.168 | 0.404 | 0.016 | 0.236 |

Mean drop across environments: GBLUP 0.185, pedigree BLUP 0.202.
