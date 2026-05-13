# Trabajo 2 — MCIC Math Tools (Semestre 1)

Este repositorio contiene la implementación y documentación del Trabajo 2 del curso **MCIC - Herramientas Matemáticas**. El proyecto es un sistema de análisis de tráfico en redes y modelado estocástico basado en el modelo de colas **M/M/k/k (Erlang B)**.

> **Nota sobre el reporte LaTeX**: Aunque la arquitectura y el código implementan M/M/k/k y Erlang B, el abstract del archivo `doc/TrabajoGrupal2_ErlangB.tex` hace referencia a un "generador aleatorio de melodías basado en dependencia estadística (Edith Piaf)". Esta discrepancia debe ser corregida en el documento final.

## Arquitectura del Proyecto

El proyecto está diseñado con una arquitectura modular y orientada al dominio (DDD):

### 1. Frontend (`frontend/`)
Dashboard interactivo de simulación M/M/k/k enfocado en uso académico. No utiliza manejadores de estado globales complejos (como Redux o Zustand), manejando todo el estado mediante `useState/useEffect` y un hook propio `useSimulation.ts`.
- **Stack**: React 18, Vite, TypeScript, Tailwind CSS.
- **Gráficos y UI**: `recharts` para estadística, `reactflow` para diagramas de estado de Markov, y `@react-three/fiber` / `three` para una vista interactiva 3D.
- **Renderizado Matemático**: `katex` para las fórmulas de Erlang-B.

### 2. Backend (`backend/`)
API construida en **FastAPI** y servida por **Uvicorn** que expone el motor de simulación.
- **Endpoints**:
  - `GET /health`: Estado del servicio.
  - `POST /simulate`: Recibe parámetros (`lam`, `mu`, `k`, `sample_size`, `seed`) y devuelve los resultados de la simulación M/M/k/k (tiempos, estados, probabilidad de bloqueo, etc).

### 3. Core Python (`src/`)
Implementa la lógica pesada en Python de manera independiente, dividida en Dominio y Aplicación:
- **`src/core/`**: 
  - `simulation.py`: Simulación por eventos discretos de M/M/k/k (sin cola, las llamadas se rechazan si la capacidad $k$ se llena).
  - `theory.py`: Fórmulas analíticas (cerradas) para Erlang-B y probabilidades estacionarias.
- **`src/analysis/`**: 
  - `sensitivity.py`: Análisis variando $A = \lambda/\mu$ para comparar teoría vs. simulación.
  - `validation.py`: Gráficas QQ-plot e histogramas.
*(Nota: Actualmente no existe un parser en Python que consuma directamente los archivos empíricos `.TL` de la carpeta `data/`).*

### 4. Matlab (`matlab/`)
Scripts matemáticos para validación y generación empírica de distribuciones basándose en las trazas Bellcore:
- `mmkk.m`: Simulador del modelo de colas M/M/k/k para estimar la probabilidad de bloqueo.
- `superfuncion.m`: Generador de funciones empíricas a partir de datos (crea archivos `.m` dinámicamente).
- `actividad1.m`: Grafica la probabilidad de bloqueo teórica (Erlang B) variando el tráfico.
- `actividad2.m`: Demostración del simulador `mmkk.m` generando vectores exponenciales.
- `actividad3.m`: Compara la probabilidad de bloqueo simulada vs. la teórica (Erlang-B).
- `actividad4.m`: Genera las funciones empíricas (`f1` a `f4`) leyendo los archivos `.TL` (las trazas) y hace los QQ-plots contra exponenciales.
- `actividad5.m`: Simula M/M/k/k usando *arribos empíricos* (`f1` a `f4`) escalados, y los compara con la teoría Erlang-B.
- `actividad6.m`: Simulación aplicada a un entorno Cloud (Kubernetes), calculando rechazos (503 Service Unavailable) al limitar los Pods.

### 5. Datos (`data/`)
Archivos de trazas de tráfico reales de Bellcore (`BCOct89Ext.TL`, `BCpAug89.TL`, etc.). Estos archivos son consumidos por los scripts de Matlab (Actividad 4) para crear distribuciones empíricas.

### 6. Documentación (`doc/` y raíz)
- `ARCHITECTURE.md`: Resumen de diseño del sistema.
- `TrabajoGrupal2_ErlangB.tex`: Documento base para el informe final.

## Requisitos y Configuración

### Frontend y Backend (Docker)
Ambos módulos cuentan con su respectivo `Dockerfile`, lo que permite ejecutarlos fácilmente usando Docker.
- **Frontend**: `npm install` y `npm run dev`.
- **Backend**: `uvicorn backend.app:app` o construir la imagen Docker.

### Matlab
- Tener Matlab instalado.
- Ejecutar los scripts `actividadX.m` directamente en la consola de Matlab estando situados dentro de esa carpeta (ya que los scripts hacen referencia relativa a `../data/*.TL`).

## Compilar Documentación
Para compilar el PDF final en LaTeX:
```bash
cd doc
pdflatex TrabajoGrupal2_ErlangB.tex
```

## Flujo de Trabajo y Colaboración

- **Ramas**: Crear ramas descriptivas (ej: `feat/frontend-charts`, `fix/matlab-erlang`).
- **Commits**: Usar convención *Conventional Commits* (ej: `feat: agregar visualización de paquetes`, `fix: corregir cálculo de probabilidad de bloqueo`).
- **Issues**: Manejar el progreso mediante issues asignados a cada integrante.
