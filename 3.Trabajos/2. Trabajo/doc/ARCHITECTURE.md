# Arquitectura y diseño (DDD) — Trabajo 2

Resumen ejecutivo (1 párrafo):

Este proyecto sigue un enfoque dirigido por el dominio (DDD) para modelar colas M/M/k/k. El dominio central es la simulación de colas — encapsulado en el paquete `src.core` — que expone servicios de dominio (motor de simulación y fórmulas analíticas). La capa de aplicación (scripts en `src.analysis`) orquesta experimentos, validación y generación de figuras. La capa de interfaz/entrega está representada por `backend/app.py` (FastAPI) que actúa como fachada: recibe parámetros, delega al servicio de dominio y devuelve los resultados listos para graficar en el frontend. La separación facilita pruebas unitarias, reproducibilidad y extensión a un frontend React.

Componentes principales:

- Dominio (`src/core`):
  - SimulationService (funciones en simulation.py): lógica de eventos discretos, entidades ligeras (registros de cliente aceptado).
  - Theory (theory.py): fórmulas cerradas para M/M/1 y M/M/k/k.

- Aplicación (`src/analysis`): scripts para análisis de sensibilidad y utilidades de validación estadística (QQ-plot, histogramas).

- Interfaz (API): `backend/app.py` — contrato REST simple (POST /simulate) que retorna coordenadas (X,Y) y métricas.

- Infra / Reproducibilidad:
  - requirements.txt para dependencias.
  - Estructura de carpetas: `src/`, `doc/`, `data/`, `README.md`, `TAREA.md`.

Decisiones de diseño relevantes:

- Modelado M/M/k/k: elegimos capacidad finita porque permite comparar bloqueo P_k y controlar estabilidad cuando A>=1.
- Motor de simulación orientado a vectores de tiempos (interarrival/service) para facilitar reproducibilidad y pruebas unitarias.
- API recibe parámetros básicos (lam, mu, K, sample_size, seed) y devuelve listas para graficar; el frontend es responsable de renderizar.

Extensiones futuras:

- Soporte de múltiples servidores (M/M/c/K).
- Persistencia de experimentos en una base de datos para reproducibilidad y dashboard.
- Frontend React con visualización interactiva (Plotly/React-Plotly)
