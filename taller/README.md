# Curso de Servicios Web Geográficos

## Descripción

Este curso proporciona una guía práctica completa para trabajar con servicios web geográficos, estándares de información geoespacial, y desarrollo de aplicaciones web cartográficas.

## Objetivo

Aprender a configurar, administrar y consumir servicios web geográficos utilizando tecnologías estándar OGC (Open Geospatial Consortium), con énfasis en WMS y WFS.

## Requisitos Previos

- Conocimientos básicos de línea de comandos
- Conexión a internet
- Equipo con Windows (las instrucciones están orientadas a este sistema operativo)

## Contenido del Curso

### [Capítulo 1: Introducción a Git](./capitulo-01-git.md)
- ¿Qué es Git?
- Instalación de Git en Windows
- Comandos básicos de Git
- Clonación de este repositorio

### [Capítulo 2: Explorar y consumir servicios OGC existentes](./capitulo-02-consumir-servicios-ogc.md)
- Consumir servicios reales sin instalar nada
- Operaciones WMS: GetCapabilities, GetMap, GetFeatureInfo
- Operaciones WFS: GetFeature, filtros, GeoJSON
- Teselas WMTS y esquema XYZ
- Navegador, QGIS y línea de comandos

### [Capítulo 3: Instalación de PostgreSQL y PostGIS con Docker](./capitulo-03-postgresql-postgis.md)
- ¿Qué es PostgreSQL?
- ¿Qué es PostGIS?
- Levantar PostGIS con Docker
- Verificación de la base de datos espacial

### [Capítulo 4: Instalación y Configuración de GeoServer con Docker](./capitulo-04-geoserver.md)
- ¿Qué es GeoServer?
- Levantar GeoServer con Docker
- Interfaz de administración

### [Capítulo 5: Servicios Web Geográficos](./capitulo-05-servicios-web-geograficos.md)
- Estándares OGC
- Web Map Service (WMS)
- Web Feature Service (WFS)
- Diferencias y casos de uso
- Parámetros y peticiones

### [Capítulo 6: Estándares para Información Geográfica](./capitulo-06-estandares-geograficos.md)
- GeoJSON: Formato de intercambio
- SLD (Styled Layer Descriptor): Estilos para capas
- Otros formatos relevantes
- Ejemplos prácticos

### [Capítulo 7: Carga de Datos a PostgreSQL](./capitulo-07-carga-datos-postgresql.md)
- Herramientas para carga de datos (en el contenedor)
- Uso de shp2pgsql y ogr2ogr
- Carga de shapefiles de departamentos y municipios
- Verificación de datos

### [Capítulo 8: Publicación de Capas en GeoServer](./capitulo-08-publicacion-geoserver.md)
- Creación de espacios de trabajo
- Configuración de almacenes de datos (host `postgis`)
- Publicación de capas desde PostgreSQL
- Aplicación de estilos SLD
- Servicios WMS y WFS, y WMTS con GeoWebCache

### [Capítulo 9: Aplicación Web con Leaflet](./capitulo-09-aplicacion-leaflet.md)
- Introducción a Leaflet
- Configuración del proyecto
- Consumo de servicios WMS
- Consumo de servicios WFS
- Aplicación práctica: Visualización de departamentos y municipios
- Interactividad y controles

## Datos del Curso

El directorio `data/` contiene los siguientes conjuntos de datos:

- **Departamentos**: Shapefile y GeoJSON de departamentos
- **Municipios**: Shapefile y GeoJSON de municipios
- **Estilos SLD**: Archivos de estilo para cada capa

## Estructura del Repositorio

```
servicios_sig_y_websites/
├── data/                          # Datos geográficos
│   ├── departamentos.shp          # Shapefile de departamentos
│   ├── departamentos.geojson      # GeoJSON de departamentos
│   ├── departamentos.sld          # Estilo para departamentos
│   ├── municipios.shp             # Shapefile de municipios
│   ├── municipios.geojson         # GeoJSON de municipios
│   └── municipios.sld             # Estilo para municipios
├── taller/                        # Documentación del curso
│   ├── capitulo-01-git.md
│   ├── capitulo-02-consumir-servicios-ogc.md
│   ├── capitulo-03-postgresql-postgis.md
│   ├── capitulo-04-geoserver.md
│   ├── capitulo-05-servicios-web-geograficos.md
│   ├── capitulo-06-estandares-geograficos.md
│   ├── capitulo-07-carga-datos-postgresql.md
│   ├── capitulo-08-publicacion-geoserver.md
│   └── capitulo-09-aplicacion-leaflet.md
└── webapp/                        # Aplicación web de ejemplo
    └── index.html
```

## Orden Recomendado

Se recomienda seguir los capítulos en orden secuencial, ya que cada uno construye sobre los conocimientos y configuraciones del anterior.

## Soporte y Recursos

- Documentación oficial de GeoServer: https://docs.geoserver.org/
- Documentación de PostGIS: https://postgis.net/documentation/
- Documentación de Leaflet: https://leafletjs.com/
- Estándares OGC: https://www.ogc.org/standards/

## Licencia

Este material está disponible para fines educativos.

---

**¡Comienza ahora con el [Capítulo 1: Introducción a Git](./capitulo-01-git.md)!**
