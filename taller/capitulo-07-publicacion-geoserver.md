# Capítulo 7: Publicación de Capas en GeoServer

## Objetivos del Capítulo

- Crear espacios de trabajo (workspaces)
- Configurar almacenes de datos (stores)
- Conectar GeoServer a PostgreSQL/PostGIS
- Publicar capas de departamentos y municipios
- Aplicar estilos SLD
- Configurar metadatos de capas
- Probar servicios WMS y WFS
- Optimizar el rendimiento

## 7.1 Arquitectura de Publicación en GeoServer

### Jerarquía de Conceptos

```
Workspace (Espacio de Trabajo)
  └── Store (Almacén de Datos)
       └── Layer (Capa)
            └── Style (Estilo)
```

### Definiciones

| Concepto | Descripción | Ejemplo |
|----------|-------------|---------|
| **Workspace** | Contenedor lógico para organizar datos | `taller` |
| **Store** | Conexión a fuente de datos | `taller_postgis` |
| **Layer** | Capa geográfica publicada | `departamentos`, `municipios` |
| **Style** | Representación visual de la capa | `departamentos_style` |
| **Layer Group** | Agrupación de múltiples capas | `colombia_admin` |

## 7.2 Crear Espacio de Trabajo

### Paso 1: Acceder a Workspaces

