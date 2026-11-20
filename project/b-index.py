"""B-index of R&D tax subsidies by country and year.

1. Read the OECD R&D implied tax incentives table (CSV, from GitHub).
2. B-index = 1 - implied tax subsidy rate, for SMEs (PME) under the loss (L) scenario.
3. Shows the graph of the series of FR, DE, CN (CN_X_HK) and US.

Requires pandas and matplotlib.

Evens Salies, 11/2026, v1.
"""

import math

import matplotlib.pyplot as plt
import pandas as pd
from matplotlib.ticker import FuncFormatter

# Jost is used when it is installed; otherwise matplotlib falls back to DejaVu Sans.
plt.rcParams["font.family"] = ["Jost", "DejaVu Sans"]

# OECD table of implied tax subsidy rates, 2000-2025 (CSV, on the feat/bindex-oecd-graph branch)
OECD_CSV = "https://raw.githubusercontent.com/evenssalies/R-D-Scoreboard/feat/bindex-oecd-graph/datasets/OECD.STI.STP%2CDSD_RDTAX%40DF_RDSUB%2C1.0%2Ccomplete%2C2026-11-20%2015-19-26.csv"

# OECD area code -> alpha-2 code used in the graphs (CHN is taken as China excluding Hong Kong)
SAMPLE_AREAS = {"FRA": "FR", "DEU": "DE", "CHN": "CN_X_HK", "USA": "US"}

# Country codes -> names in the legend of the BI_L_PME graph
COUNTRY_NAMES = {
    "FR": "France",
    "DE": "Allemagne",
    "CN_X_HK": "Chine (hors HK)",
    "US": "\u00c9tats-Unis",
}

# Country codes -> line colours of the BI_L_PME graph
COUNTRY_COLORS = {
    "FR": "darkblue",
    "DE": "black",
    "CN_X_HK": "darkgoldenrod",
    "US": "brown",
}


def build_sample(csv_file=OECD_CSV):
    """BI_L_PME for SMEs with loss-making profits, the four countries of the graphs, 2000-2025."""
    raw = pd.read_csv(csv_file)
    rows = raw[
        raw["REF_AREA"].isin(SAMPLE_AREAS)
        & (raw["SIZE"] == "SME")
        & (raw["PROFIT_SCENARIO"] == "LOSS_MAKING")
        & raw["TIME_PERIOD"].between(2000, 2025)
    ]
    sample = pd.DataFrame({
        "alpha2": rows["REF_AREA"].map(SAMPLE_AREAS),
        "YEAR": rows["TIME_PERIOD"],
        "BI_L_PME": 1 - rows["OBS_VALUE"],  # B-index = 1 - implied tax subsidy rate
    })
    return sample.sort_values(["alpha2", "YEAR"]).reset_index(drop=True)


def plot_bi_l_pme(bindex, countries=("FR", "DE", "CN_X_HK", "US")):
    """BI_L_PME alone (SMEs, loss scenario), one line per country, over time."""
    fig, ax = plt.subplots(figsize=(9, 5))
    for code in countries:
        series = bindex[bindex["alpha2"] == code].sort_values("YEAR")
        (line,) = ax.plot(series["YEAR"], series["BI_L_PME"], marker="o", markersize=3, color=COUNTRY_COLORS[code])
        last = series.iloc[-1]
        # Name written at the end of its line, in capitals (small caps are not available in matplotlib).
        ax.annotate(
            COUNTRY_NAMES[code].upper(),
            xy=(last["YEAR"], last["BI_L_PME"]),
            xytext=(6, 0),
            textcoords="offset points",
            va="center",
            fontsize=8,
            color=line.get_color(),
        )
    ax.set_title("Coût d'un euro dépensé à la R&D net de la fiscalité, 2000-2025")
    ax.set_xlabel("")
    ax.set_ylabel("Coût (€)")
    ax.set_xticks(range(2000, 2026, 5))
    ax.tick_params(length=0)  # no tick marks, labels only
    # French decimal comma, with as many decimals as the tick step needs
    ticks = ax.get_yticks()
    decimals = max(0, -math.floor(math.log10(ticks[1] - ticks[0])))
    ax.yaxis.set_major_formatter(FuncFormatter(lambda v, _: f"{v:.{decimals}f}".replace(".", ",")))
    ax.grid(alpha=0.3)
    for spine in ax.spines.values():
        spine.set_visible(False)  # no frame, so the names at the right edge do not cross a line
    fig.text(0.01, 0.01, "Coût pour une PME qui viendrait s'installe en France et ne dégagerait pas de chiffre d'affaires.", fontsize=8, ha="left", va="bottom")
    fig.tight_layout(rect=(0, 0.05, 1, 1))  # room for the footnote and the names at the right edge
    plt.show()


if __name__ == "__main__":
    sample = build_sample()
    print(sample.shape)
    plot_bi_l_pme(sample)
