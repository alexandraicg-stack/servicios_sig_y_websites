# Capítulo 6: Carga de Datos a PostgreSQL

## Objetivos del Capítulo

- Conocer herramientas para cargar datos geográficos
- Usar shp2pgsql (dentro del contenedor PostGIS) para cargar shapefiles
- Usar ogr2ogr para cargar múltiples formatos
- Cargar los datos del curso al PostGIS que corre en Docker
- Verificar y consultar los datos cargados
- Crear índices espaciales
- Optimizar el rendimiento

> Este capítulo asume que ya levantaste el stack con `docker compose up -d` (Capítulo 2). El contenedor de base de datos se llama **`curso_postgis`**, la base es **`taller_gis`** (usuario/clave `postgres`/`postgres`) y la carpeta `./data` del repositorio está disponible **dentro del contenedor en `/data`**.

## 6.1 Herramientas de Carga de Datos

### Herramientas Disponibles

| Herramienta | Formatos | Ventajas | Dónde se ejecuta (con Docker) |
|-------------|----------|----------|-------------|
| **shp2pgsql** | Shapefile | Incluido en la imagen PostGIS, rápido | Dentro del contenedor `curso_postgis` |
| **ogr2ogr** | 50+ formatos | Muy versátil, conversión | GDAL en el host, o un contenedor GDAL efímero |
| **QGIS DB Manager** | Todos | Interfaz gráfica | QGIS en el host (conecta a `localhost:5432`) |
| **pgAdmin** | CSV, texto | GUI integrada | pgAdmin en el host (conecta a `localhost:5432`) |
| **psql COPY** | CSV, texto | Rápido para datos tabulares | `docker exec … psql` |

### ¿Cuál Usar?

- **shp2pgsql**: Para shapefiles específicamente
- **ogr2ogr**: Para cualquier formato, conversiones complejas
- **QGIS**: Para usuarios que prefieren GUI
- **psql**: Para datos sin geometría

## 6.2 Usando shp2pgsql

### ¿Qué es shp2pgsql?

**shp2pgsql** es una herramienta de línea de comandos que convierte shapefiles a SQL para PostGIS.

### Dónde se ejecuta

Con Docker **no necesitas instalar nada**: `shp2pgsql` ya viene dentro de la imagen `postgis/postgis`. Los comandos se ejecutan **dentro del contenedor** `curso_postgis`, y los shapefiles del repositorio están montados en `/data`.

La forma general es ejecutar `shp2pgsql` y canalizarlo a `psql`, todo dentro del contenedor:

```bash
docker exec -it curso_postgis bash -c "shp2pgsql [opciones] /data/<shapefile> <schema>.<tabla> | psql -U postgres -d taller_gis"
```

> ¿Tu shapefile no está en `./data`? Cópialo al contenedor y apunta a `/tmp`:
> ```bash
> docker cp mi_capa.shp curso_postgis:/tmp/
> docker exec -it curso_postgis bash -c "shp2pgsql -I -s 4326 /tmp/mi_capa.shp public.mi_capa | psql -U postgres -d taller_gis"
> ```

### Opciones Principales

| Opción | Descripción |
|--------|-------------|
| `-I` | Crear índice espacial (GIST) |
| `-s <SRID>` | Especificar SRID (sistema de coordenadas) |
| `-W <encoding>` | Codificación del archivo (ej. UTF-8, LATIN1) |
| `-D` | Formato dump (más portable) |
| `-g <columna>` | Nombre de columna geométrica (default: geom) |
| `-k` | Mantener identificadores en mayúsculas |
| `-d` | Drop table (eliminar tabla si existe) |
| `-a` | Append (agregar a tabla existente) |
| `-c` | Create (crear tabla nueva, error si existe) |
| `-p` | Prepare (solo crear tabla, sin datos) |

### Modos de Operación

| Modo | Opción | Comportamiento |
|------|--------|----------------|
| **Create** | `-c` | Crea tabla nueva (error si existe) |
| **Append** | `-a` | Agrega datos a tabla existente |
| **Drop** | `-d` | Elimina y recrea tabla |
| **Prepare** | `-p` | Solo crea estructura, sin datos |

### Ejemplo Básico

