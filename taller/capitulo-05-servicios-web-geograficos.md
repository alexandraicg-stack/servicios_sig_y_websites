# Capítulo 5: Servicios Web Geográficos

## Objetivos del Capítulo

- Comprender los estándares OGC
- Entender qué es un servicio web geográfico
- Conocer WMS (Web Map Service) en profundidad
- Conocer WFS (Web Feature Service) en profundidad
- Diferenciar entre WMS y WFS
- Aprender a construir peticiones HTTP para cada servicio
- Explorar otros servicios OGC

## 5.1 ¿Qué es OGC?

### Open Geospatial Consortium

**OGC** (Open Geospatial Consortium) es una organización internacional que desarrolla estándares abiertos para:

- **Interoperabilidad**: Sistemas geoespaciales que funcionan juntos
- **Servicios web**: Acceso a datos geográficos vía internet
- **Formatos de datos**: Intercambio de información geoespacial
- **APIs**: Interfaces de programación estándar

### Importancia de los Estándares OGC

| Beneficio | Descripción |
|-----------|-------------|
| **Interoperabilidad** | Sistemas diferentes pueden trabajar juntos |
| **Independencia** | No dependes de un proveedor específico |
| **Reutilización** | Los mismos datos sirven para múltiples aplicaciones |
| **Ahorro de costos** | Evita desarrollos propietarios |
| **Escalabilidad** | Facilita el crecimiento del sistema |

### Principales Estándares OGC

- **WMS**: Web Map Service (mapas como imágenes)
- **WFS**: Web Feature Service (datos vectoriales)
- **WCS**: Web Coverage Service (datos ráster)
- **WMTS**: Web Map Tile Service (teselas de mapas)
- **WPS**: Web Processing Service (geoprocesamiento)
- **CSW**: Catalogue Service for the Web (catálogos de metadatos)
- **SLD**: Styled Layer Descriptor (estilos)
- **GML**: Geography Markup Language (formato XML)

## 5.2 Arquitectura de Servicios Web Geográficos

### Modelo Cliente-Servidor

```
┌─────────────┐         HTTP Request            ┌─────────────┐
│             │ ──────────────────────────────> │             │
│   Cliente   │                                 │   Servidor  │
│  (Navegador,│                                 │  GeoServer  │
│   Leaflet,  │                                 │             │
│    QGIS)    │ <────────────────────────────── │             │
│             │         HTTP Response           │             │
└─────────────┘      (Imagen o datos)           └─────────────┘
```

### Componentes

1. **Cliente**: Aplicación que solicita datos (navegador, SIG de escritorio, app móvil)
2. **Servidor**: Software que sirve datos geográficos (GeoServer, MapServer, QGIS Server)
3. **Protocolo**: HTTP/HTTPS
4. **Formato de petición**: URL con parámetros
5. **Formato de respuesta**: Imagen (PNG, JPG), datos (GML, GeoJSON), XML

## 5.3 Web Map Service (WMS)

### ¿Qué es WMS?

**WMS** es un estándar OGC para servir **mapas georreferenciados como imágenes**.

### Características

- **Salida**: Imágenes (PNG, JPEG, GIF)
- **Estilos**: Renderizado en el servidor
- **Rendimiento**: Eficiente para visualización
- **Limitación**: No permite consultar atributos individuales

### Versiones de WMS

- **1.0.0**: Primera versión (obsoleta)
- **1.1.0**: Ampliamente utilizada
- **1.1.1**: Mejoras menores
- **1.3.0**: Versión actual recomendada

### Operaciones WMS

#### 1. GetCapabilities

Devuelve metadatos sobre el servicio y las capas disponibles.

**Petición**:
```
http://localhost:8080/geoserver/wms?
  service=WMS&
  version=1.1.0&
  request=GetCapabilities
```

**Respuesta**: Documento XML con:
- Información del servicio
- Lista de capas disponibles
- Sistemas de coordenadas soportados
- Formatos de salida disponibles
- Estilos disponibles

