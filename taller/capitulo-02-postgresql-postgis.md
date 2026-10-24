# Capítulo 2: Instalación de PostgreSQL y PostGIS

## Objetivos del Capítulo

- Comprender qué son PostgreSQL y PostGIS
- Levantar PostgreSQL + PostGIS con **Docker** (vía principal del curso)
- Verificar la base de datos espacial `taller_gis`
- Administrarla con pgAdmin y `psql`
- Realizar consultas espaciales básicas

> Este capítulo usa **Docker** como método principal. Si no puedes usar Docker en tu equipo, al final encontrarás el **Anexo A — Instalación nativa (opcional)**.

## 2.1 ¿Qué es PostgreSQL?

**PostgreSQL** es un sistema de gestión de bases de datos relacional (RDBMS) de código abierto:

### Características Principales

- **Robusto y confiable**: 30+ años de desarrollo activo
- **Cumplimiento ACID**: Garantiza integridad transaccional
- **Extensible**: Soporta extensiones personalizadas
- **Multiplataforma**: Windows, Linux, macOS
- **Estándares SQL**: Cumple con estándares SQL:2016

### ¿Por qué PostgreSQL?

- **Gratuito y de código abierto**
- **Alto rendimiento**
- **Seguro y confiable**
- **Soporte para datos espaciales mediante PostGIS**
- **Amplia adopción en la industria**

## 2.2 ¿Qué es PostGIS?

**PostGIS** es una extensión espacial para PostgreSQL que añade soporte para:

- **Objetos geográficos**: Puntos, líneas, polígonos
- **Consultas espaciales**: Intersecciones, uniones, distancias
- **Índices espaciales**: Consultas rápidas sobre datos geográficos
- **Transformaciones**: Reproyección entre sistemas de coordenadas
- **Análisis geoespacial**: Buffers, centroides, áreas, perímetros

### Capacidades de PostGIS

| Funcionalidad | Descripción |
|---------------|-------------|
| Geometrías | Puntos, LineStrings, Polígonos, Multi-geometrías |
| Geografías | Cálculos sobre el elipsoide terrestre |
| Raster | Almacenamiento y análisis de datos ráster |
| Topología | Relaciones topológicas complejas |
| 3D | Soporte para geometrías tridimensionales |

## 2.3 Levantar PostgreSQL + PostGIS con Docker

En lugar de instalar PostgreSQL y PostGIS directamente en el sistema operativo, el curso usa **Docker**: una imagen oficial ya trae PostgreSQL y PostGIS listos y la base de datos del curso se crea sola. Así todos trabajamos con la misma versión y evitamos problemas de instalación.

### Paso 1: Requisito — Docker Desktop

Instala **Docker Desktop** desde [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/) y asegúrate de que esté corriendo. Verifica:

```bash
docker --version
docker compose version
```

### Paso 2: Levantar el servicio

Desde la **raíz del repositorio** (donde está `docker-compose.yml`):

```bash
docker compose up -d        # descarga la imagen y levanta el contenedor
docker compose ps           # verifica que "curso_postgis" esté "running"/"healthy"
docker compose logs -f postgis   # (opcional) ver registros en vivo; Ctrl+C para salir
```

El servicio `postgis` usa la imagen `postgis/postgis:16-3.4` y, al arrancar por primera vez, **crea automáticamente**:

- la base de datos **`taller_gis`**,
- con la **extensión PostGIS ya habilitada**,
- usuario y contraseña **`postgres` / `postgres`**,
- publicada en **`localhost:5432`**.

> No hace falta instalar PostGIS aparte ni usar Stack Builder: la imagen ya lo incluye.

### Paso 3: Verificar PostgreSQL y PostGIS

Ejecuta `psql` **dentro del contenedor** con `docker exec`:

```bash
docker exec -it curso_postgis psql -U postgres -d taller_gis -c "SELECT version();"
docker exec -it curso_postgis psql -U postgres -d taller_gis -c "SELECT postgis_version();"
```

Deberías ver la versión de PostgreSQL 16 y algo como `3.4 USE_GEOS=1 USE_PROJ=1 USE_STATS=1`.

