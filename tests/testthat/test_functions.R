root <- normalizePath(file.path(testthat::test_path(), "..", ".."))
source(file.path(root, "R", "functions.R"))

test_that("wheat data load with the expected shape and environment labels", {
  d <- load_wheat()
  expect_equal(dim(d$Y), c(599, 4))
  expect_equal(colnames(d$Y), c("E1", "E2", "E3", "E4"))
  expect_equal(dim(d$X), c(599, 1279))
  expect_equal(dim(d$A), c(599, 599))
  expect_length(d$sets, 599)
  expect_false(anyNA(d$Y))
})

test_that("folds are reproducible, complete and balanced", {
  f1 <- make_folds(599, 10, seed = 7)
  expect_identical(f1, make_folds(599, 10, seed = 7))
  expect_length(f1, 599)
  expect_setequal(unique(f1), 1:10)
  expect_lte(diff(range(table(f1))), 1)
})

test_that("G is symmetric with an average self-relationship of about 1", {
  set.seed(1)
  X <- matrix(rbinom(50 * 200, 1, 0.4), 50, 200)
  G <- make_G(X)
  expect_equal(G, t(G))
  expect_equal(mean(diag(G)), 1, tolerance = 0.05)
})

test_that("cross-validation returns one out-of-fold prediction per line", {
  set.seed(2)
  y <- rnorm(40)
  pred <- predict_cv(y, make_folds(40, 5, 1), function(yt) rep(mean(yt, na.rm = TRUE), length(yt)))
  expect_length(pred, 40)
  expect_false(anyNA(pred))
})

test_that("marker ridge BLUP and GBLUP give the same predictions", {
  d <- load_wheat()
  X <- d$X[1:200, 1:400]
  y <- d$Y[1:200, "E1"]
  y[1:20] <- NA
  Xs <- scale(X[, apply(X, 2, sd) > 0])
  p_ridge <- fit_ridge_blup(y, Xs)
  p_gblup <- fit_kernel_blup(y, tcrossprod(Xs) / ncol(Xs))
  expect_gt(cor(p_ridge[1:20], p_gblup[1:20]), 0.9999)
})

test_that("genomic heritability lies between 0 and 1", {
  d <- load_wheat()
  h2 <- reml_h2(d$Y[, "E1"], make_G(d$X))
  expect_gt(h2, 0)
  expect_lt(h2, 1)
})

# ---------------------------------------------------------------- Week 2 helpers
test_that("Gaussian kernel is symmetric with ones on the diagonal", {
  set.seed(3)
  X <- matrix(rbinom(30 * 80, 1, 0.5), 30, 80)
  K <- gaussian_kernel(X)
  expect_equal(K, t(K))
  expect_equal(unname(diag(K)), rep(1, 30))
  expect_true(all(K > 0 & K <= 1))
})

test_that("top-20% overlap is 1 for a perfect ranking and 0 for a reversed one", {
  obs <- 1:50
  expect_equal(top_overlap(obs, obs), 1)
  expect_equal(top_overlap(obs, -obs), 0)
})

test_that("cv_metrics returns the four metrics", {
  m <- cv_metrics(1:20, (1:20) + rnorm(20, sd = 0.1))
  expect_named(m, c("pearson", "spearman", "top20", "mse"))
  expect_gt(m$pearson, 0.99)
})

test_that("paired verdict follows the rule fixed in the plan", {
  expect_equal(paired_verdict(rep(0.03, 6)), "better")
  expect_equal(paired_verdict(rep(-0.03, 6)), "worse")
  expect_equal(paired_verdict(rep(0.01, 6)), "no meaningful difference")             # too small
  expect_equal(paired_verdict(c(0.08, 0.08, 0.08, -0.01, -0.01, -0.01)), "no meaningful difference")  # inconsistent
})

test_that("effective sample size is near n for independent draws and small for a sticky chain", {
  set.seed(4)
  expect_gt(ess(rnorm(2000)), 1500)
  expect_lt(ess(cumsum(rnorm(2000))), 100)
})

test_that("command-line flags are parsed", {
  a <- c("--quick", "--reps=3", "--iter=600")
  expect_true(get_flag(a, "quick", FALSE))
  expect_equal(get_flag(a, "reps", 5), 3)
  expect_equal(get_flag(a, "iter", 12000), 600)
  expect_equal(get_flag(a, "workers", 4), 4)
})
