# Changelog

Weekly progress notes. Newest first.

## 2026-11-25 (Week 2 results)
- Full comparison on 6 fold sets (101 min on 10 workers). Laptop and Linux results identical.
- H2 supported: BayesB and Bayesian LASSO within 0.01 of GBLUP everywhere.
- H1 partly supported: GBLUP beats pedigree BLUP in E1 and E2 only.
- RKHS best: +0.04 to +0.07 over GBLUP in E1, E3, E4; matches Crossa et al. (2010) RKHS within 0.015.
- Pedigree + markers beats GBLUP in E1, E3, E4.
- All 16 MCMC chains pass the convergence check.
- Across-group prediction loses 0.19 (GBLUP) and 0.20 (pedigree) in predictive ability vs. random splits of equal size.
- Fixed: convergence check now saves chains inside the repo (Windows temp-folder issue).
- Next: Week 3, multi-environment models with CV1 and CV2.

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
