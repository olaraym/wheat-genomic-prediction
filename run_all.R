# Rerun every step in order and record the software versions used.
# Run from the repo folder:  Rscript run_all.R
steps <- c("scripts/00_data_checks.R",          # Step 0: about 10 s
           "scripts/01_reproduce_benchmark.R",   # Step 1: 3-15 min
           "scripts/02b_convergence.R",          # Step 2b: MCMC check, a few min
           "scripts/02_single_env_models.R",     # Step 2: the long one; run --quick first to see its time
           "scripts/02c_structure_cv.R")         # Step 2c: under a minute
for (s in steps) {
  message("\n==== ", s, " ====")
  source(s, echo = FALSE, local = new.env())
}
writeLines(capture.output(sessionInfo()), "results/sessionInfo.txt")
message("\nAll steps finished. Results are in results/")
