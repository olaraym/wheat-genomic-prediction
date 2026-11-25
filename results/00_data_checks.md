# Step 0: data checks

Generated 2026-11-24 with BGLR 1.1.4 and rrBLUP 4.6.3.

## 1. Dimensions and missing values

| object | rows | columns | missing |
| --- | --- | --- | --- |
| Y (yield) | 599 | 4 | 0 |
| X (markers) | 599 | 1279 | 0 |
| A (pedigree) | 599 | 599 | 0 |
| sets (folds) | 599 | 1 | 0 |

## 2. Yield per environment

Mean 0 and variance 1 mean the yields are already standardized within environment, as in Crossa et al. (2010).

| env | mean | variance | min | max |
| --- | --- | --- | --- | --- |
| E1 | 0.000 | 1.000 | -2.419 | 3.279 |
| E2 | 0.000 | 1.000 | -2.950 | 2.707 |
| E3 | 0.000 | 1.000 | -3.351 | 4.875 |
| E4 | -0.000 | 1.000 | -3.576 | 2.792 |

## 3. Published cross-validation partition (`wheat.sets`)

| fold | lines |
| --- | --- |
| 1 | 57 |
| 2 | 50 |
| 3 | 61 |
| 4 | 73 |
| 5 | 52 |
| 6 | 68 |
| 7 | 51 |
| 8 | 64 |
| 9 | 63 |
| 10 | 60 |

## 4. Phenotypic correlations between environments

| env | E1 | E2 | E3 | E4 |
| --- | --- | --- | --- | --- |
| E1 | 1.000 | -0.020 | -0.193 | -0.123 |
| E2 | -0.020 | 1.000 | 0.661 | 0.411 |
| E3 | -0.193 | 0.661 | 1.000 | 0.388 |
| E4 | -0.123 | 0.411 | 0.388 | 1.000 |

## 5. Markers

- Values present: 0, 1
- Minor allele frequency: min 0.008, median 0.239; markers with MAF < 0.05: 96

## 6. Population structure

Variance explained by marker PCs 1-5: 11.3, 5.0, 4.2, 3.3, 2.4 %

## 7. Pedigree vs. marker relationships

- Mean diagonal: A = 1.98, G = 1.00 (A is about 2 because inbred lines have inbreeding near 1)
- Correlation of off-diagonal relationships, A vs. G: 0.268

## 8. Heritability preview (REML, all lines)

`ceiling_r` = square root of genomic heritability: roughly the best predictive ability markers could reach.

| env | h2_markers | h2_pedigree | ceiling_r |
| --- | --- | --- | --- |
| E1 | 0.498 | 0.500 | 0.706 |
| E2 | 0.448 | 0.454 | 0.670 |
| E3 | 0.423 | 0.584 | 0.650 |
| E4 | 0.430 | 0.536 | 0.655 |

