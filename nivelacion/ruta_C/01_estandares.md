# Ruta C · C1 — Repaso de estándares con servicios reales (1 h)

**Meta:** si ya desarrollas o publicas, afina el vocabulario OGC comparando los servicios reales que usaremos en el curso.

---

## 1. El mapa mental

| Estándar | Qué entrega | Petición típica |
|---|---|---|
| **WMS** | imágenes (mapas renderizados) | `GetMap`, `GetCapabilities` |
| **WFS** | geometrías + atributos (vectores) | `GetFeature` |
| **WMTS** | teselas pre-renderizadas | `GetTile` |
| **FeatureServer** (Esri) | vectores por REST + JSON | `/query?...&f=geojson` |
| **OGC API – Features** | vectores por REST moderno | `/collections/{id}/items` |

La diferencia clave: WMS/WFS/WMTS usan `GetCapabilities` + parámetros `KVP`; los **REST** (FeatureServer, OGC API) usan rutas y JSON, mucho más amigables para la web.

---

## 2. Leer un GetCapabilities

Abre en el navegador (WMS de DANE, MGN 2024):

```
https://geoportal.dane.gov.co/mparcgis/services/MGN2024/Serv_CapasMGN_2024/MapServer/WMSServer?service=WMS&request=GetCapabilities
```

Busca en el XML: las `<Layer>` (capas disponibles), los `<CRS>` que soporta y los `<Format>` de salida. Eso es lo que un cliente (QGIS, OpenLayers) lee para saber qué puede pedir.

---

## 3. Comparar en vivo

El **mismo tipo de dato** (veredas de Boyacá), por dos vías:

- **FeatureServer (Esri):**
  ```
  https://services6.arcgis.com/Ex2fmFOuTOHRZtML/ArcGIS/rest/services/Veredas_Boyaca_2024/FeatureServer/0/query?where=1=1&outFields=*&resultRecordCount=3&f=geojson
  ```
- **OGC API – Features (demo oficial pygeoapi, otra temática):**
  ```
  https://demo.pygeoapi.io/master/collections?f=json
  ```

Observa que ambos devuelven JSON navegable por rutas, con paginación y filtros, frente al XML + KVP del WMS/WFS clásico.

---

## Ejercicio C1

1. Abre el `GetCapabilities` del WMS de DANE y anota: ¿cuántas capas publica? ¿qué CRS soporta?
2. Pide 3 veredas por el FeatureServer y 3 por una colección de la demo pygeoapi; compara la estructura del JSON.
3. En una tabla de tu repo (`c1_comparativa.md`), resume para WMS, WFS, FeatureServer y OGC API Features: qué entrega, cómo se filtra y cómo se pagina.

**Entregable:** `c1_comparativa.md` en tu repositorio.
