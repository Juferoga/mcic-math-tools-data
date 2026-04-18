"""
FastAPI backend para exponer la simulación como un servicio REST.

Endpoint principal:
POST /simulate
  cuerpo JSON: {"lam": float, "mu": float, "K": int, "sample_size": int, "seed": Optional[int]}
  respuesta JSON: {"times": [...], "states": [...], "wait_times": [...], "blocking_probability": float, "mean_wait": float}

Ejecutar:
uvicorn backend.app:app --reload --port 8000
"""
from __future__ import annotations
from typing import List, Optional
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import math
from fastapi.middleware.cors import CORSMiddleware

from src.core.simulation import simulate_from_rates

app = FastAPI(title="MM1K Simulation API", version="0.1")

# ==================== CORS ====================
origins = [
    "http://localhost:5173",      # ← Puerto donde corre Vite (frontend)
    "http://127.0.0.1:5173",
    "http://localhost:3000",      # por si usas otro puerto
    # Agrega aquí tu dominio de producción cuando deployes
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,           # o ["*"] para desarrollo (no recomendado en prod)
    allow_credentials=True,
    allow_methods=["*"],             # permite GET, POST, PUT, DELETE, OPTIONS, etc.
    allow_headers=["*"],             # permite todos los headers (Authorization, Content-Type, etc.)
)
# =============================================

class SimRequest(BaseModel):
    lam: float = Field(..., gt=0.0, description="Tasa de llegada (lambda)")
    mu: float = Field(..., gt=0.0, description="Tasa de servicio (mu)")
    k: int = Field(1, gt=0, description="Número de servidores (k) — sin cola, modelo M/M/k/k")
    sample_size: int = Field(10000, gt=0, description="Número de arribos a simular")
    seed: Optional[int] = Field(None, description="Semilla opcional para reproducibilidad")


class SimResponse(BaseModel):
    times: List[float]
    states: List[int]
    wait_times: List[float]
    blocking_probability: float
    mean_wait: float


@app.get("/health")
async def health() -> dict:
    return {"status": "ok"}


@app.post("/simulate", response_model=SimResponse)
async def simulate(req: SimRequest):
    # validar parámetros sencillos
    if req.lam <= 0 or req.mu <= 0:
        raise HTTPException(status_code=400, detail="lam y mu deben ser > 0")

    try:
        # ahora el parámetro es k (número de servidores)
        res = simulate_from_rates(lam=req.lam, mu=req.mu, k=req.k, sample_size=req.sample_size, seed=req.seed)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    # limpiar wait_times (remover NaNs si los hubiera)
    raw_waits = res.wait_times.tolist() if hasattr(res.wait_times, 'tolist') else list(res.wait_times)
    waits = [float(w) for w in raw_waits if not (isinstance(w, float) and math.isnan(w))]

    return SimResponse(
        times=res.event_times.tolist(),
        states=res.system_sizes.tolist(),
        wait_times=waits,
        blocking_probability=res.blocking_probability,
        mean_wait=res.mean_wait,
    )
