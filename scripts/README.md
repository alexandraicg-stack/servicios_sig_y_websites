# Scripts

Utilidades del curso para descargar datos y verificar fuentes. Sirven además como **ejemplos de código** (Python, Bash, PowerShell y cmd).

## `descargar_boyaca.py` — descarga de datos (Python)

Descarga el paquete de datos de Boyacá en GeoJSON desde el IDE Boyacá (ArcGIS FeatureServer) y el DANE (MGN 2024). **Sin dependencias externas**: solo la biblioteca estándar (`urllib`, `json`, `argparse`). Es un buen ejemplo de consumo de un servicio REST con paginación.

```bash
python scripts/descargar_boyaca.py                      # salida por defecto
python scripts/descargar_boyaca.py --out nivelacion/datos
python scripts/descargar_boyaca.py --shp                # también a Shapefile si hay ogr2ogr
```

Genera: municipios (123), veredas (1.713), hospitales (464), red vial (614) y provincias (123).

## `verificar_fuentes.*` — chequeo de endpoints en vivo

El mismo chequeo en cuatro entornos. Recorre ~19 fuentes geoespaciales (IDE Boyacá, IGAC, DANE, SGC, Copernicus DEM, Earth Search STAC, Geofabrik, datos.gov.co…) e informa el código HTTP, el `content-type` y si responden.

| Archivo | Entorno | Cómo se ejecuta |
|---|---|---|
| `verificar_fuentes.sh` | Linux / macOS / Git Bash | `bash scripts/verificar_fuentes.sh` |
| `verificar_fuentes.ps1` | Windows PowerShell 5.1+ | `powershell -ExecutionPolicy Bypass -File scripts\verificar_fuentes.ps1` |
| `verificar_fuentes.bat` | Windows cmd (usa `curl.exe`) | `scripts\verificar_fuentes.bat` |

Notas:
- La versión **Bash** usa `curl` con GET; las de **PowerShell** y **cmd** piden solo el primer byte (HEAD o `Range: 0-0`) para **no descargar** los rásteres ni los ZIP completos.
- En PowerShell y cmd los nombres van sin tildes para evitar problemas de *codepage* en consola.
- Un endpoint que responde `2xx` se marca `OK`; cualquier otro código o un tiempo de espera agotado se marca `FALLA`. Algunos portales gubernamentales pueden estar caídos de forma intermitente.
