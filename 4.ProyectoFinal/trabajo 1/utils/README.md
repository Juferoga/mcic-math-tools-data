# Generador Aleatorio de Melodías - Síntesis Karplus-Strong

[cite_start]Este repositorio contiene el desarrollo del primer trabajo grupal de Herramientas Matemáticas para el Manejo de la Información (2026-1)[cite: 3, 6]. [cite_start]El objetivo principal es diseñar y proponer un generador aleatorio de melodías basado en la dependencia estadística [cite: 13][cite_start], utilizando el algoritmo base de Karplus-Strong para la síntesis de sonido de guitarra acústica[cite: 64].

[cite_start]Para este proyecto, se seleccionaron obras del repertorio de la compositora e intérprete francesa Edith Piaf[cite: 149].

## 📂 Estructura del Proyecto

* **`/songs`**: Contiene los archivos MIDI originales de las canciones seleccionadas.
* **`/utils`**: Herramientas de extracción y procesamiento.
    * `midi2matlab.py`: Script en Python desarrollado para automatizar la extracción de las pistas melódicas de los archivos MIDI y convertirlas al formato matricial requerido por las funciones de MATLAB.
* **`generamelodia.m` & `acorde.m`**: Funciones base proporcionadas para la síntesis de audio usando el algoritmo Karplus-Strong.
* **`va.m`**: Script principal del generador aleatorio basado en probabilidad condicional y estadística.

## ⚙️ Requisitos

Para ejecutar y modificar este proyecto necesitas:
1.  **MATLAB** (Recomendado R2023a o superior).
2.  **Python 3.x** (Para la herramienta de extracción MIDI).
3.  Librería **music21** de Python.

## 🚀 Uso de la Herramienta de Extracción MIDI

Si deseas agregar nuevas canciones en formato MIDI y convertirlas a matrices de MATLAB, utiliza el script incluido en `/utils`.

1. Activa el entorno virtual:
   ```bash
   source utils/venv/bin/activate
   ```
2. Instala las dependencias (si no lo has hecho):
   ```bash
    pip install music21
    ```
3. Ejecuta el script apuntando al archivo MIDI y redirige la salida a un archivo .m:
    ```bash
    python utils/midi2matlab.py "songs/archivo_ejemplo.mid" > nueva_melodia.m
    ```
4. Sigue las instrucciones interactivas en la consola para seleccionar la pista de la melodía principal.

🎵 Síntesis en MATLAB

Una vez generadas las matrices, puedes escucharlas en MATLAB ejecutando la función generamelodia. Por ejemplo, para sintetizar a 118 BPM y escuchar el resultado:
Matlab
```
tempo = 118;
generamelodia(melodia, tempo, 1);
```
