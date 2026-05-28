#!/usr/bin/env python3
"""
descarga_binance.py
===================
Descarga velas (klines) de BTC/USDT desde la API pública de Binance,
calcula retornos logarítmicos de los precios de cierre, y exporta
un CSV compatible con MATLAB.

API pública (sin autenticación):
    https://api.binance.com/api/v3/klines?symbol=BTCUSDT&interval=1m&limit=1000

Limitaciones de rate (documentación oficial):
    - Límite general: 1200 requests/minuto por IP.
    - Código 429: Too Many Requests.
    - Código 418: IP banned (violation of rate limits).
    - Se recomienda no superar ~1000 req/min en práctica.

Uso:
    venv/bin/python src/descarga_binance.py

Autor: Asistente de código
Fecha: 2026-05-27
"""

import time
import math
import csv
import sys
from datetime import datetime, timezone
from typing import List, Dict, Any, Optional

import requests
import pandas as pd

# ---------------------------------------------------------------------------
# Constantes
# ---------------------------------------------------------------------------
BASE_URL = "https://api.binance.com/api/v3/klines"
SYMBOL = "BTCUSDT"
INTERVAL = "1m"          # Cambiar a "5m" si se prefiere menor granularidad
LIMIT_PER_REQ = 1000     # Máximo permitido por la API
TARGET_TOTAL = 5000      # Total de velas a descargar (TARGET_TOTAL <= 1000 => 1 req)
SLEEP_BETWEEN_REQUESTS = 0.15  # ~400 req/min, bien por debajo del límite de 1200
MAX_RETRIES = 5
BACKOFF_BASE = 2.0       # segundos base para exponential backoff

OUTPUT_CSV = "data/btcusdt_returns.csv"


def fetch_klines(
    symbol: str,
    interval: str,
    limit: int = 1000,
    start_time_ms: Optional[int] = None,
    end_time_ms: Optional[int] = None,
) -> List[List[Any]]:
    """
    Descarga un bloque de velas desde Binance con reintentos y backoff exponencial.
    """
    params: Dict[str, Any] = {
        "symbol": symbol,
        "interval": interval,
        "limit": limit,
    }
    if start_time_ms is not None:
        params["startTime"] = start_time_ms
    if end_time_ms is not None:
        params["endTime"] = end_time_ms

    for attempt in range(1, MAX_RETRIES + 1):
        try:
            response = requests.get(BASE_URL, params=params, timeout=30)

            if response.status_code == 429:
                retry_after = int(response.headers.get("Retry-After", 5))
                print(f"⚠️  Rate limit alcanzado (429). Esperando {retry_after}s... (intento {attempt}/{MAX_RETRIES})")
                time.sleep(retry_after)
                continue

            if response.status_code == 418:
                print(f"🚫 IP baneada por violación de límites (418). Abortando.")
                sys.exit(1)

            response.raise_for_status()
            data = response.json()

            if not isinstance(data, list):
                print(f"⚠️  Respuesta inesperada: {data}")
                if attempt < MAX_RETRIES:
                    time.sleep(BACKOFF_BASE ** attempt)
                    continue
                return []

            return data

        except requests.exceptions.RequestException as exc:
            print(f"⚠️  Error de red en intento {attempt}/{MAX_RETRIES}: {exc}")
            if attempt < MAX_RETRIES:
                time.sleep(BACKOFF_BASE ** attempt)
            else:
                raise

    return []


def download_series(
    symbol: str,
    interval: str,
    total_klines: int,
    limit_per_req: int = 1000,
) -> pd.DataFrame:
    """
    Descarga una serie temporal completa paginando hacia atrás desde el momento actual.
    """
    all_klines: List[List[Any]] = []
    remaining = total_klines
    end_time_ms = None

    print(f"📥 Descargando hasta {total_klines} velas {interval} de {symbol}...")

    while remaining > 0:
        req_limit = min(limit_per_req, remaining)
        klines = fetch_klines(
            symbol=symbol,
            interval=interval,
            limit=req_limit,
            end_time_ms=end_time_ms,
        )

        if not klines:
            print("⚠️  No se recibieron más datos. Posiblemente se alcanzó el inicio del historial.")
            break

        all_klines.extend(klines)
        remaining -= len(klines)

        # El primer elemento de cada vela es el timestamp de apertura en ms
        earliest_open_time = int(klines[0][0])
        end_time_ms = earliest_open_time - 1  # para la siguiente página

        print(f"   → Recibidas {len(klines)} velas. Total acumulado: {len(all_klines)}")

        if remaining > 0:
            time.sleep(SLEEP_BETWEEN_REQUESTS)

    # -----------------------------------------------------------------------
    # Construir DataFrame
    # -----------------------------------------------------------------------
    # Estructura de la API según documentación oficial:
    # [openTime, open, high, low, close, volume, closeTime, quoteVolume,
    #  numTrades, takerBuyBaseVolume, takerBuyQuoteVolume, ignore]
    df = pd.DataFrame(
        all_klines,
        columns=[
            "open_time_ms",
            "open",
            "high",
            "low",
            "close",
            "volume",
            "close_time_ms",
            "quote_volume",
            "num_trades",
            "taker_buy_base",
            "taker_buy_quote",
            "ignore",
        ],
    )

    # Convertir tipos numéricos
    numeric_cols = ["open", "high", "low", "close", "volume", "quote_volume",
                    "num_trades", "taker_buy_base", "taker_buy_quote"]
    for col in numeric_cols:
        df[col] = pd.to_numeric(df[col], errors="coerce")

    df["open_time_ms"] = pd.to_numeric(df["open_time_ms"], errors="coerce").astype("int64")
    df["close_time_ms"] = pd.to_numeric(df["close_time_ms"], errors="coerce").astype("int64")

    # Ordenar cronológicamente (ascendente)
    df = df.sort_values("open_time_ms").reset_index(drop=True)

    return df


