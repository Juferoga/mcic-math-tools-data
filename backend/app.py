"""
FastAPI backend para exponer la simulación como un servicio REST.

Endpoint principal:
POST /simulate
  cuerpo JSON: {"lam": float, "mu": float, "K": int, "sample_size": int, "seed": Optional[int]}
  respuesta JSON: {"times": [...], "states": [...], "blocking_probability": float, "mean_wait": float}

Ejecutar:
uvicorn backend.app:app --reload --port 8000
"""
from __future__ import annotations
from typing import List, Optional
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

from src.core.simulation import simulate_from_rates

app = FastAPI(title="MM1K Simulation API", version="0.1")


class SimRequest(BaseModel):
    lam: float = Field(..., gt=0.0, description="Tasa de llegada (lambda)")
    mu: float = Field(..., gt=0.0, description="Tasa de servicio (mu)")
    K: int = Field(10, gt=0, description="Capacidad total del sistema (incluye el que está en servicio)")
    sample_size: int = Field(10000, gt=0, description="Número de arribos a simular")
    seed: Optional[int] = Field(None, description="Semilla opcional para reproducibilidad")


class SimResponse(BaseModel):
    times: List[float]
    states: List[int]
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
        res = simulate_from_rates(lam=req.lam, mu=req.mu, K=req.K, sample_size=req.sample_size, seed=req.seed)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    return SimResponse(
        times=res.event_times.tolist(),
        states=res.system_sizes.tolist(),
        blocking_probability=res.blocking_probability,
        mean_wait=res.mean_wait,
    )
