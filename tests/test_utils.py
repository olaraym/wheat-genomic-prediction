from pathlib import Path
import sys

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))
from utils import load_table, pearson_accuracy  # noqa: E402

TOY = Path(__file__).resolve().parents[1] / "data" / "toy" / "toy_phenotypes.csv"


def test_toy_data_loads():
    df = load_table(TOY)
    assert {"line", "observed", "predicted"} <= set(df.columns)
    assert len(df) == 6


def test_perfect_prediction_has_accuracy_one():
    assert pearson_accuracy([1, 2, 3], [2, 4, 6]) == pytest.approx(1.0)


def test_accuracy_on_toy_data_is_bounded():
    df = load_table(TOY)
    acc = pearson_accuracy(df["observed"], df["predicted"])
    assert -1.0 <= acc <= 1.0


def test_length_mismatch_raises():
    with pytest.raises(ValueError):
        pearson_accuracy([1, 2], [1, 2, 3])
