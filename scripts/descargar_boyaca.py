#!/usr/bin/env python3
"""
Descarga el paquete de datos de Boyacá para el curso.

Fuentes: IDE Boyacá (ArcGIS FeatureServer) y DANE (MGN 2024).
Salida: GeoJSON en 06_Propuesta_2026-2/datos/ (o el directorio indicado).
Sin dependencias externas: solo biblioteca estándar.

Uso:
    python3 descargar_boyaca.py
    python3 descargar_boyaca.py --out ../../04_Datos/boyaca
    python3 descargar_boyaca.py --shp   # convierte a Shapefile si ogr2ogr existe
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

IDE = "https://services6.arcgis.com/Ex2fmFOuTOHRZtML/ArcGIS/rest/services"
DANE = "https://geoportal.dane.gov.co/mparcgis/rest/services/MGN2024/Serv_CapasMGN_2024/FeatureServer"

TAREAS = [
    {
        "nombre": "municipios_boyaca",
        "url": f"{DANE}/317/query",
        "params": {
            "where": "dpto_ccdgo='15'",
            "outFields": "mpio_ccdgo,mpio_cnmbr,dpto_cnmbr,mpio_narea",
            "outSR": "4326",
            "f": "geojson",
        },
    },
    {
        "nombre": "veredas_boyaca",
        "url": f"{IDE}/Veredas_Boyaca_2024/FeatureServer/0/query",
        "params": {
            "where": "1=1",
            "outFields": "NOMB_MPIO,NOMBRE_VER,CODIGO_VER,VIGENCIA",
            "outSR": "4326",
            "f": "geojson",
        },
    },
    {
        "nombre": "hospitales_boyaca",
        "url": f"{IDE}/Hospitales_Boyac%C3%A1/FeatureServer/0/query",
        "params": {
            "where": "1=1",
            "outFields": "Nombre,NOM_MPIO,Direccion,Telefono",
            "outSR": "4326",
            "f": "geojson",
        },
    },
    {
        "nombre": "red_vial_departamental",
        "url": f"{IDE}/shape_red_vial_departamental/FeatureServer/0/query",
        "params": {"where": "1=1", "outFields": "*", "outSR": "4326", "f": "geojson"},
    },
    {
        "nombre": "provincias_boyaca",
        "url": f"{IDE}/Capa_Provincias_Boyaca/FeatureServer/0/query",
        "params": {"where": "1=1", "outFields": "*", "outSR": "4326", "f": "geojson"},
    },
]

MAX_REGISTROS = 2000  # límite por defecto de ArcGIS


def descargar(url: str, params: dict, destino: Path) -> int:
    """Descarga con paginación por resultOffset. Devuelve el número de features."""
    features: list[dict] = []
    offset = 0
    while True:
        q = dict(params)
        q["resultOffset"] = str(offset)
        q["resultRecordCount"] = str(MAX_REGISTROS)
        full = f"{url}?{urllib.parse.urlencode(q)}"
        req = urllib.request.Request(full, headers={"User-Agent": "curso-sig-ujdec/1.0"})
        with urllib.request.urlopen(req, timeout=90) as r:
            data = json.load(r)

        if "error" in data:
            raise RuntimeError(f"ArcGIS error: {data['error']}")

        lote = data.get("features", [])
        features.extend(lote)
        print(f"  · offset {offset}: {len(lote)} features")

        if len(lote) < MAX_REGISTROS or not data.get("exceededTransferLimit"):
            break
        offset += MAX_REGISTROS
        time.sleep(0.3)

    fc = {"type": "FeatureCollection", "features": features}
    destino.write_text(json.dumps(fc, ensure_ascii=False), encoding="utf-8")
    return len(features)


def a_shapefile(geojson: Path) -> None:
    if not shutil.which("ogr2ogr"):
        print("  (ogr2ogr no disponible; se omite Shapefile)")
        return
    shp = geojson.with_suffix(".shp")
    subprocess.run(
        ["ogr2ogr", "-f", "ESRI Shapefile", str(shp), str(geojson)],
        check=False,
        capture_output=True,
    )
    print(f"  → {shp.name}")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=str(Path(__file__).resolve().parent.parent / "datos"))
    ap.add_argument("--shp", action="store_true")
    args = ap.parse_args()

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    print(f"Destino: {out}\n")

    fallos = 0
    for t in TAREAS:
        print(f"[{t['nombre']}]")
        try:
            n = descargar(t["url"], t["params"], out / f"{t['nombre']}.geojson")
            print(f"  ✓ {n} features → {t['nombre']}.geojson")
            if args.shp:
                a_shapefile(out / f"{t['nombre']}.geojson")
        except Exception as e:  # noqa: BLE001
            fallos += 1
            print(f"  ✗ {type(e).__name__}: {e}")
        print()

    print(f"Listo. {len(TAREAS) - fallos}/{len(TAREAS)} descargas correctas.")
    return 1 if fallos else 0


if __name__ == "__main__":
    sys.exit(main())
