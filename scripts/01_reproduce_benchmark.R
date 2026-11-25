# Step 1. Reproduce Crossa et al. (2010), Table 3, before comparing any new model.
#   Input:  yield (standardized), pedigree matrix A, marker matrix X, published folds
#   Process: pedigree BLUP and marker ridge BLUP, one environment at a time, 10-fold CV:
#            replicate 0 = the published partition (wheat.sets), replicates 1-10 = random seeds
#            GBLUP is also fitted as an internal check: it must equal marker ridge BLUP.
#   Output: results/01_validation.md, results/01_validation.csv, results/01_cv_replicates.csv
# Run from the repo folder:  Rscript scripts/01_reproduce_benchmark.R

source("R/functions.R")
N_REPS <- 10
TOLERANCE <- 0.05   # pass criterion, fixed in the plan

d <- load_wheat()
Y <- d$Y
Xs <- scale(d$X)
G <- make_G(d$X)

models <- list(
  pedigree_blup = function(y) fit_kernel_blup(y, d$A),
  marker_blup   = function(y) fit_ridge_blup(y, Xs),
  gblup_check   = function(y) fit_kernel_blup(y, G)
)

fold_sets <- c(list(published = d$sets),
               setNames(lapply(seq_len(N_REPS), function(r) make_folds(nrow(Y), 10, seed = 2026 + r)),
                        paste0("seed_", 2026 + seq_len(N_REPS))))

t0 <- Sys.time()
rows <- list()
for (rep_name in names(fold_sets)) {
  folds <- fold_sets[[rep_name]]
  for (env in colnames(Y)) {
    preds <- lapply(models, function(fit) predict_cv(Y[, env], folds, fit))
    for (m in names(models)) {
      rows[[length(rows) + 1]] <- data.frame(replicate = rep_name, env = env, model = m,
                                             r = cor(Y[, env], preds[[m]]))
    }
    # internal check: GBLUP and marker ridge BLUP are the same model
    stopifnot(cor(preds$marker_blup, preds$gblup_check) > 0.9999)
  }
  cat(sprintf("%-10s done (%.0f s)\n", rep_name, as.numeric(difftime(Sys.time(), t0, units = "secs"))))
}
reps <- do.call(rbind, rows)
write.csv(reps, "results/01_cv_replicates.csv", row.names = FALSE)

# Summaries: published partition, and mean +/- SD over the random replicates
pub <- subset(reps, replicate == "published")
rnd <- subset(reps, replicate != "published")
agg <- aggregate(r ~ env + model, rnd, function(v) c(mean = mean(v), sd = sd(v)))
agg <- data.frame(env = agg$env, model = agg$model, r_mean = agg$r[, "mean"], r_sd = agg$r[, "sd"])
val <- merge(merge(agg, setNames(pub[, c("env", "model", "r")], c("env", "model", "r_published_folds"))),
             setNames(CROSSA_2010, c("model", "env", "r_crossa_2010")), all.x = TRUE)
val$difference <- val$r_mean - val$r_crossa_2010
val$pass <- ifelse(is.na(val$r_crossa_2010), "internal check",
                   ifelse(abs(val$difference) <= TOLERANCE, "PASS", "FAIL"))
val <- val[order(val$model, val$env), c("model", "env", "r_crossa_2010", "r_published_folds",
                                        "r_mean", "r_sd", "difference", "pass")]
write.csv(val, "results/01_validation.csv", row.names = FALSE)

n_fail <- sum(val$pass == "FAIL")
report <- c("# Step 1: reproducing Crossa et al. (2010), Table 3", "",
  sprintf("Pass criterion: mean predictive ability over %d random 10-fold replicates within +/-%.2f of the published value.",
          N_REPS, TOLERANCE),
  "`r_published_folds` uses the fold partition shipped with the data (`wheat.sets`).", "",
  md_table(val), "",
  if (n_fail == 0) "**Result: benchmark reproduced in every environment. Gate passed.**"
  else sprintf("**Result: %d of 8 comparisons outside tolerance. Investigate before Step 2.**", n_fail),
  "", "GBLUP (`gblup_check`) matched marker ridge BLUP in every fit (correlation of predictions > 0.9999).",
  "", sprintf("Run time: %.0f s.", as.numeric(difftime(Sys.time(), t0, units = "secs"))))
writeLines(report, "results/01_validation.md")
cat(paste(report, collapse = "\n"), "\n")
