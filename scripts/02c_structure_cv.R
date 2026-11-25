# Step 2c. Does accuracy hold when predicting across the two genetic groups? (assumption A7)
#   Input:  markers (to find the groups), yield, pedigree and marker relationship matrices
#   Process: k-means (k = 2) on the first 5 marker principal components defines two groups.
#            Across-group CV: train on one group, predict the other (and vice versa).
#            Control: random 2-fold CV with the same training-set sizes, 10 times, so the only
#            difference from the across-group CV is WHICH lines are in training, not how many.
#   Output: results/02c_structure.md and .csv, results/figures/02c_groups_pca.png
# Usage:  Rscript scripts/02c_structure_cv.R

source("R/functions.R")
suppressPackageStartupMessages(library(ggplot2))

d <- load_wheat()
Y <- d$Y; A <- d$A; G <- make_G(d$X)

pca <- prcomp(d$X, center = TRUE, scale. = TRUE)
set.seed(1)
groups <- kmeans(pca$x[, 1:5], centers = 2, nstart = 25)$cluster
sizes <- table(groups)

models <- list(pedigree_blup = function(y) fit_kernel_blup(y, A),
               gblup         = function(y) fit_kernel_blup(y, G))

# Random control folds with exactly the group sizes
control_folds <- function(seed) {
  set.seed(seed)
  f <- rep(2L, length(groups))
  f[sample(length(groups), sizes[["1"]])] <- 1L
  f
}

rows <- list()
for (env in colnames(Y)) for (m in names(models)) {
  across <- cor(Y[, env], predict_cv(Y[, env], groups, models[[m]]))
  ctrl <- vapply(1:10, function(s) cor(Y[, env], predict_cv(Y[, env], control_folds(s), models[[m]])), 0)
  rows[[length(rows) + 1]] <- data.frame(env = env, model = m, r_across_groups = across,
                                         r_random_same_size = mean(ctrl), r_random_sd = sd(ctrl),
                                         drop = mean(ctrl) - across)
}
res <- do.call(rbind, rows)
write.csv(res, "results/02c_structure.csv", row.names = FALSE)

p <- ggplot(data.frame(PC1 = pca$x[, 1], PC2 = pca$x[, 2], group = factor(groups)),
            aes(PC1, PC2, colour = group)) + geom_point(size = 1.3, alpha = 0.8) +
  labs(title = sprintf("Two genetic groups (k-means, 5 PCs): %d and %d lines",
                       sizes[["1"]], sizes[["2"]])) + theme_minimal()
ggsave("results/figures/02c_groups_pca.png", p, width = 6, height = 4.5, dpi = 150)

report <- c("# Step 2c: prediction across genetic groups", "",
  sprintf("Groups from k-means (k = 2) on the first 5 marker principal components: %d and %d lines.",
          sizes[["1"]], sizes[["2"]]),
  "`r_across_groups`: train on one group, predict the other. `r_random_same_size`: random splits of the same sizes (mean of 10).",
  "`drop` = how much accuracy is lost when training and test lines come from different groups.", "",
  md_table(res), "",
  sprintf("Mean drop across environments: GBLUP %.3f, pedigree BLUP %.3f.",
          mean(res$drop[res$model == "gblup"]), mean(res$drop[res$model == "pedigree_blup"])))
writeLines(report, "results/02c_structure.md")
cat(paste(report, collapse = "\n"), "\n")
