# Step 2b. Check that the Bayesian models' MCMC chains settled (assumption A10).
#   Input:  all lines, one environment at a time
#   Process: fit each Bayesian model on the full data with the run's settings (12,000 iterations,
#            2,000 burn-in) and read the saved chain of the residual variance
#   Output: results/02b_convergence.md and .csv
#   Pass:   effective sample size >= 100 AND the two halves of the chain differ by < 10%
# Usage:  Rscript scripts/02b_convergence.R [--iter=12000] [--workers=N]

source("R/functions.R")
suppressPackageStartupMessages(library(future.apply))
args    <- commandArgs(trailingOnly = TRUE)
N_ITER  <- get_flag(args, "iter", 12000)
BURN_IN <- round(N_ITER / 6)
WORKERS <- get_flag(args, "workers", max(1, min(10, parallel::detectCores() - 1)))
THIN    <- 5                                   # BGLR default: every 5th sample is saved

d  <- load_wheat()
Y  <- d$Y; A <- d$A; Xs <- scale(d$X); G <- make_G(d$X); K_gauss <- gaussian_kernel(d$X)
etas <- list(
  bayes_b          = list(list(X = Xs, model = "BayesB")),
  bayes_lasso      = list(list(X = Xs, model = "BL")),
  rkhs             = list(list(K = K_gauss, model = "RKHS")),
  pedigree_markers = list(list(K = A, model = "RKHS"), list(K = G, model = "RKHS")))
tasks <- expand.grid(model = names(etas), env = colnames(Y), stringsAsFactors = FALSE)

# Chains are saved inside the repo (git-ignored), with an absolute forward-slash path built here in the
# main session. Windows temp folders under a user name with a space were unreliable for BGLR's files.
MCMC_DIR <- "results/_mcmc"
dir.create(MCMC_DIR, recursive = TRUE, showWarnings = FALSE)
MCMC_DIR <- normalizePath(MCMC_DIR, winslash = "/", mustWork = TRUE)
tasks$prefix <- file.path(MCMC_DIR, paste0(tasks$model, "_", tasks$env, "_"))

check_one <- function(i) {
  tk <- tasks[i, ]
  set.seed(i)
  mult <- if (tk$model == "bayes_lasso") 2 else 1             # same settings as Step 2
  BGLR(y = Y[, tk$env], ETA = etas[[tk$model]], nIter = mult * N_ITER, burnIn = mult * BURN_IN, thin = THIN,
       verbose = FALSE, saveAt = tk$prefix)
  chain_file <- paste0(tk$prefix, "varE.dat")
  if (!file.exists(chain_file)) {
    stop(sprintf("Chain file not found: %s\nFiles in that folder: %s\nWorking directory: %s",
                 chain_file, paste(list.files(dirname(tk$prefix)), collapse = ", "), getwd()))
  }
  chain <- scan(chain_file, quiet = TRUE)
  chain <- chain[-seq_len(mult * BURN_IN / THIN)]              # drop burn-in samples
  half <- floor(length(chain) / 2)
  m1 <- mean(chain[seq_len(half)]); m2 <- mean(chain[-seq_len(half)])
  data.frame(model = tk$model, env = tk$env, samples = length(chain), mean_varE = mean(chain),
             ess = ess(chain), half_change_pct = 100 * abs(m2 - m1) / mean(chain))
}

if (WORKERS > 1) plan(multisession, workers = WORKERS) else plan(sequential)
res <- do.call(rbind, future_lapply(seq_len(nrow(tasks)), check_one, future.seed = TRUE,
                                    future.chunk.size = 1, future.packages = "BGLR"))
plan(sequential)
res$pass <- ifelse(!is.na(res$ess) & res$ess >= 100 & res$half_change_pct < 10, "PASS", "CHECK")
write.csv(res, "results/02b_convergence.csv", row.names = FALSE)

report <- c("# Step 2b: MCMC convergence of the Bayesian models", "",
  sprintf("Chain: residual variance, %d iterations, %d burn-in (Bayesian LASSO: twice both), every %dth sample kept.", N_ITER, BURN_IN, THIN),
  "Pass: effective sample size >= 100 and the two halves of the chain differ by less than 10%.", "",
  md_table(res), "",
  if (all(res$pass == "PASS")) "**All chains pass.**" else
    "**Some chains need attention: rerun with more iterations (e.g. --iter=24000) and compare.**")
writeLines(report, "results/02b_convergence.md")
cat(paste(report, collapse = "\n"), "\n")