**Ejemplo de respuesta (fragmento)**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<WMT_MS_Capabilities version="1.1.0">
  <Service>
    <Name>WMS</Name>
    <Title>GeoServer Web Map Service</Title>
    <Abstract>A compliant implementation of WMS</Abstract>
  </Service>
  <Capability>
    <Request>
      <GetCapabilities>...</GetCapabilities>
      <GetMap>...</GetMap>
      <GetFeatureInfo>...</GetFeatureInfo>
    </Request>
    <Layer>
      <Title>Departamentos</Title>
      <Name>taller:departamentos</Name>
      <SRS>EPSG:4326</SRS>
      <LatLonBoundingBox minx="-79.0" miny="-4.2" maxx="-66.8" maxy="13.4"/>
    </Layer>
  </Capability>
</WMT_MS_Capabilities>
```

#### 2. GetMap

Solicita un mapa renderizado como imagen.

**Parámetros obligatorios**:

| Parámetro | Descripción | Ejemplo |
|-----------|-------------|---------|
| `SERVICE` | Tipo de servicio | `WMS` |
| `VERSION` | Versión del servicio | `1.1.0` o `1.3.0` |
| `REQUEST` | Tipo de petición | `GetMap` |
| `LAYERS` | Capas a visualizar | `taller:departamentos` |
| `STYLES` | Estilos a aplicar | `` (vacío para estilo por defecto) |
| `SRS` (1.1.0) o `CRS` (1.3.0) | Sistema de coordenadas | `EPSG:4326` |
| `BBOX` | Extensión geográfica | `minx,miny,maxx,maxy` |
| `WIDTH` | Ancho en píxeles | `800` |
| `HEIGHT` | Alto en píxeles | `600` |
| `FORMAT` | Formato de imagen | `image/png` |

**Parámetros opcionales**:

| Parámetro | Descripción | Ejemplo |
|-----------|-------------|---------|
| `TRANSPARENT` | Fondo transparente | `TRUE` |
| `BGCOLOR` | Color de fondo | `0xFFFFFF` |
| `EXCEPTIONS` | Formato de errores | `application/vnd.ogc.se_xml` |

**Ejemplo de petición**:
```
http://localhost:8080/geoserver/wms?
  SERVICE=WMS&
  VERSION=1.1.0&
  REQUEST=GetMap&
  LAYERS=taller:departamentos&
  STYLES=&
  SRS=EPSG:4326&
  BBOX=-79.0,-4.2,-66.8,13.4&
  WIDTH=800&
  HEIGHT=600&
  FORMAT=image/png&
  TRANSPARENT=TRUE
```

**Respuesta**: Imagen PNG del mapa

#### 3. GetFeatureInfo

Consulta información de elementos en una ubicación específica del mapa.

**Parámetros adicionales a GetMap**:

| Parámetro | Descripción | Ejemplo |
|-----------|-------------|---------|
| `QUERY_LAYERS` | Capas a consultar | `taller:departamentos` |
| `INFO_FORMAT` | Formato de respuesta | `text/html`, `application/json` |
| `X` (o `I` en 1.3.0) | Coordenada X del píxel | `400` |
| `Y` (o `J` en 1.3.0) | Coordenada Y del píxel | `300` |

**Ejemplo de petición**:
```
http://localhost:8080/geoserver/wms?
  SERVICE=WMS&
  VERSION=1.1.0&
  REQUEST=GetFeatureInfo&
  LAYERS=taller:departamentos&
  QUERY_LAYERS=taller:departamentos&
  STYLES=&
  SRS=EPSG:4326&
  BBOX=-79.0,-4.2,-66.8,13.4&
  WIDTH=800&
  HEIGHT=600&
  X=400&
  Y=300&
  INFO_FORMAT=application/json&
  FEATURE_COUNT=10
