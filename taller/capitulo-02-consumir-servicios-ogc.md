# Capítulo 2: Explorar y consumir servicios OGC existentes

> **Taller práctico — consumir antes de publicar.** Antes de instalar PostgreSQL o GeoServer, vas a *usar* servicios web geográficos que ya existen en internet. Así entiendes qué es realmente un geoservicio y qué operaciones ofrece, para que cuando publiques los tuyos (capítulos 5 y 8) sepas exactamente qué estás construyendo.

## Objetivos del Capítulo

- Entender qué es un servicio web geográfico **consumiéndolo**, sin instalar nada.
- Practicar las operaciones básicas de **WMS**, **WFS** y **WMTS** contra servicios públicos reales de Colombia.
- Leer un `GetCapabilities` y construir peticiones a mano (`GetMap`, `GetFeature`, `GetTile`).
- Consumir los mismos servicios desde el **navegador**, **QGIS** y la **línea de comandos** (`curl` / Python).

## Requisitos

Solo necesitas un **navegador**, **QGIS** y, opcionalmente, `curl` o Python. **No** se instala ningún servidor en este capítulo.

---

## 2.1 ¿Por qué consumir antes de publicar?

Un **servicio web geográfico** es un servidor que responde peticiones sobre datos espaciales mediante estándares OGC. En vez de descargar un archivo, le *preguntas* al servidor y te responde: una imagen de mapa (WMS), las geometrías y atributos (WFS) o teselas pre-generadas (WMTS).

La mejor forma de entenderlo es usar uno que ya funciona. En Colombia hay servicios públicos que exponen estos estándares:

| Entidad | Servicio | Punto de entrada |
|---|---|---|
| **DANE** (MGN 2024) | WMS y WFS | `https://geoportal.dane.gov.co/mparcgis/services/MGN2024/Serv_CapasMGN_2024/MapServer` |
| **IGAC** | WMS (vía ArcGIS) | `https://mapas.igac.gov.co/server/rest/services` |
| **IDE Boyacá** | FeatureServer REST | `https://services6.arcgis.com/Ex2fmFOuTOHRZtML/ArcGIS/rest/services` |

> **Regla de dos rutas.** Los portales públicos a veces se caen. Si un servicio no responde en clase, usa otro de la tabla; y más adelante repetirás estas mismas operaciones contra **tu propio GeoServer**, donde tendrás control total.

---

## 2.2 Anatomía de una petición OGC

Los servicios clásicos (WMS/WFS/WMTS) se piden por **URL con parámetros** (estilo *KVP*, clave=valor):

```
https://servidor/ruta?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetCapabilities
└──────── punto de entrada ──────┘ └──────── parámetros ────────┘
```

Tres parámetros están siempre presentes:

- `SERVICE` — qué servicio: `WMS`, `WFS` o `WMTS`.
- `VERSION` — la versión del estándar (p. ej. `1.1.1`, `1.3.0`, `2.0.0`).
- `REQUEST` — qué operación: `GetCapabilities`, `GetMap`, `GetFeature`, `GetTile`…

La **primera petición siempre es `GetCapabilities`**: es el "menú" del servicio.

---

## 2.3 WMS — Web Map Service (mapas como imágenes)

El WMS devuelve **imágenes** de mapas renderizados en el servidor.

### GetCapabilities — leer el menú

Abre en el navegador:

```
https://geoportal.dane.gov.co/mparcgis/services/MGN2024/Serv_CapasMGN_2024/MapServer/WMSServer?service=WMS&request=GetCapabilities
```

En el XML busca:
- `<Layer>` — las **capas** disponibles (anota su `<Name>`, p. ej. `0`, `1`, …).
- `<CRS>` / `<SRS>` — los **sistemas de coordenadas** soportados (p. ej. `EPSG:4326`).
- `<Format>` — los **formatos** de salida (`image/png`, `image/jpeg`).
- `<Style>` — los estilos disponibles.

### GetMap — pedir una imagen

Con el nombre de capa que leíste, construye la URL a mano (WMS 1.1.1, `bbox = minx,miny,maxx,maxy` en lon/lat):

