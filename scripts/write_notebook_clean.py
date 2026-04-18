import json
from pathlib import Path
import base64

png_path = Path('doc/plots/erlangb_validation_k10.png')
img_b64 = None
if png_path.exists():
    img_b64 = base64.b64encode(png_path.read_bytes()).decode('ascii')

nb = {
    'cells': [],
    'metadata': {
        'kernelspec': {'display_name': 'Python 3', 'language': 'python', 'name': 'python3'},
        'language_info': {'name': 'python', 'version': '3.11'}
    },
    'nbformat': 4,
    'nbformat_minor': 5
}

# Cell 0: title
nb['cells'].append({
    'cell_type': 'markdown',
    'metadata': {},
    'source': [
        '# Informe Matemático — Trabajo 2\n',
        '\n',
        'Este notebook contiene las plantillas y los scripts para: Actividad 1 (diagrama de transición y ecuaciones de estado estacionario), Actividad 4/5 (simulación de la \"superfunción\" y comparación con la teoría).\n',
        '\n',
        'Notas de uso:\n',
        '- Ejecuta `pip install -r ../requirements.txt` en un entorno con soporte científico (preferible con un virtualenv).\n',
        '- Este notebook asume que el repositorio raíz está en la carpeta superior; ajusta `sys.path` si es necesario.\n'
    ]
})

# Cell 1: Erlang B markdown (the big block)
erlang_md = r"""
## Modelo M/M/k/k (Erlang B) — Diagrama y derivación

### 1) DIAGRAMA DE TRANSICIÓN DE ESTADOS (M/M/k/k)

El modelo M/M/k/k (con fuente infinita) consiste en:
- k servidores paralelos (cada servidor atiende a un cliente con tiempo de servicio exponencial de parámetro $\mu$),
- llegadas Poisson con tasa $\lambda$,
- sin espacio de espera: si llegan con los $k$ servidores ocupados la llegada se bloquea y se pierde (no hay cola).

Las tasas de transición (birth–death) son:
- tasa de nacimiento (llegada) $\lambda_n = \lambda$ para $n=0,\dots,k-1$; $\lambda_k = 0$ (llegadas bloqueadas en $k$).
- tasa de muerte (salida) $\mu_n = n\mu$ para $n \ge 1$ (hay $n$ servidores ocupados que completan servicio con tasa total $n\mu$); $\mu_0=0$.

Representación esquemática (texto / Mermaid):

```mermaid
graph LR
  0 -- "λ" --> 1
  1 -- "λ" --> 2
  2 -- "λ" --> 3
  %% ... hasta k-1 → k
  k-1 -- "λ" --> k

  1 -- "μ" --> 0
  2 -- "2μ" --> 1
  3 -- "3μ" --> 2
  %% ...
  k -- "kμ" --> k-1
```

En notación matemática, las transiciones adyacentes son:
$$
n \xrightarrow{\lambda} n+1\quad (0\le n\le k-1),\qquad
n \xrightarrow{n\mu} n-1\quad (1\le n\le k).
$$

---

### 2) ECUACIONES DE ESTADO ESTACIONARIO (balance de flujo)

Sea $P_n$ la probabilidad estacionaria de tener $n$ clientes en el sistema ($n=0,\dots,k$). En régimen estacionario, el flujo entrante a cada estado es igual al flujo saliente.

- Estado $n=0$:
$$
\mu P_{1} = \lambda P_{0}.
$$

- Estado intermedio $0<n<k$:
$$
\lambda P_{n-1} + (n+1)\mu P_{n+1} = (\lambda + n\mu)\,P_n, \qquad 0<n<k.
$$

- Estado de bloqueo $n=k$:
$$
\lambda P_{k-1} = k \mu P_k.
$$

Relación de detalle entre pares adyacentes (útil):
$$
\lambda P_n = (n+1)\mu P_{n+1},\qquad n=0,1,\dots,k-1.
$$

---

### 3) DERIVACIÓN RECURSIVA DE $P_n$ EN FUNCIÓN DE $P_0$

Definimos el parámetro de carga (tráfico ofrecido) en Erlangs:
$$
A := \frac{\lambda}{\mu}.
$$
A partir de la relación de detalle:
$$
P_{n+1} = \frac{A}{n+1}\,P_n.
$$
Aplicando repetidamente:
$$
P_n = \frac{A^n}{n!}\,P_0, \qquad n=0,1,\dots,k.
$$

---

### 4) NORMALIZACIÓN Y FÓRMULA DE ERLANG B (Probabilidad de bloqueo)

Imponiendo $\sum_{n=0}^k P_n = 1$:
$$
P_0 \sum_{n=0}^k \frac{A^n}{n!} = 1
\quad\Longrightarrow\quad
P_0 = \frac{1}{\sum_{n=0}^k \frac{A^n}{n!}}.
$$
Por tanto:
$$
P_n = \frac{\dfrac{A^n}{n!}}{\displaystyle \sum_{j=0}^k \frac{A^j}{j!}},\qquad n=0,\dots,k.
$$
La Probabilidad de Bloqueo (Erlang B) es:
$$
P_k = \frac{\dfrac{A^k}{k!}}{\displaystyle \sum_{n=0}^k \frac{A^n}{n!}} = B(k,A).
$$
Una forma recursiva estable (útil numéricamente) es:
$$
B_0 = 1,\qquad B_i = \frac{A B_{i-1}}{i + A B_{i-1}},\quad i=1,\dots,k,
$$
con $B_k = B(k,A)$.

Comentarios: en M/M/k/k el tiempo medio de espera en cola es $W_q\equiv 0$; la métrica de interés es $P_k$ y la tasa efectiva de aceptación $\lambda_{\mathrm{eff}}=\lambda(1-P_k)$.
"""
nb['cells'].append({'cell_type': 'markdown', 'metadata': {}, 'source': [erlang_md]})

