# Datos para la nivelación

Las guías de nivelación usan el **paquete de datos de Boyacá**. Para no versionar decenas de MB de GeoJSON, este directorio no los incluye: se generan con el script de descarga incluido en el repositorio.

## Descargar el paquete

```bash
# desde la raíz del repositorio
python scripts/descargar_boyaca.py --out nivelacion/datos
```

Sin dependencias externas (solo biblioteca estándar de Python). Fuentes: IDE Boyacá (ArcGIS FeatureServer) y DANE (MGN 2024).

## Archivos que genera

| Archivo | Features | Campos clave |
|---|---|---|
| `municipios_boyaca.geojson` | 123 | `mpio_ccdgo`, `mpio_cnmbr`, `mpio_narea` |
| `veredas_boyaca.geojson` | 1.713 | `NOMB_MPIO`, `NOMBRE_VER`, `CODIGO_VER` |
| `hospitales_boyaca.geojson` | 464 | `Nombre`, `NOM_MPIO`, `Direccion` |
| `red_vial_departamental.geojson` | 614 | geometría de líneas |
| `provincias_boyaca.geojson` | 123 | `provincia`, `cod_mun` (municipios etiquetados por provincia) |

> El repositorio también trae datos de Colombia a nivel nacional en `../../data/` (departamentos y municipios); son un conjunto distinto al paquete de Boyacá de la nivelación.