```bash
# Cargar departamentos directamente a PostGIS (dentro del contenedor)
docker exec -it curso_postgis bash -c "shp2pgsql -I -s 4326 /data/departamentos.shp public.departamentos | psql -U postgres -d taller_gis"
```

### Ejemplo con Codificación

```bash
# Shapefile con codificación LATIN1
docker exec -it curso_postgis bash -c "shp2pgsql -I -s 4326 -W LATIN1 /data/municipios.shp public.municipios | psql -U postgres -d taller_gis"
```

### Ejemplo Completo

```bash
# Cargar departamentos (-d: elimina y recrea la tabla; -W UTF8: codificación)
docker exec -it curso_postgis bash -c "shp2pgsql -I -s 4326 -d -W UTF8 /data/departamentos.shp public.departamentos | psql -U postgres -d taller_gis"

# Cargar municipios
docker exec -it curso_postgis bash -c "shp2pgsql -I -s 4326 -d -W UTF8 /data/municipios.shp public.municipios | psql -U postgres -d taller_gis"
```

### Verificar el SRID del Shapefile

Antes de cargar, verifica el sistema de coordenadas:

```bash
# Ver contenido del archivo .prj
type departamentos.prj
```

O usando ogrinfo:
```bash
ogrinfo -al -so departamentos.shp
```

### Solución de Problemas

#### Error de Codificación

Si aparecen caracteres extraños (ñ, á, é):

```bash
# Probar con LATIN1
docker exec -it curso_postgis bash -c "shp2pgsql -I -s 4326 -W LATIN1 /data/municipios.shp public.municipios | psql -U postgres -d taller_gis"
```

#### Tabla ya Existe

```bash
# Usar -d para eliminar y recrear
docker exec -it curso_postgis bash -c "shp2pgsql -I -s 4326 -d /data/departamentos.shp public.departamentos | psql -U postgres -d taller_gis"
```

#### Problemas con Geometrías Inválidas

```bash
# Se cargarán igual, luego corregir en PostgreSQL
UPDATE departamentos SET geom = ST_MakeValid(geom) WHERE NOT ST_IsValid(geom);
```

## 6.3 Usando ogr2ogr (GDAL/OGR)

### ¿Qué es ogr2ogr?

**ogr2ogr** es parte de GDAL/OGR, una biblioteca para leer y escribir formatos geoespaciales.

### Dos formas de ejecutar ogr2ogr (con Docker)

A diferencia de `shp2pgsql`, **`ogr2ogr` (GDAL) no viene en la imagen de PostGIS**. Tienes dos opciones:

**(a) GDAL instalado en tu equipo (host).** Si ya tienes GDAL (p. ej. vía QGIS u OSGeo4W), conéctate al puerto publicado `localhost:5432`:

```bash
ogr2ogr -f "PostgreSQL" PG:"host=localhost port=5432 dbname=taller_gis user=postgres password=postgres" data/municipios.shp -nln municipios -lco GEOMETRY_NAME=geom -lco FID=gid -overwrite -progress
```

**(b) Un contenedor GDAL efímero** unido a la red del stack, que se conecta por el nombre de servicio `postgis` (no necesitas instalar nada):

```bash
# PowerShell / cmd usan %cd% ; en bash usa $PWD
docker run --rm -v "%cd%/data:/data" --network servicios_sig_y_websites_default ghcr.io/osgeo/gdal:alpine-small-latest \
  ogr2ogr -f "PostgreSQL" PG:"host=postgis dbname=taller_gis user=postgres password=postgres" /data/municipios.shp -nln municipios -lco GEOMETRY_NAME=geom -overwrite
```

> El nombre de la red `servicios_sig_y_websites_default` lo asigna Docker Compose a partir del nombre de la carpeta del repositorio; verifícalo con `docker network ls`.

Para verificar tu versión de GDAL (opción a): `ogr2ogr --version`.

En los ejemplos siguientes, ajusta la cadena `PG:"..."` según la forma elegida: `host=localhost` si usas GDAL en el host (añade `password=postgres`), o `host=postgis` si usas el contenedor GDAL efímero.

### Sintaxis Básica

```bash
ogr2ogr -f <formato_salida> <destino> <origen> [opciones]
```