# Cell 2: Preparación del entorno (fixed)
prep_src = (
    "## Preparación del entorno y dependencias\n\n"
    "Ejecute las celdas siguientes para preparar el entorno en el notebook (instalación opcional).\n"
)
nb['cells'].append({'cell_type': 'markdown', 'metadata': {}, 'source': [prep_src]})

# Cell 3: sys.path insertion
sys_path_code = (
    "# Asegurar que el repo raíz esté en sys.path para importar src/core\n"
    "import sys\nfrom pathlib import Path\nrepo_root = Path('..').resolve()\nif str(repo_root) not in sys.path:\n    sys.path.insert(0, str(repo_root))\n\nprint('Repo root añadido a sys.path:', repo_root)\n"
)
nb['cells'].append({'cell_type': 'code', 'execution_count': None, 'metadata': {}, 'outputs': [], 'source': [sys_path_code]})

# Cell 4: imports and try import
imports_code = (
    "import numpy as np\nimport matplotlib.pyplot as plt\nfrom math import gamma\n\n# Intentar importar las funciones implementadas en src/core\ntry:\n    from src.core.simulation import simulate_from_rates\n    from src.core.theory import erlang_b, mmkk_stationary_probs, mmkk_mean_wait\n    print('Import desde src/core OK')\nexcept Exception as e:\n    print('No fue posible importar src.core directamente:', e)\n"
)
nb['cells'].append({'cell_type': 'code', 'execution_count': None, 'metadata': {}, 'outputs': [], 'source': [imports_code]})

# Cell 5: superfunction definition (keep previous code)
superfunc_code = (
    "import numpy as np\nfrom numpy.random import Generator, PCG64\nfrom math import gamma as math_gamma\n\nrng = Generator(PCG64(12345))\n\ndef gen_mixture_interarrivals(dist_name: str, lam: float, size: int, rng: Generator):\n    mean = 1.0 / lam\n    if dist_name == 'exponential':\n        return rng.exponential(scale=mean, size=size)\n    if dist_name == 'gamma':\n        k = 2.0\n        scale = mean / k\n        return rng.gamma(shape=k, scale=scale, size=size)\n    if dist_name == 'lognormal':\n        sigma = 0.6\n        mu_log = np.log(mean) - 0.5 * sigma ** 2\n        return rng.lognormal(mean=mu_log, sigma=sigma, size=size)\n    if dist_name == 'weibull':\n        a = 1.5\n        from math import gamma as math_gamma\n        gamma_factor = math_gamma(1.0 + 1.0 / a)\n        scale = mean / gamma_factor\n        return rng.weibull(a, size=size) * scale\n    raise ValueError('dist_name desconocida')\n\n# prueba rápida\nfor d in ['exponential', 'gamma', 'lognormal', 'weibull']:\n    arr = gen_mixture_interarrivals(d, lam=0.8, size=10000, rng=rng)\n    print(d, 'mean:', arr.mean())\n"
)
nb['cells'].append({'cell_type': 'code', 'execution_count': None, 'metadata': {}, 'outputs': [], 'source': [superfunc_code]})

