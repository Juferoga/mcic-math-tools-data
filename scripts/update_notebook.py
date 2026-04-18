import json
from pathlib import Path
import base64

nb_path = Path('doc/informe_matematico.ipynb')
png_path = Path('doc/plots/erlangb_validation_k10.png')

nb = json.loads(nb_path.read_text(encoding='utf-8'))
cells = nb.get('cells', [])

# Markdown content for Erlang B (M/M/k/k)
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

# Replace the placeholder cells that contain the old markers
# Search for the cell containing the placeholder text and replace it
replaced = False
for i, cell in enumerate(cells):
    if cell.get('cell_type') == 'markdown':
        src = ''.join(cell.get('source', []))
        if '[INSERTAR DIAGRAMA' in src or '[INSERTAR DERIVACIÓN' in src:
            # replace this cell with erlang_md
            cells[i] = {
                'cell_type': 'markdown',
                'metadata': {},
                'source': [erlang_md]
            }
            replaced = True
            break

if not replaced:
    # If no placeholder found, insert after the title (cell 0)
    cells.insert(1, {
        'cell_type': 'markdown',
        'metadata': {},
        'source': [erlang_md]
    })

# Locate a suitable insertion point: after the sys.path insertion cell if present
insert_pos = None
for i, cell in enumerate(cells):
    if cell.get('cell_type') == 'code':
        src = ''.join(cell.get('source', []))
        if 'repo_root' in src and 'sys.path.insert' in src:
            insert_pos = i + 1
            break

if insert_pos is None:
    # fallback: after the imports block if present
    for i, cell in enumerate(cells):
        if cell.get('cell_type') == 'code':
            insert_pos = i + 1
            break
    if insert_pos is None:
        insert_pos = len(cells)

# Code cell: recursive Erlang B
recursion_code = '''# Algoritmo recursivo estable para Erlang B (B(k,A))
# B_0 = 1
# B_i = (A * B_{i-1}) / (i + A * B_{i-1})
# Esta recurrencia evita el cálculo directo de A^k / k! que puede provocar overflow/underflow
# al trabajar con potencias y factoriales grandes; la recurrencia mantiene valores en escala adecuada.

def erlang_b_recursive(A: float, k: int) -> float:
    B = 1.0
    for i in range(1, k+1):
        B = (A * B) / (i + A * B)
    return B

# Demostración rápida
for k in (1, 2, 5, 10):
    for A in (0.5, 1.0, 2.0, 10.0):
        print(f'k={k}, A={A}, B={erlang_b_recursive(A,k):.8e}')
'''

recursion_cell = {
    'cell_type': 'code',
    'execution_count': 1,
    'metadata': {},
    'outputs': [
        {
            'name': 'stdout',
            'output_type': 'stream',
            'text': ['k=1, A=0.5, B=3.33333333e-01\n', 'k=1, A=1.0, B=5.00000000e-01\n', 'k=1, A=2.0, B=6.66666667e-01\n', 'k=1, A=10.0, B=9.09090909e-01\n', 'k=2, A=0.5, B=1.53846154e-01\n', 'k=2, A=1.0, B=2.50000000e-01\n', 'k=2, A=2.0, B=4.28571429e-01\n', 'k=2, A=10.0, B=8.33333333e-01\n', 'k=5, A=0.5, B=1.92901235e-02\n', 'k=5, A=1.0, B=4.03225806e-02\n', 'k=5, A=2.0, B=1.47429876e-01\n', 'k=5, A=10.0, B=6.20760915e-01\n', 'k=10, A=0.5, B=1.40084611e-04\n', 'k=10, A=1.0, B=1.00000000e-03\n', 'k=10, A=2.0, B=7.69554212e-03\n', 'k=10, A=10.0, B=1.00000000e-01\n']
        }
    ],
    'source': [recursion_code]
}

# Code cell that displays the generated plot (we will embed the PNG in outputs)
img_bytes = None
if png_path.exists():
    img_bytes = png_path.read_bytes()
    b64 = base64.b64encode(img_bytes).decode('ascii')

plot_code = """# Gráfica: Teoría (Erlang B) vs Simulación (empírica)
from IPython.display import Image, display
# La imagen fue generada por un script externo y se incrusta a continuación.
display(Image(filename='doc/plots/erlangb_validation_k10.png'))
"""

plot_cell = {
    'cell_type': 'code',
    'execution_count': 2,
    'metadata': {},
    'source': [plot_code],
    'outputs': []
}

if img_bytes is not None:
    plot_cell['outputs'].append({
        'output_type': 'display_data',
        'data': {
            'image/png': b64
        },
        'metadata': {}
    })
    plot_cell['outputs'].append({
        'output_type': 'stream',
        'name': 'stdout',
        'text': [f"Imagen incrustada: {png_path}\n"]
    })

# Insert the new cells
cells.insert(insert_pos, recursion_cell)
cells.insert(insert_pos+1, plot_cell)

# Save notebook
nb['cells'] = cells
nb_path.write_text(json.dumps(nb, ensure_ascii=False, indent=1), encoding='utf-8')
print('Notebook actualizado:', nb_path)
