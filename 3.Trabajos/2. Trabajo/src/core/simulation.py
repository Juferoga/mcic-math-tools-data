"""
Discrete-event simulation engine for an M/M/k/k queue (Erlang B):
- k parallel servers, no waiting room (capacity = k)
- arrivals: Poisson process (exponential interarrival times)
- service: exponential with rate mu

API:
- simulate_mmk_k(interarrival_times, service_times, k) -> SimulationResult
- simulate_from_rates(lam, mu, k, sample_size, seed=None) -> SimulationResult

Notes:
- If an arrival finds all k servers busy it is blocked (counted as lost).
- Waiting times in queue are always 0 for accepted customers (service starts immediately).

Date: 2026-04-18
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import List, Optional
import math
import heapq
import numpy as np


@dataclass
class SimulationResult:
    event_times: np.ndarray  # timestamps of events (arrival or departure)
    system_sizes: np.ndarray  # number of busy servers after each event
    wait_times: (
        np.ndarray
    )  # waiting times in queue for each accepted customer (all zeros here)
    blocked_count: int
    total_arrivals: int
    blocking_probability: float
    mean_wait: float


def simulate_mmk_k(
    interarrival_times: np.ndarray, service_times: np.ndarray, k: int
) -> SimulationResult:
    """
    Simulación por eventos discretos de una cola M/M/k/k (Erlang B).

    Parámetros:
    - interarrival_times: vector de tiempos entre arribos (no tiempos absolutos).
    - service_times: vector de duraciones de servicio (suficientes para los aceptados).
    - k: número de servidores paralelos (capacidad total del sistema, sin cola).

    Retorna:
    SimulationResult con métricas (P_block, mean_wait=0) y evolución temporal.
    """
    if k < 1:
        raise ValueError("k debe ser >= 1 (número de servidores)")

    interarrival = np.asarray(interarrival_times, dtype=float)
    service = np.asarray(service_times, dtype=float)
    n_arrivals = interarrival.shape[0]
    if n_arrivals == 0:
        raise ValueError("interarrival_times no puede estar vacío")

    arrival_times = np.cumsum(interarrival)

    # heap de tiempos de salida (departure times) para clientes en servicio
    departures_heap: List[float] = []

    event_times: List[float] = []
    system_sizes: List[int] = []

    blocked = 0
    total_arrivals = 0
    service_idx = 0

    # lista de wait_times (seran 0 para aceptados)
    wait_times_list: List[float] = []

    # Procesar cada llegada en orden de tiempo
    for arrival_time in arrival_times:
        # liberar servidores cuya salida ocurren antes o en arrival_time
        while departures_heap and departures_heap[0] <= arrival_time:
            dep = heapq.heappop(departures_heap)
            # registrar evento de salida
            event_times.append(float(dep))
            system_sizes.append(len(departures_heap))

        total_arrivals += 1
        busy = len(departures_heap)
        if busy < k:
            # aceptar: servicio inicia inmediatamente
            if service_idx >= service.shape[0]:
                raise ValueError(
                    "service_times debe contener al menos tantos valores como clientes aceptados"
                )
            s = float(service[service_idx])
            service_idx += 1
            dep_time = float(arrival_time + s)
            heapq.heappush(departures_heap, dep_time)

            # registro: llegada y nuevo tamaño del sistema
            event_times.append(float(arrival_time))
            system_sizes.append(len(departures_heap))

            # espera en cola = 0
            wait_times_list.append(0.0)
        else:
            # bloqueo
            blocked += 1
            # registrar la llegada como evento (opcional) - tamaño inalterado
            event_times.append(float(arrival_time))
            system_sizes.append(len(departures_heap))

    # procesar las salidas restantes
    while departures_heap:
        dep = heapq.heappop(departures_heap)
        event_times.append(float(dep))
        system_sizes.append(len(departures_heap))

    wait_times = np.array(wait_times_list, dtype=float)
    mean_wait = float(np.mean(wait_times)) if wait_times.size > 0 else 0.0
    blocking_probability = (
        float(blocked) / float(total_arrivals) if total_arrivals > 0 else 0.0
    )

    return SimulationResult(
        event_times=np.array(event_times, dtype=float),
        system_sizes=np.array(system_sizes, dtype=int),
        wait_times=wait_times,
        blocked_count=blocked,
        total_arrivals=total_arrivals,
        blocking_probability=blocking_probability,
        mean_wait=mean_wait,
    )


# alias explícito alineado al modelo M/M/k/k
simulate_mmkk = simulate_mmk_k


def simulate_from_rates(
    lam: float, mu: float, k: int, sample_size: int = 10000, seed: Optional[int] = None
) -> SimulationResult:
    """
    Genera muestras exponenciales a partir de las tasas y llama a simulate_mmk_k.

    - lam: tasa de llegada (lambda)
    - mu: tasa de servicio (mu)
    - k: número de servidores
    - sample_size: número de arribos a generar
    - seed: semilla para reproducibilidad
    """
    if lam < 0 or mu <= 0:
        raise ValueError("lam >= 0 y mu > 0")

    rng = np.random.default_rng(seed)
    interarrival = (
        rng.exponential(1.0 / lam, size=sample_size)
        if lam > 0
        else np.full(sample_size, np.inf)
    )
    services = rng.exponential(1.0 / mu, size=sample_size)

    return simulate_mmk_k(interarrival, services, k)