def compute_log_returns(df: pd.DataFrame) -> pd.DataFrame:
    """
    Calcula los retornos logarítmicos de la columna 'close'.
    r_t = ln(P_t / P_{t-1})
    """
    df["log_return"] = np.log(df["close"] / df["close"].shift(1))
    return df


def export_to_matlab_csv(df: pd.DataFrame, path: str) -> None:
    """
    Exporta un CSV limpio compatible con MATLAB.
    """
    # Seleccionar columnas relevantes para el análisis de fractalidad
    export_df = df[[
        "open_time_ms",
        "open",
        "high",
        "low",
        "close",
        "volume",
        "num_trades",
        "log_return",
    ]].copy()

    # Agregar columna de fecha legible para referencia humana
    export_df["datetime_utc"] = pd.to_datetime(export_df["open_time_ms"], unit="ms", utc=True)

    # Reordenar: datetime primero para facilitar lectura humana
    cols = ["datetime_utc", "open_time_ms", "open", "high", "low", "close",
            "volume", "num_trades", "log_return"]
    export_df = export_df[cols]

    export_df.to_csv(path, index=False, float_format="%.8f")
    print(f"💾 CSV exportado: {path}")


def print_statistics(df: pd.DataFrame) -> None:
    """
    Imprime estadísticas descriptivas básicas de la serie de retornos.
    """
    returns = df["log_return"].dropna()

    start_dt = pd.to_datetime(df["open_time_ms"].iloc[0], unit="ms", utc=True)
    end_dt = pd.to_datetime(df["open_time_ms"].iloc[-1], unit="ms", utc=True)

    print("\n" + "=" * 60)
    print("ESTADÍSTICAS DE LA SERIE DE RETORNOS LOGARÍTMICOS")
    print("=" * 60)
    print(f"Símbolo        : {SYMBOL}")
    print(f"Intervalo      : {INTERVAL}")
    print(f"Total de velas : {len(df)}")
    print(f"Retornos válidos: {len(returns)} (n-1)")
    print(f"Rango temporal : {start_dt} → {end_dt}")
    print(f"Duración       : {end_dt - start_dt}")
    print(f"Precio apertura: {df['close'].iloc[0]:.2f} USDT")
    print(f"Precio cierre  : {df['close'].iloc[-1]:.2f} USDT")
    print("-" * 60)
    print(f"Media (μ)      : {returns.mean():.8f}")
    print(f"Mediana        : {returns.median():.8f}")
    print(f"Desv. std (σ)  : {returns.std():.8f}")
    print(f"Mínimo         : {returns.min():.8f}")
    print(f"Máximo         : {returns.max():.8f}")
    print(f"Skewness       : {returns.skew():.4f}")
    print(f"Kurtosis       : {returns.kurtosis():.4f}")
    print("=" * 60)
    print("\nPrimeras 5 filas:")
    print(df.head())
    print("\nÚltimas 5 filas:")
    print(df.tail())


def main() -> None:
    import numpy as np  # import local para evitar overhead si se usa como módulo
    global np

    # Crear directorio de salida si no existe
    import os
    os.makedirs(os.path.dirname(OUTPUT_CSV) or ".", exist_ok=True)

    # Descargar datos
    df = download_series(
        symbol=SYMBOL,
        interval=INTERVAL,
        total_klines=TARGET_TOTAL,
        limit_per_req=LIMIT_PER_REQ,
    )

    if df.empty:
        print("❌ No se pudieron descargar datos.")
        sys.exit(1)

    # Calcular retornos logarítmicos
    df["log_return"] = np.log(df["close"] / df["close"].shift(1))

    # Exportar
    export_to_matlab_csv(df, OUTPUT_CSV)

    # Estadísticas
    print_statistics(df)

    # Nota sobre rate limits
    print("\n" + "=" * 60)
    print("NOTA SOBRE RATE LIMITS DE LA API DE BINANCE")
    print("=" * 60)
    print("• Límite general : 1200 requests/minuto por IP.")
    print("• Este script usa SLEEP_BETWEEN_REQUESTS=0.15s (~400 req/min).")
    print("• Si recibís 429: se aplica backoff exponencial automático.")
    print("• Si recibís 418: la IP fue baneada; detener ejecución inmediatamente.")
    print("=" * 60)


if __name__ == "__main__":
    main()