```

**Respuesta**: Datos JSON con información del elemento clickeado

### Diferencias entre WMS 1.1.0 y 1.3.0

| Aspecto | WMS 1.1.0 | WMS 1.3.0 |
|---------|-----------|-----------|
| Sistema de coordenadas | `SRS` | `CRS` |
| Coordenadas del píxel | `X`, `Y` | `I`, `J` |
| Orden de ejes EPSG:4326 | lon, lat | lat, lon |
| Namespace | `WMT_MS_Capabilities` | `WMS_Capabilities` |

**⚠️ IMPORTANTE**: En WMS 1.3.0 con EPSG:4326, el BBOX es `miny,minx,maxy,maxx` (lat,lon) en lugar de `minx,miny,maxx,maxy` (lon,lat).

## 5.4 Web Feature Service (WFS)

### ¿Qué es WFS?

**WFS** es un estándar OGC para servir **datos vectoriales** (geometrías y atributos).

### Características

- **Salida**: Datos vectoriales (GML, GeoJSON, CSV)
- **Consultas**: Filtrado por atributos y espaciales
- **Edición**: WFS-T permite crear, actualizar, eliminar
- **Geometrías**: Acceso a coordenadas exactas

### Versiones de WFS

- **1.0.0**: Primera versión
- **1.1.0**: Mejoras en consultas
- **2.0.0**: Versión actual recomendada

### Niveles de Conformidad

| Nivel | Capacidades |
|-------|-------------|
| **Basic WFS** | GetCapabilities, DescribeFeatureType, GetFeature |
| **Transaction WFS** | + Transaction (Insert, Update, Delete) |
| **Locking WFS** | + LockFeature, GetFeatureWithLock |

### Operaciones WFS

#### 1. GetCapabilities

Devuelve metadatos sobre el servicio y los tipos de elementos (feature types).

**Petición**:
```
http://localhost:8080/geoserver/wfs?
  service=WFS&
  version=2.0.0&
  request=GetCapabilities
```

**Respuesta**: XML con capacidades del servicio

#### 2. DescribeFeatureType

Describe la estructura de un tipo de elemento (esquema).

**Petición**:
```
http://localhost:8080/geoserver/wfs?
  service=WFS&
  version=2.0.0&
  request=DescribeFeatureType&
  typeName=taller:departamentos
```

**Respuesta**: XML Schema (XSD) describiendo los campos y tipos de datos

**Ejemplo de respuesta**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <xsd:element name="departamentos" type="taller:departamentosType"/>
  <xsd:complexType name="departamentosType">
    <xsd:sequence>
      <xsd:element name="geom" type="gml:MultiPolygonPropertyType"/>
      <xsd:element name="codigo" type="xsd:string"/>
      <xsd:element name="nombre" type="xsd:string"/>
      <xsd:element name="poblacion" type="xsd:int"/>
    </xsd:sequence>
  </xsd:complexType>
</xsd:schema>
```

#### 3. GetFeature

Solicita datos de elementos.

**Parámetros**:

| Parámetro | Descripción | Ejemplo |
|-----------|-------------|---------|
| `SERVICE` | Tipo de servicio | `WFS` |
| `VERSION` | Versión | `2.0.0` |
| `REQUEST` | Tipo de petición | `GetFeature` |
| `TYPENAME` | Tipo de elemento | `taller:departamentos` |
| `OUTPUTFORMAT` | Formato de salida | `application/json` |
| `COUNT` | Número máximo de elementos | `10` |
| `STARTINDEX` | Índice inicial (paginación) | `0` |
| `SRSNAME` | Sistema de coordenadas | `EPSG:4326` |
| `BBOX` | Filtro espacial por extensión | `minx,miny,maxx,maxy,EPSG:4326` |
| `PROPERTYNAME` | Campos a retornar | `nombre,poblacion` |

**Ejemplo básico**:
```
http://localhost:8080/geoserver/wfs?
  service=WFS&
  version=2.0.0&
  request=GetFeature&
  typeName=taller:departamentos&
  outputFormat=application/json
```

**Ejemplo con filtro espacial**:
```
http://localhost:8080/geoserver/wfs?
  service=WFS&
  version=2.0.0&
  request=GetFeature&
  typeName=taller:departamentos&
  outputFormat=application/json&
  bbox=-75.0,2.0,-73.0,5.0,EPSG:4326
```

**Ejemplo con paginación**:
```
http://localhost:8080/geoserver/wfs?
  service=WFS&
  version=2.0.0&
  request=GetFeature&
  typeName=taller:municipios&
  outputFormat=application/json&
  count=50&
  startIndex=0
```

**Respuesta**: GeoJSON con los datos

```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "id": "departamentos.1",
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [[[-74.0, 4.0], ...]]
      },
      "properties": {
        "codigo": "25",
        "nombre": "Cundinamarca",
        "poblacion": 3000000
      }
    }
  ]
}
```

#### 5. GetPropertyValue

Obtiene solo valores de propiedades específicas (sin geometría).

**Ejemplo**:
```
http://localhost:8080/geoserver/wfs?
  service=WFS&
  version=2.0.0&
  request=GetPropertyValue&
  typeName=taller:departamentos&
  valueReference=nombre
```

