# Step 2. Compare six prediction models, one environment at a time, on identical folds.
#   Input:  standardized yield (4 environments), markers, pedigree matrix, the Week 1 fold sets
#   Process: 10-fold CV for each model x environment x fold set; Bayesian fits run in parallel
#   Output: results/02_single_env.md (+ csv tables, predictions, two figures)
#
# Usage, from the repo folder:
#   Rscript scripts/02_single_env_models.R --quick        # ~1-5 min timing trial (published folds, short chains)
#   Rscript scripts/02_single_env_models.R                # full run: published folds + 5 random fold sets
# Options: --workers=N (default: cores - 1, max 10) --reps=N (random fold sets, default 5) --iter=N (MCMC, default 12000)
# Bayesian LASSO runs twice as many iterations as the other Bayesian models, because its chains mix
# more slowly (Step 2b found an effective sample size just under 100 at 12,000 iterations).

source("R/functions.R")
suppressPackageStartupMessages({ library(future.apply); library(ggplot2) })

args    <- commandArgs(trailingOnly = TRUE)
QUICK   <- isTRUE(get_flag(args, "quick", FALSE))
N_REPS  <- if (QUICK) 0 else get_flag(args, "reps", 5)
N_ITER  <- get_flag(args, "iter", if (QUICK) 1500 else 12000)
BURN_IN <- round(N_ITER / 6)                 # 12000 -> 2000, as in the plan
WORKERS <- get_flag(args, "workers", max(1, min(10, parallel::detectCores() - 1)))
TAG     <- if (QUICK) "02_quick" else "02"
dir.create("results/figures", recursive = TRUE, showWarnings = FALSE)

d  <- load_wheat()
Y  <- d$Y
A  <- d$A
Xs <- scale(d$X)
G  <- make_G(d$X)
K_gauss <- gaussian_kernel(d$X, h = 1)

MODELS <- c("pedigree_blup", "gblup", "bayes_b", "bayes_lasso", "rkhs", "pedigree_markers")
BAYESIAN <- c("bayes_b", "bayes_lasso", "rkhs", "pedigree_markers")

fit_model <- function(model, y_train) {
  switch(model,
    pedigree_blup    = fit_kernel_blup(y_train, A),
    gblup            = fit_kernel_blup(y_train, G),
    bayes_b          = fit_bglr(y_train, list(list(X = Xs, model = "BayesB")), N_ITER, BURN_IN),
    bayes_lasso      = fit_bglr(y_train, list(list(X = Xs, model = "BL")), 2 * N_ITER, 2 * BURN_IN),  # mixes slowly: see 02b
    rkhs             = fit_bglr(y_train, list(list(K = K_gauss, model = "RKHS")), N_ITER, BURN_IN),
    pedigree_markers = fit_bglr(y_train, list(list(K = A, model = "RKHS"), list(K = G, model = "RKHS")),
                                N_ITER, BURN_IN))
}

# Same fold sets as Week 1: the published partition, then seeds 2027, 2028, ...
fold_sets <- list(published = d$sets)
for (r in seq_len(N_REPS)) fold_sets[[paste0("seed_", 2026 + r)]] <- make_folds(nrow(Y), 10, seed = 2026 + r)

# One task = one model x environment x fold set (10 fits). Slow Bayesian tasks go first.
tasks <- expand.grid(model = MODELS, env = colnames(Y), replicate = names(fold_sets),
                     stringsAsFactors = FALSE)
tasks$seed <- 100000 * match(tasks$replicate, names(fold_sets)) + 1000 * match(tasks$env, colnames(Y)) +
  10 * match(tasks$model, MODELS)
tasks <- tasks[order(!tasks$model %in% BAYESIAN), ]

run_task <- function(i) {
  tk <- tasks[i, ]
  folds <- fold_sets[[tk$replicate]]
  y <- Y[, tk$env]
  pred <- rep(NA_real_, length(y))
  t0 <- Sys.time()
  for (f in sort(unique(folds))) {
    set.seed(tk$seed + f)                       # reproducible MCMC, whatever the number of workers
    test <- folds == f
    y_train <- y
    y_train[test] <- NA
    pred[test] <- fit_model(tk$model, y_train)[test]
  }
  list(pred = data.frame(replicate = tk$replicate, env = tk$env, model = tk$model,
                         line = seq_along(y), observed = y, predicted = pred),
       seconds = as.numeric(difftime(Sys.time(), t0, units = "secs")))
}

cat(sprintf("%d tasks (%d fits) on %d workers; MCMC %d iterations (burn-in %d)%s\n",
            nrow(tasks), 10 * nrow(tasks), WORKERS, N_ITER, BURN_IN, if (QUICK) "  [QUICK TRIAL]" else ""))
t_start <- Sys.time()
if (WORKERS > 1) plan(multisession, workers = WORKERS) else plan(sequential)
out <- future_lapply(seq_len(nrow(tasks)), run_task, future.seed = TRUE, future.chunk.size = 1,
                     future.packages = c("BGLR", "rrBLUP"))
plan(sequential)
elapsed <- as.numeric(difftime(Sys.time(), t_start, units = "secs"))

preds <- do.call(rbind, lapply(out, `[[`, "pred"))
tasks$seconds <- vapply(out, `[[`, 0, "seconds")
write.csv(preds, gzfile(sprintf("results/%s_predictions.csv.gz", TAG)), row.names = FALSE)

# ---------------------------------------------------------------- metrics
keys <- unique(preds[, c("replicate", "env", "model")])
reps <- do.call(rbind, lapply(seq_len(nrow(keys)), function(i) {
  k <- keys[i, ]
  p <- preds[preds$replicate == k$replicate & preds$env == k$env & preds$model == k$model, ]
  cbind(k, cv_metrics(p$observed, p$predicted))
}))
write.csv(reps, sprintf("results/%s_single_env_replicates.csv", TAG), row.names = FALSE)

