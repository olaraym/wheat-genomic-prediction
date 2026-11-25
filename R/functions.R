# Shared functions for P1 (wheat genomic prediction).
# Every script starts with: source("R/functions.R")

suppressPackageStartupMessages({
  library(BGLR)
  library(rrBLUP)
})

# BGLR stores the four mega-environments as columns "1", "2", "4", "5".
# They are relabelled E1-E4 in that order, the order used by Crossa et al. (2010).
# Reproducing their per-environment accuracies (Step 1) confirms the mapping.
ENV_LABELS <- c("1" = "E1", "2" = "E2", "4" = "E3", "5" = "E4")

# Published predictive abilities, Crossa et al. (2010) Genetics 186:713-724, Table 3.
CROSSA_2010 <- data.frame(
  model = rep(c("pedigree_blup", "marker_blup"), each = 4),
  env   = rep(c("E1", "E2", "E3", "E4"), 2),
  r     = c(0.448, 0.417, 0.417, 0.449,
            0.480, 0.488, 0.355, 0.464)
)

#' Load the CIMMYT wheat data shipped with BGLR.
#' Returns Y (599 x 4 yield, columns E1-E4), X (599 x 1279 DArT 0/1),
#' A (599 x 599 pedigree relationship matrix) and sets (published 10-fold partition).
load_wheat <- function() {
  e <- new.env()
  data("wheat", package = "BGLR", envir = e)
  Y <- e$wheat.Y
  colnames(Y) <- unname(ENV_LABELS[colnames(Y)])
  list(Y = Y, X = e$wheat.X, A = e$wheat.A, sets = as.integer(e$wheat.sets))
}

#' Genomic relationship matrix: markers centred and scaled, G = Xs Xs' / p,
#' so the average self-relationship is about 1 (the convention in BGLR examples).
make_G <- function(X) {
  keep <- apply(X, 2, sd) > 0
  Xs <- scale(X[, keep, drop = FALSE])
  tcrossprod(Xs) / ncol(Xs)
}

#' Random k-fold assignment, reproducible from a seed. Fold sizes differ by at most one.
make_folds <- function(n, k = 10, seed = 1) {
  set.seed(seed)
  sample(rep(seq_len(k), length.out = n))
}

#' Out-of-fold predictions: for each fold, hide its phenotypes (NA), fit on the rest,
#' and keep the predictions for the hidden lines. fit_fun(y_with_NA) must return
#' predictions for all n lines.
predict_cv <- function(y, folds, fit_fun) {
  out <- rep(NA_real_, length(y))
  for (f in sort(unique(folds))) {
    test <- folds == f
    y_train <- y
    y_train[test] <- NA
    out[test] <- fit_fun(y_train)[test]
  }
  out
}

# ---------------------------------------------------------------- model fits
# Each returns predictions (intercept + genetic value) for all lines, including
# those whose phenotype is NA. rrBLUP::mixed.solve drops NA records when fitting.

#' Kernel BLUP by REML: GBLUP with K = G, pedigree BLUP with K = A.
fit_kernel_blup <- function(y_train, K) {
  m <- mixed.solve(y_train, K = K)
  as.numeric(m$beta) + as.numeric(m$u)
}

#' Marker ridge-regression BLUP: one shrunken effect per marker (equivalent to GBLUP).
fit_ridge_blup <- function(y_train, Xs) {
  m <- mixed.solve(y_train, Z = Xs)
  as.numeric(m$beta) + as.numeric(Xs %*% m$u)
}

#' Any BGLR model (BayesB, BL, RKHS, combinations). ETA is a BGLR linear-predictor list.
fit_bglr <- function(y_train, ETA, nIter = 12000, burnIn = 2000) {
  out_dir <- tempfile("bglr_")
  dir.create(out_dir)
  on.exit(unlink(out_dir, recursive = TRUE), add = TRUE)
  fm <- BGLR(y = y_train, ETA = ETA, nIter = nIter, burnIn = burnIn,
             verbose = FALSE, saveAt = file.path(out_dir, ""))
  as.numeric(fm$yHat)
}

