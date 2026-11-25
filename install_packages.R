# One-time setup: install the R packages P1 needs.
# Run from the repo folder:  Rscript install_packages.R
pkgs <- c("BGLR", "rrBLUP", "data.table", "ggplot2", "future.apply", "testthat")
missing <- setdiff(pkgs, rownames(installed.packages()))
if (length(missing)) install.packages(missing, repos = "https://cloud.r-project.org")
for (p in pkgs) cat(sprintf("%-14s %s\n", p, as.character(packageVersion(p))))
