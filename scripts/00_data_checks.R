# Step 0. Check and explore the data before any modelling.
#   Input:  BGLR's wheat data (yield, markers, pedigree matrix, published folds)
#   Output: results/00_data_checks.md and four figures in results/figures/
# Run from the repo folder:  Rscript scripts/00_data_checks.R

source("R/functions.R")
suppressPackageStartupMessages(library(ggplot2))
dir.create("results/figures", recursive = TRUE, showWarnings = FALSE)

d <- load_wheat()
Y <- d$Y; X <- d$X; A <- d$A
G <- make_G(X)
report <- c("# Step 0: data checks", "",
            sprintf("Generated %s with BGLR %s and rrBLUP %s.", format(Sys.time(), "%Y-%m-%d"),
                    packageVersion("BGLR"), packageVersion("rrBLUP")), "")

# ---- 1. Dimensions and missing values (assumption A11)
report <- c(report, "## 1. Dimensions and missing values", "",
  md_table(data.frame(
    object  = c("Y (yield)", "X (markers)", "A (pedigree)", "sets (folds)"),
    rows    = c(nrow(Y), nrow(X), nrow(A), length(d$sets)),
    columns = c(ncol(Y), ncol(X), ncol(A), 1),
    missing = c(sum(is.na(Y)), sum(is.na(X)), sum(is.na(A)), sum(is.na(d$sets)))
  ), digits = 0), "")

# ---- 2. Is yield already standardized? (assumption A2)
stats <- data.frame(env = colnames(Y), mean = colMeans(Y), variance = apply(Y, 2, var),
                    min = apply(Y, 2, min), max = apply(Y, 2, max))
report <- c(report, "## 2. Yield per environment", "",
  "Mean 0 and variance 1 mean the yields are already standardized within environment, as in Crossa et al. (2010).", "",
  md_table(stats), "")

# ---- 3. Published fold partition
report <- c(report, "## 3. Published cross-validation partition (`wheat.sets`)", "",
  md_table(as.data.frame(table(fold = d$sets), responseName = "lines"), digits = 0), "")

# ---- 4. Phenotypic correlations between environments
pc <- cor(Y)
report <- c(report, "## 4. Phenotypic correlations between environments", "",
  md_table(data.frame(env = rownames(pc), round(pc, 3), check.names = FALSE)), "")
pc_long <- as.data.frame(as.table(pc))
p1 <- ggplot(pc_long, aes(Var1, Var2, fill = Freq)) + geom_tile(colour = "white") +
  geom_text(aes(label = sprintf("%.2f", Freq))) +
  scale_fill_gradient2(limits = c(-1, 1), low = "#b2182b", mid = "white", high = "#2166ac") +
  labs(x = NULL, y = NULL, fill = "r", title = "Phenotypic correlation of yield between environments") +
  theme_minimal()
ggsave("results/figures/00_env_correlation.png", p1, width = 5, height = 4, dpi = 150)

# ---- 5. Markers: coding and allele frequencies (assumptions A4, A5)
p_freq <- colMeans(X)
maf <- pmin(p_freq, 1 - p_freq)
report <- c(report, "## 5. Markers", "",
  sprintf("- Values present: %s", paste(sort(unique(as.vector(X))), collapse = ", ")),
  sprintf("- Minor allele frequency: min %.3f, median %.3f; markers with MAF < 0.05: %d",
          min(maf), median(maf), sum(maf < 0.05)), "")
p2 <- ggplot(data.frame(maf), aes(maf)) + geom_histogram(bins = 40, fill = "grey40") +
  labs(x = "minor allele frequency", y = "markers", title = "Allele frequencies of 1,279 DArT markers") +
  theme_minimal()
ggsave("results/figures/00_allele_freq.png", p2, width = 5, height = 3.5, dpi = 150)

# ---- 6. Population structure: principal components of the markers (assumption A7)
pca <- prcomp(X, center = TRUE, scale. = TRUE)
ve <- 100 * pca$sdev^2 / sum(pca$sdev^2)
report <- c(report, "## 6. Population structure", "",
  sprintf("Variance explained by marker PCs 1-5: %s %%", paste(sprintf("%.1f", ve[1:5]), collapse = ", ")), "")
p3 <- ggplot(data.frame(PC1 = pca$x[, 1], PC2 = pca$x[, 2], E1 = Y[, "E1"]), aes(PC1, PC2, colour = E1)) +
  geom_point(size = 1.4) + scale_colour_gradient2(low = "#b2182b", mid = "grey85", high = "#2166ac") +
  labs(x = sprintf("PC1 (%.1f%%)", ve[1]), y = sprintf("PC2 (%.1f%%)", ve[2]), colour = "yield E1",
       title = "Marker principal components, coloured by E1 yield") + theme_minimal()
ggsave("results/figures/00_marker_pca.png", p3, width = 5.5, height = 4.5, dpi = 150)

# ---- 7. Pedigree (A) vs markers (G) (assumption A6)
off <- upper.tri(G)
report <- c(report, "## 7. Pedigree vs. marker relationships", "",
  sprintf("- Mean diagonal: A = %.2f, G = %.2f (A is about 2 because inbred lines have inbreeding near 1)",
          mean(diag(A)), mean(diag(G))),
  sprintf("- Correlation of off-diagonal relationships, A vs. G: %.3f", cor(A[off], G[off])), "")
set.seed(1)
idx <- sample(which(off), 20000)
p4 <- ggplot(data.frame(A = A[idx], G = G[idx]), aes(A, G)) + geom_point(alpha = 0.15, size = 0.6) +
  labs(title = "Pedigree A vs. markers G (20,000 random pairs)") + theme_minimal()
ggsave("results/figures/00_A_vs_G.png", p4, width = 5.5, height = 4.5, dpi = 150)

# ---- 8. Preview: genomic and pedigree heritability per environment (full data, REML)
h2 <- data.frame(env = colnames(Y),
                 h2_markers  = sapply(colnames(Y), function(e) reml_h2(Y[, e], G)),
                 h2_pedigree = sapply(colnames(Y), function(e) reml_h2(Y[, e], A)))
h2$ceiling_r <- sqrt(h2$h2_markers)
report <- c(report, "## 8. Heritability preview (REML, all lines)", "",
  "`ceiling_r` = square root of genomic heritability: roughly the best predictive ability markers could reach.", "",
  md_table(h2), "")

writeLines(report, "results/00_data_checks.md")
cat(paste(report, collapse = "\n"), "\n")