### Paso 4: Detener y continuar

```bash
docker compose down     # detiene y elimina los contenedores
docker compose up -d    # los vuelve a levantar
```

Los datos **se conservan** en el volumen `pgdata` entre reinicios. Para borrar todo y empezar de cero: `docker compose down -v` (elimina también los volúmenes).

## 2.5 La Base de Datos del Curso

Con Docker **no tienes que crear la base**: el contenedor ya levantó `taller_gis` con PostGIS habilitado. Esta sección es para **verificarla** y, si lo necesitas, crear bases adicionales.

### Paso 1: Verificar la base y la extensión

Abre una sesión `psql` dentro del contenedor:

```bash
docker exec -it curso_postgis psql -U postgres -d taller_gis
```

Dentro de `psql`:

```sql
-- Confirmar que PostGIS está activo
SELECT postgis_full_version();

-- Listar las extensiones instaladas
\dx
```

Deberías ver:
```
List of installed extensions
   Name     | Version |   Schema   |         Description
------------+---------+------------+------------------------------
 postgis    | 3.4.x   | public     | PostGIS geometry and geography...
 plpgsql    | 1.0     | pg_catalog | PL/pgSQL procedural language
```

### Paso 2: (Opcional) Extensiones adicionales

Si tu proyecto las necesita, dentro de `taller_gis`:

```sql
CREATE EXTENSION IF NOT EXISTS postgis_topology;        -- topología
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;           -- requerida por el geocoder
CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;  -- geocodificación
```

### Paso 3: (Opcional) Crear otra base de datos

Si quisieras una base distinta a la del curso:

```sql
CREATE DATABASE mi_otra_base;
\c mi_otra_base
CREATE EXTENSION postgis;
```

## 2.6 Herramientas de Administración

### pgAdmin 4

**pgAdmin 4** es la herramienta gráfica principal para administrar PostgreSQL:

#### Características

- Interfaz gráfica intuitiva
- Visualización de datos y esquemas
- Editor SQL con autocompletado
- Monitor de rendimiento
- Herramientas de backup y restore

#### Acceso

pgAdmin se instala aparte (o se agrega como otro servicio de Docker). Para conectarlo a la base que corre en el contenedor:

1. Abre pgAdmin 4 → click derecho en **Servers** → **Register** → **Server…**
2. Pestaña **Connection**:
   - **Host**: `localhost`  ·  **Port**: `5432`
   - **Maintenance database**: `taller_gis`
   - **Username**: `postgres`  ·  **Password**: `postgres`
3. Guarda y navega a **taller_gis** → **Query Tool** para ejecutar SQL.

> Desde la **máquina host** la base está en `localhost:5432` porque el puerto está publicado en `docker-compose.yml`.

### psql (Command Line)

**psql** ya viene dentro del contenedor; no necesitas instalarlo. Lo ejecutas con `docker exec`:

#### Comandos Útiles

| Comando | Descripción |
|---------|-------------|
| `\l` | Listar bases de datos |
| `\c database` | Conectar a una base de datos |
| `\dt` | Listar tablas |
| `\d table` | Describir una tabla |
| `\df` | Listar funciones |
| `\dx` | Listar extensiones |
| `\q` | Salir |
| `\?` | Ayuda |
| `\h SQL_COMMAND` | Ayuda sobre comando SQL |

#### Ejemplo de Sesión

```bash
docker exec -it curso_postgis psql -U postgres -d taller_gis
```

```sql
-- Ver versión de PostgreSQL
SELECT version();

-- Ver versión de PostGIS
SELECT PostGIS_version();

-- Listar tablas
\dt

-- Salir
\q
```

## 2.7 Consultas Espaciales Básicas

> Ejecuta el SQL de esta sección (y las siguientes 2.8 y 2.9) dentro de una sesión `psql` del contenedor: `docker exec -it curso_postgis psql -U postgres -d taller_gis`, o pégalo en el Query Tool de pgAdmin conectado a `localhost:5432`.

### Crear una Tabla con Geometría

