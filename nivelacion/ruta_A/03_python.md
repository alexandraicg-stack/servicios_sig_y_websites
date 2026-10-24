# Ruta A · A3 — Python básico (3 h)

**Meta:** leer y procesar datos con Python sin depender de que "alguien pase el script". Primero sin librerías, luego con `pandas`.

---

## 1. Instalación y entorno virtual

- Instala Python 3.11+ desde <https://python.org> (en Windows marca **"Add Python to PATH"**) o usa `uv` (<https://docs.astral.sh/uv/>), más rápido.
- Un **entorno virtual** aísla las librerías de cada proyecto para no romper el sistema:

```bash
python -m venv venv
# activar:
source venv/bin/activate        # Unix: Git Bash / mac / Linux
.\venv\Scripts\Activate.ps1     # PowerShell (Windows)
venv\Scripts\activate.bat       # CMD (Windows)
pip install pandas
```

Cuando el prompt muestra `(venv)` estás dentro. `deactivate` sale.

---

## 2. Lo esencial del lenguaje

```python
# tipos
nombre = "Tunja"          # str
poblacion = 172000        # int
area = 121.5              # float

# listas y diccionarios
municipios = ["Tunja", "Duitama", "Sogamoso"]
municipio = {"nombre": "Tunja", "codigo": "15001", "area": 121.5}

# condicional y bucle
for m in municipios:
    if m.startswith("S"):
        print(m, "empieza por S")

# función
def area_en_hectareas(km2):
    return km2 * 100
```

**Errores típicos:** indentación (usa 4 espacios, nunca mezcles con tabs), rutas Windows (`C:\datos` → usa `/` o `r"C:\datos"`), y encoding (abre siempre con `encoding="utf-8"`).

---

## 3. Leer archivos: `json` y `csv`

Un GeoJSON es un JSON. Puedes leerlo con la librería estándar:

```python
import json

with open("datos/provincias_boyaca.geojson", encoding="utf-8") as f:
    datos = json.load(f)

print("Número de features:", len(datos["features"]))
primero = datos["features"][0]["properties"]
print(primero)   # verás 'provincia', 'NOMBRE_ENT', 'cod_mun', ...
```

---

## Ejercicio A3 — Municipios por provincia

El archivo `provincias_boyaca.geojson` trae los 123 municipios con un campo `provincia`. Cuenta cuántos municipios hay en cada provincia.

**Parte 1 — sin pandas (solo librería estándar):**

```python
import json
from collections import Counter

with open("datos/provincias_boyaca.geojson", encoding="utf-8") as f:
    datos = json.load(f)

conteo = Counter(
    feat["properties"]["provincia"]
    for feat in datos["features"]
)

for provincia, n in conteo.most_common():
    print(f"{provincia:20} {n}")
```

**Parte 2 — con pandas:**

```python
import pandas as pd

props = [f["properties"] for f in datos["features"]]
df = pd.DataFrame(props)
print(df.groupby("provincia").size().sort_values(ascending=False))
```

**Pregunta de cierre:** ¿cuántas provincias distintas hay? (Debe darte ~13, no 123 — eso te confirma la diferencia entre "municipio" y "provincia").

**Entregable:** captura de la salida de ambas partes.
