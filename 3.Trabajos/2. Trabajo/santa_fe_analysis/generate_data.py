#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generación de datos — Venta de boletería Independiente Santa Fe (M/M/k/k)
=========================================================================
Cada escenario modela una taquilla de boletería como un sistema M/M/k/k:
  - k = número de ventanillas (taquillas) abiertas
  - λ = tasa de llegada de hinchas (fans/min)
  - μ = tasa de servicio de cada vendedor (ventas/min)
  - Sin cola: si todas las taquillas están ocupadas, el hincha se va (bloqueo)

Escenarios:
  1. Partido de Liga regular        (k=5,  λ=20/min,  μ=4/min)
  2. Clásico vs Millonarios         (k=10, λ=60/min,  μ=3/min)
  3. Final de Copa                    (k=15, λ=100/min, μ=2/min)
  4. Súper-clásico (Clausura)         (k=20, λ=150/min, μ=2.5/min)

Salida:
  santa_fe_analysis/data/dataset_<escenario>.csv
  santa_fe_analysis/data/resultados_simulacion.csv
  santa_fe_analysis/data/dimensionamiento_taquillas.csv
  santa_fe_analysis/data/sensibilidad_lambda.csv
  santa_fe_analysis/data/resumen.json
"""

import os
import sys
import json
import numpy as np
import pandas as pd

# Rutas aislados
BASE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(BASE, 'data')
os.makedirs(DATA, exist_ok=True)

sys.path.insert(0, os.path.join(BASE, '..'))
from src.core.theory import erlang_b, mmkk_stationary_probs
from src.core.simulation import simulate_mmk_k


# ============================================================================
# ESCENARIOS SANTA FE
# ============================================================================
ESCENARIOS = [
    {
        "key": "liga_regular",
        "nombre": "Partido de Liga regular",
        "k": 5,
        "lambda": 20.0,      # fans por minuto
        "mu": 4.0,           # ventas por minuto por taquilla
        "n_peticiones": 30000,
        "color": "#1f77b4",
    },
    {
        "key": "clasico_millonarios",
        "nombre": "Clásico vs Millonarios",
        "k": 10,
        "lambda": 60.0,
        "mu": 3.0,
        "n_peticiones": 50000,
        "color": "#ff7f0e",
    },
    {
        "key": "final_copa",
        "nombre": "Final de Copa",
        "k": 15,
        "lambda": 100.0,
        "mu": 2.0,
        "n_peticiones": 80000,
        "color": "#2ca02c",
    },
    {
        "key": "superclasico",
        "nombre": "Súper-clásico (Clausura)",
        "k": 20,
        "lambda": 150.0,
        "mu": 2.5,
        "n_peticiones": 100000,
        "color": "#d62728",
    },
]


def erlangB_recursive(k: int, a: float) -> float:
    """Recursión de Jagerman."""
    B = 1.0
    for i in range(1, k + 1):
        B = (a * B) / (i + a * B)
    return B


def calcular_metricas(k, lam, mu):
    a = lam / mu
    B = erlangB_recursive(k, a)
    Pn = mmkk_stationary_probs(lam, mu, k)
    N_prom = float(np.sum(np.arange(0, k + 1) * Pn))
    rho = N_prom / k
    lam_ef = lam * (1 - B)
    return {
        'k': k, 'lambda': lam, 'mu': mu, 'a': a,
        'B': B, 'N_prom': N_prom, 'rho': rho, 'lambda_ef': lam_ef
    }


def simular_mmkk_custom(tiempo_entre_arribos, tiempos_servicio, k):
    """Simulador ligero adaptado (mismas entradas que mmkk.m de MATLAB)."""
    n = len(tiempo_entre_arribos)
    reloj = np.cumsum(tiempo_entre_arribos)
    fin_servicio = np.zeros(k)
    bloqueados = 0
    atendidos = 0
    tiempo_ocupado = 0.0

    for i in range(n):
        t = reloj[i]
        ocupados = fin_servicio > t
        if np.sum(ocupados) == k:
            bloqueados += 1
        else:
            idx_libre = np.argmin(fin_servicio)
            inicio = max(t, fin_servicio[idx_libre])
            fin = inicio + tiempos_servicio[i]
            fin_servicio[idx_libre] = fin
            atendidos += 1
            tiempo_ocupado += tiempos_servicio[i]

    total = atendidos + bloqueados
    B_sim = bloqueados / total if total > 0 else 0
    tiempo_total = reloj[-1]
    util = tiempo_ocupado / (k * tiempo_total)
    return {
        'total': total, 'atendidos': atendidos, 'bloqueados': bloqueados,
        'B_sim': B_sim, 'utilizacion': util, 'tiempo_total': tiempo_total
    }


# ============================================================================
# 1. GENERAR DATASETS
# ============================================================================
print("=" * 70)
print("SANTA FE — GENERACIÓN DE DATASETS DE BOLETERÍA")
print("=" * 70)

for esc in ESCENARIOS:
    print(f"\n--- {esc['nombre']} ---")
    lam, mu = esc['lambda'], esc['mu']
    n = esc['n_peticiones']

    # Tiempos entre llegadas ~ Exp(λ)  [en minutos]
    interarribos = np.random.exponential(1.0 / lam, n)
    # Tiempos de servicio ~ Exp(μ)     [en minutos]
    servicios = np.random.exponential(1.0 / mu, n)

    df = pd.DataFrame({
        'fan_id': range(1, n + 1),
        'tiempo_entre_llegadas_min': interarribos,
        'tiempo_venta_min': servicios,
        'tiempo_llegada_abs_min': np.cumsum(interarribos),
    })
    path = os.path.join(DATA, f"dataset_{esc['key']}.csv")
    df.to_csv(path, index=False)
    print(f"    Dataset: {path} ({n} fans)")
    print(f"    λ estimada: {1.0/np.mean(interarribos):.2f} fans/min")
    print(f"    μ estimada: {1.0/np.mean(servicios):.2f} ventas/min")


# ============================================================================
# 2. SIMULAR BLOQUEOS (hinchas que se van sin boleto)
# ============================================================================
print("\n" + "=" * 70)
print("SANTA FE — SIMULACIÓN DE BLOQUEOS (hinchas sin boleto)")
print("=" * 70)

resultados_sim = []
for esc in ESCENARIOS:
    print(f"\n--- {esc['nombre']} ---")
    df = pd.read_csv(os.path.join(DATA, f"dataset_{esc['key']}.csv"))
    res = simular_mmkk_custom(
        df['tiempo_entre_llegadas_min'].values,
        df['tiempo_venta_min'].values,
        esc['k']
    )
    met = calcular_metricas(esc['k'], esc['lambda'], esc['mu'])
    print(f"    Total hinchas: {res['total']}")
    print(f"    Atendidos (con boleto): {res['atendidos']}")
    print(f"    Bloqueados (sin boleto): {res['bloqueados']}")
    print(f"    B(k,a) teórico: {met['B']:.6f}")
    print(f"    B(k,a) simulado: {res['B_sim']:.6f}")
    print(f"    Diferencia: {abs(met['B'] - res['B_sim']):.6f}")
    print(f"    Utilización ρ: {met['rho']:.4f}")
    resultados_sim.append({
        'escenario': esc['key'],
        'nombre': esc['nombre'],
        **met, **res
    })

pd.DataFrame(resultados_sim).to_csv(os.path.join(DATA, 'resultados_simulacion.csv'), index=False)
print(f"\n    → {os.path.join(DATA, 'resultados_simulacion.csv')}")


# ============================================================================
# 3. DIMENSIONAMIENTO ÓPTIMO DE TAQUILLAS
# ============================================================================
print("\n" + "=" * 70)
print("SANTA FE — DIMENSIONAMIENTO ÓPTIMO DE TAQUILLAS")
print("=" * 70)

UMBRALES = [
    ("Estricto (99.9%)", 0.001),
    ("Alto (99%)", 0.01),
    ("Estándar (95%)", 0.05),
    ("Relajado (90%)", 0.10),
]

resultados_dim = []
for esc in ESCENARIOS:
    a = esc['lambda'] / esc['mu']
    print(f"\n--- {esc['nombre']} ---")
    print(f"    Carga a = {a:.2f} Erlangs | Taquillas actuales k = {esc['k']}")
    print(f"    B actual = {erlangB_recursive(esc['k'], a):.6f}")
    print(f"    {'Umbral':<22} | k* | B(k*,a)   | ρ      | N̄")
    print("    " + "-" * 55)
    for nom, Bmax in UMBRALES:
        k = 1
        while erlangB_recursive(k, a) > Bmax:
            k += 1
            if k > 500: break
        Bopt = erlangB_recursive(k, a)
        met = calcular_metricas(k, esc['lambda'], esc['mu'])
        print(f"    {nom:<22} | {k:>2} | {Bopt:.6f} | {met['rho']:.4f} | {met['N_prom']:.2f}")
        resultados_dim.append({
            'escenario': esc['key'], 'nombre': esc['nombre'], 'a': a,
            'k_actual': esc['k'], 'umbral_nombre': nom, 'B_max': Bmax,
            'k_optimo': k, 'B_optimo': Bopt, 'rho': met['rho'], 'N_prom': met['N_prom']
        })

pd.DataFrame(resultados_dim).to_csv(os.path.join(DATA, 'dimensionamiento_taquillas.csv'), index=False)
print(f"\n    → {os.path.join(DATA, 'dimensionamiento_taquillas.csv')}")


# ============================================================================
# 4. SENSIBILIDAD B(k,a) vs λ
# ============================================================================
print("\n" + "=" * 70)
print("SANTA FE — ANÁLISIS DE SENSIBILIDAD B(k,a) vs λ")
print("=" * 70)

k_fijo = 10
mu_fijo = 3.0
lambdas = np.arange(5, 91, 5)
sens = []
for lam in lambdas:
    a = lam / mu_fijo
    B = erlangB_recursive(k_fijo, a)
    met = calcular_metricas(k_fijo, lam, mu_fijo)
    sens.append({'lambda': lam, 'a': a, 'B': B, 'rho': met['rho'], 'N_prom': met['N_prom']})

pd.DataFrame(sens).to_csv(os.path.join(DATA, 'sensibilidad_lambda.csv'), index=False)
print(f"    → {os.path.join(DATA, 'sensibilidad_lambda.csv')}")
print(f"    k={k_fijo}, μ={mu_fijo}")


# ============================================================================
# 5. RESUMEN JSON
# ============================================================================
resumen = {
    "actividad": "Venta de boletería Independiente Santa Fe — M/M/k/k",
    "analogia": {
        "k": "Número de taquillas abiertas",
        "lambda": "Tasa de llegada de hinchas (fans/min)",
        "mu": "Tasa de venta por taquilla (ventas/min)",
        "bloqueo": "Hincha que llega y se va porque todas las taquillas están ocupadas"
    },
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

with open(os.path.join(DATA, 'resumen.json'), 'w', encoding='utf-8') as f:
    json.dump(resumen, f, indent=2, ensure_ascii=False)
print(f"\n    → {os.path.join(DATA, 'resumen.json')}")

print("\n" + "=" * 70)
print("¡LISTO! Datos generados en santa_fe_analysis/data/")
print("=" * 70)
