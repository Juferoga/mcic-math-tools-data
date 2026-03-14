#!/usr/bin/env python3
import sys
import os
import re
import argparse
from music21 import converter, note, chord, tempo
from fractions import Fraction

def limpiar_nombre(nombre):
    """Limpia el string para que sea un nombre de archivo válido."""
    nombre = re.sub(r'[^\w\s-]', '', nombre).strip().lower()
    return re.sub(r'[-\s]+', '_', nombre)

def main():
    parser = argparse.ArgumentParser(description="Extrae pistas MIDI y las convierte a matriz para MATLAB.")
    parser.add_argument("ruta_midi", help="Ruta completa o relativa al archivo .mid")
    args = parser.parse_args()

    print(f"\n[+] Cargando archivo: {args.ruta_midi} ...")
    
    try:
        midi_data = converter.parse(args.ruta_midi)
    except Exception as e:
        print(f"[!] Error al cargar el archivo MIDI: {e}")
        sys.exit(1)

    bpm = 120
    tempos_encontrados = midi_data.flat.getElementsByClass(tempo.MetronomeMark)
    if tempos_encontrados:
        bpm = round(tempos_encontrados[0].number)
        print(f"[+] Tempo detectado: {bpm} BPM")

    partes = midi_data.parts
    if not partes:
        print("[!] No se encontraron pistas válidas en el archivo.")
        sys.exit(1)

    print("\n[?] Pistas disponibles en el archivo:")
    for i, part in enumerate(partes):
        nombre = part.partName if part.partName else f"Pista_Desconocida_{i}"
        print(f"    [{i}] - {nombre}")

    try:
        seleccion = int(input("\n>>> Ingresa el número de la pista que deseas extraer: "))
        if seleccion < 0 or seleccion >= len(partes):
            raise ValueError
    except ValueError:
        print("[!] Selección inválida. Saliendo del script.")
        sys.exit(1)

    pista_seleccionada = partes[seleccion]
    nombre_pista = pista_seleccionada.partName or f"Pista_{seleccion}"
    print(f"\n[*] Procesando '{nombre_pista}'...\n")

    cuerdas_midi = [40, 45, 50, 55, 59, 64]

    def obtener_trastes(midi_pitch):
        trastes = [-1, -1, -1, -1, -1, -1]
        for i in range(5, -1, -1):
            fret = midi_pitch - cuerdas_midi[i]
            if 0 <= fret <= 22:
                trastes[i] = int(fret)
                break
        return trastes

    salida_matlab =  f"%% Matriz extraída de: {os.path.basename(args.ruta_midi)}\n"
    salida_matlab += f"%% Pista: {nombre_pista}\n"
    salida_matlab += "format rat;\n\n"
    salida_matlab += "melodia = [...\n"

    for element in pista_seleccionada.flatten().notesAndRests:
        duracion_num = element.duration.quarterLength / 4.0
        
        if duracion_num <= 0:
            continue
            
        duracion_frac = Fraction(duracion_num).limit_denominator(128)
        frac_str = f"{duracion_frac.numerator}/{duracion_frac.denominator}" if duracion_frac.denominator != 1 else str(duracion_frac.numerator)
        
        if isinstance(element, note.Note):
            trastes = obtener_trastes(element.pitch.midi)
            comentario = f"% Nota: {element.nameWithOctave}"
        elif isinstance(element, chord.Chord):
            top_note = element.sortAscending()[-1]
            trastes = obtener_trastes(top_note.pitch.midi)
            comentario = f"% Nota: {top_note.nameWithOctave} (Acorde simplificado)"
        elif isinstance(element, note.Rest):
            trastes = [-1, -1, -1, -1, -1, -1]
            comentario = "% Silencio"
        else:
            continue
        
        trastes_str = " ".join([f"{t:2}" for t in trastes])
        salida_matlab += f"    {trastes_str}  {frac_str:<6}; ... {comentario}\n"

    salida_matlab += "];\n\n"
    salida_matlab += f"%% Reproducción automática\n"
    salida_matlab += f"tempo_bpm = {bpm};\n"
    salida_matlab += "generamelodia(melodia, tempo_bpm, 1);\n"

    out_dir = "out-song"
    os.makedirs(out_dir, exist_ok=True)
    
    nombre_base = limpiar_nombre(os.path.splitext(os.path.basename(args.ruta_midi))[0])
    nombre_pista_limpio = limpiar_nombre(nombre_pista)
    nombre_archivo = f"{nombre_base}_{nombre_pista_limpio}.m"
    ruta_salida = os.path.join(out_dir, nombre_archivo)

    with open(ruta_salida, 'w', encoding='utf-8') as f:
        f.write(salida_matlab)

    print(f"[+] ¡Éxito! El código MATLAB se guardó correctamente en:")
    print(f"    ---> {ruta_salida}\n")

if __name__ == '__main__':
    main()