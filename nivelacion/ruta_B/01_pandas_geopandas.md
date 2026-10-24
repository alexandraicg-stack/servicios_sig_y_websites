# Ruta B · B1 — Python intermedio para datos (2 h)

**Meta:** procesar datos geográficos con `pandas`, `geopandas` y `requests`. Si ya programas algo, aquí afianzas el flujo del curso.

---

## 1. Entorno reproducible

```bash
python -m venv venv
source venv/bin/activate            # PowerShell: .\venv\Scripts\Activate.ps1 · CMD: venv\Scripts\activate.bat
pip install pandas geopandas shapely requests
pip freeze > requirements.txt       # congela versiones para que otro reproduzca
```

> `geopandas` arrastra GDAL. Si falla en Windows, usa `conda`/`mamba` o `uv`, o trabaja dentro de un contenedor (ver B3).

---

## 2. pandas — tablas

```python
import geopandas as gpd

gdf = gpd.read_file("datos/veredas_boyaca.geojson")
print(gdf.shape)                    # (1713, n_columnas)
print(gdf.columns.tolist())         # NOMB_MPIO, NOMBRE_VER, CODIGO_VER, VIGENCIA, geometry

# filtrar y agrupar
tunja = gdf[gdf["NOMB_MPIO"] == "TUNJA"]
por_municipio = gdf.groupby("NOMB_MPIO").size().sort_values(ascending=False)
print(por_municipio.head())
```

`groupby`, `.size()`, filtros booleanos y `merge` (joins) son el pan de cada día.

---

## 3. geopandas + shapely — geometría

```python
# reproyectar a metros (MAGNA-SIRGAS origen nacional) para medir
gdf_m = gdf.to_crs(9377)
gdf_m["area_ha"] = gdf_m.geometry.area / 10_000     # m² → hectáreas

# buffer de 500 m alrededor de hospitales
hosp = gpd.read_file("datos/hospitales_boyaca.geojson").to_crs(9377)
hosp["buffer"] = hosp.geometry.buffer(500)

# guardar resultado
gdf_m.to_file("salidas/veredas_area.gpkg", driver="GPKG")
```

> Para **medir áreas o distancias** reproyecta siempre a un CRS en metros (`9377` o `3116`). Medir en grados (`4326`) da números sin sentido.

---

## 4. requests — traer datos de un servicio

```python
import requests, geopandas as gpd

url = "https://services6.arcgis.com/Ex2fmFOuTOHRZtML/ArcGIS/rest/services/Veredas_Boyaca_2024/FeatureServer/0/query"
params = {
    "where": "NOMB_MPIO = 'TUNJA'",
    "outFields": "NOMB_MPIO,NOMBRE_VER,CODIGO_VER",
    "outSR": "4326",
    "f": "geojson",
}
r = requests.get(url, params=params, timeout=30)
r.raise_for_status()
gdf = gpd.GeoDataFrame.from_features(r.json()["features"], crs=4326)
print(len(gdf), "veredas en Tunja")
```

---

## Ejercicio B1

1. Descarga las veredas de **Tunja** directamente del IDE Boyacá con `requests` (código de arriba).
2. Con el paquete completo `veredas_boyaca.geojson`, cuenta cuántas veredas tiene cada municipio y muestra el top 10.
3. Reproyecta a `EPSG:9377`, calcula el área en hectáreas de cada vereda y encuentra las 5 más grandes.

**Entregable:** un script `b1_veredas.py` en tu repo + captura de las tres salidas.
