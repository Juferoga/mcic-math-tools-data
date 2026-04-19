"""
Script de análisis de sensibilidad: varía A = lambda/mu y compara simulación vs teoría
Guarda gráficas en doc/plots/ y resultados en data/

Ejemplo de uso:
python -m src.analysis.sensitivity --mu 1.0 --K 10 --sample-size 20000 --replicates 3
"""

from __future__ import annotations
import argparse
import json
import os
from typing import List
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime

from src.core.simulation import simulate_from_rates
from src.core.theory import erlang_b, mmkk_mean_wait


def run_sensitivity(
    mu: float = 1.0,
    k: int = 10,
    sample_size: int = 20000,
    replicates: int = 3,
    a_min: float = 0.1,
    a_max: float = 1.5,
    steps: int = 20,
    seed: int = 0,
):
    A_values = np.linspace(a_min, a_max, steps)

    blocking_sim_mean: List[float] = []
    blocking_sim_std: List[float] = []
    blocking_theory: List[float] = []

    wait_sim_mean: List[float] = []
    wait_sim_std: List[float] = []
    wait_theory: List[float] = []

    for i, A in enumerate(A_values):
        lam = A * mu
        sim_blocking_vals = []
        sim_wait_vals = []
        for r in range(replicates):
            s = seed + i * 100 + r
            res = simulate_from_rates(
                lam=lam, mu=mu, k=k, sample_size=sample_size, seed=s
            )
            sim_blocking_vals.append(res.blocking_probability)
            sim_wait_vals.append(res.mean_wait)

        sim_blocking_vals = np.array(sim_blocking_vals, dtype=float)
        sim_wait_vals = np.array(sim_wait_vals, dtype=float)

        blocking_sim_mean.append(float(sim_blocking_vals.mean()))
        blocking_sim_std.append(float(sim_blocking_vals.std(ddof=0)))

        wait_sim_mean.append(float(sim_wait_vals.mean()))
        wait_sim_std.append(float(sim_wait_vals.std(ddof=0)))

        # theory (Erlang B)
        p_k = erlang_b(lam, mu, k)
        _, wq = mmkk_mean_wait(lam, mu, k)

        blocking_theory.append(float(p_k))
        wait_theory.append(float(wq))

        print(
            f"A={A:.3f} (lam={lam:.3f}): blocking sim={blocking_sim_mean[-1]:.4f} theory={blocking_theory[-1]:.4f} | wait sim={wait_sim_mean[-1]:.4f} theory={wait_theory[-1]:.4f}"
        )

    # guardar resultados
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    out_dir = os.path.join(os.getcwd(), "doc", "plots")
    os.makedirs(out_dir, exist_ok=True)
    fig_path = os.path.join(out_dir, f"sensitivity_{timestamp}.png")

    # gráficas
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # blocking
    axes[0].errorbar(
        A_values,
        blocking_sim_mean,
        yerr=blocking_sim_std,
        fmt="o",
        label="Simulación (media±std)",
    )
    axes[0].plot(A_values, blocking_theory, "-k", label="Teoría (P_k)")
    axes[0].set_xlabel("A = lambda/mu")
    axes[0].set_ylabel("Probabilidad de bloqueo P_k")
    axes[0].set_title("Blocking probability: simulación vs teoría")
    axes[0].legend()

    # waiting time
    axes[1].errorbar(
        A_values,
        wait_sim_mean,
        yerr=wait_sim_std,
        fmt="o",
        label="Simulación (media±std)",
    )
    axes[1].plot(A_values, wait_theory, "-k", label="Teoría (Wq)")
    axes[1].set_xlabel("A = lambda/mu")
    axes[1].set_ylabel("Tiempo medio de espera en cola E[Tw] (s)")
    axes[1].set_title("Tiempo medio de espera: simulación vs teoría")
    axes[1].legend()

    plt.tight_layout()
    fig.savefig(fig_path, dpi=150, bbox_inches="tight")

    # guardar resultados numéricos
    results = {
        "A_values": A_values.tolist(),
        "blocking_sim_mean": blocking_sim_mean,
        "blocking_sim_std": blocking_sim_std,
        "blocking_theory": blocking_theory,
        "wait_sim_mean": wait_sim_mean,
        "wait_sim_std": wait_sim_std,
        "wait_theory": wait_theory,
        "mu": mu,
        "k": k,
        "sample_size": sample_size,
        "replicates": replicates,
    }
    out_data = os.path.join(os.getcwd(), "data")
    os.makedirs(out_data, exist_ok=True)
    json_path = os.path.join(out_data, f"sensitivity_results_{timestamp}.json")
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2)

    print(f"Gráfica guardada en: {fig_path}")
    print(f"Resultados guardados en: {json_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Análisis de sensibilidad A=lambda/mu")
    parser.add_argument("--mu", type=float, default=1.0)
    parser.add_argument("--k", type=int, default=10, help="Número de servidores (k)")
    parser.add_argument("--sample-size", type=int, default=20000)
    parser.add_argument("--replicates", type=int, default=3)
    parser.add_argument("--a-min", type=float, default=0.1)
    parser.add_argument("--a-max", type=float, default=1.5)
    parser.add_argument("--steps", type=int, default=20)
    parser.add_argument("--seed", type=int, default=0)
    args = parser.parse_args()

    run_sensitivity(
        mu=args.mu,
        k=args.k,
        sample_size=args.sample_size,
        replicates=args.replicates,
        a_min=args.a_min,
        a_max=args.a_max,
        steps=args.steps,
        seed=args.seed,
    )
