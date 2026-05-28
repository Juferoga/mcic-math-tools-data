#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
descarga_fred.py
================
Descarga la serie DGS10 (Treasury Constant Maturity Rate, 10-Year)
desde FRED (Federal Reserve Economic Data) vía CSV público,
preprocesa la serie (interpolación de faltantes, diferencias opcionales)
y exporta un archivo .csv compatible con MATLAB.

Uso:
    python3 src/descarga_fred.py

Salida:
    - doc/data/fred_dgs10_niveles.csv   (serie en niveles, para MATLAB)
    - doc/data/fred_dgs10_diff.csv      (diferencias diarias, para MATLAB)
    - Estadísticas por consola
"""

import os
import urllib.request
import pandas as pd
import numpy as np

# ------------------------------------------------------------------
# CONFIGURACIÓN
# ------------------------------------------------------------------
SERIE_ID = "DGS10"
FRED_CSV_URL = f"https://fred.stlouisfed.org/graph/fredgraph.csv?id={SERIE_ID}"
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "doc", "data")
os.makedirs(OUTPUT_DIR, exist_ok=True)

NIVELES_CSV = os.path.join(OUTPUT_DIR, "fred_dgs10_niveles.csv")
DIFF_CSV = os.path.join(OUTPUT_DIR, "fred_dgs10_diff.csv")

# ------------------------------------------------------------------
# 1. DESCARGA
# ------------------------------------------------------------------
print(f"--- Descargando serie {SERIE_ID} desde FRED ---")
print(f"URL: {FRED_CSV_URL}")

try:
    with urllib.request.urlopen(FRED_CSV_URL, timeout=30) as response:
        raw_csv = response.read().decode("utf-8")
    # Guardar crudo por si acaso
    raw_path = os.path.join(OUTPUT_DIR, "fred_dgs10_raw.csv")
    with open(raw_path, "w", encoding="utf-8") as f:
        f.write(raw_csv)
    print(f"  CSV crudo guardado en: {raw_path}")
except Exception as e:
    raise SystemExit(f"Error al descargar datos de FRED: {e}")

# ------------------------------------------------------------------
# 2. LECTURA Y PREPROCESAMIENTO
# ------------------------------------------------------------------
print("\n--- Leyendo y preprocesando datos ---")

# FRED entrega: observation_date, DGS10
df = pd.read_csv(raw_path, parse_dates=["observation_date"])

# Renombrar para comodidad
df = df.rename(columns={"observation_date": "DATE", SERIE_ID: "valor"})

# Ordenar cronológicamente
df = df.sort_values("DATE").reset_index(drop=True)

# La serie puede tener '.' como marcador de faltante en FRED
df["valor"] = pd.to_numeric(df["valor"], errors="coerce")

print(f"  Observaciones totales:        {len(df)}")
print(f"  Rango de fechas:              {df['DATE'].min().date()}  →  {df['DATE'].max().date()}")
print(f"  Valores faltantes (orig):     {df['valor'].isna().sum()}")

# Interpolar faltantes (lineal) — útil para días festivos o gapse
# en series diarias de mercado.
df["valor_interp"] = df["valor"].interpolate(method="linear")

# También rellenar posibles extremos con forward/backward fill
df["valor_interp"] = df["valor_interp"].ffill().bfill()

print(f"  Valores faltantes (post-int): {df['valor_interp'].isna().sum()}")

# Diferencias diarias (útil si se quiere analizar retornos / cambios)
df["diff"] = df["valor_interp"].diff()
df["diff"] = df["diff"].fillna(0.0)  # primer valor sin diferencia

# ------------------------------------------------------------------
# 3. ESTADÍSTICAS BÁSICAS
# ------------------------------------------------------------------
print("\n--- Estadísticas: NIVELES (DGS10) ---")
niveles = df["valor_interp"]
print(f"  Muestras válidas:  {niveles.count()}")
print(f"  Media:             {niveles.mean():.6f}")
print(f"  Mediana:           {niveles.median():.6f}")
print(f"  Desv. estándar:    {niveles.std():.6f}")
print(f"  Mínimo:            {niveles.min():.6f}")
print(f"  Máximo:            {niveles.max():.6f}")
print(f"  Coef. variación:   {(niveles.std()/niveles.mean()):.4f}")

print("\n--- Estadísticas: DIFERENCIAS DIARIAS ---")
diffs = df["diff"]
print(f"  Muestras válidas:  {diffs.count()}")
print(f"  Media:             {diffs.mean():.6f}")
print(f"  Mediana:           {diffs.median():.6f}")
print(f"  Desv. estándar:    {diffs.std():.6f}")
print(f"  Mínimo:            {diffs.min():.6f}")
print(f"  Máximo:            {diffs.max():.6f}")

# Autocorrelación de orden 1 (indicador rápido de memoria)
acf1_niveles = niveles.autocorr(lag=1)
acf1_diffs = diffs.autocorr(lag=1)
print(f"\n  ACF(1) niveles:    {acf1_niveles:.4f}")
print(f"  ACF(1) diffs:      {acf1_diffs:.4f}")
print(f"  >> Nota: ACF(1) elevada en niveles sugiere memoria persistente (LRD).")

# ------------------------------------------------------------------
# 4. EXPORTE A CSV (COMPATIBLE MATLAB)
# ------------------------------------------------------------------
print("\n--- Exportando CSV para MATLAB ---")

# Niveles (sin índice, sin cabecera)
niveles.to_csv(NIVELES_CSV, index=False, header=False)
print(f"  Niveles  → {NIVELES_CSV}")

# Diferencias (sin índice, sin cabecera)
diffs.to_csv(DIFF_CSV, index=False, header=False)
print(f"  Diffs    → {DIFF_CSV}")

# ------------------------------------------------------------------
# 5. RESUMEN EJECUTIVO
# ------------------------------------------------------------------
print("\n" + "="*60)
print("RESUMEN EJECUTIVO")
print("="*60)
print(f"  Serie:              {SERIE_ID} — 10-Year Treasury Constant Maturity Rate")
print(f"  Fuente:             FRED / Federal Reserve Bank of St. Louis")
print(f"  Frecuencia:         Diaria")
print(f"  Observaciones:      {len(df)}")
print(f"  Fecha inicio:       {df['DATE'].min().date()}")
print(f"  Fecha fin:          {df['DATE'].max().date()}")
print(f"  Media nivel:        {niveles.mean():.4f} %")
print(f"  Desv. std nivel:    {niveles.std():.4f} %")
print(f"  ACF(1) niveles:     {acf1_niveles:.4f}")
print(f"\n  Valor esperado H:   ~0.65 – 0.85 (memoria persistente)")
print(f"  Justificación:      Política monetaria de suavización,")
print(f"                      persistencia de shocks (2008, COVID-19),")
print(f"                      y autocorrelación de largo plazo.")
print("="*60)
