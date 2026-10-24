# Capítulo 9: Aplicación Web con Leaflet

## Objetivos del Capítulo

- Conocer Leaflet y sus características
- Configurar un proyecto web básico
- Crear un mapa interactivo
- Consumir servicios WMS de GeoServer
- Consumir servicios WFS de GeoServer
- Agregar interactividad (popups, eventos)
- Implementar controles y leyendas
- Desplegar la aplicación

## 9.1 ¿Qué es Leaflet?

### Introducción

**Leaflet** es la biblioteca JavaScript líder para mapas web interactivos de código abierto.

### Características

- **Ligero**: ~42 KB de JavaScript
- **Mobile-friendly**: Diseñado para móviles
- **Extensible**: Cientos de plugins
- **Personalizable**: Control total sobre el diseño
- **Compatible**: Funciona en todos los navegadores modernos
- **Código abierto**: Licencia BSD

### Ventajas sobre Otras Bibliotecas

| Característica | Leaflet | OpenLayers | Google Maps |
|----------------|---------|------------|-------------|
| **Tamaño** | 42 KB | ~200 KB | ~500 KB |
| **Curva de aprendizaje** | Baja | Media | Baja |
| **Código abierto** | - | - | - |
| **Soporte OGC** | Plugin | Nativo | Limitado |
| **Personalización** | Alta | Muy alta | Media |
| **Mobile** | Excelente | Buena | Buena |

### ¿Cuándo Usar Leaflet?

- Mapas web ligeros y rápidos
- Aplicaciones móviles
- Proyectos con servicios OGC (WMS, WFS)
- Necesitas control total del diseño
- Proyecto de código abierto

## 9.2 Configuración del Proyecto

### Estructura de Archivos

```
webapp/
├── index.html          # Página principal
├── css/
│   └── style.css      # Estilos personalizados
├── js/
│   └── app.js         # Lógica de la aplicación
└── assets/
    └── images/        # Imágenes y recursos
```

### Crear Directorio del Proyecto

```bash
cd servicios_sig_y_websites
mkdir -p webapp/css webapp/js webapp/assets/images
```

### Incluir Leaflet

#### Opción 1: CDN (Recomendado para Desarrollo)

```html
<!-- CSS de Leaflet -->
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
    integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
    crossorigin=""/>

<!-- JavaScript de Leaflet -->
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
    integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
    crossorigin=""></script>
```

#### Opción 2: Descarga Local (Producción)

