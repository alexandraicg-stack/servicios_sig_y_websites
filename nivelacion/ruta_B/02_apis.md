# Ruta B · B2 — APIs y JSON (1 h)

**Meta:** consumir un servicio REST entendiendo sus parámetros, su paginación y sus límites. Es exactamente lo que harás con OGC API y con los FeatureServer de las IDE.

---

## 1. Anatomía de una petición REST

```
https://servidor/ruta/query ? param1=valor & param2=valor
└────────── endpoint ──────┘ └──────── query string ───────┘
```

Un FeatureServer de ArcGIS (como el del IDE Boyacá) acepta:

| Parámetro | Para qué | Ejemplo |
|---|---|---|
| `where` | filtro SQL | `where=NOMB_MPIO='TUNJA'` |
| `outFields` | campos a traer | `outFields=NOMB_MPIO,CODIGO_VER` (o `*`) |
| `outSR` | CRS de salida (EPSG) | `outSR=4326` |
| `f` | formato | `f=geojson` |
| `resultOffset` | desde qué registro | `resultOffset=2000` |
| `resultRecordCount` | cuántos traer | `resultRecordCount=1000` |

---

## 2. Codificación de URL

Los espacios y símbolos se codifican: espacio → `%20`, `=` → `%3D`, `'` → `%27`. Si usas `requests` con `params={...}`, la librería **codifica por ti**; no lo hagas a mano.

---

## 3. Autenticación

- Los servicios **abiertos** (IDE Boyacá, DANE, Earth Search) no piden token: son la excepción feliz que usamos para enseñar.
- Muchos otros piden **API key** o token en un header `Authorization`. Cuando los uses, el token **nunca** va en el código que subes a GitHub: va en una variable de entorno o archivo `.env` ignorado por Git.

---

## 4. El límite de 2000 y la paginación

Los FeatureServer de ArcGIS devuelven **máximo ~2000 registros por petición** (`maxRecordCount`). Para traer todo hay que **paginar**: pedir en bloques moviendo `resultOffset`.

```python
import requests

url = "https://services6.arcgis.com/Ex2fmFOuTOHRZtML/ArcGIS/rest/services/Veredas_Boyaca_2024/FeatureServer/0/query"
base = {"where": "1=1", "outFields": "NOMB_MPIO,NOMBRE_VER", "outSR": "4326", "f": "geojson"}

features, offset, bloque = [], 0, 1000
while True:
    p = {**base, "resultOffset": offset, "resultRecordCount": bloque}
    datos = requests.get(url, params=p, timeout=30).json()
    nuevos = datos.get("features", [])
    features += nuevos
    print(f"offset {offset}: +{len(nuevos)} (total {len(features)})")
    if len(nuevos) < bloque:          # último bloque
        break
    offset += bloque

print("TOTAL:", len(features))        # debe acercarse a 1.713
```

---

## Ejercicio B2

1. Ejecuta el script de paginación y confirma que recuperas las **1.713 veredas** (no solo 1.000 o 2.000).
2. Añade una línea que, al terminar, imprima cuántos municipios distintos (`NOMB_MPIO`) aparecen.
3. Modifica `resultRecordCount` a `500` y observa cuántas vueltas da el bucle. ¿Cambia el total?

**Entregable:** el script `b2_paginacion.py` + captura mostrando el total recuperado.
