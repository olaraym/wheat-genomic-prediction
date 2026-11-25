# AI assistance log

This project used AI coding tools. This file records what they did and what I checked myself,
so a reader can judge the work.

## Tools used

| Tool | Version / model | Used for |
| --- | --- | --- |
| Claude (Anthropic) | – | Week 1 and 2 scaffolds: R/functions.R, Step 0–2c scripts, tests, CI workflow |

## Log

| Date | Task | What the AI produced | What I verified by hand |
| --- | --- | --- | --- |
| 2026-11-24 | Week 1 scripts | data checks, benchmark reproduction, 6 test groups (17 checks) | _to fill:_ read each script; reran on my laptop; checked the E1-E4 column mapping against the benchmark; checked the MAF finding |
| 2026-11-25 | Week 2 scripts | six-model comparison (parallel), convergence check, structure check, 17 more tests | _to fill:_ read each script; reran --quick and the full run on my laptop; checked the convergence table and the groups plot |

## Rules I follow

- I run and read every AI-generated piece of code before committing it.
- Scientific choices (models, parameters, thresholds) are mine and are justified in the README.
- Results are checked against a published benchmark (`results/validation.md`).