### Cargar a PostgreSQL

```bash
ogr2ogr -f "PostgreSQL" PG:"dbname=taller_gis user=postgres password=tu_password" departamentos.shp -nln departamentos -lco GEOMETRY_NAME=geom -lco FID=gid -overwrite
```

**Parámetros**:

| Parámetro | Descripción |
|-----------|-------------|
| `-f "PostgreSQL"` | Formato de salida |
| `PG:"..."` | Cadena de conexión PostgreSQL |
| `-nln <nombre>` | Nombre de tabla (new layer name) |
| `-lco GEOMETRY_NAME=geom` | Nombre columna geometría |
| `-lco FID=gid` | Nombre columna ID |
| `-overwrite` | Sobrescribir si existe |
| `-append` | Agregar a tabla existente |
| `-update` | Actualizar dataset existente |
| `-s_srs <srs>` | SRS de origen |
| `-t_srs <srs>` | SRS de destino (reproyectar) |
| `-where <condición>` | Filtro SQL |
| `-progress` | Mostrar barra de progreso |

### Ejemplos Prácticos

#### Cargar Shapefile

```bash
ogr2ogr -f "PostgreSQL" PG:"dbname=taller_gis user=postgres" departamentos.shp -nln departamentos -lco GEOMETRY_NAME=geom -overwrite -progress
```

#### Cargar GeoJSON

```bash
ogr2ogr -f "PostgreSQL" PG:"dbname=taller_gis user=postgres" departamentos.geojson -nln departamentos_geojson -lco GEOMETRY_NAME=geom -overwrite
```

#### Cargar con Reproyección

```bash
# Convertir de EPSG:4326 a EPSG:3116 (MAGNA Colombia Bogotá)
ogr2ogr -f "PostgreSQL" PG:"dbname=taller_gis user=postgres" departamentos.shp -nln departamentos_3116 -t_srs EPSG:3116 -overwrite
```

#### Cargar con Filtro

```bash
# Solo departamentos con código específico
ogr2ogr -f "PostgreSQL" PG:"dbname=taller_gis user=postgres" departamentos.shp -nln departamentos_filtrados -where "dpto_ccdgo='25'" -overwrite
```

#### Cargar Múltiples Capas

```bash
# Cargar todas las capas de un GeoPackage
ogr2ogr -f "PostgreSQL" PG:"dbname=taller_gis user=postgres" datos.gpkg -overwrite
```

### Ventajas de ogr2ogr

- Soporta 50+ formatos (Shapefile, GeoJSON, KML, GML, GPX, etc.)
- Reproyección automática
- Filtros y transformaciones
- Conversión entre formatos
- Multiplataforma

## 6.4 Cargar Datos del Curso

### Preparación

1. Asegúrate de que el stack esté corriendo: `docker compose ps` (debe verse `curso_postgis`).
2. Verifica que los shapefiles están en `./data` del repositorio (y, por tanto, en `/data` dentro del contenedor):

```bash
docker exec -it curso_postgis ls /data
```

Deberías ver, entre otros, `departamentos.shp` y `municipios.shp`.

### Método 1: Usando shp2pgsql (recomendado)

#### Cargar Departamentos

```bash
docker exec -it curso_postgis bash -c "shp2pgsql -I -s 4326 -d -W UTF8 /data/departamentos.shp public.departamentos | psql -U postgres -d taller_gis"
```

**Salida esperada**:
```
BEGIN
CREATE TABLE
                      addgeometrytable
-------------------------------------------------------------
 public.departamentos.geom SRID:4326 TYPE:MULTIPOLYGON DIMS:2
(1 row)

INSERT 0 1
INSERT 0 1
...
COMMIT
CREATE INDEX
```

#### Cargar Municipios

```bash
docker exec -it curso_postgis bash -c "shp2pgsql -I -s 4326 -d -W UTF8 /data/municipios.shp public.municipios | psql -U postgres -d taller_gis"
```

### Método 2: Usando ogr2ogr

Con **GDAL en el host** (conecta al puerto publicado `localhost:5432`):

