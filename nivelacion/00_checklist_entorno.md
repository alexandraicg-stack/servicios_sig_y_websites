# Módulo 0 — Checklist de entorno

Este es el **contrato de entrada** del curso. Al completar las rutas de nivelación (A, B y C) debes poder mostrar lo siguiente. Los puntos **1 a 3 son obligatorios**; los puntos **4 y 5 son deseables**.

> Entregable: un solo documento (PDF o Markdown) con **una captura de pantalla por cada ítem marcado** y el enlace a tu repositorio de GitHub. Se entrega antes de la sesión de alistamiento (T-2).

---

## Checklist

```
[ ] 1. QGIS 3.34 LTR o superior instalado y abierto
[ ] 1. Una capa de Boyacá cargada; el CRS visible en la esquina inferior derecha
[ ] 2. Terminal abierta; "python --version" responde (3.11+)
[ ] 2. "git --version" responde; git config user.name y user.email configurados
[ ] 2. "docker --version" y "docker compose version" responden
[ ] 3. Cuenta de GitHub activa; repositorio "curso-sig-<tu-nombre>" creado (git init, al menos una rama además de main, y push/pull probados)
[ ] 4. Página mínima publicada (Vercel o GitHub Pages) con Leaflet y un GeoJSON; URL compartida
[ ] 5. Ficha de datos completada para una fuente colombiana (plantilla abajo)
[ ] 6. VS Code instalado con las extensiones Python y Docker
```

Quien no cumpla **1–3** asiste a la sesión de alistamiento obligatoria del T-2; no es un castigo, es para no perder la primera clase instalando software.

---

## Cómo capturar cada evidencia

| Ítem | Qué mostrar en la captura |
|---|---|
| QGIS + capa | El lienzo con una capa de Boyacá y el **código EPSG** visible abajo a la derecha (ej. `EPSG:4326`) |
| Terminal | Las tres líneas `python --version`, `git --version`, `docker --version` con sus respuestas |
| GitHub | La página del repositorio `curso-sig-<nombre>` mostrando el README y al menos un commit |
| Página web | La URL pública abierta en el navegador con el mapa visible |

---

## Dónde están los datos

Todas las rutas usan el **paquete de datos de Boyacá**. Para generarlo:

- `python scripts/descargar_boyaca.py --out nivelacion/datos` (desde la raíz del repositorio).
- Detalle y campos de cada capa: [`datos/README.md`](datos/README.md).

| Archivo | Qué contiene | Campos clave |
|---|---|---|
| `municipios_boyaca.geojson` | 123 municipios (DANE MGN 2024) | `mpio_ccdgo`, `mpio_cnmbr`, `mpio_narea` |
| `veredas_boyaca.geojson` | 1.713 veredas (IDE Boyacá 2024) | `NOMB_MPIO`, `NOMBRE_VER`, `CODIGO_VER` |
| `hospitales_boyaca.geojson` | 464 hospitales (IDE Boyacá) | `Nombre`, `NOM_MPIO`, `Direccion` |
| `red_vial_departamental.geojson` | 614 tramos viales (IDE Boyacá) | geometría de líneas |
| `provincias_boyaca.geojson` | 123 municipios **etiquetados por provincia** | `provincia`, `mpio_cnmbr`/`NOMBRE_ENT`, `cod_mun` |

> Ojo: `provincias_boyaca.geojson` **no** contiene las 13 provincias como polígonos: trae los 123 municipios con un campo `provincia`. Es útil para agrupar (`group by provincia`), no para dibujar límites provinciales.

---

## Plantilla — Ficha de datos (ítem 5)

Copia esto en tu repositorio como `ficha_<fuente>.md` y complétalo para una fuente colombiana (IDE Boyacá, DANE, IGAC, SGC…):

```markdown
# Ficha de datos

- **Nombre del conjunto:**
- **Fuente / entidad:**
- **URL del servicio o descarga:**
- **Tipo:** servicio vivo (WMS/WFS/OGC API/FeatureServer) | descarga (SHP/GPKG/GeoJSON/COG)
- **Formato:**
- **Geometría:** punto | línea | polígono | ráster
- **CRS (EPSG):**
- **Número de registros / resolución:**
- **Vigencia / fecha:**
- **Licencia y atribución:**
- **Fecha de verificación:**
- **Estado:** vivo | descarga | caído
- **Nota / para qué sirve en mi proyecto:**
```

---

## Reconocimiento

Completar la nivelación **no da nota**, pero es **requisito para los talleres** y se reconoce con la insignia **"Entorno listo"** en la hoja de seguimiento del curso. Si no alcanzas a completarla, avisa: hay acompañamiento individual y una ruta reducida (solo ítems 1–3).
