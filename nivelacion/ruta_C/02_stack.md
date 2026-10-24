# Ruta C · C2 — Levantar el stack del curso (1 h)

**Meta:** tener corriendo la infraestructura base (PostGIS + GeoServer + pg_tileserv) y verificar los tres puertos. Es el punto de partida del Módulo 2.

> Requiere Docker funcionando. Si no puedes correrlo localmente, avísale al docente: hay una variante en la nube del curso.

---

## 1. El stack

El curso usa un `docker-compose` con tres piezas:

| Servicio | Imagen | Puerto | Para qué |
|---|---|---|---|
| **PostGIS** | `postgis/postgis:16-3.4` | 5432 | base de datos espacial |
| **GeoServer** | `docker.osgeo.org/geoserver:2.25.x` | 8080 | WMS/WFS/WMTS |
| **pg_tileserv** | `pramsey/pg_tileserv` | 7800 | vector tiles directo desde PostGIS |

Puedes partir del `docker-compose.yml` de la raíz del repositorio (PostGIS + GeoServer) y añadir `pg_tileserv`, o usar un compose mínimo como este:

```yaml
services:
  postgis:
    image: postgis/postgis:16-3.4
    environment:
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: geodatos
    ports: ["5432:5432"]
    volumes: ["pgdata:/var/lib/postgresql/data"]

  geoserver:
    image: docker.osgeo.org/geoserver:2.25.3
    ports: ["8080:8080"]
    depends_on: [postgis]

  pg_tileserv:
    image: pramsey/pg_tileserv:latest
    environment:
      DATABASE_URL: postgres://postgres:postgres@postgis:5432/geodatos
    ports: ["7800:7800"]
    depends_on: [postgis]

volumes:
  pgdata:
```

---

## 2. Arrancar y verificar los tres puertos

```bash
docker compose up -d
docker compose ps        # los tres en estado "running"/"healthy"
```

| Servicio | URL de verificación | Qué esperar |
|---|---|---|
| GeoServer | <http://localhost:8080/geoserver> | login (admin / geoserver) |
| pg_tileserv | <http://localhost:7800/index.json> | JSON con las capas publicables |
| PostGIS | `docker exec -it <postgis> psql -U postgres -d geodatos -c "SELECT postgis_version();"` | la versión de PostGIS |

> Recuerda: entre contenedores el host es `postgis` (nombre del servicio); desde tu máquina es `localhost`.

---

## Ejercicio C2

1. Levanta el stack y confirma los **tres puertos** respondiendo (capturas de GeoServer, del JSON de pg_tileserv y de `postgis_version()`).
2. Carga `municipios_boyaca.geojson` a PostGIS (con QGIS o con `ogr2ogr`).
3. Recarga <http://localhost:7800/index.json> y verifica que la tabla aparece como capa servible en vector tiles.

**Entregable:** las tres capturas de verificación de puertos.
