# Rerun every step in order and record the software versions used.
# Run from the repo folder:  Rscript run_all.R
steps <- c("scripts/00_data_checks.R", "scripts/01_reproduce_benchmark.R")
for (s in steps) {
  message("\n==== ", s, " ====")
  source(s, echo = FALSE, local = new.env())
}
writeLines(capture.output(sessionInfo()), "results/sessionInfo.txt")
message("\nAll steps finished. Results are in results/")