```sql
-- Crear una tabla de ciudades
CREATE TABLE ciudades (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    poblacion INTEGER,
    geom GEOMETRY(POINT, 4326)
);
```

**Explicación**:
- `GEOMETRY(POINT, 4326)`: Geometría de tipo POINT con SRID 4326 (WGS84)
- `SRID`: Sistema de referencia espacial (en este caso, coordenadas geográficas)

### Insertar Datos Espaciales

```sql
-- Insertar algunas ciudades de Colombia
INSERT INTO ciudades (nombre, poblacion, geom) VALUES
    ('Bogotá', 7181469, ST_SetSRID(ST_MakePoint(-74.0721, 4.7110), 4326)),
    ('Medellín', 2508452, ST_SetSRID(ST_MakePoint(-75.5636, 6.2442), 4326)),
    ('Cali', 2227642, ST_SetSRID(ST_MakePoint(-76.5225, 3.4516), 4326)),
    ('Barranquilla', 1232766, ST_SetSRID(ST_MakePoint(-74.7813, 10.9685), 4326)),
    ('Cartagena', 1028736, ST_SetSRID(ST_MakePoint(-75.5144, 10.3910), 4326));
```

### Consultas Espaciales

#### Calcular Distancia entre Ciudades

```sql
-- Distancia entre Bogotá y Medellín (en metros)
SELECT
    ST_Distance(
        (SELECT geom FROM ciudades WHERE nombre = 'Bogotá')::geography,
        (SELECT geom FROM ciudades WHERE nombre = 'Medellín')::geography
    ) / 1000 AS distancia_km;
```

#### Encontrar Ciudades Cercanas

```sql
-- Ciudades a menos de 500 km de Bogotá
SELECT
    c2.nombre,
    ST_Distance(c1.geom::geography, c2.geom::geography) / 1000 AS distancia_km
FROM
    ciudades c1,
    ciudades c2
WHERE
    c1.nombre = 'Bogotá'
    AND c2.nombre != 'Bogotá'
    AND ST_Distance(c1.geom::geography, c2.geom::geography) < 500000
ORDER BY distancia_km;
```

#### Crear un Buffer (Área de Influencia)

```sql
-- Crear un buffer de 100 km alrededor de Bogotá
SELECT
    nombre,
    ST_Buffer(geom::geography, 100000)::geometry AS buffer_geom
FROM ciudades
WHERE nombre = 'Bogotá';
```

### Funciones Espaciales Comunes

| Función | Descripción |
|---------|-------------|
| `ST_MakePoint(x, y)` | Crea un punto |
| `ST_SetSRID(geom, srid)` | Asigna un SRID a una geometría |
| `ST_Distance(geom1, geom2)` | Calcula distancia entre geometrías |
| `ST_Area(geom)` | Calcula área de un polígono |
| `ST_Length(geom)` | Calcula longitud de una línea |
| `ST_Buffer(geom, radio)` | Crea buffer alrededor de geometría |
| `ST_Intersects(geom1, geom2)` | Verifica si geometrías se intersecan |
| `ST_Contains(geom1, geom2)` | Verifica si geom1 contiene a geom2 |
| `ST_AsText(geom)` | Convierte geometría a WKT |
| `ST_AsGeoJSON(geom)` | Convierte geometría a GeoJSON |

## 2.8 Sistemas de Referencia Espacial (SRID)

### ¿Qué es un SRID?

Un **SRID** (Spatial Reference System Identifier) identifica un sistema de coordenadas:

- **4326**: WGS84 (coordenadas geográficas: latitud/longitud)
- **3857**: Web Mercator (usado en mapas web como Google Maps)
- **9377**: MAGNA-SIRGAS 2018 Colombia (proyectado)
- **3116**: MAGNA-SIRGAS Colombia Bogotá (proyectado)

### Consultar SRIDs Disponibles

```sql
-- Ver todos los SRIDs
SELECT srid, auth_name, srtext
FROM spatial_ref_sys
WHERE srid IN (4326, 3857, 9377, 3116);
```

### Transformar entre Sistemas de Coordenadas