1. Inicia sesión en GeoServer: [http://localhost:8080/geoserver](http://localhost:8080/geoserver)
2. Usuario: `admin`, Contraseña: `geoserver` (o la que configuraste)
3. Ve a **Data** → **Workspaces**

### Paso 2: Crear Nuevo Workspace

1. Haz clic en **Add new workspace**
2. Configura:
   - **Name**: `taller`
   - **Namespace URI**: `http://www.geoserver.org/taller`
   - - **Default Workspace** (opcional)
   - **Isolated Workspace**: Dejar desmarcado
3. Haz clic en **Submit**

### Verificación

Deberías ver el workspace `taller` en la lista.

### ¿Para Qué Sirven los Workspaces?

- **Organización**: Separar proyectos o temas
- **Seguridad**: Permisos por workspace
- **Namespaces**: Evitar conflictos de nombres
- **URLs**: Servicios específicos por workspace

**Ejemplo de URLs**:
```
http://localhost:8080/geoserver/taller/wms
http://localhost:8080/geoserver/taller/wfs
```

## 7.3 Crear Almacén de Datos (Store)

### Tipos de Stores

| Tipo | Descripción | Formato |
|------|-------------|---------|
| **Vector Data** | Datos vectoriales | Shapefile, PostGIS, GeoJSON |
| **Raster Data** | Datos ráster | GeoTIFF, NetCDF, ImageMosaic |
| **Cascaded WMS** | Servidor WMS externo | WMS remoto |

### Paso 1: Acceder a Stores

1. Ve a **Data** → **Stores**
2. Haz clic en **Add new Store**

### Paso 2: Seleccionar Tipo

1. En **Vector Data Sources**, selecciona **PostGIS - PostGIS Database**

### Paso 3: Configurar Conexión

#### Información Básica

- **Workspace**: `taller`
- **Data Source Name**: `taller_postgis`
- **Description**: `Base de datos PostGIS con datos del curso`
- - **Enabled**

#### Parámetros de Conexión

| Parámetro | Valor | Descripción |
|-----------|-------|-------------|
| **host** | `postgis` | Nombre del servicio PostGIS en Docker |
| **port** | `5432` | Puerto PostgreSQL |
| **database** | `taller_gis` | Nombre de la base de datos |
| **schema** | `public` | Schema de PostgreSQL |
| **user** | `postgres` | Usuario de PostgreSQL |
| **passwd** | `postgres` | Contraseña del usuario |

> **⚠️ Importante: el host es `postgis`, no `localhost`.** GeoServer y PostGIS corren en contenedores dentro de la misma red de Docker Compose y se localizan entre sí por su **nombre de servicio** (el definido en `docker-compose.yml`). Si pusieras `localhost`, GeoServer buscaría la base de datos *dentro de su propio contenedor* y la conexión fallaría.
>
> **Si usaste la instalación nativa** (Anexos de los capítulos 2 y 3, con PostgreSQL y GeoServer en el mismo equipo), entonces el host del Store **sí** es `localhost`.

#### Opciones Avanzadas

- **namespace**: Dejar en blanco (usa el del workspace)
- **max connections**: `10` (conexiones simultáneas)
- **min connections**: `1`
- **fetch size**: `1000` (registros por consulta)
- **Connection timeout**: `20` segundos
- **validate connections**: - (verificar conexiones)
- **Primary key metadata table**: Dejar en blanco
- **Loose bbox**: ❌ (usar bbox exacto)
- **Estimated extends**: - (estimación rápida de extensiones)
- **Expose primary keys**: ❌

### Paso 4: Guardar

1. Haz clic en **Save**
2. Si la conexión es exitosa, verás la lista de tablas disponibles

### Solución de Problemas

#### Error: Could not connect to database

Con Docker, verifica:
- El contenedor de PostGIS está arriba: `docker compose ps` (el servicio `postgis` en estado *running/healthy*).
- El **host** del Store es `postgis` (no `localhost`) y ambos contenedores se levantaron con el mismo `docker compose up`.
- Usuario/contraseña correctos (`postgres`/`postgres`) y base de datos `taller_gis`.

En instalación nativa, verifica en cambio: que PostgreSQL esté ejecutándose, el host `localhost`, las credenciales, que la base `taller_gis` exista y que el firewall permita el puerto 5432.

#### Error: No suitable driver

Verifica:
- El driver PostgreSQL JDBC está en `geoserver/WEB-INF/lib/`
- Reinicia GeoServer

## 7.4 Publicar Capas

### Método 1: Desde el Store

Después de guardar el store, aparece automáticamente la lista de capas:

1. Verás la lista de tablas PostGIS disponibles
2. Busca `departamentos`
3. Haz clic en **Publish**

### Método 2: Desde Layers

1. Ve a **Data** → **Layers**
2. Haz clic en **Add a new layer**
3. Selecciona el store: `taller:taller_postgis`
4. Haz clic en **Configure new SQL view** o selecciona una tabla
5. Selecciona `departamentos`
6. Haz clic en **Publish**

### Configurar Capa: Departamentos

#### Pestaña Data

**Información Básica**:
- **Name**: `departamentos`
- **Title**: `Departamentos de Colombia`
- **Abstract**: `División administrativa de primer nivel de Colombia`
- - **Enabled**
- - **Advertised**

**Keywords**:
- Agrega palabras clave: `departamentos`, `colombia`, `administración`, `división`

**Coordinate Reference Systems**:
- **Native SRS**: `EPSG:4326` (detectado automáticamente)
- **Declared SRS**: `EPSG:4326`
- **SRS handling**: `Force declared`

**Bounding Boxes**:
1. Haz clic en **Compute from data** para Native Bounding Box
2. Haz clic en **Compute from native bounds** para Lat/Lon Bounding Box

Deberías ver algo como:
```
Native Bounding Box:
  minx: -79.0, maxx: -66.8
  miny: -4.2, maxy: 13.4
```

**Feature Type Details**:
- Verifica que aparezcan los campos de la tabla:
  - `gid` (Integer)
  - `dpto_ccdgo` (String)
  - `dpto_cnmbr` (String)
  - `geom` (MultiPolygon)

#### Pestaña Publishing

**WMS Settings**:
- **Queryable**: - (permite GetFeatureInfo)
- **Opaque**: ❌

**WFS Settings**:
- **Per-Request Feature Limit**: `1000000`
- **Maximum number of decimals**: `8`

**Default Style**:
- Por ahora, deja `polygon` (lo cambiaremos después)

#### Pestaña Tile Caching

- **Create a cached layer for this layer**: - (opcional, mejora rendimiento)

### Paso Final: Guardar

1. Haz clic en **Save**
2. La capa `departamentos` ahora está publicada

### Publicar Capa: Municipios

Repite el proceso para `municipios`:

1. Ve a **Data** → **Layers** → **Add new layer**
2. Selecciona `taller:taller_postgis`
3. Selecciona `municipios` → **Publish**
4. Configura:
   - **Name**: `municipios`
   - **Title**: `Municipios de Colombia`
   - **Abstract**: `División administrativa de segundo nivel de Colombia`
   - **Keywords**: `municipios`, `colombia`, `administración`
   - **SRS**: `EPSG:4326`
   - Calcula bounding boxes
5. **Save**

## 7.5 Aplicar Estilos SLD

### Subir Archivos SLD

#### Paso 1: Preparar Archivos

Los archivos SLD están en el repositorio:
- `data/departamentos.sld`
- `data/municipios.sld`

#### Paso 2: Crear Estilo en GeoServer

1. Ve a **Data** → **Styles**
2. Haz clic en **Add a new style**

#### Configurar Estilo: Departamentos

**Información Básica**:
- **Workspace**: `taller`
- **Name**: `departamentos_style`
- **Format**: `SLD`

**Cargar SLD**:
1. Haz clic en **Browse** junto a "Style file"
2. Selecciona `departamentos.sld` del repositorio
3. Haz clic en **Upload**
4. El contenido del SLD aparecerá en el editor

**Validar**:
1. Haz clic en **Validate**
2. Si hay errores, corrígelos
3. Si es válido, verás: "No validation errors"

**Guardar**:
1. Haz clic en **Submit**

#### Configurar Estilo: Municipios

Repite el proceso:
1. **Add a new style**
2. **Workspace**: `taller`
3. **Name**: `municipios_style`
4. Sube `municipios.sld`
5. Valida y guarda

### Asignar Estilos a Capas

#### Departamentos

1. Ve a **Data** → **Layers**
2. Selecciona `taller:departamentos`
3. Pestaña **Publishing**
4. En **Default Style**, selecciona `taller:departamentos_style`
5. **Save**

#### Municipios

1. Selecciona `taller:municipios`
2. **Publishing** → **Default Style**: `taller:municipios_style`
3. **Save**

### Crear Estilos Personalizados

#### Ejemplo: Estilo Básico para Puntos

Si tuvieras una capa de ciudades:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor version="1.0.0"
    xmlns="http://www.opengis.net/sld"
    xmlns:ogc="http://www.opengis.net/ogc"
    xmlns:se="http://www.opengis.net/se">
  <NamedLayer>
    <Name>ciudades</Name>
    <UserStyle>
      <Title>Ciudades - Puntos rojos</Title>
      <FeatureTypeStyle>
        <Rule>
          <Name>rule1</Name>
          <Title>Ciudad</Title>
          <PointSymbolizer>
            <Graphic>
              <Mark>
                <WellKnownName>circle</WellKnownName>
                <Fill>
                  <CssParameter name="fill">#FF0000</CssParameter>
                </Fill>
                <Stroke>
                  <CssParameter name="stroke">#000000</CssParameter>
                  <CssParameter name="stroke-width">1</CssParameter>
                </Stroke>
              </Mark>
              <Size>8</Size>
            </Graphic>
          </PointSymbolizer>
        </Rule>
      </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>
```

## 7.6 Vista Previa de Capas

### Layer Preview

1. Ve a **Data** → **Layer Preview**
2. Busca `taller:departamentos`
3. En el menú desplegable, selecciona **OpenLayers**

### Explorar el Mapa

Deberías ver:
- Polígonos de departamentos con relleno amarillo-verde (`#e8f881`)
- Bordes oscuros
- Etiquetas con nombres de departamentos

### Opciones de Vista Previa

| Formato | Descripción |
|---------|-------------|
| **OpenLayers** | Mapa interactivo en navegador |
| **GML 2/3** | Datos en formato GML |
| **GeoJSON** | Datos en formato JSON |
| **CSV** | Atributos en CSV (sin geometría) |
| **KML** | Para Google Earth |
| **PDF** | Mapa en PDF |

### Probar GetFeatureInfo

1. En la vista OpenLayers de departamentos
2. Haz clic sobre un departamento
3. Verás un popup con información:
   - `gid`
   - `dpto_ccdgo`
   - `dpto_cnmbr`

## 7.7 Probar Servicios

### URLs de Servicios

#### GetCapabilities

**WMS**:
```
http://localhost:8080/geoserver/taller/wms?service=WMS&version=1.1.0&request=GetCapabilities
```

**WFS**:
```
http://localhost:8080/geoserver/taller/wfs?service=WFS&version=2.0.0&request=GetCapabilities
```

#### GetMap (WMS)

```
http://localhost:8080/geoserver/taller/wms?
  service=WMS&
  version=1.1.0&
  request=GetMap&
  layers=taller:departamentos&
  styles=&
  bbox=-79.0,-4.2,-66.8,13.4&
  width=800&
  height=600&
  srs=EPSG:4326&
  format=image/png
```

#### GetFeature (WFS)

**Todos los departamentos (GeoJSON)**:
```
http://localhost:8080/geoserver/taller/wfs?
  service=WFS&
  version=2.0.0&
  request=GetFeature&
  typeName=taller:departamentos&
  outputFormat=application/json
```

**Con filtro CQL**:
```
http://localhost:8080/geoserver/taller/wfs?
  service=WFS&
  version=2.0.0&
  request=GetFeature&
  typeName=taller:departamentos&
  outputFormat=application/json&
  cql_filter=dpto_cnmbr='Cundinamarca'
```

**Solo 5 municipios**:
```
http://localhost:8080/geoserver/taller/wfs?
  service=WFS&
  version=2.0.0&
  request=GetFeature&
  typeName=taller:municipios&
  outputFormat=application/json&
  count=5
```

### Probar desde Navegador

Copia y pega las URLs en el navegador para verificar las respuestas.

### Probar con cURL

```bash
# WMS GetMap
curl "http://localhost:8080/geoserver/taller/wms?service=WMS&version=1.1.0&request=GetMap&layers=taller:departamentos&bbox=-79,-4.2,-66.8,13.4&width=400&height=300&srs=EPSG:4326&format=image/png" -o departamentos.png

# WFS GetFeature
curl "http://localhost:8080/geoserver/taller/wfs?service=WFS&version=2.0.0&request=GetFeature&typeName=taller:departamentos&outputFormat=application/json&count=1" | jq
```

## 7.8 Configurar Metadatos

### Metadatos de Capa

1. Ve a **Data** → **Layers** → `taller:departamentos`
2. Pestaña **Publishing**

#### Metadata

**Attribution**:
- **Attribution Text**: `Instituto Geográfico Agustín Codazzi (IGAC)`
- **Attribution Link**: `https://www.igac.gov.co`

**Metadata Links**:
- Agrega enlaces a metadatos ISO o FGDC si están disponibles

#### Access Constraints

```
Uso educativo y no comercial. Para uso comercial contactar al IGAC.
```

### Metadatos del Workspace

1. Ve a **Data** → **Workspaces** → `taller`
2. **Settings** → **Contact Information**
3. Agrega información de contacto

## 7.9 Crear Grupo de Capas

### ¿Para Qué?

Un **Layer Group** permite servir múltiples capas como una sola.

### Paso 1: Crear Layer Group

1. Ve a **Data** → **Layer Groups**
2. Haz clic en **Add new layer group**

### Paso 2: Configurar

**Información Básica**:
- **Workspace**: `taller`
- **Name**: `colombia_admin`
- **Title**: `División Administrativa de Colombia`
- **Abstract**: `Departamentos y municipios de Colombia`

**Layers**:
1. Haz clic en **Add Layer**
2. Selecciona `taller:departamentos`
3. Haz clic en **Add Layer** nuevamente
4. Selecciona `taller:municipios`

**Orden** (de arriba hacia abajo):
1. `municipios` (se dibuja primero)
2. `departamentos` (se dibuja encima)

**Bounding Box**:
1. Haz clic en **Generate Bounds**

### Paso 3: Guardar

1. Haz clic en **Save**
2. Ahora puedes servir ambas capas juntas

### Usar el Layer Group

```
http://localhost:8080/geoserver/taller/wms?
  service=WMS&
  version=1.1.0&
  request=GetMap&
  layers=taller:colombia_admin&
  bbox=-79.0,-4.2,-66.8,13.4&
  width=800&
  height=600&
  srs=EPSG:4326&
  format=image/png
```

## 7.10 Optimización de Rendimiento

### Caché de Teselas (GeoWebCache)

GeoServer incluye GeoWebCache integrado.

#### Habilitar Caché para Capa

1. Ve a **Data** → **Layers** → `taller:departamentos`
2. Pestaña **Tile Caching**
3. - **Create a cached layer for this layer**
4. **Tile cache configuration**:
   - **Gridsets**: Selecciona `EPSG:4326`, `EPSG:900913` (Web Mercator)
   - **Tile Formats**: `image/png`, `image/jpeg`
5. **Save**

#### Pre-generar Caché

1. Ve a **Tile Layers**
2. Busca `taller:departamentos`
3. Haz clic en **Seed/Truncate**
4. Configura:
   - **Operation**: `Seed`
   - **Grid Set**: `EPSG:4326`
   - **Format**: `image/png`
   - **Zoom start**: `0`
   - **Zoom stop**: `10`
5. Haz clic en **Submit**

### Índices en PostgreSQL

Asegúrate de tener índices espaciales:

```sql
-- Verificar índices
SELECT indexname FROM pg_indexes
WHERE tablename IN ('departamentos', 'municipios');

-- Crear si no existen
CREATE INDEX idx_departamentos_geom ON departamentos USING GIST (geom);
CREATE INDEX idx_municipios_geom ON municipios USING GIST (geom);

-- Actualizar estadísticas
VACUUM ANALYZE departamentos;
VACUUM ANALYZE municipios;
```

### Configuración de Store

En el store `taller_postgis`:
- **max connections**: `10`
- **fetch size**: `1000`
- - **validate connections**
- - **Estimated extends**

### Configuración Global

1. Ve a **Settings** → **Global**
2. **Resource Cache**: `100` MB
3. **Number of decimals**: `6-8`
4. **Enable global services**: Según necesidad

## 7.11 Seguridad Básica

### Restringir Acceso a Capas

1. Ve a **Security** → **Data**
2. Haz clic en **Add new rule**
3. Configura:
   - **Workspace**: `taller`
   - **Layer**: `departamentos`
   - **Access mode**: `READ`
   - **Roles**: `ROLE_AUTHENTICATED` (solo usuarios autenticados)
4. **Save**

### Crear Usuario

1. Ve a **Security** → **Users, Groups, Roles**
2. Pestaña **Users/Groups**
3. **Add new user**:
   - **User name**: `viewer`
   - **Password**: `viewer123`
   - **Enabled**: 
   - **Roles**: `ROLE_VIEWER`
4. **Save**

### Probar Acceso

Sin autenticación, algunos servicios devolverán error 403.

## Resumen

En este capítulo has aprendido:

- Crear espacios de trabajo (workspaces)
- Configurar almacenes de datos PostGIS
- Conectar GeoServer a PostgreSQL
- Publicar capas de departamentos y municipios
- Aplicar estilos SLD personalizados
- Configurar metadatos de capas
- Probar servicios WMS y WFS
- Crear grupos de capas
- Optimizar rendimiento con caché
- Configurar seguridad básica

## Ejercicio Práctico

1. Crea el workspace `taller`
2. Configura el store `taller_postgis` conectado a tu base de datos
3. Publica la capa `departamentos`
4. Publica la capa `municipios`
5. Sube y aplica los estilos SLD del repositorio
6. Visualiza las capas en Layer Preview
7. Crea el layer group `colombia_admin`
8. Prueba el servicio WMS con GetMap
9. Prueba el servicio WFS con GetFeature y filtro CQL
10. Habilita el caché para la capa de departamentos

## Referencias

- GeoServer Documentation. (2024). *Publishing Data*. https://docs.geoserver.org/stable/en/user/data/
- GeoServer Documentation. (2024). *Styling*. https://docs.geoserver.org/stable/en/user/styling/
- GeoServer Documentation. (2024). *Layer Groups*. https://docs.geoserver.org/stable/en/user/data/webadmin/layergroups.html
- GeoServer Documentation. (2024). *GeoWebCache*. https://docs.geoserver.org/stable/en/user/geowebcache/
- GeoServer Documentation. (2024). *Security*. https://docs.geoserver.org/stable/en/user/security/
- Iacovella, S., & Youngblood, B. (2013). *GeoServer Beginner's Guide*. Packt Publishing. Chapter 3-4.

---

**Capítulo anterior**: [Capítulo 6: Carga de Datos a PostgreSQL](./capitulo-06-carga-datos-postgresql.md)

**Próximo capítulo**: [Capítulo 8: Aplicación Web con Leaflet](./capitulo-08-aplicacion-leaflet.md)
