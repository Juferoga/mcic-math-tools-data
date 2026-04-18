"""
Teoremas analíticos y fórmulas cerradas para colas M/M/1 y M/M/1/K.

Funciones:
- mm1_waiting_time_theoretical(lam, mu) -> Wq (tiempo medio de espera en cola) para M/M/1 infinito.
- mm1k_stationary_probs(lam, mu, K) -> array Pn (probabilidades estacionarias n=0..K)
- mm1k_blocking_probability(lam, mu, K) -> P_K
- mm1k_mean_wait(lam, mu, K) -> (W, Wq) tiempos medios (sistema, cola) condicionados a clientes aceptados

Notas:
- Maneja el caso rho == 1 numéricamente.
- Para K finito, usamos la distribución estacionaria clásica.
"""
from __future__ import annotations
from typing import Tuple
import numpy as np


def mm1_waiting_time_theoretical(lam: float, mu: float) -> float:
    """
    Tiempo medio de espera en cola (Wq) para M/M/1 (cola infinita) bajo estabilidad rho < 1.
    Si rho >= 1 devuelve np.inf (sistema inestable, tiempo medio diverge).
    """
    if lam <= 0 or mu <= 0:
        raise ValueError("lam y mu deben ser positivos")
    rho = lam / mu
    if rho >= 1.0:
        return float('inf')
    # Wq = rho / (mu - lam)
    return rho / (mu - lam)


def mm1k_stationary_probs(lam: float, mu: float, K: int) -> np.ndarray:
    """
    Calcula las probabilidades estacionarias P_n (n = 0..K) para un proceso M/M/1/K.
    Retorna un array de tamaño K+1 con P_0..P_K.
    """
    if K < 0:
        raise ValueError("K debe ser >= 0")
    if lam < 0 or mu <= 0:
        raise ValueError("lam debe ser >=0 y mu > 0")

    rho = lam / mu
    n = np.arange(0, K + 1)

    if abs(rho - 1.0) < 1e-12:
        # caso rho == 1: P_n = 1/(K+1)
        return np.ones(K + 1, dtype=float) / float(K + 1)

    # caso general
    # P0 = (1 - rho) / (1 - rho^(K+1)) for rho != 1
    denom = 1.0 - rho ** (K + 1)
    if denom == 0.0:
        # numéricamente inestable; fallback
        raise ArithmeticError("Denominador numérico igual a cero al calcular P0")
    P0 = (1.0 - rho) / denom
    Pn = P0 * (rho ** n)
    return Pn


def mm1k_blocking_probability(lam: float, mu: float, K: int) -> float:
    """
    Probabilidad de bloqueo P_K (es decir, probabilidad estacionaria de que el sistema tenga K clientes).
    """
    Pn = mm1k_stationary_probs(lam, mu, K)
    return float(Pn[-1])


def mm1k_mean_wait(lam: float, mu: float, K: int) -> Tuple[float, float]:
    """
    Calcula el tiempo medio en sistema (W) y tiempo medio en cola (Wq) para M/M/1/K
    teniendo en cuenta que algunas llegadas son bloqueadas.

    W = L / lambda_eff, donde L = E[N] = sum_{n=0}^K n P_n y lambda_eff = lam * (1 - P_K)
    Wq = W - 1/mu (tiempo medio en cola excluyendo servicio)
    """
    Pn = mm1k_stationary_probs(lam, mu, K)
    n = np.arange(0, K + 1)
    L = float(np.sum(n * Pn))
    Pk = float(Pn[-1])
    lambda_eff = lam * (1.0 - Pk)
    if lambda_eff <= 0.0:
        return float('inf'), float('inf')

    W = L / lambda_eff
    Wq = W - 1.0 / mu
    return W, Wq