1. Descarga Leaflet: [https://leafletjs.com/download.html](https://leafletjs.com/download.html)
2. Extrae en `webapp/libs/leaflet/`
3. Incluye en HTML:

```html
<link rel="stylesheet" href="libs/leaflet/leaflet.css"/>
<script src="libs/leaflet/leaflet.js"></script>
```

## 9.3 Crear el Mapa Básico

### HTML Base (index.html)

```html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mapa de Colombia - Departamentos y Municipios</title>

    <!-- Leaflet CSS -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>

    <!-- Estilos personalizados -->
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
        }

        #map {
            width: 100%;
            height: 100vh;
        }

        .info {
            padding: 6px 8px;
            font: 14px/16px Arial, sans-serif;
            background: white;
            background: rgba(255,255,255,0.8);
            box-shadow: 0 0 15px rgba(0,0,0,0.2);
            border-radius: 5px;
        }

        .info h4 {
            margin: 0 0 5px;
            color: #777;
        }
    </style>
</head>
<body>
    <!-- Contenedor del mapa -->
    <div id="map"></div>

    <!-- Leaflet JavaScript -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

    <!-- Nuestra aplicación -->
    <script src="js/app.js"></script>
</body>
</html>
```

### JavaScript (js/app.js)

```javascript
// Crear el mapa centrado en Colombia
const map = L.map('map').setView([4.5709, -74.2973], 6);

// Agregar capa base de OpenStreetMap
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    maxZoom: 19
}).addTo(map);
```

### Probar el Mapa

1. Abre `index.html` en un navegador
2. Deberías ver un mapa de OpenStreetMap centrado en Colombia

## 9.4 Consumir WMS de GeoServer

### Agregar Capa WMS

```javascript
// URL del servicio WMS de GeoServer
const geoserverUrl = 'http://localhost:8080/geoserver/taller/wms';

// Agregar capa WMS de departamentos
const departamentosWMS = L.tileLayer.wms(geoserverUrl, {
    layers: 'taller:departamentos',
    format: 'image/png',
    transparent: true,
    attribution: 'IGAC - Instituto Geográfico Agustín Codazzi'
}).addTo(map);

// Agregar capa WMS de municipios
const municipiosWMS = L.tileLayer.wms(geoserverUrl, {
    layers: 'taller:municipios',
    format: 'image/png',
    transparent: true,
    attribution: 'IGAC'
});
```

### Control de Capas

```javascript
// Capas base
const baseMaps = {
    "OpenStreetMap": L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap contributors'
    }),
    "Satellite": L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
        attribution: 'Tiles &copy; Esri'
    })
};

// Capas superpuestas
const overlayMaps = {
    "Departamentos": departamentosWMS,
    "Municipios": municipiosWMS
};

// Agregar control de capas
L.control.layers(baseMaps, overlayMaps, {
    collapsed: false
}).addTo(map);

// Agregar capa base por defecto
baseMaps["OpenStreetMap"].addTo(map);
```

## 9.5 Consumir WFS de GeoServer

### Cargar Datos GeoJSON desde WFS

```javascript
// URL del servicio WFS
const wfsUrl = 'http://localhost:8080/geoserver/taller/wfs?service=WFS&version=2.0.0&request=GetFeature&typeName=taller:departamentos&outputFormat=application/json';

// Cargar y mostrar departamentos como GeoJSON
fetch(wfsUrl)
    .then(response => response.json())
    .then(data => {
        // Crear capa GeoJSON
        const departamentosGeoJSON = L.geoJSON(data, {
            style: {
                color: '#232323',
                weight: 2,
                fillColor: '#e8f881',
                fillOpacity: 0.5
            },
            onEachFeature: onEachFeature
        });

        // Agregar al mapa
        departamentosGeoJSON.addTo(map);

        // Ajustar vista al extent de los datos
        map.fitBounds(departamentosGeoJSON.getBounds());
    })
    .catch(error => console.error('Error cargando WFS:', error));
```

### Función para Interactividad

```javascript
function onEachFeature(feature, layer) {
    // Popup al hacer clic
    if (feature.properties) {
        const popupContent = `
            <strong>${feature.properties.dpto_cnmbr}</strong><br>
            Código: ${feature.properties.dpto_ccdgo}
        `;
        layer.bindPopup(popupContent);
    }

    // Highlight al pasar el mouse
    layer.on({
        mouseover: highlightFeature,
        mouseout: resetHighlight,
        click: zoomToFeature
    });
}

function highlightFeature(e) {
    const layer = e.target;

    layer.setStyle({
        weight: 5,
        color: '#666',
        fillOpacity: 0.7
    });

    layer.bringToFront();
}

function resetHighlight(e) {
    const layer = e.target;
    layer.setStyle({
        weight: 2,
        color: '#232323',
        fillOpacity: 0.5
    });
}

function zoomToFeature(e) {
    map.fitBounds(e.target.getBounds());
}
```

### Estilizar por Atributo

```javascript
function getColor(area) {
    return area > 50000 ? '#800026' :
           area > 40000 ? '#BD0026' :
           area > 30000 ? '#E31A1C' :
           area > 20000 ? '#FC4E2A' :
           area > 10000 ? '#FD8D3C' :
           area > 5000  ? '#FEB24C' :
           area > 2000  ? '#FED976' :
                          '#FFEDA0';
}

function style(feature) {
    return {
        fillColor: getColor(feature.properties.area),
        weight: 2,
        opacity: 1,
        color: 'white',
        fillOpacity: 0.7
    };
}

// Aplicar estilo
const departamentosGeoJSON = L.geoJSON(data, {
    style: style,
    onEachFeature: onEachFeature
}).addTo(map);
```

## 9.6 Agregar Controles Personalizados

### Panel de Información

```javascript
// Crear control de información
const info = L.control();

info.onAdd = function (map) {
    this._div = L.DomUtil.create('div', 'info');
    this.update();
    return this._div;
};

info.update = function (props) {
    this._div.innerHTML = '<h4>Departamentos de Colombia</h4>' +
        (props ?
            '<b>' + props.dpto_cnmbr + '</b><br />' +
            'Código: ' + props.dpto_ccdgo
            : 'Pasa el cursor sobre un departamento');
};

info.addTo(map);

// Actualizar al pasar el mouse
function highlightFeature(e) {
    const layer = e.target;
    layer.setStyle({
        weight: 5,
        color: '#666',
        fillOpacity: 0.7
    });
    info.update(layer.feature.properties);
}

function resetHighlight(e) {
    const layer = e.target;
    layer.setStyle({
        weight: 2,
        color: '#232323',
        fillOpacity: 0.5
    });
    info.update();
}
```

### Leyenda

```javascript
// Crear leyenda
const legend = L.control({position: 'bottomright'});

legend.onAdd = function (map) {
    const div = L.DomUtil.create('div', 'info legend');
    const grades = [0, 2000, 5000, 10000, 20000, 30000, 40000, 50000];
    const labels = [];

    div.innerHTML = '<strong>Área (km²)</strong><br>';

    // Loop a través de los intervalos y genera etiquetas
    for (let i = 0; i < grades.length; i++) {
        div.innerHTML +=
            '<i style="background:' + getColor(grades[i] + 1) + '; width: 18px; height: 18px; float: left; margin-right: 8px; opacity: 0.7;"></i> ' +
            grades[i] + (grades[i + 1] ? '&ndash;' + grades[i + 1] + '<br>' : '+');
    }

    return div;
};

legend.addTo(map);
```

### Escala

```javascript
// Agregar escala
L.control.scale({
    position: 'bottomleft',
    metric: true,
    imperial: false
}).addTo(map);
```

## 9.7 Búsqueda y Filtros

### Búsqueda por Nombre

```javascript
// Crear control de búsqueda
const searchControl = L.control({position: 'topright'});

searchControl.onAdd = function (map) {
    const div = L.DomUtil.create('div', 'search-control');
    div.innerHTML = `
        <input type="text" id="search-input" placeholder="Buscar departamento...">
        <button id="search-button">Buscar</button>
    `;
    return div;
};

searchControl.addTo(map);

// Función de búsqueda
document.addEventListener('DOMContentLoaded', function() {
    const searchButton = document.getElementById('search-button');
    const searchInput = document.getElementById('search-input');

    searchButton.addEventListener('click', function() {
        const searchText = searchInput.value.toLowerCase();

        departamentosGeoJSON.eachLayer(function(layer) {
            const nombre = layer.feature.properties.dpto_cnmbr.toLowerCase();

            if (nombre.includes(searchText)) {
                map.fitBounds(layer.getBounds());
                layer.openPopup();
            }
        });
    });
});
```

### Filtro WFS con CQL

```javascript
function loadDepartamentosByCQL(filter) {
    const wfsUrl = `http://localhost:8080/geoserver/taller/wfs?service=WFS&version=2.0.0&request=GetFeature&typeName=taller:departamentos&outputFormat=application/json&cql_filter=${filter}`;

    fetch(wfsUrl)
        .then(response => response.json())
        .then(data => {
            // Limpiar capas anteriores
            map.eachLayer(layer => {
                if (layer instanceof L.GeoJSON) {
                    map.removeLayer(layer);
                }
            });

            // Agregar nuevos datos
            L.geoJSON(data, {
                style: style,
                onEachFeature: onEachFeature
            }).addTo(map);
        });
}