```bash
ogr2ogr -f "PostgreSQL" PG:"host=localhost port=5432 dbname=taller_gis user=postgres password=postgres" data/departamentos.shp -nln departamentos -lco GEOMETRY_NAME=geom -lco FID=gid -overwrite -progress
ogr2ogr -f "PostgreSQL" PG:"host=localhost port=5432 dbname=taller_gis user=postgres password=postgres" data/municipios.shp -nln municipios -lco GEOMETRY_NAME=geom -lco FID=gid -overwrite -progress
```

Sin GDAL en el host, usa el **contenedor GDAL efímero** (ver §6.3, forma b) cambiando `host=localhost` por `host=postgis`.

### Método 3: Usando pgAdmin 4 (GUI)

1. Abre **pgAdmin 4**
2. Conéctate al servidor PostgreSQL
3. Navega a **Databases** → **taller_gis** → **Schemas** → **public**
4. Click derecho en **public** → **CREATE Script** → **No disponible nativamente**

**Nota**: pgAdmin 4 no tiene importador directo de Shapefiles. Usa QGIS para GUI.

### Método 4: Usando QGIS DB Manager

1. Abre **QGIS**
2. Agrega las capas shapefile al proyecto
3. Ve a **Database** → **DB Manager**
4. Conéctate a PostgreSQL (crear nueva conexión si es necesario)
5. Selecciona **PostGIS** → **taller_gis** → **public**
6. Menú **Table** → **Import Layer/File**
7. Selecciona la capa a importar
8. Configura:
   - **Table name**: `departamentos`
   - **Geometry column**: `geom`
   - **Source SRID**: `4326`
   - **Target SRID**: `4326`
   - - **Create spatial index**
   - - **Convert field names to lowercase**
9. Haz clic en **OK**

## 6.5 Verificar Datos Cargados

### Conectarse a la Base de Datos

```bash
docker exec -it curso_postgis psql -U postgres -d taller_gis
```

Desde ahí puedes ejecutar los comandos `\dt`, `\d` y las consultas SQL de abajo. (También puedes conectarte con pgAdmin o QGIS a `localhost:5432`.)

### Listar Tablas

```sql
-- Listar todas las tablas
\dt

-- Listar tablas con información detallada
\dt+
```

**Salida esperada**:
```
              List of relations
 Schema |     Name      | Type  |  Owner
--------+---------------+-------+----------
 public | departamentos | table | postgres
 public | municipios    | table | postgres
 public | spatial_ref_sys | table | postgres
```

### Describir Estructura de Tabla

```sql
-- Ver estructura de departamentos
\d departamentos

-- Ver columnas y tipos
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'departamentos';
```

### Contar Registros

```sql
-- Contar departamentos
SELECT COUNT(*) FROM departamentos;

-- Contar municipios
SELECT COUNT(*) FROM municipios;
```

**Colombia tiene**:
- 32 departamentos + 1 Distrito Capital = 33
- ~1100 municipios

### Ver Primeros Registros

```sql
-- Ver 5 departamentos
SELECT * FROM departamentos LIMIT 5;

-- Ver solo nombres
SELECT dpto_cnmbr FROM departamentos ORDER BY dpto_cnmbr;
```

### Verificar Geometrías

```sql
-- Verificar que todas las geometrías son válidas
SELECT COUNT(*)
FROM departamentos
WHERE NOT ST_IsValid(geom);

-- Si hay geometrías inválidas (debería ser 0)
-- Corregirlas:
UPDATE departamentos
SET geom = ST_MakeValid(geom)
WHERE NOT ST_IsValid(geom);
```

### Verificar SRID

```sql
-- Ver el SRID de las geometrías
SELECT DISTINCT ST_SRID(geom) FROM departamentos;

-- Debería retornar: 4326
```

### Verificar Tipo de Geometría

```sql
-- Ver tipo de geometría
SELECT DISTINCT GeometryType(geom) FROM departamentos;

-- O usando ST_GeometryType
SELECT DISTINCT ST_GeometryType(geom) FROM departamentos;
```

### Calcular Extensión (Bounding Box)

```sql
-- Extensión de todos los departamentos
SELECT ST_Extent(geom) FROM departamentos;

-- Resultado aproximado:
-- BOX(-79.0 -4.2, -66.8 13.4)
```

### Ver Metadatos Espaciales