```
https://geoportal.dane.gov.co/mparcgis/services/MGN2024/Serv_CapasMGN_2024/MapServer/WMSServer?
  service=WMS&version=1.1.1&request=GetMap
  &layers=0
  &styles=                         (obligatorio; vacío = estilo por defecto)
  &srs=EPSG:4326
  &bbox=-74.5,5.1,-72.0,6.9        (aprox. Boyacá)
  &width=800&height=600
  &format=image/png
```

Pégala en el navegador: deberías ver la imagen. Cambia el `bbox`, el `width/height` o el `format` y observa el efecto.

> **Si obtienes un XML `StylesNotDefined` en lugar de la imagen**, faltó el parámetro `styles`. En WMS **1.1.1 es obligatorio**: déjalo **vacío** (`&styles=`) para usar el estilo por defecto, o indica uno del `GetCapabilities` (estas capas traen `default`, así que también sirve `&styles=default`). La respuesta de error es, además, un buen ejemplo de un `ServiceExceptionReport` de OGC.

> **Ojo con el orden de ejes.** En WMS **1.1.1** el `bbox` va `minx,miny,maxx,maxy` (lon,lat). En **1.3.0** con `EPSG:4326` el orden es lat,lon. Si el mapa "sale en blanco" o corrido, casi siempre es el orden de ejes o un CRS no soportado.

### GetFeatureInfo — consultar un punto

Parte de la misma petición `GetMap` (incluido `styles=`) y añade `request=GetFeatureInfo`, `query_layers`, `info_format=text/html` y la posición del píxel (`x`,`y` o `i`,`j`) para obtener los atributos del objeto bajo ese punto.

### En QGIS

*Capa → Agregar capa → WMS/WMTS → Nueva* → pega la URL base (sin parámetros). QGIS lee el `GetCapabilities`, lista las capas y las dibuja. Es el mismo WMS, ahora desde un cliente de escritorio.

---

## 2.4 WFS — Web Feature Service (datos vectoriales)

El WFS devuelve **geometrías y atributos** (no imágenes): puedes descargarlos y analizarlos.

### Las tres operaciones

```
# 1) Menú del servicio
.../WFSServer?service=WFS&version=2.0.0&request=GetCapabilities

# 2) Esquema de una capa (campos y tipos)
.../WFSServer?service=WFS&version=2.0.0&request=DescribeFeatureType&typeNames=<capa>

# 3) Descargar features
.../WFSServer?service=WFS&version=2.0.0&request=GetFeature&typeNames=<capa>&count=5
```

Punto de entrada WFS del DANE:

```
https://geoportal.dane.gov.co/mparcgis/services/MGN2024/Serv_CapasMGN_2024/MapServer/WFSServer?service=WFS&request=GetCapabilities
```

Parámetros útiles de `GetFeature`:
- `typeNames` — la capa (del `GetCapabilities`).
- `count` y `startIndex` — **paginación**.
- `outputFormat` — `GML` (siempre) o `application/json` / `GEOJSON` si el servidor lo ofrece.
- `bbox` o `CQL_FILTER` — filtros espacial y por atributos.

### Desde la línea de comandos y Python

```bash
# Guardar la respuesta en un archivo
curl -s "https://.../WFSServer?service=WFS&version=2.0.0&request=GetFeature&typeNames=<capa>&count=5&outputFormat=GEOJSON" -o salida.geojson
```

```python
import requests
url = "https://.../WFSServer"
params = {"service":"WFS","version":"2.0.0","request":"GetFeature",
          "typeNames":"<capa>","count":10,"outputFormat":"GEOJSON"}
r = requests.get(url, params=params, timeout=30)
geo = r.json()
print(len(geo["features"]), "features")
```

### WMS vs WFS

| | WMS | WFS |
|---|---|---|
| Devuelve | Imagen (PNG/JPEG) | Datos (GML/GeoJSON) |
| ¿Puedo editar/analizar? | No | Sí |
| Operación típica | `GetMap` | `GetFeature` |
| Uso | Visualización rápida | Descarga y análisis |

### Contraste: FeatureServer REST (IDE Boyacá)

El IDE Boyacá no expone WFS clásico sino un **FeatureServer de ArcGIS** (REST + JSON). Compara la misma idea por otro camino:

```
https://services6.arcgis.com/Ex2fmFOuTOHRZtML/ArcGIS/rest/services/Veredas_Boyaca_2024/FeatureServer/0/query?where=1=1&outFields=NOMB_MPIO,NOMBRE_VER&resultRecordCount=5&f=geojson
```

