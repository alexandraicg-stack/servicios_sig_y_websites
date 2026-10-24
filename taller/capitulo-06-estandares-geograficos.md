# Capítulo 6: Estándares para Información Geográfica

## Objetivos del Capítulo

- Comprender el formato GeoJSON
- Trabajar con archivos GeoJSON
- Entender SLD (Styled Layer Descriptor)
- Crear y modificar estilos SLD
- Conocer otros formatos geográficos relevantes
- Aplicar estilos a capas en GeoServer

## 6.1 GeoJSON

### ¿Qué es GeoJSON?

**GeoJSON** es un formato abierto para codificar datos geoespaciales utilizando JSON (JavaScript Object Notation).

### Características

- **Basado en JSON**: Fácil de leer y escribir
- **Web-friendly**: Compatible con JavaScript
- **Geometrías y atributos**: Combina forma y datos
- **Estándar abierto**: RFC 7946
- **Ampliamente soportado**: Leaflet, OpenLayers, QGIS, PostGIS

### Estructura Básica

```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [-74.0721, 4.7110]
      },
      "properties": {
        "nombre": "Bogotá",
        "poblacion": 7181469
      }
    }
  ]
}
```

### Componentes de GeoJSON

#### 1. FeatureCollection

Contenedor de múltiples features:

```json
{
  "type": "FeatureCollection",
  "features": [...]
}
```

#### 2. Feature

Representa un elemento geográfico individual:

```json
{
  "type": "Feature",
  "id": "unique-id",
  "geometry": {...},
  "properties": {...}
}
```

#### 3. Geometry

Define la forma espacial:

**Point (Punto)**:
```json
{
  "type": "Point",
  "coordinates": [-74.0721, 4.7110]
}
```

**LineString (Línea)**:
```json
{
  "type": "LineString",
  "coordinates": [
    [-74.0, 4.0],
    [-73.0, 5.0],
    [-72.0, 6.0]
  ]
}
```

**Polygon (Polígono)**:
```json
{
  "type": "Polygon",
  "coordinates": [
    [
      [-74.0, 4.0],
      [-73.0, 4.0],
      [-73.0, 5.0],
      [-74.0, 5.0],
      [-74.0, 4.0]
    ]
  ]
}
```

**MultiPoint**:
```json
{
  "type": "MultiPoint",
  "coordinates": [
    [-74.0, 4.0],
    [-73.0, 5.0]
  ]
}
```

**MultiLineString**:
```json
{
  "type": "MultiLineString",
  "coordinates": [
    [[-74.0, 4.0], [-73.0, 5.0]],
    [[-72.0, 6.0], [-71.0, 7.0]]
  ]
}
```

**MultiPolygon**:
```json
{
  "type": "MultiPolygon",
  "coordinates": [
    [
      [[-74.0, 4.0], [-73.0, 4.0], [-73.0, 5.0], [-74.0, 5.0], [-74.0, 4.0]]
    ],
    [
      [[-72.0, 6.0], [-71.0, 6.0], [-71.0, 7.0], [-72.0, 7.0], [-72.0, 6.0]]
    ]
  ]
}
```

**GeometryCollection**:
```json
{
  "type": "GeometryCollection",
  "geometries": [
    {
      "type": "Point",
      "coordinates": [-74.0, 4.0]
    },
    {
      "type": "LineString",
      "coordinates": [[-74.0, 4.0], [-73.0, 5.0]]
    }
  ]
}
```

#### 4. Properties

Atributos del feature:

```json
{
  "properties": {
    "nombre": "Cundinamarca",
    "codigo": "25",
    "poblacion": 3000000,
    "area_km2": 24210.0,
    "activo": true
  }
}
```

### Convenciones Importantes

#### Orden de Coordenadas

**GeoJSON usa [longitud, latitud]**, no [latitud, longitud]:

- **Correcto**:
```json
"coordinates": [-74.0721, 4.7110]  // [lon, lat]
```

❌ **Incorrecto**:
```json
"coordinates": [4.7110, -74.0721]  // [lat, lon]
```

#### Sistema de Referencia

