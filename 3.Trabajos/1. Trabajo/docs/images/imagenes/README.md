# Gráficas del Proyecto: Generador Aleatorio de Melodías

Este directorio contiene las gráficas generadas en cada una de las actividades de análisis y síntesis estocástica del proyecto, diseñadas en fondo blanco y alta resolución (300 DPI) para incluirse fácilmente en el documento de entrega (Tarea 6).

Se han generado al menos 3 gráficos clave por actividad para sustentar el desarrollo matemático y computacional.

---

## 📊 Actividad 4: Independencia Estadística de Tiempos
En esta actividad se ignoró la dependencia temporal para estudiar únicamente la distribución global marginal de los tiempos de las notas.
*   **`act4_1_probabilidades.png`**: Histograma de las probabilidades estimadas de cada duración en el corpus base.
*   **`act4_2_cdf_tiempos.png`**: Función de Distribución Acumulada (CDF). Esta es la función escalonada exacta que utiliza el algoritmo de muestreo por transformada inversa para generar variables aleatorias de tiempo.
*   **`act4_3_comparacion_aleatoria.png`**: Gráfico comparativo de los primeros 50 tiempos de la canción original vs. los generados bajo independencia estadística total. Sirve para ver cómo el modelo aleatorio pierde estructura rítmica.

---

## 🔗 Actividad 5: Modelo de Markov de Tiempos Relativos
Se introduce dependencia de primer orden: la probabilidad del tiempo de la nota $i+1$ depende exclusivamente del tiempo de la nota $i$.
*   **`act5_1_heatmap_markov.png`**: Mapa de calor clásico de la Matriz de Transición de Markov $P[T_{i+1}|T_i]$. Zonas más amarillas/cálidas indican mayor probabilidad de transición.
*   **`act5_2_markov_3d.png`**: Vista en 3D (gráfico de barras tridimensional) de las probabilidades de transición condicionales. Ayuda a visualizar qué combinaciones específicas dominan (picos altos).
*   **`act5_3_comparacion_markov.png`**: Gráfico comparativo (Original vs. Markov) para las primeras 50 notas. Aquí se nota cómo el modelo estocástico de primer orden recupera la coherencia de pequeños "bloques" rítmicos.

---

## 🎸 Actividad 6: Dependencia entre Trastes y Cuerdas (Exploratorio)
Estudio exploratorio sobre la dependencia espacial (notas tocadas) independientemente de su tiempo.
*   **`act6_1_histograma_trastes.png`**: Histograma que refleja qué trastes son más presionados en el corpus original. El valor `0` indica una cuerda al aire.
*   **`act6_2_uso_cuerdas.png`**: Distribución de actividad en la guitarra. Demuestra empíricamente sobre qué cuerdas (de la 1 a la 6) recae el mayor peso melódico o armónico en las 3 canciones de Edith Piaf.
*   **`act6_3_dependencia_trastes.png`**: Gráfico de dispersión (*Scatter plot*) de transiciones que muestra el Traste de la nota actual vs el Traste de la nota siguiente. Revela visualmente patrones de movimiento y posiciones recurrentes en el mástil.

---

## 🎶 Actividad 7: Generador Aleatorio Final (Dependencia Múltiple)
El generador final fusiona acordes y tiempos en "Estados Completos" para sintetizar una nueva pieza aplicando una Cadena de Markov a todo el conjunto de información musical.
*   **`act7_1_melodia_generada.png`**: Un gráfico estilo partitura computacional (*Scatter plot*) de la nueva melodía de 200 notas. El Eje X es el avance del tiempo musical, el Eje Y la cuerda y el número es el traste.
*   **`act7_2_sparsidad_estados.png`**: Representación de la estructura (Sparsity) de la mega-matriz de transición final, que en este modelo superó los 200 estados únicos. Los puntos negros representan probabilidades mayores a cero.
*   **`act7_3_comparacion_distribuciones.png`**: Un análisis retrospectivo de validación. Compara lado a lado el histograma de tiempos del corpus original con el histograma de tiempos de la canción generada, comprobando que la generación estocástica de estados preserva la "huella dactilar" rítmica del compositor.