Mismo resultado (features en GeoJSON), distinta gramática: rutas REST en vez de `request=GetFeature`.

---

## 2.5 WMTS — Web Map Tile Service (teselas)

El WMTS sirve **teselas** (imágenes pequeñas) pre-generadas en una **pirámide** de niveles de zoom. Es muy rápido porque el servidor no renderiza al vuelo: entrega teselas ya listas.

- `GetCapabilities` del WMTS describe los **TileMatrixSet** (la pirámide) y las capas.
- `GetTile` pide una tesela por su **TileMatrix** (nivel de zoom), **TileRow** (fila) y **TileCol** (columna).

La forma más común de teselas en la web es el esquema **XYZ** (`z/x/y`), que usan los mapas base. Pruébalo —siempre funciona— para entender la pirámide:

```
https://tile.openstreetmap.org/7/38/60.png     ->  z=7,  x=38, y=60
https://tile.openstreetmap.org/8/76/120.png    ->  z=8 (más detalle)
```

Sube el primer número (`z`) y verás más detalle: cada nivel **cuadruplica** el número de teselas.

> **WMTS propio en el Capítulo 8.** Los WMTS públicos a veces no están habilitados o son inestables. Por eso, el WMTS "de verdad" lo montarás tú con **GeoWebCache sobre GeoServer** en el Capítulo 8 (Publicación): ahí sembrarás teselas y pedirás un `GetTile` sobre tus propios datos. En este capítulo basta entender la **estructura** `z/x/y` ↔ `TileMatrix/TileRow/TileCol`.

---

## 2.6 Tres herramientas, el mismo servicio

| Herramienta | Para qué | Cómo |
|---|---|---|
| **Navegador + DevTools** | Ver la URL y la respuesta cruda | `F12` → pestaña *Network* |
| **QGIS** | Consumir el servicio como cliente SIG | *Agregar capa → WMS/WMTS* o *WFS* |
| **`curl` / Python** | Automatizar y analizar | `curl ... -o` · `requests.get(...)` |

---

## Resumen

- Un geoservicio se **consume por URL**: `SERVICE`, `VERSION`, `REQUEST` y, siempre primero, `GetCapabilities`.
- **WMS** entrega imágenes (`GetMap`); **WFS** entrega datos (`GetFeature`, filtrables y paginables); **WMTS** entrega teselas de una pirámide (`GetTile`, estructura `z/x/y`).
- Lo mismo se consume desde navegador, QGIS y código.
- En los próximos capítulos **publicarás** estos servicios con GeoServer; ahora ya sabes qué vas a construir.

---

## Ejercicio Práctico (consolidación)

Trabaja contra el WMS/WFS del DANE (o un servicio equivalente de la tabla) y entrega una ficha `operaciones-ogc.md` en tu repositorio con:

1. **WMS — GetCapabilities:** nombre de **2 capas**, sus **CRS** y **formatos** soportados.
2. **WMS — GetMap:** una **URL propia** que renderice un área de Boyacá, más la **captura** de la imagen.
3. **WFS — GetFeature:** una petición **filtrada** (por `bbox` o `CQL_FILTER`) que devuelva **GeoJSON**, con el **conteo** de features obtenido (desde QGIS, `curl` o Python).
4. **WMTS/teselas:** una URL de tesela (`z/x/y` o `GetTile`) indicando qué **nivel de zoom, fila y columna** pediste.

**Entregable:** `operaciones-ogc.md` con las cuatro respuestas y las capturas.

---

## Referencias

- OGC — Web Map Service (WMS): https://www.ogc.org/standard/wms/
- OGC — Web Feature Service (WFS): https://www.ogc.org/standard/wfs/
- OGC — Web Map Tile Service (WMTS): https://www.ogc.org/standard/wmts/
- DANE — Geoportal / MGN: https://geoportal.dane.gov.co
- Esquema de teselas XYZ (slippy map): https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames

---

**Capítulo anterior**: [Capítulo 1: Introducción a Git](./capitulo-01-git.md)

**Próximo capítulo**: [Capítulo 3: Instalación de PostgreSQL y PostGIS](./capitulo-03-postgresql-postgis.md)