// Ejemplo: Filtrar por código
loadDepartamentosByCQL("dpto_ccdgo='25'"); // Solo Cundinamarca
```

## 9.8 Marcadores y Popups

### Agregar Marcador

```javascript
// Marcador simple
const bogotaMarker = L.marker([4.7110, -74.0721])
    .addTo(map)
    .bindPopup('<b>Bogotá D.C.</b><br>Capital de Colombia');

// Marcador personalizado
const customIcon = L.icon({
    iconUrl: 'assets/images/marker-icon.png',
    iconSize: [25, 41],
    iconAnchor: [12, 41],
    popupAnchor: [1, -34]
});

const marker = L.marker([4.7110, -74.0721], {icon: customIcon})
    .addTo(map)
    .bindPopup('Bogotá');
```

### Popup con HTML Personalizado

```javascript
const popupContent = `
    <div style="text-align: center;">
        <h3>${feature.properties.dpto_cnmbr}</h3>
        <img src="assets/images/${feature.properties.dpto_ccdgo}.jpg" width="200">
        <p><strong>Código:</strong> ${feature.properties.dpto_ccdgo}</p>
        <p><strong>Área:</strong> ${feature.properties.area.toLocaleString()} km²</p>
        <a href="#" onclick="zoomToDepartamento('${feature.properties.dpto_ccdgo}')">Ver detalle</a>
    </div>
`;