#### 5. Transaction (WFS-T)

Permite crear, actualizar o eliminar elementos.

**Ejemplo de inserción (POST)**:
```xml
<wfs:Transaction service="WFS" version="2.0.0">
  <wfs:Insert>
    <taller:departamentos>
      <taller:nombre>Nuevo Departamento</taller:nombre>
      <taller:geom>
        <gml:Point srsName="EPSG:4326">
          <gml:pos>-74.0 4.0</gml:pos>
        </gml:Point>
      </taller:geom>
    </taller:departamentos>
  </wfs:Insert>
</wfs:Transaction>
```

### Filtros CQL (Common Query Language)

GeoServer soporta filtros CQL más legibles que XML.

**Ejemplos**:

**Filtro por atributo**:
```
http://localhost:8080/geoserver/wfs?
  service=WFS&
  request=GetFeature&
  typeName=taller:departamentos&
  outputFormat=application/json&
  cql_filter=poblacion > 1000000
```

**Filtro con LIKE**:
```
cql_filter=nombre LIKE 'San%'
```

**Filtro espacial (intersección)**:
```
cql_filter=INTERSECTS(geom, POINT(-74.0 4.0))
```

**Filtro combinado**:
```
cql_filter=poblacion > 500000 AND nombre LIKE 'C%'
```

## 5.5 Diferencias entre WMS y WFS

| Aspecto | WMS | WFS |
|---------|-----|-----|
| **Tipo de datos** | Imágenes (ráster) | Datos vectoriales |
| **Formato de salida** | PNG, JPEG, GIF | GML, GeoJSON, CSV, Shapefile |
| **Uso principal** | Visualización de mapas | Análisis y consulta de datos |
| **Consultas** | Limitadas (GetFeatureInfo) | Avanzadas (filtros espaciales y alfanuméricos) |
| **Edición** | No | Sí (WFS-T) |
| **Ancho de banda** | Menor (imágenes comprimidas) | Mayor (datos completos) |
| **Estilos** | Renderizados en servidor | Renderizados en cliente |
| **Interactividad** | Baja | Alta |
| **Rendimiento** | Mejor para visualización | Mejor para análisis |

### ¿Cuándo Usar Cada Uno?

**Usa WMS cuando**:
- Solo necesitas visualizar datos
- Quieres mapas estilizados
- Tienes muchos datos y no necesitas descargarlos todos
- Quieres minimizar el tráfico de red

**Usa WFS cuando**:
- Necesitas acceder a atributos de los datos
- Quieres hacer análisis espacial en el cliente
- Necesitas filtrar datos por atributos
- Quieres descargar datos para uso offline
- Necesitas editar datos (WFS-T)

**Combina ambos**:
- WMS como capa base (visualización rápida)
- WFS para capas de interés (consultas y análisis)

## 5.6 Otros Servicios OGC

### WCS (Web Coverage Service)

Sirve datos ráster (coberturas).

**Usos**: Modelos de elevación, imágenes satelitales, datos climáticos

**Operaciones**:
- GetCapabilities
- DescribeCoverage
- GetCoverage

**Ejemplo**:
```
http://localhost:8080/geoserver/wcs?
  service=WCS&
  version=2.0.1&
  request=GetCoverage&
  coverageId=elevation&
  format=image/tiff
```

### WMTS (Web Map Tile Service)

Sirve teselas de mapas pre-renderizadas.

**Ventajas**:
- Alto rendimiento
- Caché eficiente
- Compatible con mapas base

**Ejemplo**:
```
http://localhost:8080/geoserver/gwc/service/wmts?
  service=WMTS&
  request=GetTile&
  layer=taller:departamentos&
  tilematrixset=EPSG:4326&
  tilematrix=EPSG:4326:10&
  tilerow=384&
  tilecol=512&
  format=image/png
```

### WPS (Web Processing Service)

Ejecuta procesos geoespaciales en el servidor.

**Usos**: Buffer, intersección, unión, análisis de densidad

**Operaciones**:
- GetCapabilities
- DescribeProcess
- Execute

## 5.7 Pruebas Prácticas con GeoServer

### Usando el Navegador

#### Probar GetCapabilities