```sql
-- Transformar de WGS84 (4326) a Web Mercator (3857)
SELECT
    nombre,
    ST_Transform(geom, 3857) AS geom_mercator
FROM ciudades;
```

## 2.9 Índices Espaciales

Los índices espaciales mejoran significativamente el rendimiento de consultas espaciales.

### Crear un Índice Espacial

```sql
-- Crear índice espacial en la columna geom
CREATE INDEX idx_ciudades_geom
ON ciudades
USING GIST (geom);
```

**GIST** (Generalized Search Tree) es el tipo de índice recomendado para datos espaciales.

### Verificar Índices

```sql
-- Listar índices de la tabla
\d ciudades

-- O con SQL
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'ciudades';
```

## Resumen

En este capítulo has aprendido:

- Qué son PostgreSQL y PostGIS
- Cómo levantar PostgreSQL + PostGIS con Docker (`docker compose up -d`)
- Cómo verificar la base `taller_gis` y la extensión PostGIS
- Herramientas de administración (pgAdmin 4, `psql` vía `docker exec`)
- Realizar consultas espaciales básicas
- Trabajar con sistemas de referencia espacial
- Crear índices espaciales para mejorar rendimiento

## Ejercicio Práctico

1. Levanta el stack con `docker compose up -d` y verifica `postgis_version()`
2. Conéctate a `taller_gis` con `docker exec -it curso_postgis psql -U postgres -d taller_gis`
3. Crea la tabla `ciudades` con los ejemplos del capítulo
4. Inserta los datos de las ciudades
5. Calcula la distancia entre todas las ciudades
6. Crea un buffer de 200 km alrededor de tu ciudad favorita
7. Crea un índice espacial en la tabla

## Referencias

- PostgreSQL Documentation. (2024). *PostgreSQL 16 Documentation*. https://www.postgresql.org/docs/16/
- PostGIS Documentation. (2024). *PostGIS 3.4 Manual*. https://postgis.net/docs/
- PostGIS. (2024). *Imagen oficial `postgis/postgis` en Docker Hub*. https://hub.docker.com/r/postgis/postgis
- Obe, R., & Hsu, L. (2021). *PostGIS in Action* (3rd ed.). Manning Publications.
- Ramsey, P. (2024). *Introduction to PostGIS*. http://postgis.net/workshops/postgis-intro/
- EnterpriseDB. (2024). *PostgreSQL Installer for Windows*. https://www.enterprisedb.com/downloads/postgres-postgresql-downloads

---

## Anexo A — Instalación nativa (opcional)

Si **no puedes usar Docker**, puedes instalar PostgreSQL y PostGIS directamente en Windows. Es más frágil y depende de tu equipo; úsalo solo como alternativa.

1. **Descarga PostgreSQL 16** (instalador de EnterpriseDB): https://www.enterprisedb.com/downloads/postgres-postgresql-downloads
2. **Ejecuta el instalador** dejando las opciones por defecto. Puntos clave:
   - Componentes: PostgreSQL Server, **pgAdmin 4**, **Stack Builder** y Command Line Tools.
   - Define la contraseña del superusuario `postgres` (recuérdala) y deja el puerto `5432`.
3. **Instala PostGIS** con **Stack Builder** (se ofrece al terminar): *Spatial Extensions → PostGIS Bundle for PostgreSQL 16* → descargar e instalar.
   - Alternativa: instaladores en https://postgis.net/windows_downloads/
4. **Crea la base y habilita PostGIS** (desde `psql -U postgres` o pgAdmin):
   ```sql
   CREATE DATABASE taller_gis OWNER postgres ENCODING 'UTF8' TEMPLATE template0;
   \c taller_gis
   CREATE EXTENSION postgis;
   SELECT postgis_version();
   ```
5. A partir de aquí, en el resto del capítulo sustituye `docker exec -it curso_postgis psql -U postgres -d taller_gis` por `psql -U postgres -d taller_gis`.

---

**Capítulo anterior**: [Capítulo 1: Introducción a Git](./capitulo-01-git.md)

**Próximo capítulo**: [Capítulo 3: Instalación y Configuración de GeoServer](./capitulo-03-geoserver.md)
