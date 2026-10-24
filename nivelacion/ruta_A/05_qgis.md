# Ruta A · A5 — QGIS: repaso operativo (1–2 h)

**Meta:** cargar, filtrar, reproyectar y exportar datos en QGIS con control del CRS. Es la base de todo lo demás.

> Instala **QGIS 3.34 LTR** o superior desde <https://qgis.org>.

---

## 1. CRS: por qué una capa "se ve corrida"

- El **CRS** (sistema de referencia de coordenadas) dice cómo se traducen las coordenadas a posiciones en la Tierra. `EPSG:4326` (lat/lon, grados) y `EPSG:9377` (MAGNA-SIRGAS / origen único nacional, metros) son los que más verás en Colombia.
- Si una capa aparece lejos o deformada, casi siempre es un **CRS mal declarado**. El código EPSG aparece abajo a la derecha en QGIS.
- **Reproyectar** convierte de un CRS a otro. No cambia la ubicación real, cambia cómo se representa.

---

## 2. Formatos: Shapefile vs. GeoPackage

| | Shapefile (`.shp`) | GeoPackage (`.gpkg`) |
|---|---|---|
| Archivos | Varios (`.shp`, `.dbf`, `.shx`, `.prj`…) | Uno solo |
| Nombres de campo | Máx. 10 caracteres | Sin límite práctico |
| Encoding | Problemático con tildes | UTF-8 nativo |
| Varias capas | No | Sí, en un archivo |

**Recomendación:** usa GeoPackage siempre que puedas. El Shapefile sigue vivo por compatibilidad.

---

## 3. Operaciones básicas

- **Cargar:** arrastra el GeoJSON al lienzo, o *Capa → Agregar capa vectorial*.
- **Filtrar:** clic derecho en la capa → *Filtrar…* → expresión, p. ej. `"mpio_cnmbr" = 'TUNJA'`.
- **Tabla de atributos:** `F6` o clic derecho → *Abrir tabla de atributos*.
- **Calculadora de campos:** en la tabla, el ábaco; crea campos nuevos (p. ej. área en hectáreas).
- **Exportar:** clic derecho → *Exportar → Guardar objetos como…* → elige formato y CRS.

---

## Ejercicio A5 — De DANE a GeoPackage

1. Carga `municipios_boyaca.geojson` (123 municipios, campos `mpio_ccdgo`, `mpio_cnmbr`, `mpio_narea`).
2. Observa el CRS abajo a la derecha (debe ser `EPSG:4326`).
3. Abre la tabla de atributos y ordena por `mpio_narea` para ver el municipio más grande.
4. Filtra solo Tunja: expresión `"mpio_cnmbr" = 'TUNJA'`.
5. Exporta la capa filtrada a **GeoPackage** (*Guardar objetos como…* → GeoPackage → nombre `tunja.gpkg`).
6. Vuelve a cargar `tunja.gpkg` y confirma el CRS.

**Pregunta de cierre:** ¿los municipios de Boyacá empiezan todos por el código `15`? (Sí — `mpio_ccdgo` concatena el `15` del departamento con el del municipio).

**Entregable:** captura de QGIS con `tunja.gpkg` cargado y el CRS `EPSG:4326` visible.