- **Por defecto**: WGS84 (EPSG:4326)
- Las coordenadas deben estar en grados decimales
- Desde RFC 7946, no se soportan otros CRS en GeoJSON

#### Polígonos

- El primer anillo es el exterior (sentido antihorario)
- Anillos adicionales son huecos (sentido horario)
- El primer y último punto deben ser iguales (cerrar el polígono)

### Ejemplo Completo: Departamentos de Colombia

```json
{
  "type": "FeatureCollection",
  "name": "departamentos",
  "crs": {
    "type": "name",
    "properties": {
      "name": "urn:ogc:def:crs:OGC:1.3:CRS84"
    }
  },
  "features": [
    {
      "type": "Feature",
      "id": 1,
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [-74.297, 4.572],
              [-74.298, 4.571],
              [-74.297, 4.570],
              [-74.296, 4.571],
              [-74.297, 4.572]
            ]
          ]
        ]
      },
      "properties": {
        "dpto_ccdgo": "25",
        "dpto_cnmbr": "Cundinamarca",
        "area": 24210.0,
        "perimeter": 1125.5
      }
    },
    {
      "type": "Feature",
      "id": 2,
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [...]
      },
      "properties": {
        "dpto_ccdgo": "05",
        "dpto_cnmbr": "Antioquia",
        "area": 63612.0,
        "perimeter": 1876.3
      }
    }
  ]
}
```

### Trabajar con GeoJSON

#### Leer GeoJSON en JavaScript

```javascript
// Cargar GeoJSON desde archivo
fetch('departamentos.geojson')
  .then(response => response.json())
  .then(data => {
    console.log('Total features:', data.features.length);

    // Iterar sobre features
    data.features.forEach(feature => {
      console.log(feature.properties.dpto_cnmbr);
    });
  });
```

#### Crear GeoJSON Programáticamente

```javascript
const miGeoJSON = {
  type: "FeatureCollection",
  features: [
    {
      type: "Feature",
      geometry: {
        type: "Point",
        coordinates: [-74.0721, 4.7110]
      },
      properties: {
        ciudad: "Bogotá",
        pais: "Colombia"
      }
    }
  ]
};

// Convertir a string
const jsonString = JSON.stringify(miGeoJSON, null, 2);
```

#### Validar GeoJSON