layer.bindPopup(popupContent);
```

## 9.9 Ejemplo Completo: Aplicación del Curso

### index.html

```html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Colombia - Departamentos y Municipios</title>

    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: Arial, sans-serif;
        }

        #map {
            width: 100%;
            height: 100vh;
        }

        .info {
            padding: 10px;
            font: 14px/16px Arial, sans-serif;
            background: white;
            box-shadow: 0 0 15px rgba(0,0,0,0.2);
            border-radius: 5px;
        }

        .info h4 {
            margin: 0 0 5px;
            color: #333;
        }

        .legend {
            line-height: 18px;
            color: #555;
        }

        .legend i {
            width: 18px;
            height: 18px;
            float: left;
            margin-right: 8px;
            opacity: 0.7;
        }

        .leaflet-control-layers {
            border: 2px solid rgba(0,0,0,0.2);
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div id="map"></div>

    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        // Configuración del mapa
        const map = L.map('map').setView([4.5709, -74.2973], 6);

        // URL de GeoServer
        const geoserverUrl = 'http://localhost:8080/geoserver/taller/wms';

        // Capas base
        const osmLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; OpenStreetMap contributors'
        });

        const satelliteLayer = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
            attribution: 'Esri'
        });

        // Agregar capa base por defecto
        osmLayer.addTo(map);

        // Capas WMS
        const departamentosWMS = L.tileLayer.wms(geoserverUrl, {
            layers: 'taller:departamentos',
            format: 'image/png',
            transparent: true,
            attribution: 'IGAC'
        });

        const municipiosWMS = L.tileLayer.wms(geoserverUrl, {
            layers: 'taller:municipios',
            format: 'image/png',
            transparent: true,
            attribution: 'IGAC'
        });

        // Agregar departamentos por defecto
        departamentosWMS.addTo(map);

        // Control de capas
        const baseMaps = {
            "Mapa base": osmLayer,
            "Satélite": satelliteLayer
        };

        const overlayMaps = {
            "Departamentos (WMS)": departamentosWMS,
            "Municipios (WMS)": municipiosWMS
        };

        L.control.layers(baseMaps, overlayMaps).addTo(map);

        // Cargar departamentos como GeoJSON para interactividad
        const wfsUrl = 'http://localhost:8080/geoserver/taller/wfs?service=WFS&version=2.0.0&request=GetFeature&typeName=taller:departamentos&outputFormat=application/json';

        fetch(wfsUrl)
            .then(response => response.json())
            .then(data => {
                const departamentosLayer = L.geoJSON(data, {
                    style: {
                        color: 'transparent',
                        weight: 0,
                        fillOpacity: 0
                    },
                    onEachFeature: function(feature, layer) {
                        const popupContent = `
                            <h3>${feature.properties.dpto_cnmbr}</h3>
                            <p><strong>Código:</strong> ${feature.properties.dpto_ccdgo}</p>
                        `;
                        layer.bindPopup(popupContent);

                        layer.on({
                            click: function(e) {
                                map.fitBounds(e.target.getBounds());
                            }
                        });
                    }
                }).addTo(map);
            })
            .catch(error => console.error('Error:', error));

        // Control de escala
        L.control.scale({
            position: 'bottomleft',
            metric: true,
            imperial: false
        }).addTo(map);

        // Panel de información
        const info = L.control({position: 'topleft'});

        info.onAdd = function (map) {
            this._div = L.DomUtil.create('div', 'info');
            this._div.innerHTML = `
                <h4>Colombia - Servicios Geográficos</h4>
                <p>Visualización de departamentos y municipios</p>
                <p><small>Datos: IGAC | Servidor: GeoServer</small></p>
            `;
            return this._div;
        };

        info.addTo(map);
    </script>
