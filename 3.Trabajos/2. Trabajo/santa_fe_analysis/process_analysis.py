#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Procesamiento gráfico y tablas — Boletería Santa Fe (M/M/k/k)
==============================================================
Genera plots profesionales y tablas LaTeX a partir de los datasets
ya creados en santa_fe_analysis/data/.

Salida:
  santa_fe_analysis/plots/   -> 10 figuras en alta resolución
  santa_fe_analysis/data/tablas_latex.tex -> tablas listas para el paper
  santa_fe_analysis/data/resumen_procesado.json -> resumen consolidado
"""

import os
import sys
import json
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy import stats

BASE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(BASE, 'data')
PLOTS = os.path.join(BASE, 'plots')
os.makedirs(PLOTS, exist_ok=True)

sys.path.insert(0, os.path.join(BASE, '..'))
from src.core.theory import erlang_b, mmkk_stationary_probs
from src.analysis.validation import qq_plot_exponential, histogram_with_exponential

plt.rcParams.update({
    'font.size': 10,
    'axes.titlesize': 11,
    'axes.labelsize': 10,
    'legend.fontsize': 9,
    'figure.dpi': 150,
    'savefig.dpi': 200,
    'savefig.bbox': 'tight',
})

ESCENARIOS = [
    {"key": "liga_regular",        "nombre": "Partido de Liga regular",     "k": 5,  "lambda": 20.0,  "mu": 4.0,  "color": "#1f77b4"},
    {"key": "clasico_millonarios", "nombre": "Clásico vs Millonarios",      "k": 10, "lambda": 60.0,  "mu": 3.0,  "color": "#ff7f0e"},
    {"key": "final_copa",          "nombre": "Final de Copa",               "k": 15, "lambda": 100.0, "mu": 2.0,  "color": "#2ca02c"},
    {"key": "superclasico",        "nombre": "Súper-clásico (Clausura)",    "k": 20, "lambda": 150.0, "mu": 2.5,  "color": "#d62728"},
]


def erlangB_recursive(k, a):
    B = 1.0
    for i in range(1, k + 1):
        B = (a * B) / (i + a * B)
    return B


def calcular_metricas(k, lam, mu):
    a = lam / mu
    B = erlangB_recursive(k, a)
    Pn = mmkk_stationary_probs(lam, mu, k)
    N_prom = float(np.sum(np.arange(0, k + 1) * Pn))
    return {'k': k, 'lambda': lam, 'mu': mu, 'a': a, 'B': B, 'N_prom': N_prom, 'rho': N_prom / k}


def load_dataset(key):
    return pd.read_csv(os.path.join(DATA, f'dataset_{key}.csv'))


# ============================================================================
# 1. VALIDACIÓN (QQ + histogramas)
# ============================================================================
def plot_validacion():
    print("\n[1/6] Validación gráfica por escenario...")
    for esc in ESCENARIOS:
        df = load_dataset(esc['key'])
        fig, axes = plt.subplots(2, 2, figsize=(11, 9))
        fig.suptitle(f"Validación de supuestos — {esc['nombre']}\n"
                     f"$k={esc['k']}$ taquillas, $\\lambda={esc['lambda']}$, $\\mu={esc['mu']}$",
                     fontweight='bold', fontsize=12)
        histogram_with_exponential(df['tiempo_entre_llegadas_min'].values, esc['lambda'], bins=60, ax=axes[0,0])
        axes[0,0].set_title("Tiempos entre llegadas — Histograma")
        axes[0,0].set_xlabel("Tiempo entre llegadas (min)")
        qq_plot_exponential(df['tiempo_entre_llegadas_min'].values, esc['lambda'], ax=axes[0,1])
        axes[0,1].set_title("Tiempos entre llegadas — QQ-plot")
        histogram_with_exponential(df['tiempo_venta_min'].values, esc['mu'], bins=60, ax=axes[1,0])
        axes[1,0].set_title("Tiempos de venta — Histograma")
        axes[1,0].set_xlabel("Tiempo de venta (min)")
        qq_plot_exponential(df['tiempo_venta_min'].values, esc['mu'], ax=axes[1,1])
        axes[1,1].set_title("Tiempos de venta — QQ-plot")
        plt.tight_layout(rect=[0, 0, 1, 0.96])
        out = os.path.join(PLOTS, f"validacion_{esc['key']}.png")
        fig.savefig(out)
        plt.close(fig)
        print(f"    ✓ {out}")


# ============================================================================
# 2. COMPARACIÓN B TEORÍA vs SIMULACIÓN
# ============================================================================
def plot_comparacion():
    print("\n[2/6] Comparación simulación vs teoría...")
    df_sim = pd.read_csv(os.path.join(DATA, 'resultados_simulacion.csv'))
    fig, ax = plt.subplots(figsize=(9, 5))
    x = np.arange(len(ESCENARIOS))
    width = 0.35
    B_teo = [erlangB_recursive(esc['k'], esc['lambda']/esc['mu']) for esc in ESCENARIOS]
    B_sim = df_sim['B_sim'].values
    bars1 = ax.bar(x - width/2, B_teo, width, label='Erlang B (teoría)', color='steelblue', edgecolor='black', linewidth=0.5)
    bars2 = ax.bar(x + width/2, B_sim, width, label='Simulación (eventos discretos)', color='coral', edgecolor='black', linewidth=0.5)
    ax.set_ylabel('Probabilidad de bloqueo $B(k,a)$')
    ax.set_title('Comparación: Erlang B analítico vs Simulación M/M/k/k — Boletería Santa Fe')
    ax.set_xticks(x)
    ax.set_xticklabels([e['nombre'] for e in ESCENARIOS], rotation=15, ha='right')
    ax.legend()
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
    print(f"    ✓ {out}")


# ============================================================================
# 3. CURVAS DE ERLANG B POR ESCENARIO
# ============================================================================
def plot_curvas_erlang():
    print("\n[3/6] Curvas de Erlang B por escenario...")
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
# 4. OCUPACIÓN TEMPORAL DE TAQUILLAS
# ============================================================================
def plot_ocupacion():
    print("\n[4/6] Ocupación temporal de taquillas...")
    from src.core.simulation import simulate_mmk_k
    fig, axes = plt.subplots(2, 2, figsize=(13, 9))
    axes = axes.flatten()
    for idx, esc in enumerate(ESCENARIOS):
        ax = axes[idx]
        df = load_dataset(esc['key'])
        inter = df['tiempo_entre_llegadas_min'].values[:5000]
        serv = df['tiempo_venta_min'].values[:5000]
        res = simulate_mmk_k(inter, serv, esc['k'])
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


# ============================================================================
# 5. DIMENSIONAMIENTO ÓPTIMO
# ============================================================================
def plot_dimensionamiento():
    print("\n[5/6] Dimensionamiento óptimo de taquillas...")
    umbrales = [
        ("99.9%", 0.001, "#2166ac"),
        ("99%",   0.01,  "#4393c3"),
        ("95%",   0.05,  "#92c5de"),
        ("90%",   0.10,  "#d1e5f0"),
    ]
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
    k_act = [e['k'] for e in ESCENARIOS]
    ax.scatter(x, k_act, color='red', s=80, zorder=5, marker='D', label='$k$ actual', edgecolors='black', linewidths=0.5)
    ax.set_ylabel('Número de taquillas $k^*$')
    ax.set_title('Dimensionamiento óptimo de taquillas por nivel de servicio — Boletería Santa Fe')
    ax.set_xticks(x)
    ax.set_xticklabels([e['nombre'] for e in ESCENARIOS], rotation=15, ha='right')
    ax.legend(loc='upper left')
    ax.grid(axis='y', alpha=0.3)
    plt.tight_layout()
    out = os.path.join(PLOTS, "dimensionamiento_optimo.png")
    fig.savefig(out)
    plt.close(fig)
    print(f"    ✓ {out}")


# ============================================================================
# 6. DISTRIBUCIÓN ESTACIONARIA P_n
# ============================================================================
def plot_distribucion():
    print("\n[6/6] Distribución estacionaria P_n...")
    fig, axes = plt.subplots(2, 2, figsize=(12, 9))
    axes = axes.flatten()
    for idx, esc in enumerate(ESCENARIOS):
        ax = axes[idx]
        Pn = mmkk_stationary_probs(esc['lambda'], esc['mu'], esc['k'])
        n = np.arange(0, esc['k'] + 1)
        ax.bar(n, Pn, color=esc['color'], edgecolor='black', linewidth=0.5, alpha=0.8)
        ax.axvline(x=esc['k'], color='red', linestyle='--', alpha=0.5, label=f'$k={esc["k"]}$')
        ax.bar(esc['k'], Pn[-1], color='red', edgecolor='black', linewidth=0.5, alpha=0.9, label=f'$P_k={Pn[-1]:.4f}$')
        ax.set_xlabel('Número de taquillas ocupadas $n$')
        ax.set_ylabel('Probabilidad $P_n$')
        ax.set_title(f"Distribución estacionaria — {esc['nombre']}")
        ax.set_xticks(n)
        ax.legend(loc='upper left', fontsize=8)
        ax.grid(axis='y', alpha=0.3)
    plt.tight_layout()
    out = os.path.join(PLOTS, "distribucion_estacionaria.png")
    fig.savefig(out)
    plt.close(fig)
    print(f"    ✓ {out}")


# ============================================================================
# 7. TABLAS LATEX
# ============================================================================
def generar_tablas_latex():
    print("\n[7/6] Tablas LaTeX...")
    lines = []
    lines.append("% ============================================================")
    lines.append("% TABLAS SANTA FE — Venta de boletería Independiente Santa Fe")
    lines.append("% ============================================================")
    lines.append("")

    # Tabla 1
    lines.append("\\begin{table}[H]")
    lines.append("\\centering")
    lines.append("\\caption{Escenarios de boletería Santa Fe y resultados de simulación M/M/k/k.}")
    lines.append("\\label{tab:santa_fe_resultados}")
    lines.append("\\begin{tabular}{lccccc}")
    lines.append("\\toprule")
    lines.append("\\textbf{Escenario} & $k$ & $\\lambda$ & $\\mu$ & $a$ & $\\hat{B}_{sim}$ \\\\")
    lines.append("\\midrule")
    df_sim = pd.read_csv(os.path.join(DATA, 'resultados_simulacion.csv'))
    for _, row in df_sim.iterrows():
        nom = row['nombre']
        lines.append(f"{nom} & {int(row['k'])} & {row['lambda']:.0f} & {row['mu']:.1f} & {row['a']:.2f} & {row['B_sim']:.4f} \\\\")
    lines.append("\\bottomrule")
    lines.append("\\end{tabular}")
    lines.append("\\end{table}")
    lines.append("")

    # Tabla 2
    lines.append("\\begin{table}[H]")
    lines.append("\\centering")
    lines.append("\\caption{Dimensionamiento óptimo de taquillas por nivel de servicio.}")
    lines.append("\\label{tab:santa_fe_dimensionamiento}")
    lines.append("\\begin{tabular}{l|cccc}")
    lines.append("\\toprule")
    lines.append("& \\multicolumn{4}{c}{\\textbf{$k^*$ mínimo para umbral $B_{max}$}} \\\\")
    lines.append("\\textbf{Escenario} & $0.001$ & $0.01$ & $0.05$ & $0.10$ \\\\")
    lines.append("\\midrule")
    for esc in ESCENARIOS:
        a = esc['lambda'] / esc['mu']
        ks = []
        for Bmax in [0.001, 0.01, 0.05, 0.10]:
            k = 1
            while erlangB_recursive(k, a) > Bmax:
                k += 1
                if k > 500: break
            ks.append(k)
        lines.append(f"{esc['nombre']} & {ks[0]} & {ks[1]} & {ks[2]} & {ks[3]} \\\\")
    lines.append("\\bottomrule")
    lines.append("\\end{tabular}")
    lines.append("\\end{table}")

    tex_path = os.path.join(DATA, "tablas_latex.tex")
    with open(tex_path, 'w', encoding='utf-8') as f:
        f.write("\n".join(lines))
    print(f"    ✓ {tex_path}")


# ============================================================================
# 8. RESUMEN CONSOLIDADO
# ============================================================================
def generar_resumen():
    print("\n[8/6] Resumen consolidado JSON...")
    resumen = {
        "actividad": "Venta de boletería Independiente Santa Fe — M/M/k/k",
        "plots_generados": sorted(os.listdir(PLOTS)),
        "tablas_generadas": ["tablas_latex.tex"],
        "escenarios": []
    }
    for esc in ESCENARIOS:
        met = calcular_metricas(esc['k'], esc['lambda'], esc['mu'])
        resumen["escenarios"].append({
            "key": esc['key'],
            "nombre": esc['nombre'],
            "k": esc['k'],
            "lambda": esc['lambda'],
            "mu": esc['mu'],
            "a_erlangs": round(met['a'], 2),
            "B_k_a": round(met['B'], 6),
            "N_prom": round(met['N_prom'], 2),
            "rho": round(met['rho'], 4),
        })
    json_path = os.path.join(DATA, "resumen_procesado.json")
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(resumen, f, indent=2, ensure_ascii=False)
    print(f"    ✓ {json_path}")


# ============================================================================
# MAIN
# ============================================================================
def main():
    print("=" * 70)
    print("SANTA FE — PROCESAMIENTO GRÁFICO Y TABLAS")
    print("=" * 70)
    plot_validacion()
    plot_comparacion()
    plot_curvas_erlang()
    plot_ocupacion()
    plot_dimensionamiento()
    plot_distribucion()
    generar_tablas_latex()
    generar_resumen()
    print("\n" + "=" * 70)
    print("¡LISTO! Todo en santa_fe_analysis/")
    print(f"  📁 Plots:  {PLOTS}")
    print(f"  📁 Datos:  {DATA}")
    print("=" * 70)


if __name__ == "__main__":
    main()
