"""
Funciones de validación estadística: QQ-plot contra exponencial y histograma con ajuste.

- qq_plot_exponential(data, rate, ax=None, savepath=None)
- histogram_with_exponential(data, rate, bins=50, ax=None, savepath=None)

Ambas funciones devuelven la figura (matplotlib.figure.Figure) si se desea further programmatic usage.
"""
from __future__ import annotations
from typing import Optional, Tuple
import numpy as np
import matplotlib.pyplot as plt
from scipy import stats


def qq_plot_exponential(data: np.ndarray, rate: float, ax: Optional[plt.Axes] = None, savepath: Optional[str] = None) -> plt.Figure:
    """
    Genera un QQ-plot contra la distribución exponencial con tasa `rate`.

    data: arreglo de observaciones (tiempos entre eventos, tiempos de servicio, etc.)
    rate: lambda de la exponencial (tasa)
    """
    data = np.asarray(data, dtype=float)
    data = data[~np.isnan(data)]
    data = data[data >= 0]
    n = data.size

    if n == 0:
        raise ValueError("data vacío o sin valores válidos")

    if ax is None:
        fig, ax = plt.subplots(figsize=(6, 6))
    else:
        fig = ax.figure

    # quantiles teóricos para la exponencial
    # q_i = (i - 0.5)/n
    probs = (np.arange(1, n + 1) - 0.5) / float(n)
    theoretical_q = -np.log(1.0 - probs) / rate
    sample_q = np.sort(data)

    ax.scatter(theoretical_q, sample_q, s=8, alpha=0.7)
    # línea referencia y=x
    mx = max(theoretical_q.max(), sample_q.max())
    ax.plot([0, mx], [0, mx], color="C1", linestyle="--")
    ax.set_xlabel("Cuantiles teóricos (Exponencial)")
    ax.set_ylabel("Cuantiles muestrales")
    ax.set_title("QQ-plot vs Exponencial (rate={:.3f})".format(rate))

    if savepath:
        fig.savefig(savepath, dpi=150, bbox_inches="tight")

    return fig


def histogram_with_exponential(data: np.ndarray, rate: float, bins: int = 50, ax: Optional[plt.Axes] = None, savepath: Optional[str] = None) -> plt.Figure:
    """
    Histograma de datos con la densidad teórica de la exponencial overlay.
    """
    data = np.asarray(data, dtype=float)
    data = data[~np.isnan(data)]
    data = data[data >= 0]
    n = data.size
    if n == 0:
        raise ValueError("data vacío o sin valores válidos")

    if ax is None:
        fig, ax = plt.subplots(figsize=(7, 4))
    else:
        fig = ax.figure

    counts, bins_edges, _ = ax.hist(data, bins=bins, density=True, alpha=0.6, label="Empírico")

    # densidad exponencial
    xs = np.linspace(0, bins_edges[-1], 200)
    pdf = rate * np.exp(-rate * xs)
    ax.plot(xs, pdf, color="C1", lw=2, label=f"Exponencial(rate={rate:.3f})")

    ax.set_xlabel("Valor")
    ax.set_ylabel("Densidad")
    ax.set_title("Histograma y densidad exponencial")
    ax.legend()

    if savepath:
        fig.savefig(savepath, dpi=150, bbox_inches="tight")

    return fig