</body>
</html>
```

## 9.10 Despliegue

### Servidor Local

#### Opción 1: Python HTTP Server

```bash
cd webapp
python -m http.server 8000
```

Accede en: [http://localhost:8000](http://localhost:8000)

#### Opción 2: Node.js http-server

```bash
npm install -g http-server
cd webapp
http-server -p 8000
```

### Producción

#### GitHub Pages

1. Sube el código a GitHub
2. Ve a **Settings** → **Pages**
3. Selecciona la rama `main` y carpeta `/webapp`
4. Guarda

#### Netlify

1. Arrastra la carpeta `webapp` a [https://app.netlify.com/drop](https://app.netlify.com/drop)
2. Tu sitio estará en línea en segundos

### CORS (Cross-Origin Resource Sharing)

Si tienes problemas de CORS con GeoServer:

1. Edita `geoserver/webapps/geoserver/WEB-INF/web.xml`
2. Agrega:

```xml
<filter>
    <filter-name>CorsFilter</filter-name>
    <filter-class>org.apache.catalina.filters.CorsFilter</filter-class>
    <init-param>
        <param-name>cors.allowed.origins</param-name>
        <param-value>*</param-value>
    </init-param>
</filter>
<filter-mapping>
    <filter-name>CorsFilter</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>
```

3. Reinicia GeoServer

## Resumen

En este capítulo has aprendido:

- Qué es Leaflet y sus características
- Configurar un proyecto web con Leaflet
- Crear un mapa interactivo básico
- Consumir servicios WMS de GeoServer
- Consumir servicios WFS de GeoServer
- Agregar interactividad con popups y eventos
- Implementar controles personalizados
- Crear leyendas y paneles de información
- Estilizar capas por atributos
- Desplegar la aplicación

## Ejercicio Práctico

1. Crea la estructura del proyecto `webapp/`
2. Implementa el mapa básico con OpenStreetMap
3. Agrega las capas WMS de departamentos y municipios
4. Implementa el control de capas
5. Carga los departamentos como GeoJSON desde WFS
6. Agrega popups con información de cada departamento
7. Implementa highlight al pasar el mouse
8. Agrega un control de información
9. Crea una leyenda
10. Despliega localmente con Python HTTP Server

## Referencias

- Leaflet Documentation. (2024). *Leaflet - an open-source JavaScript library for interactive maps*. https://leafletjs.com/
- Leaflet Tutorials. (2024). *Quick Start Guide*. https://leafletjs.com/examples/quick-start/
- Leaflet Tutorials. (2024). *Using GeoJSON with Leaflet*. https://leafletjs.com/examples/geojson/
- Leaflet Tutorials. (2024). *Interactive Choropleth Map*. https://leafletjs.com/examples/choropleth/
- Agafonkin, V. (2024). *Leaflet Plugins*. https://leafletjs.com/plugins.html
- Dorman, M. (2020). *Introduction to Web Mapping*. CRC Press.

---

**Capítulo anterior**: [Capítulo 8: Publicación de Capas en GeoServer](./capitulo-08-publicacion-geoserver.md)

**¡Felicitaciones!** Has completado el curso de Servicios Web Geográficos.

---

## Proyecto Final

Crea una aplicación web completa que:

1. - Consuma servicios WMS y WFS de GeoServer
2. - Muestre departamentos y municipios de Colombia
3. - Permita alternar entre capas
4. - Muestre información al hacer clic
5. - Incluya una leyenda
6. - Tenga un panel de información
7. - Sea responsive (funcione en móvil)
8. - Esté desplegada en línea

**Bonus**:
- Agregar búsqueda de departamentos
- Filtrar municipios por departamento
- Gráficos con Chart.js
- Exportar datos a CSV
