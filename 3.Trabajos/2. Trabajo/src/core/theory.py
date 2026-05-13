"""
Fórmulas analíticas para el modelo M/M/k/k (Erlang B).

Funciones:
- erlang_b(lam, mu, k) -> P_blocking (Erlang B)
- mmkk_stationary_probs(lam, mu, k) -> array Pn (n = 0..k)
- mmkk_mean_wait(lam, mu, k) -> (W, Wq) donde Wq = 0 por definición (no hay cola)

Referencias: Fórmula clásica de Erlang B.
"""
from __future__ import annotations
from typing import Tuple
import math
import numpy as np


def _power_div_factorial(A: float, n: int) -> float:
    # cálculo estable de A^n / n! (usa lgamma para evitar overflow si es necesario)
    try:
        return math.exp(n * math.log(A) - math.lgamma(n + 1))
    except Exception:
        # fallback (menos estable)
        return (A ** n) / math.factorial(n)


def erlang_b(lam: float, mu: float, k: int) -> float:
    """
    Probabilidad de bloqueo (Erlang B) para M/M/k/k.
    A = lam / mu (tráfico ofrecido en Erlangs)
    B(k,A) = (A^k / k!) / sum_{n=0}^k (A^n / n!)
    """
    if k < 0:
        raise ValueError("k debe ser >= 0")
    if mu <= 0 or lam < 0:
        raise ValueError("lam >= 0 y mu > 0")

    A = lam / mu if mu != 0 else float('inf')

    # calcular denominador de forma estable
    terms = [_power_div_factorial(A, n) for n in range(0, k + 1)]
    denom = float(sum(terms))
    numer = float(terms[-1])
    if denom == 0.0:
        return float('nan')
    return numer / denom


def mmkk_stationary_probs(lam: float, mu: float, k: int) -> np.ndarray:
    """
    Retorna P_n (n=0..k) para M/M/k/k usando la forma P_n = (A^n / n!) / sum_{j=0}^k (A^j / j!).
    """
    if k < 0:
        raise ValueError("k debe ser >= 0")
    A = lam / mu if mu != 0 else float('inf')
    terms = [_power_div_factorial(A, n) for n in range(0, k + 1)]
    denom = float(sum(terms))
    if denom == 0.0:
        raise ArithmeticError("Denominador numérico igual a cero al calcular Pn")
    Pn = np.array([t / denom for t in terms], dtype=float)
    return Pn


def mmkk_mean_wait(lam: float, mu: float, k: int) -> Tuple[float, float]:
    """
    Para M/M/k/k no hay cola: Wq = 0.
    Calculamos W = L / lambda_eff, donde L = E[N] = sum n P_n y lambda_eff = lam * (1 - P_k).
    Si lambda_eff == 0 devolvemos (inf, 0).
    """
    Pn = mmkk_stationary_probs(lam, mu, k)
    n = np.arange(0, k + 1)
    L = float(np.sum(n * Pn))
    Pk = float(Pn[-1])
    lambda_eff = lam * (1.0 - Pk)
    if lambda_eff <= 0.0:
        return float('inf'), 0.0
    W = L / lambda_eff
    Wq = 0.0
    return W, Wq