summ <- do.call(rbind, lapply(split(reps, list(reps$model, reps$env), drop = TRUE), function(s)
  data.frame(model = s$model[1], env = s$env[1], pearson_mean = mean(s$pearson),
             pearson_sd = if (nrow(s) > 1) sd(s$pearson) else NA, spearman = mean(s$spearman),
             top20 = mean(s$top20), mse = mean(s$mse))))
summ <- summ[order(summ$env, -summ$pearson_mean), ]
write.csv(summ, sprintf("results/%s_single_env.csv", TAG), row.names = FALSE)

# Paired differences against GBLUP, fold set by fold set
ref <- subset(reps, model == "gblup")[, c("replicate", "env", "pearson")]
names(ref)[3] <- "gblup"
cmp <- merge(subset(reps, model != "gblup")[, c("replicate", "env", "model", "pearson")], ref)
cmp$diff <- cmp$pearson - cmp$gblup
vs <- do.call(rbind, lapply(split(cmp, list(cmp$model, cmp$env), drop = TRUE), function(s)
  data.frame(model = s$model[1], env = s$env[1], mean_diff = mean(s$diff), min_diff = min(s$diff),
             max_diff = max(s$diff), verdict_vs_gblup = paired_verdict(s$diff))))
vs <- vs[order(vs$model, vs$env), ]
write.csv(vs, sprintf("results/%s_vs_gblup.csv", TAG), row.names = FALSE)

# ---------------------------------------------------------------- hypotheses
ped <- subset(vs, model == "pedigree_blup")
h1 <- if (all(ped$verdict_vs_gblup == "worse")) "SUPPORTED: GBLUP beats pedigree BLUP in all 4 environments" else
  sprintf("NOT fully supported: GBLUP beats pedigree BLUP meaningfully in %d of 4 environments",
          sum(ped$verdict_vs_gblup == "worse"))
bay <- subset(vs, model %in% c("bayes_b", "bayes_lasso"))
h2 <- if (all(bay$verdict_vs_gblup == "no meaningful difference"))
  "SUPPORTED: BayesB and Bayesian LASSO are within 0.02 of GBLUP in every environment" else
  sprintf("NOT fully supported: %d of 8 BayesB / Bayesian LASSO comparisons differ meaningfully from GBLUP",
          sum(bay$verdict_vs_gblup != "no meaningful difference"))

# ---------------------------------------------------------------- figures
reps$model <- factor(reps$model, levels = MODELS)
p1 <- ggplot(reps, aes(model, pearson)) +
  stat_summary(fun = mean, geom = "col", fill = "grey80") +
  geom_point(alpha = 0.6, size = 1.3, position = position_jitter(width = 0.12, height = 0, seed = 1)) +
  facet_wrap(~env, nrow = 1) + coord_cartesian(ylim = c(0, 0.75)) +
  labs(x = NULL, y = "predictive ability (r)",
       title = "Predictive ability by model and environment (bars = mean, dots = fold sets)") +
  theme_minimal() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(sprintf("results/figures/%s_predictive_ability.png", TAG), p1, width = 11, height = 4.2, dpi = 150)

cmp$model <- factor(cmp$model, levels = MODELS[-2])
p2 <- ggplot(cmp, aes(model, diff)) + geom_hline(yintercept = 0, colour = "grey50") +
  geom_hline(yintercept = c(-0.02, 0.02), linetype = 2, colour = "grey50") +
  geom_point(alpha = 0.7, position = position_jitter(width = 0.12, height = 0, seed = 1)) +
  facet_wrap(~env, nrow = 1) +
  labs(x = NULL, y = "difference in r vs. GBLUP", title = "Paired differences from GBLUP (dashed: +/-0.02 threshold)") +
  theme_minimal() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(sprintf("results/figures/%s_diff_vs_gblup.png", TAG), p2, width = 11, height = 4.2, dpi = 150)

# ---------------------------------------------------------------- timing and report
timing <- aggregate(seconds ~ model, tasks, mean)
timing$seconds_per_fit <- timing$seconds / 10
proj_min <- sum(timing$seconds_per_fit[timing$model %in% BAYESIAN]) * (12000 / N_ITER) * 10 * 4 * 6 / WORKERS / 60

report <- c(sprintf("# Step 2: single-environment model comparison%s", if (QUICK) " (QUICK TRIAL: not for reporting)" else ""), "",
  sprintf("Fold sets: %s. MCMC: %d iterations, %d burn-in. %d workers; run time %.1f min.",
          paste(names(fold_sets), collapse = ", "), N_ITER, BURN_IN, WORKERS, elapsed / 60), "",
  "## Mean metrics over fold sets", "",
  "`pearson` = predictive ability; `top20` = share of the truly top 20% lines also in the predicted top 20%.", "",
  md_table(summ), "",
  "## Paired differences from GBLUP (predictive ability)", "",
  "Rule fixed in advance: a difference counts only if |mean| >= 0.02 and at least five-sixths of fold sets (5 of 6 in the full run) agree in sign.", "",
  md_table(vs), "",
  "## Hypotheses", "", paste("- H1 (markers beat pedigree):", h1), paste("- H2 (Bayesian models ~ GBLUP):", h2), "",
  "## Time per fit on this computer", "", md_table(timing[, c("model", "seconds_per_fit")], digits = 2), "")
if (QUICK) report <- c(report, sprintf(
  "**Projected full run** (6 fold sets, 12,000 iterations, %d workers): about %.0f minutes.", WORKERS, proj_min))
writeLines(report, sprintf("results/%s_single_env.md", TAG))
cat(paste(report, collapse = "\n"), "\n")
