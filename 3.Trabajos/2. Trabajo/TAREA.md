# Enunciado y Rúbrica — Trabajo 2

## Enunciado (definición del proyecto — extraído de la conversación con el docente / especificación del equipo)

Actuaremos como ingenieros para desarrollar un proyecto full-stack (Backend en Python/FastAPI, Frontend en React y Core Matemático en MATLAB/Python) cuya tarea central es modelar y simular una cola de Markov (M/M/1/K) variando el parámetro de tráfico A = lambda/mu. Se debe contrastar la simulación empírica frente al modelo analítico (ecuaciones de estado estacionario) y entregar código reproducible y un informe con resultados y discusión.

### Requisitos funcionales (resumen)
- Implementar un motor de simulación por eventos discretos que reciba vectores de `tiempos_entre_arribos` y `tiempos_de_servicio` y devuelva tiempos de espera y la evolución del estado del sistema.
- Implementar las fórmulas teóricas cerradas para E[Tw] (tiempo medio de espera en cola) y P_k (probabilidad de bloqueo) para M/M/1/K.
- Generar análisis de sensibilidad variando A = lambda/mu y comparar simulación vs teoría con gráficas.
- Incluir validación estadística (QQ-plot vs exponencial y histogramas).
- Exponer la simulación mediante un endpoint POST /simulate (FastAPI) que devuelva coordenadas (X,Y) para graficar.

## Especificaciones entregables
- Código fuente en `src/` (módulos separados: `core/` para dominio matemático, `analysis/` para scripts, `backend/` para API).
- Documentación técnica y diagrama DDD en `doc/`.
- Scripts reproducibles para ejecutar análisis y generar figuras (`src/analysis/sensitivity.py`).
- README y TAREA.md actualizados con instrucciones.

## Rúbrica (adaptada al enunciado)
Total: 100 puntos

1) Correctitud matemática y modelado — 35 puntos
- Precisión en las fórmulas y en la implementación (incluye manejo de casos límite).

2) Calidad del motor de simulación — 25 puntos
- Código modular, tipado y correctamente documentado; manejo de semillas y reproducibilidad.

3) Experimentos y comparativa (simulación vs teoría) — 25 puntos
- Análisis de sensibilidad, gráficas claras, y discusión estadística.

4) API y reproducibilidad — 10 puntos
- Endpoint funcional /simulate; instrucciones para ejecutar el servicio.

5) Presentación y documentación — 5 puntos
- README, doc/ARCHITECTURE.md y comentarios claros.

## Enunciado técnico detallado (lo que implementó el agente)

- Core matemático (Python): `src/core/simulation.py`, `src/core/theory.py`.
- Análisis y validación: `src/analysis/sensitivity.py`, `src/analysis/validation.py`.
- Backend (FastAPI): `backend/app.py`.
- Dependencias: `requirements.txt` (fastapi, uvicorn, numpy, scipy, matplotlib, pydantic).

## Cómo ejecutar (entorno de desarrollo)

1. Crear un entorno virtual e instalar dependencias:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

2. Ejecutar el servidor de la API:

```bash
uvicorn backend.app:app --reload --port 8000
```

3. Ejecutar el análisis de sensibilidad (genera figuras en `doc/plots` y resultados en `data/`):

```bash
python -m src.analysis.sensitivity --mu 1.0 --K 10 --sample-size 20000 --replicates 3
```

## Diseño DDD (breve)

- Bounded Context: `simulación de colas`.
- Entidades: `Customer` (registros internos), `Server` (estado: libre/ocupado).
- Servicios de Dominio: `SimulationService` (en `src/core/simulation.py`).
- DTO / API: request/response en `backend/app.py` (SimRequest / SimResponse).
- Scripts de Application: `src/analysis/*` orquestan experimentos y validaciones.

## Siguiente paso
Pega aquí si quieres que:
- Ajuste la rúbrica con criterios cuantitativos del profesor
- Genere un notebook de ejemplo (`notebook.ipynb`) con un análisis paso a paso
- Arme el scaffold del frontend en React que consuma `/simulate`

---

*TAREA.md actualizado automáticamente por Sekmeth con la especificación recibida.*
