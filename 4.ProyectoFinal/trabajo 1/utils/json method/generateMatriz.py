# Como se usa?
# Crea un arhivo tablatura.json donde se copia el json completo de la canción junto donde esta el script
# Al correrlo deberia generar un arhivo 'matriz_matlab.txt' con formato 

import json
from fractions import Fraction

def json_a_matriz_matlab(archivo_entrada, archivo_salida):
    try:
        with open(archivo_entrada, 'r', encoding='utf-8') as f:
            datos = json.load(f)
    except Exception as e:
        print(f"Error al leer el archivo: {e}")
        return

    # La pagina maneja 2 formatos principales, que varian ciertos atributos, el script lo soporta en esta parte
    es_base_cero = False
    for measure in datos.get("measures", []):
        for voice in measure.get("voices", []):
            for beat in voice.get("beats", []):
                for nota in beat.get("notes", []):
                    if nota.get("string") == 0:
                        es_base_cero = True
                        break

    # Se preocesa el formato para construir la matriz
    with open(archivo_salida, 'w', encoding='utf-8') as f_out:

        for i, measure in enumerate(datos.get("measures", [])):
            index_compas = measure.get("index", i + 1)
            f_out.write(f"    % Compas {index_compas}\n")

            if not measure.get("voices") or not measure["voices"][0].get("beats"):
                continue

            eventos = []

            for beat in measure["voices"][0]["beats"]:
                es_silencio = beat.get("rest", False)
                notas = beat.get("notes", [])

                if notas and notas[0].get("rest") is True:
                    es_silencio = True

                duracion = beat.get("duration", [1, 1])
                fraccion_dur = Fraction(duracion[0], duracion[1])

                es_ligadura = False
                if not es_silencio and notas:
                    es_ligadura = any(nota.get("tie", False) for nota in notas)

                if es_ligadura and eventos:
                    eventos[-1]["duration"] += fraccion_dur
                else:
                    cuerdas = [-1, -1, -1, -1, -1, -1]

                    if not es_silencio:
                        for nota in notas:
                            fret = nota.get("fret")
                            string = nota.get("string")

                            if fret is not None and string is not None:
                                # Aca se hace una distinción importante en los formatos
                                if es_base_cero:
                                    idx_cuerda = 5 - string  # Para archivos que usan 0-5
                                else:
                                    idx_cuerda = 6 - string  # Para archivos que usan 1-6

                                if 0 <= idx_cuerda <= 5:
                                    cuerdas[idx_cuerda] = fret

                    eventos.append({
                        "cuerdas": cuerdas,
                        "duration": fraccion_dur
                    })

            for ev in eventos:
                cuerdas_str = " ".join(str(c) for c in ev["cuerdas"])
                dur_str = str(ev["duration"])
                f_out.write(f"    {cuerdas_str} {dur_str};...\n")

    print(f"Archivo generado exitosamente: {archivo_salida}")

# Ya :D
json_a_matriz_matlab('tablatura.json', 'matriz_matlab.txt')