Usa herramientas en línea:
- [https://geojsonlint.com/](https://geojsonlint.com/)
- [https://geojson.io/](https://geojson.io/)

#### Convertir Formatos

**Shapefile a GeoJSON** (usando ogr2ogr):
```bash
ogr2ogr -f GeoJSON departamentos.geojson departamentos.shp
```

**CSV a GeoJSON** (con coordenadas):
```bash
ogr2ogr -f GeoJSON puntos.geojson puntos.csv -oo X_POSSIBLE_NAMES=lon -oo Y_POSSIBLE_NAMES=lat
```

**PostgreSQL a GeoJSON**:
```bash
ogr2ogr -f GeoJSON departamentos.geojson PG:"host=localhost dbname=taller_gis user=postgres" -sql "SELECT * FROM departamentos"
```

### Ventajas y Desventajas

#### Ventajas

- Fácil de leer y escribar
- Compatible con JavaScript/web
- No requiere software especial
- Soportado ampliamente
- Ideal para aplicaciones web

#### Desventajas

❌ Archivos grandes (no comprimido)
❌ Solo WGS84 (RFC 7946)
❌ No soporta topología
❌ Menos eficiente que formatos binarios

## 6.2 Styled Layer Descriptor (SLD)

### ¿Qué es SLD?

**SLD** es un estándar OGC (XML) para describir la apariencia de capas geográficas.

### Características

- **Estilos personalizados**: Colores, símbolos, etiquetas
- **Basado en reglas**: Estilos condicionales
- **Portable**: Funciona en diferentes servidores OGC
- **XML**: Formato estructurado y validable

### Estructura de un SLD

```xml
<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor version="1.1.0"
    xmlns="http://www.opengis.net/sld"
    xmlns:se="http://www.opengis.net/se"
    xmlns:ogc="http://www.opengis.net/ogc"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

  <NamedLayer>
    <se:Name>nombre_capa</se:Name>
    <UserStyle>
      <se:Name>nombre_estilo</se:Name>
      <se:FeatureTypeStyle>
        <se:Rule>
          <!-- Simbolizadores aquí -->
        </se:Rule>
      </se:FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>
```

### Componentes de SLD

#### 1. NamedLayer

Identifica la capa:

```xml
<NamedLayer>
  <se:Name>departamentos</se:Name>
  <UserStyle>...</UserStyle>
</NamedLayer>
```

#### 2. UserStyle

Define el estilo del usuario:

```xml
<UserStyle>
  <se:Name>mi_estilo_departamentos</se:Name>
  <se:FeatureTypeStyle>...</se:FeatureTypeStyle>
</UserStyle>
```

#### 3. FeatureTypeStyle

Agrupa reglas de estilo:

```xml
<se:FeatureTypeStyle>
  <se:Rule>...</se:Rule>
  <se:Rule>...</se:Rule>
</se:FeatureTypeStyle>
```

#### 4. Rule

Define una regla de estilo:

```xml
<se:Rule>
  <se:Name>Nombre de la regla</se:Name>
  <se:Description>
    <se:Title>Título visible</se:Title>
    <se:Abstract>Descripción detallada</se:Abstract>
  </se:Description>

  <!-- Filtros (opcional) -->
  <ogc:Filter>...</ogc:Filter>

  <!-- Escala mínima/máxima (opcional) -->
  <se:MinScaleDenominator>10000</se:MinScaleDenominator>
  <se:MaxScaleDenominator>100000</se:MaxScaleDenominator>

  <!-- Simbolizadores -->
  <se:PolygonSymbolizer>...</se:PolygonSymbolizer>
</se:Rule>
```

### Simbolizadores (Symbolizers)

#### PointSymbolizer

Para geometrías de tipo punto:

```xml
<se:PointSymbolizer>
  <se:Graphic>
    <se:Mark>
      <se:WellKnownName>circle</se:WellKnownName>
      <se:Fill>
        <se:SvgParameter name="fill">#FF0000</se:SvgParameter>
        <se:SvgParameter name="fill-opacity">0.8</se:SvgParameter>
      </se:Fill>
      <se:Stroke>
        <se:SvgParameter name="stroke">#000000</se:SvgParameter>
        <se:SvgParameter name="stroke-width">1</se:SvgParameter>
      </se:Stroke>
    </se:Mark>
    <se:Size>10</se:Size>
  </se:Graphic>
</se:PointSymbolizer>
```

**Símbolos predefinidos**:
- `circle`
- `square`
- `triangle`
- `star`
- `cross`
- `x`

#### LineSymbolizer

Para geometrías de tipo línea:

```xml
<se:LineSymbolizer>
  <se:Stroke>
    <se:SvgParameter name="stroke">#0000FF</se:SvgParameter>
    <se:SvgParameter name="stroke-width">2</se:SvgParameter>
    <se:SvgParameter name="stroke-opacity">1.0</se:SvgParameter>
    <se:SvgParameter name="stroke-linejoin">round</se:SvgParameter>
    <se:SvgParameter name="stroke-linecap">round</se:SvgParameter>
    <se:SvgParameter name="stroke-dasharray">5 2</se:SvgParameter>
  </se:Stroke>
</se:LineSymbolizer>
```

**Tipos de línea**:
- `stroke-linejoin`: `miter`, `round`, `bevel`
- `stroke-linecap`: `butt`, `round`, `square`
- `stroke-dasharray`: Patrón de guiones (ej. "5 2" = 5px línea, 2px espacio)

#### PolygonSymbolizer

Para geometrías de tipo polígono:

```xml
<se:PolygonSymbolizer>
  <se:Fill>
    <se:SvgParameter name="fill">#00FF00</se:SvgParameter>
    <se:SvgParameter name="fill-opacity">0.7</se:SvgParameter>
  </se:Fill>
  <se:Stroke>
    <se:SvgParameter name="stroke">#000000</se:SvgParameter>
    <se:SvgParameter name="stroke-width">1</se:SvgParameter>
    <se:SvgParameter name="stroke-opacity">1.0</se:SvgParameter>
    <se:SvgParameter name="stroke-linejoin">bevel</se:SvgParameter>
  </se:Stroke>
</se:PolygonSymbolizer>
```

#### TextSymbolizer

Para etiquetas:

```xml
<se:TextSymbolizer>
  <se:Label>
    <ogc:PropertyName>dpto_cnmbr</ogc:PropertyName>
  </se:Label>
  <se:Font>
    <se:SvgParameter name="font-family">Arial</se:SvgParameter>
    <se:SvgParameter name="font-size">12</se:SvgParameter>
    <se:SvgParameter name="font-style">normal</se:SvgParameter>
    <se:SvgParameter name="font-weight">bold</se:SvgParameter>
  </se:Font>
  <se:LabelPlacement>
    <se:PointPlacement>
      <se:AnchorPoint>
        <se:AnchorPointX>0.5</se:AnchorPointX>
        <se:AnchorPointY>0.5</se:AnchorPointY>
      </se:AnchorPoint>
    </se:PointPlacement>
  </se:LabelPlacement>
  <se:Fill>
    <se:SvgParameter name="fill">#000000</se:SvgParameter>
  </se:Fill>
  <se:VendorOption name="maxDisplacement">1</se:VendorOption>
  <se:VendorOption name="conflictResolution">true</se:VendorOption>
</se:TextSymbolizer>
```

### Ejemplo Real: Estilo de Departamentos

Este es el estilo SLD de los departamentos del curso:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld"
    xmlns:se="http://www.opengis.net/se"
    xmlns:ogc="http://www.opengis.net/ogc"
    version="1.1.0">
  <NamedLayer>
    <se:Name>departamentos</se:Name>
    <UserStyle>
      <se:Name>departamentos</se:Name>
      <se:FeatureTypeStyle>
        <!-- Regla para el polígono -->
        <se:Rule>
          <se:Name>Single symbol</se:Name>
          <se:PolygonSymbolizer>
            <se:Fill>
              <se:SvgParameter name="fill">#e8f881</se:SvgParameter>
              <se:SvgParameter name="fill-opacity">0.8</se:SvgParameter>
            </se:Fill>
            <se:Stroke>
              <se:SvgParameter name="stroke">#232323</se:SvgParameter>
              <se:SvgParameter name="stroke-opacity">0.8</se:SvgParameter>
              <se:SvgParameter name="stroke-width">1</se:SvgParameter>
              <se:SvgParameter name="stroke-linejoin">bevel</se:SvgParameter>
            </se:Stroke>
          </se:PolygonSymbolizer>
        </se:Rule>

        <!-- Regla para las etiquetas -->
        <se:Rule>
          <se:TextSymbolizer>
            <se:Label>
              <ogc:PropertyName>dpto_cnmbr</ogc:PropertyName>
            </se:Label>
            <se:Font>
              <se:SvgParameter name="font-family">Open Sans</se:SvgParameter>
              <se:SvgParameter name="font-size">13</se:SvgParameter>
            </se:Font>
            <se:LabelPlacement>
              <se:PointPlacement>
                <se:AnchorPoint>
                  <se:AnchorPointX>0</se:AnchorPointX>
                  <se:AnchorPointY>0.5</se:AnchorPointY>
                </se:AnchorPoint>
              </se:PointPlacement>
            </se:LabelPlacement>
            <se:Fill>
              <se:SvgParameter name="fill">#323232</se:SvgParameter>
            </se:Fill>
            <se:VendorOption name="maxDisplacement">1</se:VendorOption>
          </se:TextSymbolizer>
        </se:Rule>
      </se:FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>
```

### Filtros en SLD

Los filtros permiten aplicar estilos condicionales:

#### Filtro por Atributo

```xml
<se:Rule>
  <se:Name>Poblacion alta</se:Name>
  <ogc:Filter>
    <ogc:PropertyIsGreaterThan>
      <ogc:PropertyName>poblacion</ogc:PropertyName>
      <ogc:Literal>1000000</ogc:Literal>
    </ogc:PropertyIsGreaterThan>
  </ogc:Filter>
  <se:PolygonSymbolizer>
    <se:Fill>
      <se:SvgParameter name="fill">#FF0000</se:SvgParameter>
    </se:Fill>
  </se:PolygonSymbolizer>
</se:Rule>
```

#### Filtro por Rango

```xml
<ogc:Filter>
  <ogc:And>
    <ogc:PropertyIsGreaterThanOrEqualTo>
      <ogc:PropertyName>poblacion</ogc:PropertyName>
      <ogc:Literal>500000</ogc:Literal>
    </ogc:PropertyIsGreaterThanOrEqualTo>
    <ogc:PropertyIsLessThan>
      <ogc:PropertyName>poblacion</ogc:PropertyName>
      <ogc:Literal>1000000</ogc:Literal>
    </ogc:PropertyIsLessThan>
  </ogc:And>
</ogc:Filter>
```

#### Filtro por Texto

```xml
<ogc:Filter>
  <ogc:PropertyIsLike wildCard="*" singleChar="?" escapeChar="\">
    <ogc:PropertyName>nombre</ogc:PropertyName>
    <ogc:Literal>San*</ogc:Literal>
  </ogc:PropertyIsLike>
</ogc:Filter>
```

### Escala de Visualización

Controla la visibilidad según el nivel de zoom:

```xml
<se:Rule>
  <se:Name>Vista cercana</se:Name>
  <!-- Visible solo entre escalas 1:10,000 y 1:100,000 -->
  <se:MinScaleDenominator>10000</se:MinScaleDenominator>
  <se:MaxScaleDenominator>100000</se:MaxScaleDenominator>
  <se:PolygonSymbolizer>...</se:PolygonSymbolizer>
</se:Rule>
```

### Ejemplo Avanzado: Clasificación por Población

```xml
<se:FeatureTypeStyle>
  <!-- Poblacion < 500,000 -->
  <se:Rule>
    <se:Name>Baja</se:Name>
    <ogc:Filter>
      <ogc:PropertyIsLessThan>
        <ogc:PropertyName>poblacion</ogc:PropertyName>
        <ogc:Literal>500000</ogc:Literal>
      </ogc:PropertyIsLessThan>
    </ogc:Filter>
    <se:PolygonSymbolizer>
      <se:Fill>
        <se:SvgParameter name="fill">#FFFFB2</se:SvgParameter>
      </se:Fill>
    </se:PolygonSymbolizer>
  </se:Rule>

  <!-- 500,000 <= Poblacion < 1,000,000 -->
  <se:Rule>
    <se:Name>Media</se:Name>
    <ogc:Filter>
      <ogc:And>
        <ogc:PropertyIsGreaterThanOrEqualTo>
          <ogc:PropertyName>poblacion</ogc:PropertyName>
          <ogc:Literal>500000</ogc:Literal>
        </ogc:PropertyIsGreaterThanOrEqualTo>
        <ogc:PropertyIsLessThan>
          <ogc:PropertyName>poblacion</ogc:PropertyName>
          <ogc:Literal>1000000</ogc:Literal>
        </ogc:PropertyIsLessThan>
      </ogc:And>
    </ogc:Filter>
    <se:PolygonSymbolizer>
      <se:Fill>
        <se:SvgParameter name="fill">#FEB24C</se:SvgParameter>
      </se:Fill>
    </se:PolygonSymbolizer>
  </se:Rule>

  <!-- Poblacion >= 1,000,000 -->
  <se:Rule>
    <se:Name>Alta</se:Name>
    <ogc:Filter>
      <ogc:PropertyIsGreaterThanOrEqualTo>
        <ogc:PropertyName>poblacion</ogc:PropertyName>
        <ogc:Literal>1000000</ogc:Literal>
      </ogc:PropertyIsGreaterThanOrEqualTo>
    </ogc:Filter>
    <se:PolygonSymbolizer>
      <se:Fill>
        <se:SvgParameter name="fill">#F03B20</se:SvgParameter>
      </se:Fill>
    </se:PolygonSymbolizer>
  </se:Rule>
</se:FeatureTypeStyle>
```

### Herramientas para Trabajar con SLD

#### 1. QGIS

Exportar estilos a SLD desde QGIS:

1. Diseña el estilo en QGIS
2. Botón derecho en la capa → **Propiedades** → **Simbología**
3. **Estilo** (menú inferior) → **Guardar estilo** → **Archivo SLD**

#### 2. GeoServer Style Editor

1. **Data** → **Styles** → **Add a new style**
2. Edita directamente en el editor web
3. Valida con el botón **Validate**

#### 3. Editores de Texto

Cualquier editor XML funciona:
- VS Code con extensión XML
- Notepad++
- Sublime Text

## 6.3 Otros Formatos Geográficos

### KML (Keyhole Markup Language)

Formato de Google Earth:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Placemark>
    <name>Bogotá</name>
    <Point>
      <coordinates>-74.0721,4.7110,0</coordinates>
    </Point>
  </Placemark>
</kml>
```

**Uso**: Google Earth, Google Maps

### GML (Geography Markup Language)

Formato XML de OGC:

```xml
<gml:Point srsName="EPSG:4326">
  <gml:pos>4.7110 -74.0721</gml:pos>
</gml:Point>
```

**Uso**: Intercambio entre sistemas OGC

### Shapefile

Formato vectorial de Esri (múltiples archivos):

- `.shp`: Geometrías
- `.shx`: Índice
- `.dbf`: Atributos
- `.prj`: Proyección
- `.cpg`: Codificación

**Uso**: SIG de escritorio (QGIS, ArcGIS)

### GeoPackage

Formato SQLite para datos geoespaciales:

- Archivo único `.gpkg`
- Soporta múltiples capas
- Geometrías y ráster
- Estándar OGC

**Uso**: Intercambio moderno, SIG de escritorio y móvil

### TopoJSON

Extensión de GeoJSON con topología:

- Archivos más pequeños
- Comparte geometrías
- Mantiene topología

**Uso**: Visualizaciones web (D3.js)

## Resumen

En este capítulo has aprendido:

- Estructura y sintaxis de GeoJSON
- Tipos de geometrías en GeoJSON
- Cómo trabajar con archivos GeoJSON
- Estructura y componentes de SLD
- Simbolizadores para puntos, líneas y polígonos
- Etiquetas con TextSymbolizer
- Filtros y reglas condicionales
- Ejemplos reales de SLD del curso
- Otros formatos geográficos relevantes

## Ejercicio Práctico

1. Abre el archivo `data/departamentos.geojson` en un editor
2. Identifica los elementos: FeatureCollection, Feature, geometry, properties
3. Cuenta cuántos departamentos hay en el archivo
4. Abre el archivo `data/departamentos.sld` en un editor XML
5. Identifica el color de relleno y el color del borde
6. Modifica el color de relleno a `#FFD700` (dorado)
7. Cambia el tamaño de fuente de las etiquetas a `16`
8. Valida el SLD modificado en GeoServer (próximo capítulo)

## Referencias

- Butler, H., Daly, M., Doyle, A., Gillies, S., Hagen, S., & Schaub, T. (2016). *The GeoJSON Format (RFC 7946)*. IETF. https://tools.ietf.org/html/rfc7946
- Open Geospatial Consortium. (2007). *Styled Layer Descriptor 1.1.0*. https://www.ogc.org/standards/sld
- Open Geospatial Consortium. (2012). *Symbology Encoding 1.1.0*. https://www.ogc.org/standards/se
- GeoServer Documentation. (2024). *Styling*. https://docs.geoserver.org/stable/en/user/styling/
- Macwright, T. (2024). *More than you ever wanted to know about GeoJSON*. https://macwright.com/2015/03/23/geojson-second-bite.html
- GeoJSON.io. (2024). *geojson.io - a quick, simple tool for creating, viewing, and sharing spatial data*. https://geojson.io/

---

**Capítulo anterior**: [Capítulo 5: Servicios Web Geográficos](./capitulo-05-servicios-web-geograficos.md)

**Próximo capítulo**: [Capítulo 7: Carga de Datos a PostgreSQL](./capitulo-07-carga-datos-postgresql.md)
