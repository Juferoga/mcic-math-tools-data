# simulacion_memoria_exponencial.py
# Autor: Juan Felipe Rodríguez G. (20261595004)
# Curso: Herramientas Matemáticas para el Manejo de la Información
# Tarea 7: Propiedad sin memoria (distribución exponencial)
#
# Ejecutar:
#   python3 simulacion_memoria_exponencial.py
#
# Nota:
# - Este script es opcional y sirve como comprobación empírica (Monte Carlo)
#   de que P(T>s+t | T>s) ≈ P(T>t) cuando T ~ Exp(lambda).

import random
import math


def estimar_probabilidades(lmbda: float, s: float, t: float, n: int = 200000):
    """Estima P(T>s+t | T>s) y P(T>t) para T~Exp(lambda)."""
    count_gt_s = 0
    count_gt_s_and_gt_s_plus_t = 0
    count_gt_t = 0

    for _ in range(n):
        # random.expovariate(lmbda) genera una Exp(lambda)
        T = random.expovariate(lmbda)

        if T > s:
            count_gt_s += 1
            if T > s + t:
                count_gt_s_and_gt_s_plus_t += 1

        if T > t:
            count_gt_t += 1

    p_cond = count_gt_s_and_gt_s_plus_t / count_gt_s
    p_tail = count_gt_t / n

    # Valor teórico: P(T>t)=exp(-lambda*t)
    p_teo = math.exp(-lmbda * t)

    return p_cond, p_tail, p_teo


def main():
    lmbda = 2.0
    s = 1.5
    t = 0.75
    n = 200000

    p_cond, p_tail, p_teo = estimar_probabilidades(lmbda, s, t, n=n)

    print("=== Exponencial sin memoria (simulación) ===")
    print(f"Simulaciones: {n}")
    print(f"lambda = {lmbda}, s = {s}, t = {t}")
    print(f"Estimado  P(T>s+t | T>s) = {p_cond:.5f}")
    print(f"Estimado  P(T>t)         = {p_tail:.5f}")
    print(f"Teórico   exp(-lambda t) = {p_teo:.5f}")


if __name__ == "__main__":
    main()
