"""
Discrete-event simulation engine for an M/M/1/K queue (single server, exponential interarrivals and services,
finite capacity K including the one in service).

API:
- simulate_mm1k(interarrival_times, service_times, K) -> SimulationResult
  -> accepts two numpy arrays (tiempos entre arribos, tiempos de servicio) and returns detailed metrics

- simulate_from_rates(lam, mu, K, sample_size, seed=None) -> SimulationResult
  -> wrapper that generates exponential samples and runs the main simulator

The implementation is event-driven (next-event selection between arrival and departure), records
system size at each event and per-customer waiting times (time in queue before service start).

Author: Sekmeth (auto-generated)
Date: 2026-04-18
"""
from __future__ import annotations
from dataclasses import dataclass
from typing import List, Optional, Tuple
import math
import numpy as np


@dataclass
class SimulationResult:
    event_times: np.ndarray  # timestamps of events (arrival or departure)
    system_sizes: np.ndarray  # system size (n in system) after each event
    wait_times: np.ndarray  # waiting times in queue for each accepted customer (service_start - arrival)
    blocked_count: int
    total_arrivals: int
    blocking_probability: float
    mean_wait: float


def simulate_mm1k(interarrival_times: np.ndarray, service_times: np.ndarray, K: int) -> SimulationResult:
    """
    Ejecuta una simulación por eventos discretos de una cola M/M/1/K.

    Parámetros:
    - interarrival_times: vector de tiempos entre arribos (no tiempos absolutos).
    - service_times: vector de duraciones de servicio.
    - K: capacidad total del sistema (incluye el cliente en servicio). P. ej. K=1 significa que solo el servidor
         puede atender a 1 cliente (sin cola).

    Retorna:
    SimulationResult con la evolución temporal (event_times, system_sizes) y métricas (P_block, E[Tw]).
    """
    if K < 1:
        raise ValueError("K debe ser >= 1 (capacidad total del sistema incluyendo el que está en servicio)")

    # Preparar vectores
    interarrival = np.asarray(interarrival_times, dtype=float)
    service = np.asarray(service_times, dtype=float)
    n_arrivals = interarrival.shape[0]
    if n_arrivals == 0:
        raise ValueError("interarrival_times no puede estar vacío")

    # tiempos absolutos de llegada
    arrival_times = np.cumsum(interarrival)

    # Guardar por seguridad suficientes tiempos de servicio (se usan cuando empieza cada servicio)
    if service.shape[0] < n_arrivals:
        # si no hay suficientes, rellenar con la última (poco elegante) o lanzar error
        raise ValueError("service_times debe contener al menos tantos valores como arrivals (para asignar servicios)")

    INF = float("inf")

    arrival_idx = 0
    next_arrival = arrival_times[0] if arrival_times.size > 0 else INF
    next_departure = INF

    current_time = 0.0
    current_serving_idx: Optional[int] = None  # índice del cliente en servicio dentro de accepted_list
    queue: List[int] = []  # índices FIFO de accepted_list que esperan servicio
    accepted: List[dict] = []  # por cliente aceptado: {'arrival_time', 'service_start_time', 'departure_time'}

    event_times: List[float] = []
    system_sizes: List[int] = []

    blocked = 0
    total_arrivals = 0
    service_idx = 0  # índice para consumir service_times

    # loop de eventos
    while True:
        # escoger el siguiente evento
        if next_arrival <= next_departure:
            # evento: llegada
            current_time = float(next_arrival)
            total_arrivals += 1

            # número en sistema antes de procesar la llegada
            in_system = (1 if current_serving_idx is not None else 0) + len(queue)

            if in_system < K:
                # aceptar
                cust = {"arrival_time": current_time, "service_start_time": None, "departure_time": None}
                accepted.append(cust)
                cust_idx = len(accepted) - 1

                if current_serving_idx is None:
                    # servidor estaba libre -> iniciar servicio inmediatamente
                    cust["service_start_time"] = current_time
                    s = float(service[service_idx])
                    cust["departure_time"] = current_time + s
                    service_idx += 1
                    current_serving_idx = cust_idx
                    next_departure = cust["departure_time"]
                else:
                    # encolado
                    queue.append(cust_idx)
            else:
                # sistema lleno -> bloqueo
                blocked += 1

            arrival_idx += 1
            next_arrival = arrival_times[arrival_idx] if arrival_idx < n_arrivals else INF

            # registro de la evolución
            event_times.append(current_time)
            system_sizes.append((1 if current_serving_idx is not None else 0) + len(queue))

        else:
            # evento: salida/departure
            current_time = float(next_departure)

            if current_serving_idx is None:
                # no debería ocurrir, pero protegemos
                next_departure = INF
                break

            # completar servicio del cliente en servicio
            accepted[current_serving_idx]["departure_time"] = current_time

            # servidor libre ahora
            current_serving_idx = None

            if queue:
                # sacar siguiente de la cola y empezar servicio
                next_idx = queue.pop(0)
                accepted[next_idx]["service_start_time"] = current_time
                s = float(service[service_idx])
                accepted[next_idx]["departure_time"] = current_time + s
                service_idx += 1
                current_serving_idx = next_idx
                next_departure = accepted[next_idx]["departure_time"]
            else:
                next_departure = INF

            # registro de la evolución
            event_times.append(current_time)
            system_sizes.append((1 if current_serving_idx is not None else 0) + len(queue))

        # condición de parada: ya procesamos todos los arribos y no quedan clientes en sistema
        if arrival_idx >= n_arrivals and current_serving_idx is None and len(queue) == 0:
            break

    # calcular métricas
    wait_times = np.array([
        a["service_start_time"] - a["arrival_time"] if a["service_start_time"] is not None else math.nan
        for a in accepted
    ], dtype=float)

    # excluir NaNs (no deberían existir si la simulación terminó correctamente)
    valid_waits = wait_times[~np.isnan(wait_times)]

    mean_wait = float(np.mean(valid_waits)) if valid_waits.size > 0 else 0.0
    blocking_probability = float(blocked) / float(total_arrivals) if total_arrivals > 0 else 0.0

    return SimulationResult(
        event_times=np.array(event_times, dtype=float),
        system_sizes=np.array(system_sizes, dtype=int),
        wait_times=wait_times,
        blocked_count=blocked,
        total_arrivals=total_arrivals,
        blocking_probability=blocking_probability,
        mean_wait=mean_wait,
    )


def simulate_from_rates(lam: float, mu: float, K: int, sample_size: int = 10000, seed: Optional[int] = None) -> SimulationResult:
    """
    Wrapper que genera tiempos exponenciales a partir de las tasas y llama a simulate_mm1k.

    - lam: tasa de llegada (lambda)
    - mu: tasa de servicio (mu)
    - K: capacidad total del sistema
    - sample_size: número de arribos a generar
    - seed: semilla para np.random.default_rng
    """
    if lam <= 0 or mu <= 0:
        raise ValueError("lam y mu deben ser > 0")

    rng = np.random.default_rng(seed)
    interarrival = rng.exponential(1.0 / lam, size=sample_size)
    services = rng.exponential(1.0 / mu, size=sample_size)

    return simulate_mm1k(interarrival, services, K)
