"""Small shared helpers. Replace or extend for each project."""

from __future__ import annotations

import pandas as pd


def load_table(path: str) -> pd.DataFrame:
    """Read a tab- or comma-separated table, choosing the separator from the extension."""
    sep = "\t" if str(path).endswith((".tsv", ".txt")) else ","
    return pd.read_csv(path, sep=sep)


def pearson_accuracy(observed, predicted) -> float:
    """Prediction accuracy as the Pearson correlation between observed and predicted values."""
    obs = pd.Series(observed, dtype=float)
    pred = pd.Series(predicted, dtype=float)
    if len(obs) != len(pred):
        raise ValueError("observed and predicted must have the same length")
    return float(obs.corr(pred))
