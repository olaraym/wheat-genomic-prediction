# Changelog

Weekly progress notes. Newest first.

## 2026-11-25 (Week 2 code)
- Step 1 rerun on Windows: identical to the Linux run, to three decimals.
- Added Step 2 (six single-environment models, parallel, `--quick` timing trial), Step 2b (MCMC convergence check)
  and Step 2c (prediction across the two genetic groups).
- Bayesian LASSO given twice the iterations after Step 2b showed an effective sample size of 90 (< 100) in E3 at 12,000.
- Tests: 34 checks.

## 2026-11-24 (Week 1, started early)
- Step 0 data checks: yield already standardized (mean 0, variance 1 per environment); no missing values;
  96 of 1,279 markers have MAF < 0.05 despite the documented filter; pedigree vs. marker relationships correlate at 0.27.
- Step 1 benchmark: Crossa et al. (2010) Table 3 reproduced within ±0.05 in all 8 comparisons (gate passed).
  Marker BLUP in E1 is borderline (+0.049), also on the published fold partition.
- GBLUP and marker ridge BLUP agreed in all 440 cross-validation fits.
- Next: Step 2, single-environment model comparison (BayesB, Bayesian LASSO, RKHS, pedigree + markers).
