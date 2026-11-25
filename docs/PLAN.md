# P1 analysis plan (summary)

**Primary question:** how accurately can genome-wide markers predict grain yield of untested wheat lines, and which
model family does it best?

**Hypotheses**
- H1: marker models beat pedigree BLUP in every environment.
- H2: GBLUP and Bayesian models perform within cross-validation noise of each other (yield is polygenic).
- H3: multi-environment models clearly improve CV2 (partly tested lines) but help little in CV1 (new lines).
- H4: gains from multi-environment models are largest between genetically correlated environments.

**Steps**
| Step | What | Output |
| --- | --- | --- |
| 0 | Data checks and exploration | `results/00_data_checks.md`, figures |
| 1 | Reproduce Crossa et al. (2010) Table 3 within ±0.05 (gate) | `results/01_validation.md` |
| 2 | Single-environment models: pedigree BLUP, GBLUP, rrBLUP, BayesB, Bayesian LASSO, RKHS, pedigree + markers | `results/02_single_env.csv` |
| 3 | Multi-environment models: across-environment, marker × environment, unstructured | `results/03_multi_env.csv` |
| 4 | Cross-validation: 10 × 10-fold within environment; CV1 and CV2 across environments | (used by Steps 1–3) |
| 5 | Metrics: Pearson r, Spearman ρ, top-20% selection overlap, MSE, runtime | (in the tables) |
| 6 | Paired comparisons over replicates; differences under 0.02 reported as no meaningful difference | (in the tables) |
| 7 | Genomic heritability and genetic correlations between environments | `results/04_variance_components.csv` |
| 8 | README, figures, release with DOI | |

**Added in Week 2:** Step 2b (MCMC convergence check) and Step 2c (prediction across the two genetic groups found
in the marker PCA, against random splits of equal size). rrBLUP is dropped from the comparison because Week 1 showed
it gives the same predictions as GBLUP in every fit.

**Timeline:** W1 setup + benchmark (done Nov 24) · W2 single-environment models · W3 multi-environment, CV1/CV2 ·
W4 heritability, report, release.

**Software note:** models use BGLR and rrBLUP only (rrBLUP's `mixed.solve` fits GBLUP and pedigree BLUP by REML), which
avoids a dependency on sommer.