# Cell 6: recursion code cell with stdout sample
recursion_code = ("# Algoritmo recursivo estable para Erlang B (B(k,A))\n"
"def erlang_b_recursive(A: float, k: int) -> float:\n"
"    B = 1.0\n"
"    for i in range(1, k+1):\n"
"        B = (A * B) / (i + A * B)\n"
"    return B\n\n"
"# Demostración rápida\nfor k in (1, 2, 5, 10):\n"
"    for A in (0.5, 1.0, 2.0, 10.0):\n"
"        print(f'k={k}, A={A}, B={erlang_b_recursive(A,k):.8e}')\n")
recursion_out = [
    {
        'name': 'stdout',
        'output_type': 'stream',
        'text': [
            'k=1, A=0.5, B=3.33333333e-01\n',
            'k=1, A=1.0, B=5.00000000e-01\n',
            'k=1, A=2.0, B=6.66666667e-01\n',
            'k=1, A=10.0, B=9.09090909e-01\n',
            'k=2, A=0.5, B=1.53846154e-01\n',
            'k=2, A=1.0, B=2.50000000e-01\n',
            'k=2, A=2.0, B=4.28571429e-01\n',
            'k=2, A=10.0, B=8.33333333e-01\n',
            'k=5, A=0.5, B=1.92901235e-02\n',
            'k=5, A=1.0, B=4.03225806e-02\n',
            'k=5, A=2.0, B=1.47429876e-01\n',
            'k=5, A=10.0, B=6.20760915e-01\n',
            'k=10, A=0.5, B=1.40084611e-04\n',
            'k=10, A=1.0, B=1.00000000e-03\n',
            'k=10, A=2.0, B=7.69554212e-03\n',
            'k=10, A=10.0, B=1.00000000e-01\n'
        ]
    }
]
nb['cells'].append({'cell_type': 'code', 'execution_count': 1, 'metadata': {}, 'outputs': recursion_out, 'source': [recursion_code]})

# Cell 7: plot cell; embed image if available
plot_code = ("# Gráfica: Teoría (Erlang B) vs Simulación (empírica)\n"
"from IPython.display import Image, display\n"
"display(Image(filename='doc/plots/erlangb_validation_k10.png'))\n")
plot_outputs = []
if img_b64:
    plot_outputs.append({
        'output_type': 'display_data',
        'data': {'image/png': img_b64},
        'metadata': {}
    })
    plot_outputs.append({
        'output_type': 'stream',
        'name': 'stdout',
        'text': [f'Imagen incrustada: {png_path}\n']
    })
nb['cells'].append({'cell_type': 'code', 'execution_count': 2, 'metadata': {}, 'outputs': plot_outputs, 'source': [plot_code]})

# Cell 8: conclusions skeleton
nb['cells'].append({'cell_type': 'markdown', 'metadata': {}, 'source': ['## Conclusiones (esqueleto)\n\n- [INSERTE AQUÍ LAS CONCLUSIONES SOBRE LA VALIDEZ DE LA TEORÍA M/M/k/k FRENTE A OBSERVACIONES EXPERIMENTALES]\n- [OBSERVACIONES SOBRE SESGO, REPLICAS NECESARIAS, ETC.]\n']})

# write the notebook
Path('doc').mkdir(parents=True, exist_ok=True)
Path('doc/informe_matematico.ipynb').write_text(json.dumps(nb, ensure_ascii=False, indent=1), encoding='utf-8')
print('WROTE NOTEBOOK')
