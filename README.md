# PROJECT TITLE

[![CI](https://github.com/Olaraym/REPO_NAME/actions/workflows/ci.yml/badge.svg)](https://github.com/Olaraym/REPO_NAME/actions/workflows/ci.yml)
<!-- After the first release, add the Zenodo DOI badge here. -->

**Question.** One sentence: what does this project answer?

**Gap it closes.** Which skill this project demonstrates (e.g., mixed models, DNA language models).

## Data

| Dataset | Source | Citation | License |
| --- | --- | --- | --- |
| NAME | URL or package | Author et al. (year) | LICENSE |

Raw data are **not** committed. `make data` downloads them into `data/raw/` (git-ignored).

## Methods

1. Step one
2. Step two
3. Step three

## Validation against published results

Before any new analysis, this repo reproduces **[published result]** from **[paper]**.
Comparison: `results/validation.md`.

## Results

Headline: **[one sentence with the key number]**

![Main figure](results/figures/main.png)

## Reproduce

```bash
git clone https://github.com/Olaraym/REPO_NAME.git
cd REPO_NAME
make env      # create the conda environment from environment.yml
conda activate REPO_NAME
make all      # download data, run the analysis, build figures
make test     # run the tests on the toy dataset
```

## Repository layout

```
data/toy/        small test data used by CI
data/raw/        downloaded data (git-ignored)
src/             reusable functions
workflow/        pipeline (Snakefile / Nextflow / scripts)
results/         tables and figures
tests/           tests run by GitHub Actions
docs/            notes and extra documentation
```

## Definition of done

- [ ] README complete (question, data, methods, result, reproduce)
- [ ] One-command run (`make all`)
- [ ] Pinned environment (`environment.yml`)
- [ ] CI passing on toy data
- [ ] Published result reproduced (`results/validation.md`)
- [ ] `AI_ASSISTANCE.md` filled in
- [ ] Tagged release + Zenodo DOI
- [ ] Resume bullet updated with the real number

## Author

Laide A. Rasaki · NC State University · [ORCID 0000-0002-5594-6827](https://orcid.org/0000-0002-5594-6827)
