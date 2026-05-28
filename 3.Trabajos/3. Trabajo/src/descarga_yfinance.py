#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
descarga_yfinance.py

Descarga la serie diaria del S&P 500 (^GSPC) desde Yahoo Finance mediante
yfinance, computa los retornos logarítmicos diarios y exporta la serie como
un CSV limpio (sin cabecera ni índice) compatible con MATLAB/Octave.

Uso:
    python3 src/descarga_yfinance.py

Requiere:
    pip install yfinance pandas numpy
"""

import os
import sys

# ------------------------------------------------------------------
# 0. Verificar dependencias
# ------------------------------------------------------------------
try:
    import yfinance as yf
except ImportError as exc:
    print("[ERROR] yfinance no está instalado.")
    print("        Ejecutá: pip install yfinance")
    sys.exit(1)

import numpy as np
import pandas as pd

# ------------------------------------------------------------------
# 1. Configuración
# ------------------------------------------------------------------
TICKER = "^GSPC"
PERIOD = "10y"          # últimos 10 años
INTERVAL = "1d"         # frecuencia diaria
OUTPUT_CSV = "data/gspc_logreturns.csv"

# ------------------------------------------------------------------
# 2. Descarga
# ------------------------------------------------------------------
print(f"Descargando {TICKER} (period={PERIOD}, interval={INTERVAL})...")
df = yf.download(
    tickers=TICKER,
    period=PERIOD,
    interval=INTERVAL,
    progress=False,
    auto_adjust=True,   # precios ajustados (splits/dividendos)
)

if df.empty:
    print("[ERROR] La descarga devolvió un DataFrame vacío.")
    sys.exit(1)

# yfinance devuelve MultiIndex columnas cuando auto_adjust=True;
# normalizamos por si acaso.
if isinstance(df.columns, pd.MultiIndex):
    df.columns = df.columns.get_level_values(0)

print(f"  Filas descargadas (precios): {len(df)}")
print(f"  Rango temporal: {df.index.min().date()} → {df.index.max().date()}")

# ------------------------------------------------------------------
# 3. Cálculo de retornos logarítmicos
# ------------------------------------------------------------------
# r_t = ln(P_t / P_{t-1})
close = df["Close"].dropna()
log_returns = np.log(close / close.shift(1)).dropna()

n = len(log_returns)
print(f"\nRetornos logarítmicos calculados: {n} observaciones")

# ------------------------------------------------------------------
# 4. Estadísticas descriptivas
# ------------------------------------------------------------------
print("\n" + "=" * 50)
print("ESTADÍSTICAS DESCRIPTIVAS (log-returns)")
print("=" * 50)
print(f"  n            : {n}")
print(f"  media        : {log_returns.mean():.8f}")
print(f"  desv. std    : {log_returns.std():.8f}")
print(f"  mínimo       : {log_returns.min():.8f}")
print(f"  máximo       : {log_returns.max():.8f}")
print(f"  asimetría    : {log_returns.skew():.4f}")
print(f"  curtosis     : {log_returns.kurtosis():.4f}")
print("=" * 50)

# ------------------------------------------------------------------
# 5. Estimación rápida del exponente de Hurst (R/S clásico)
# ------------------------------------------------------------------
def hurst_rs(x):
    """
    Estimador clásico R/S de Hurst.
    Retorna H y la pendiente del ajuste log-log.
    """
    x = np.asarray(x)
    n = len(x)
    # Tamaños de ventana geométricamente espaciados
    lags = np.unique(np.round(np.logspace(2, np.log10(n // 2), num=50)).astype(int))
    lags = lags[lags > 1]

    rs_values = []
    for lag in lags:
        n_chunks = n // lag
        rs_chunks = []
        for i in range(n_chunks):
            chunk = x[i * lag : (i + 1) * lag]
            m = np.mean(chunk)
            y = np.cumsum(chunk - m)
            r = np.max(y) - np.min(y)
            s = np.std(chunk, ddof=1)
            if s > 0:
                rs_chunks.append(r / s)
        if rs_chunks:
            rs_values.append(np.mean(rs_chunks))

    rs_values = np.array(rs_values)
    valid = (rs_values > 0) & (lags[: len(rs_values)] > 0)
    log_lags = np.log(lags[: len(rs_values)][valid])
    log_rs = np.log(rs_values[valid])

    if len(log_lags) < 2:
        return np.nan, np.nan

    slope, intercept = np.polyfit(log_lags, log_rs, 1)
    H = slope
    return H, slope

print("\nEstimando exponente de Hurst (R/S)...")
H_rs, _ = hurst_rs(log_returns.values)
print(f"  H estimado (R/S): {H_rs:.4f}")
print(f"  (Literatura para S&P 500: H ≈ 0.53 – 0.58)")

# ------------------------------------------------------------------
# 6. Persistencia en disco (formato MATLAB-compatible)
# ------------------------------------------------------------------
script_dir = os.path.dirname(os.path.abspath(__file__))
output_path = os.path.join(script_dir, "..", OUTPUT_CSV)
output_path = os.path.abspath(output_path)
os.makedirs(os.path.dirname(output_path), exist_ok=True)

# Guardar como una sola columna, sin índice, sin encabezado
log_returns.to_csv(output_path, index=False, header=False)
print(f"\nSerie guardada en: {output_path}")
print(f"  Formato: CSV de una columna, sin header ni índice (compatible MATLAB)")

# ------------------------------------------------------------------
# 7. Resumen ejecutivo
# ------------------------------------------------------------------
print("\n" + "=" * 50)
print("RESUMEN EJECUTIVO")
print("=" * 50)
print(f"  Fuente       : Yahoo Finance ({TICKER})")
print(f"  Variable     : Retornos logarítmicos diarios")
print(f"  Observaciones: {n}")
print(f"  Período      : {df.index.min().date()} → {df.index.max().date()}")
print(f"  Media        : {log_returns.mean():.8f}")
print(f"  Desv. std    : {log_returns.std():.8f}")
print(f"  H (R/S)      : {H_rs:.4f}")
print("=" * 50)