```sql
-- Ver información en geometry_columns
SELECT * FROM geometry_columns
WHERE f_table_name IN ('departamentos', 'municipios');
```

## 6.6 Crear Índices Espaciales

### ¿Por Qué Índices Espaciales?

Los índices espaciales (GIST) **aceleran significativamente** las consultas espaciales:

- Intersecciones
- Contenciones
- Distancias
- Filtros por extensión (BBOX)

### Verificar si Existe Índice

```sql
-- Ver índices de una tabla
\d departamentos

-- O con SQL
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'departamentos';
```

### Crear Índice Espacial

Si no se creó con `-I` en shp2pgsql:

```sql
-- Crear índice GIST en departamentos
CREATE INDEX idx_departamentos_geom
ON departamentos
USING GIST (geom);

-- Crear índice GIST en municipios
CREATE INDEX idx_municipios_geom
ON municipios
USING GIST (geom);
```

### Verificar Mejora de Rendimiento

```sql
-- Sin índice (lento)
EXPLAIN ANALYZE
SELECT * FROM municipios
WHERE ST_Intersects(geom, ST_MakePoint(-74.0, 4.0));

-- Con índice (rápido)
-- El plan de ejecución mostrará "Index Scan using idx_municipios_geom"
```

## 6.7 Consultas de Verificación

### Departamentos

```sql
-- Total de departamentos
SELECT COUNT(*) as total FROM departamentos;

-- Listar nombres ordenados
SELECT dpto_ccdgo as codigo, dpto_cnmbr as nombre
FROM departamentos
ORDER BY dpto_cnmbr;

-- Calcular área (en grados cuadrados, luego en km²)
SELECT
    dpto_cnmbr,
    ST_Area(geom) as area_grados,
    ST_Area(geom::geography) / 1000000 as area_km2
FROM departamentos
ORDER BY area_km2 DESC
LIMIT 5;
```

### Municipios

```sql
-- Total de municipios
SELECT COUNT(*) as total FROM municipios;

-- Municipios por departamento
SELECT
    dpto_cnmbr,
    COUNT(*) as num_municipios
FROM municipios
GROUP BY dpto_cnmbr
ORDER BY num_municipios DESC
LIMIT 5;

-- Municipio más grande por área
SELECT
    mpio_cnmbr,
    ST_Area(geom::geography) / 1000000 as area_km2
FROM municipios
ORDER BY area_km2 DESC
LIMIT 1;
```

### Consultas Espaciales

```sql
-- Municipios que intersecan con un punto (Bogotá)
SELECT mpio_cnmbr
FROM municipios
WHERE ST_Intersects(geom, ST_SetSRID(ST_MakePoint(-74.0721, 4.7110), 4326));

-- Municipios dentro de un departamento
SELECT m.mpio_cnmbr
FROM municipios m
JOIN departamentos d ON ST_Within(m.geom, d.geom)
WHERE d.dpto_cnmbr = 'Cundinamarca';

-- Departamentos vecinos de Cundinamarca
SELECT d2.dpto_cnmbr
FROM departamentos d1
JOIN departamentos d2 ON ST_Touches(d1.geom, d2.geom)
WHERE d1.dpto_cnmbr = 'Cundinamarca';
```

## 6.8 Optimización y Mantenimiento

### Actualizar Estadísticas

```sql
-- Actualizar estadísticas para optimizador
VACUUM ANALYZE departamentos;
VACUUM ANALYZE municipios;
```

### Cluster por Índice Espacial

Reorganiza físicamente la tabla según el índice:

```sql
-- Mejora rendimiento de consultas espaciales
CLUSTER departamentos USING idx_departamentos_geom;
CLUSTER municipios USING idx_municipios_geom;
```

### Verificar Tamaño de Tablas

