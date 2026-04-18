"""
Run Erlang B validation: simulate M/M/k/k for k=10, A in [1..20], save plot
"""
from pathlib import Path
import sys
repo_root = Path(__file__).resolve().parents[1]
if str(repo_root) not in sys.path:
    sys.path.insert(0, str(repo_root))

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

from src.core.simulation import simulate_from_rates
from src.core.theory import erlang_b


def run_validation():
    mu = 1.0
    k = 10
    A_values = np.linspace(1.0, 20.0, 20)
    sample_size = 20000
    replicates = 3

    emp_blocking = []
    for A in A_values:
        lam = A * mu
        bvals = []
        for r in range(replicates):
            seed = int(1234 + A * 100 + r)
            res = simulate_from_rates(lam=lam, mu=mu, k=k, sample_size=sample_size, seed=seed)
            bvals.append(res.blocking_probability)
        emp_blocking.append(float(np.mean(bvals)))

    theo_blocking = [erlang_b(A * mu, mu, k) for A in A_values]

    outdir = Path('doc/plots')
    outdir.mkdir(parents=True, exist_ok=True)
    figpath = outdir / f'erlangb_validation_k{k}.png'

    fig, ax = plt.subplots(figsize=(9,6))
    ax.plot(A_values, theo_blocking, '-k', lw=2, label='Teoría (Erlang B)')
    ax.scatter(A_values, emp_blocking, color='C1', label='Simulación (empírica)', zorder=3)
    ax.set_xlabel('A = λ/μ')
    ax.set_ylabel('Probabilidad de bloqueo $P_k$')
    ax.set_title(f'Erlang B — k={k} — Teoría vs Simulación (replicates={replicates}, sample_size={sample_size})')
    ax.legend()
    ax.grid(True)
    fig.tight_layout()
    fig.savefig(figpath, dpi=150)
    print('SAVED_PLOT:', figpath)


if __name__ == '__main__':
    run_validation()