#' Genomic heritability on the line-mean scale from a REML fit with kernel K.
#' Vu is multiplied by the mean diagonal of K so the estimate does not depend on K's scale.
reml_h2 <- function(y, K) {
  m <- mixed.solve(y, K = K)
  vg <- m$Vu * mean(diag(K))
  vg / (vg + m$Ve)
}

#' Write a data frame as a Markdown table (no extra packages needed).
md_table <- function(df, digits = 3) {
  fmt <- function(x) if (is.numeric(x)) formatC(x, format = "f", digits = digits) else as.character(x)
  body <- vapply(seq_len(nrow(df)), function(i)
    paste0("| ", paste(vapply(df[i, , drop = FALSE], fmt, ""), collapse = " | "), " |"), "")
  c(paste0("| ", paste(names(df), collapse = " | "), " |"),
    paste0("|", paste(rep(" --- |", ncol(df)), collapse = "")),
    body)
}

# ---------------------------------------------------------------- Week 2 additions

#' Gaussian kernel on markers for RKHS regression: K = exp(-h * D / mean(D)),
#' where D holds squared Euclidean distances between lines' standardized marker profiles.
#' h = 1 is a common default; larger h makes similarity fall off faster with distance.
gaussian_kernel <- function(X, h = 1) {
  keep <- apply(X, 2, sd) > 0
  Xs <- scale(X[, keep, drop = FALSE])
  D <- as.matrix(dist(Xs))^2
  exp(-h * D / mean(D))
}

#' Share of the truly top `frac` lines (by observed value) that the model also ranks in its top `frac`.
top_overlap <- function(observed, predicted, frac = 0.2) {
  k <- ceiling(frac * length(observed))
  length(intersect(order(-observed)[seq_len(k)], order(-predicted)[seq_len(k)])) / k
}

#' All Week 2 metrics for one set of out-of-fold predictions.
cv_metrics <- function(observed, predicted) {
  data.frame(pearson  = cor(observed, predicted),
             spearman = cor(observed, predicted, method = "spearman"),
             top20    = top_overlap(observed, predicted, 0.2),
             mse      = mean((observed - predicted)^2))
}

#' Paired verdict for one model vs. a reference across replicates, using the rule fixed in the plan:
#' a difference counts only if its mean is at least `threshold` AND at least `min_agree` of the
#' replicates point the same way.
paired_verdict <- function(diffs, threshold = 0.02, min_agree = 5 / 6) {
  m <- mean(diffs)
  agree <- mean(sign(diffs) == sign(m))
  if (abs(m) >= threshold && agree >= min_agree) {
    if (m > 0) "better" else "worse"
  } else {
    "no meaningful difference"
  }
}

#' Simple effective sample size of an MCMC chain: n / (1 + 2 * sum of autocorrelations),
#' summing lags until the autocorrelation drops below 0.05.
ess <- function(x) {
  x <- as.numeric(x)
  if (length(x) < 10 || var(x) == 0) return(NA_real_)
  ac <- acf(x, lag.max = min(length(x) - 1, 1000), plot = FALSE)$acf[-1]
  s <- 0
  for (r in ac) {
    if (r < 0.05) break
    s <- s + r
  }
  length(x) / (1 + 2 * s)
}

#' Read simple command-line flags such as --quick, --reps=5, --iter=12000, --workers=8.
get_flag <- function(args, name, default) {
  hit <- grep(paste0("^--", name, "(=|$)"), args, value = TRUE)
  if (!length(hit)) return(default)
  if (!grepl("=", hit[1])) return(TRUE)
  val <- sub(paste0("^--", name, "="), "", hit[1])
  if (is.numeric(default)) as.numeric(val) else val
}