Abre en el navegador:
```
http://localhost:8080/geoserver/wms?service=WMS&request=GetCapabilities
```

Deberías ver un documento XML.

#### Probar GetMap

```
http://localhost:8080/geoserver/wms?
  service=WMS&
  version=1.1.0&
  request=GetMap&
  layers=sf:states&
  styles=&
  bbox=-124.73,24.96,-66.97,49.37&
  width=800&
  height=400&
  srs=EPSG:4326&
  format=image/png
```

Deberías ver una imagen del mapa.

#### Probar WFS GetFeature

```
http://localhost:8080/geoserver/wfs?
  service=WFS&
  version=2.0.0&
  request=GetFeature&
  typeName=sf:states&
  outputFormat=application/json&
  count=5
```

Deberías ver datos GeoJSON.

### Usando Demo Requests en GeoServer

1. Ve a **Demos** → **Demo requests**
2. Selecciona un ejemplo (ej. "WFS_getFeature-1.1.xml")
3. Modifica los parámetros si es necesario
4. Haz clic en **Submit**
5. Observa la respuesta

### Usando cURL

```bash
# WMS GetCapabilities
curl "http://localhost:8080/geoserver/wms?service=WMS&request=GetCapabilities"

# WFS GetFeature
curl "http://localhost:8080/geoserver/wfs?service=WFS&version=2.0.0&request=GetFeature&typeName=sf:states&outputFormat=application/json&count=1"
```

## 5.8 Mejores Prácticas

### Rendimiento

- - Usa caché (WMTS) para capas que no cambian frecuentemente
- - Limita el número de elementos en WFS con `count`
- - Usa BBOX para limitar el área de consulta
- - Selecciona solo las propiedades necesarias con `propertyName`
- - Crea índices espaciales en la base de datos

### Seguridad

- - Valida y sanitiza parámetros de entrada
- - Implementa límites de rate limiting
- - Usa HTTPS en producción
- - Configura control de acceso por capa
- - No expongas capas sensibles públicamente

### Compatibilidad

- - Soporta múltiples versiones de WMS/WFS
- - Ofrece múltiples formatos de salida
- - Documenta los SRS soportados
- - Proporciona metadatos completos en GetCapabilities

## Resumen

En este capítulo has aprendido:

- Qué es OGC y su importancia
- Arquitectura de servicios web geográficos
- WMS: Operaciones, parámetros y casos de uso
- WFS: Operaciones, parámetros y casos de uso
- Diferencias entre WMS y WFS
- Otros servicios OGC (WCS, WMTS, WPS)
- Cómo construir peticiones HTTP
- Cómo probar servicios con navegador y cURL
- Mejores prácticas de rendimiento y seguridad

## Ejercicio Práctico

1. Accede al WMS GetCapabilities de tu GeoServer local
2. Identifica una capa de ejemplo (ej. `sf:states`)
3. Construye una petición GetMap para visualizar esa capa
4. Ejecuta una petición GetFeatureInfo en un punto del mapa
5. Accede al WFS GetCapabilities
6. Ejecuta un GetFeature para obtener datos en GeoJSON
7. Aplica un filtro CQL para obtener solo algunos elementos
8. Compara el tamaño de respuesta entre WMS y WFS

## Referencias

- Open Geospatial Consortium. (2024). *WMS 1.3.0 Implementation Specification*. https://www.ogc.org/standards/wms
- Open Geospatial Consortium. (2024). *WFS 2.0 Implementation Specification*. https://www.ogc.org/standards/wfs
- GeoServer Documentation. (2024). *WMS Reference*. https://docs.geoserver.org/stable/en/user/services/wms/
- GeoServer Documentation. (2024). *WFS Reference*. https://docs.geoserver.org/stable/en/user/services/wfs/
- GeoServer Documentation. (2024). *CQL and ECQL*. https://docs.geoserver.org/stable/en/user/filter/ecql_reference.html
- Lake, R., Burggraf, D. S., Trninic, M., & Rae, L. (2004). *Geography Mark-Up Language: Foundation for the Geo-Web*. Wiley.

---

**Capítulo anterior**: [Capítulo 4: Instalación y Configuración de GeoServer](./capitulo-04-geoserver.md)

**Próximo capítulo**: [Capítulo 6: Estándares para Información Geográfica](./capitulo-06-estandares-geograficos.md)