```sql
-- Tamaño de tablas
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

## 6.9 Exportar Datos desde PostgreSQL

### Exportar a Shapefile

`pgsql2shp` también viene en la imagen de PostGIS; se ejecuta dentro del contenedor y el resultado queda en `/tmp` (luego se copia al host con `docker cp`):

```bash
docker exec -it curso_postgis bash -c "pgsql2shp -f /tmp/departamentos_export.shp -h localhost -u postgres -P postgres taller_gis 'SELECT * FROM departamentos'"
docker cp curso_postgis:/tmp/departamentos_export.shp ./departamentos_export.shp
```

### Exportar a GeoJSON

Con GDAL en el host (conecta a `localhost:5432`):

```bash
ogr2ogr -f GeoJSON departamentos_export.geojson PG:"host=localhost port=5432 dbname=taller_gis user=postgres password=postgres" -sql "SELECT * FROM departamentos"
```

### Exportar usando SQL

```sql
-- Exportar como GeoJSON desde PostgreSQL
COPY (
    SELECT jsonb_build_object(
        'type', 'FeatureCollection',
        'features', jsonb_agg(feature)
    )
    FROM (
        SELECT jsonb_build_object(
            'type', 'Feature',
            'geometry', ST_AsGeoJSON(geom)::jsonb,
            'properties', to_jsonb(row) - 'geom'
        ) AS feature
        FROM (SELECT * FROM departamentos) row
    ) features
) TO '/tmp/departamentos.geojson';
```

> `COPY ... TO` escribe en el sistema de archivos **del servidor**, es decir, dentro del contenedor. Recupéralo con `docker cp curso_postgis:/tmp/departamentos.geojson ./departamentos.geojson`.

## Nota — Instalación nativa (opcional)

Si instalaste PostgreSQL/PostGIS de forma nativa (Anexo A del Capítulo 2) en lugar de Docker:

- `shp2pgsql`, `pgsql2shp` y `psql` están en `C:\Program Files\PostgreSQL\16\bin` (agrégalo al `PATH`). No uses `docker exec`: ejecuta los comandos directamente y apunta a la ruta local del shapefile. Ejemplo:
  ```bash
  shp2pgsql -I -s 4326 -d -W UTF8 data\departamentos.shp public.departamentos | psql -d taller_gis -U postgres
  ```
- Para `ogr2ogr`, instala GDAL con **OSGeo4W** ([osgeo4w](https://trac.osgeo.org/osgeo4w/)) y usa `PG:"host=localhost dbname=taller_gis user=postgres password=..."`.
- El host de conexión es `localhost` en todos los casos (no `postgis`).

## Resumen

En este capítulo has aprendido:

- Herramientas para cargar datos geográficos a PostgreSQL
- Uso de shp2pgsql para cargar shapefiles
- Uso de ogr2ogr para cargar múltiples formatos
- Carga de los datos del curso (departamentos y municipios)
- Verificación de datos cargados
- Creación de índices espaciales
- Consultas de verificación y validación
- Optimización y mantenimiento
- Exportación de datos desde PostgreSQL

## Ejercicio Práctico

1. Carga los shapefiles de departamentos y municipios usando shp2pgsql
2. Verifica que los datos se cargaron correctamente
3. Cuenta el número de registros en cada tabla
4. Verifica que todas las geometrías son válidas
5. Crea índices espaciales si no existen
6. Calcula el área del departamento más grande
7. Lista los 5 departamentos con más municipios
8. Encuentra el municipio que contiene el punto [-74.0721, 4.7110] (Bogotá)
9. Actualiza las estadísticas de las tablas
10. Exporta los departamentos a GeoJSON

## Referencias

- PostGIS Documentation. (2024). *Loading & Exporting Data*. https://postgis.net/docs/using_postgis_dbmanagement.html
- GDAL/OGR Documentation. (2024). *ogr2ogr*. https://gdal.org/programs/ogr2ogr.html
- PostGIS Documentation. (2024). *shp2pgsql*. https://postgis.net/docs/using_postgis_dbmanagement.html#shp2pgsql_usage
- PostgreSQL Documentation. (2024). *COPY Command*. https://www.postgresql.org/docs/current/sql-copy.html
- Obe, R., & Hsu, L. (2021). *PostGIS in Action* (3rd ed.). Manning Publications. Chapter 4: Loading Data.

---

**Capítulo anterior**: [Capítulo 5: Estándares para Información Geográfica](./capitulo-05-estandares-geograficos.md)

**Próximo capítulo**: [Capítulo 7: Publicación de Capas en GeoServer](./capitulo-07-publicacion-geoserver.md)
