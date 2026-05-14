#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Actividad 6 — Santa Fe (Python fallback para generar imágenes)
Basado en actividad6_santafe.m (MATLAB del profe)

Gráficas que enseñó el profe:
  - CDF empírica vs teórica
  - PDF/histograma vs densidad exponencial
  - QQ-plot empírico vs exponencial

Gráficas complementarias:
  - Comparación simulación vs teoría
  - Curvas B(k,a) vs lambda
  - Dimensionamiento óptimo
  - Ocupación temporal
"""

import os
import sys
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy import stats

BASE = os.path.dirname(os.path.abspath(__file__))
PLOTS = os.path.join(BASE, '..', 'doc', 'plots', 'act_6_santafe')
os.makedirs(PLOTS, exist_ok=True)

sys.path.insert(0, os.path.join(BASE, '..'))
from src.core.theory import erlang_b, mmkk_stationary_probs
from src.core.simulation import simulate_mmk_k

plt.rcParams.update({
    'font.size': 10, 'axes.titlesize': 11, 'axes.labelsize': 10,
    'legend.fontsize': 9, 'figure.dpi': 150, 'savefig.dpi': 200, 'savefig.bbox': 'tight',
})

ESCENARIOS = [
    {"nombre": "Liga regular",         "k": 5,  "lambda": 20.0,  "mu": 4.0,  "n": 30000,  "color": "#1f77b4"},
    {"nombre": "Clásico Millonarios",  "k": 10, "lambda": 60.0,  "mu": 3.0,  "n": 50000,  "color": "#ff7f0e"},
    {"nombre": "Final de Copa",        "k": 15, "lambda": 100.0, "mu": 2.0,  "n": 80000,  "color": "#2ca02c"},
    {"nombre": "Súper-clásico",        "k": 20, "lambda": 150.0, "mu": 2.5,  "n": 100000, "color": "#d62728"},
]


def erlangB_recursive(k, a):
    B = 1.0
    for i in range(1, k + 1):
        B = (a * B) / (i + a * B)
    return B


# ============================================================================
# 1. CDF, PDF, QQ-PLOT (LO QUE ENSEÑÓ EL PROFE)
# ============================================================================
print("="*70)
print("1. CDF, PDF Y QQ-PLOT (Metodología del profe)")
print("="*70)

datos_interarribos = []
datos_servicios = []

for esc in ESCENARIOS:
    print(f"\n--- {esc['nombre']} ---")
    lam, mu, n = esc['lambda'], esc['mu'], esc['n']

    inter = np.random.exponential(1.0/lam, n)
    serv = np.random.exponential(1.0/mu, n)
    datos_interarribos.append(inter)
    datos_servicios.append(serv)

    fig, axes = plt.subplots(2, 2, figsize=(11, 9))
    fig.suptitle(f"Análisis de distribución — {esc['nombre']}\n"
                 f"$\\lambda={lam}$, $\\mu={mu}$", fontweight='bold', fontsize=13)

    # 1.1 PDF/Histograma + densidad exponencial
    ax = axes[0, 0]
    ax.hist(inter, bins=60, density=True, alpha=0.7, color=esc['color'], edgecolor='none', label='Empírico')
    xs = np.linspace(0, max(inter), 200)
    ax.plot(xs, lam * np.exp(-lam * xs), 'r-', lw=2, label=f'Exp($\\lambda={lam}$)')
    ax.set_xlabel('Tiempo entre llegadas (min)')
    ax.set_ylabel('Densidad')
    ax.set_title('PDF: Interarribos vs Exponencial')
    ax.legend(loc='best')
    ax.grid(True, alpha=0.3)

    # 1.2 CDF empírica vs teórica
    ax = axes[0, 1]
    sorted_inter = np.sort(inter)
    cdf_emp = np.arange(1, len(sorted_inter)+1) / len(sorted_inter)
    ax.step(sorted_inter, cdf_emp, where='post', color=esc['color'], lw=1.5, label='Empírica')
    ax.plot(xs, 1 - np.exp(-lam * xs), 'r-', lw=2, label=f'Exp($\\lambda={lam}$)')
    ax.set_xlabel('Tiempo entre llegadas (min)')
    ax.set_ylabel('Probabilidad acumulada')
    ax.set_title('CDF: Interarribos vs Exponencial')
    ax.legend(loc='best')
    ax.grid(True, alpha=0.3)

    # 1.3 QQ-plot interarribos vs exponencial (como actividad4.m)
    ax = axes[1, 0]
    referencia = np.random.exponential(1.0/lam, size=inter.shape)
    # Cuantiles
    probs = (np.arange(1, len(inter)+1) - 0.5) / len(inter)
    q_emp = np.quantile(inter, probs)
    q_ref = np.quantile(referencia, probs)
    ax.scatter(q_ref, q_emp, s=8, alpha=0.6, color=esc['color'])
    mx = max(q_ref.max(), q_emp.max())
    ax.plot([0, mx], [0, mx], 'r--', lw=2, label='y=x')
    ax.set_xlabel('Cuantiles exponenciales')
    ax.set_ylabel('Cuantiles empíricos')
    ax.set_title(f'QQ-plot: Interarribos vs Exp($\\lambda={lam}$)')
    ax.legend(loc='best')
    ax.grid(True, alpha=0.3)

    # 1.4 QQ-plot servicios vs exponencial
    ax = axes[1, 1]
    referencia_s = np.random.exponential(1.0/mu, size=serv.shape)
    q_emp_s = np.quantile(serv, probs)
    q_ref_s = np.quantile(referencia_s, probs)
    ax.scatter(q_ref_s, q_emp_s, s=8, alpha=0.6, color=esc['color'])
    mx_s = max(q_ref_s.max(), q_emp_s.max())
    ax.plot([0, mx_s], [0, mx_s], 'r--', lw=2, label='y=x')
    ax.set_xlabel('Cuantiles exponenciales')
    ax.set_ylabel('Cuantiles empíricos')
    ax.set_title(f'QQ-plot: Servicios vs Exp($\\mu={mu}$)')
    ax.legend(loc='best')
    ax.grid(True, alpha=0.3)

    plt.tight_layout(rect=[0, 0, 1, 0.96])
    out = os.path.join(PLOTS, f"validacion_{esc['nombre'].replace(' ', '_')}.png")
    fig.savefig(out)
    plt.close(fig)
    print(f"    ✓ {out}")


# ============================================================================
# 2. COMPARACIÓN SIMULACIÓN VS TEORÍA
# ============================================================================
print("\n" + "="*70)
print("2. SIMULACIÓN Y COMPARACIÓN TEORÍA vs SIMULACIÓN")
print("="*70)
print(f"{'Escenario':<22} | k  | lambda | mu  | a     | B_teo   | B_sim   | Diff")
print("-" * 80)

B_teo = []
B_sim = []

for i, esc in enumerate(ESCENARIOS):
    k, lam, mu = esc['k'], esc['lambda'], esc['mu']
    a = lam / mu
    inter = datos_interarribos[i]
    serv = datos_servicios[i]

    # Simulación
    res = simulate_mmk_k(inter, serv, k)
    pk_sim = res.blocking_probability

    # Teoría
    pk_teo = erlangB_recursive(k, a)

    B_teo.append(pk_teo)
    B_sim.append(pk_sim)

    print(f"{esc['nombre']:<22} | {k:2d} | {lam:6.1f} | {mu:3.1f} | {a:5.2f} | {pk_teo:7.4f} | {pk_sim:7.4f} | {abs(pk_teo - pk_sim):.4f}")

# Gráfica comparación
fig, ax = plt.subplots(figsize=(9, 5))
x = np.arange(len(ESCENARIOS))
width = 0.35
bars1 = ax.bar(x - width/2, B_teo, width, label='Erlang B (teoría)', color='steelblue', edgecolor='k', linewidth=0.5)
bars2 = ax.bar(x + width/2, B_sim, width, label='Simulación (eventos discretos)', color='coral', edgecolor='k', linewidth=0.5)
ax.set_ylabel('Probabilidad de bloqueo $B(k,a)$')
ax.set_title('Comparación: Erlang B analítico vs Simulación — Boletería Santa Fe')
ax.set_xticks(x)
ax.set_xticklabels([e['nombre'] for e in ESCENARIOS], rotation=15, ha='right')
ax.legend(loc='best')
ax.set_ylim(0, max(max(B_teo), max(B_sim)) * 1.25)
ax.grid(axis='y', alpha=0.3)
for bar in bars1:
    h = bar.get_height()
    ax.annotate(f'{h:.3f}', xy=(bar.get_x() + bar.get_width()/2, h), xytext=(0, 3), textcoords="offset points", ha='center', va='bottom', fontsize=8)
for bar in bars2:
    h = bar.get_height()
    ax.annotate(f'{h:.3f}', xy=(bar.get_x() + bar.get_width()/2, h), xytext=(0, 3), textcoords="offset points", ha='center', va='bottom', fontsize=8)
plt.tight_layout()
out = os.path.join(PLOTS, "comparacion_bloqueo.png")
fig.savefig(out)
plt.close(fig)
print(f"\n    ✓ {out}")


# ============================================================================
# 3. CURVAS ERLANG B POR ESCENARIO
# ============================================================================
print("\n" + "="*70)
print("3. CURVAS DE ERLANG B POR ESCENARIO")
print("="*70)

fig, axes = plt.subplots(2, 2, figsize=(12, 9))
axes = axes.flatten()
for idx, esc in enumerate(ESCENARIOS):
    ax = axes[idx]
    k, mu = esc['k'], esc['mu']
    lambdas = np.linspace(1, k * mu * 1.5, 200)
    a_vals = lambdas / mu
    B_vals = [erlangB_recursive(k, a) for a in a_vals]
    ax.plot(lambdas, B_vals, color=esc['color'], linewidth=2.5)
    ax.axvline(x=esc['lambda'], color='black', linestyle='--', alpha=0.6, label=f"$\\lambda_{{actual}}={esc['lambda']}$")
    ax.axhline(y=0.05, color='red', linestyle=':', alpha=0.5, label='$B_{max}=0.05$')
    B_act = erlangB_recursive(k, esc['lambda']/mu)
    ax.scatter([esc['lambda']], [B_act], color='black', zorder=5, s=60)
    ax.annotate(f'$B={B_act:.3f}$', xy=(esc['lambda'], B_act), xytext=(esc['lambda'] + 5, B_act + 0.05), fontsize=9, arrowprops=dict(arrowstyle='->', color='black', alpha=0.5))
    ax.set_xlabel('Tasa de llegadas $\\lambda$ (fans/min)')
    ax.set_ylabel('Probabilidad de bloqueo $B(k,a)$')
    ax.set_title(f"{esc['nombre']} — $k={k}$, $\\mu={mu}$")
    ax.set_ylim(-0.02, 1.02)
    ax.grid(alpha=0.3)
    ax.legend(loc='upper left', fontsize=8)
plt.tight_layout()
out = os.path.join(PLOTS, "curvas_erlang_por_escenario.png")
fig.savefig(out)
plt.close(fig)
print(f"    ✓ {out}")


# ============================================================================
# 4. DIMENSIONAMIENTO ÓPTIMO
# ============================================================================
print("\n" + "="*70)
print("4. DIMENSIONAMIENTO ÓPTIMO")
print("="*70)

umbrales = [("99.9%", 0.001, "#2166ac"), ("99%", 0.01, "#4393c3"), ("95%", 0.05, "#92c5de"), ("90%", 0.10, "#d1e5f0")]
fig, ax = plt.subplots(figsize=(10, 6))
x = np.arange(len(ESCENARIOS))
width = 0.18
for i, (nombre, B_max, color) in enumerate(umbrales):
    k_stars = []
    for esc in ESCENARIOS:
        a = esc['lambda'] / esc['mu']
        k = 1
        while erlangB_recursive(k, a) > B_max:
            k += 1
            if k > 500: break
        k_stars.append(k)
    safe_name = nombre.replace('%', r'\%')
    ax.bar(x + (i - 1.5) * width, k_stars, width, label=f'$B_{{max}}={safe_name}$', color=color, edgecolor='black', linewidth=0.4)
k_act = [esc['k'] for esc in ESCENARIOS]
ax.scatter(x, k_act, color='red', s=80, zorder=5, marker='D', label='$k$ actual', edgecolors='black', linewidths=0.5)
ax.set_ylabel('Número de taquillas $k^*$')
ax.set_title('Dimensionamiento óptimo de taquillas por nivel de servicio — Santa Fe')
ax.set_xticks(x)
ax.set_xticklabels([esc['nombre'] for esc in ESCENARIOS], rotation=15, ha='right')
ax.legend(loc='upper left')
ax.grid(axis='y', alpha=0.3)
plt.tight_layout()
out = os.path.join(PLOTS, "dimensionamiento_optimo.png")
fig.savefig(out)
plt.close(fig)
print(f"    ✓ {out}")

print(f"\n{'Escenario':<22} | 99.9% | 99% | 95% | 90% | k actual")
print("-" * 65)
for esc in ESCENARIOS:
    a = esc['lambda'] / esc['mu']
    ks = []
    for B_max in [0.001, 0.01, 0.05, 0.10]:
        k = 1
        while erlangB_recursive(k, a) > B_max:
            k += 1
            if k > 500: break
        ks.append(k)
    print(f"{esc['nombre']:<22} | {ks[0]:5d} | {ks[1]:3d} | {ks[2]:3d} | {ks[3]:3d} | {esc['k']:8d}")


# ============================================================================
# 5. OCUPACIÓN TEMPORAL
# ============================================================================
print("\n" + "="*70)
print("5. OCUPACIÓN TEMPORAL")
print("="*70)

fig, axes = plt.subplots(2, 2, figsize=(13, 9))
axes = axes.flatten()
for idx, esc in enumerate(ESCENARIOS):
    ax = axes[idx]
    k, lam, mu = esc['k'], esc['lambda'], esc['mu']
    n_muestra = 5000
    inter = np.random.exponential(1.0/lam, n_muestra)
    serv = np.random.exponential(1.0/mu, n_muestra)
    res = simulate_mmk_k(inter, serv, k)
    mask = res.event_times <= 30.0
    t_w = res.event_times[mask]
    n_w = res.system_sizes[mask]
    ax.step(t_w, n_w, where='post', color=esc['color'], linewidth=1.0, alpha=0.9)
    ax.axhline(y=esc['k'], color='red', linestyle='--', alpha=0.5, linewidth=1)
    ax.fill_between(t_w, 0, n_w, step='post', alpha=0.15, color=esc['color'])
    ax.set_xlabel('Tiempo (min)')
    ax.set_ylabel('Taquillas ocupadas')
    ax.set_title(f"{esc['nombre']} ($k={esc['k']}$)")
    ax.set_ylim(-0.3, esc['k'] + 0.8)
    ax.set_xlim(0, 30)
    ax.grid(alpha=0.3)
plt.tight_layout()
out = os.path.join(PLOTS, "ocupacion_temporal_todos.png")
fig.savefig(out)
plt.close(fig)
print(f"    ✓ {out}")

print("\n" + "="*70)
print("¡LISTO! Todas las figuras en doc/plots/act_6_santafe/")
print("="*70)
