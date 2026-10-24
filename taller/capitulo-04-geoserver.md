# Capítulo 4: Instalación y Configuración de GeoServer

## Objetivos del Capítulo

- Comprender qué es GeoServer y su propósito
- Levantar GeoServer con Docker (sin instalar Java ni descargar binarios)
- Verificar el servicio y acceder a la interfaz de administración
- Conocer dónde viven los datos y los logs cuando corre en contenedor
- (Opcional) Instalar GeoServer de forma nativa

## 4.1 ¿Qué es GeoServer?

**GeoServer** es un servidor de código abierto para compartir datos geoespaciales:

### Características Principales

- **Servidor de mapas**: Publica mapas a través de estándares OGC
- **Múltiples fuentes de datos**: Shapefiles, PostGIS, Oracle, MySQL, etc.
- **Estilos personalizables**: Mediante SLD y CSS
- **Extensible**: Arquitectura de plugins
- **APIs REST**: Administración programática
- **Seguridad**: Control de acceso granular

### Servicios Soportados

| Servicio | Descripción |
|----------|-------------|
| **WMS** | Web Map Service - Mapas como imágenes |
| **WFS** | Web Feature Service - Datos vectoriales |
| **WCS** | Web Coverage Service - Datos ráster |
| **WPS** | Web Processing Service - Geoprocesamiento |
| **WMTS** | Web Map Tile Service - Mapas en teselas |

### ¿Por qué GeoServer?

- - **Código abierto** y gratuito
- - **Cumplimiento de estándares** OGC
- - **Ampliamente adoptado** en la industria
- - **Comunidad activa** y documentación extensa
- - **Integración con PostGIS** y otras bases de datos
- - **Alto rendimiento** y escalabilidad

## 4.2 Levantar GeoServer con Docker

La forma recomendada en este curso es con **Docker**. La imagen oficial ya trae Java y el servidor configurado: **no hay que instalar Java, ni descargar/extraer binarios, ni usar nssm**.

### Requisitos

- **Docker Desktop** instalado y funcionando (ver el Módulo 0 de nivelación).
- El archivo `docker-compose.yml` que está en la **raíz del repositorio** (define los servicios `geoserver` y `postgis`).

### Paso 1: Levantar los servicios

Desde la raíz del repositorio:

```bash
docker compose up -d
```

Esto descarga la imagen `docker.osgeo.org/geoserver:2.25.3` (la primera vez) y levanta GeoServer junto con PostGIS. Comprueba el estado:

```bash
docker compose ps
```

Y observa el arranque en vivo:

```bash
docker compose logs -f geoserver
```

### Paso 2: Verificar la Instalación

1. Abre un navegador y ve a: [http://localhost:8080/geoserver](http://localhost:8080/geoserver)
2. Inicia sesión con las credenciales por defecto del `docker-compose.yml`:
   - **Usuario**: `admin`
   - **Contraseña**: `geoserver`

### Detener y continuar

```bash
docker compose down     # detiene los contenedores
docker compose up -d    # vuelve a levantarlos
```

Los datos de GeoServer **se conservan** entre reinicios porque viven en el volumen `geoserver_data` (montado en `/opt/geoserver_data`). Solo se borran si eliminas el volumen explícitamente.

### Solución de problemas

- **Puerto 8080 ocupado:** edita el mapeo de puertos del servicio `geoserver` en `docker-compose.yml`, por ejemplo `"8081:8080"`, vuelve a ejecutar `docker compose up -d` y entra en [http://localhost:8081/geoserver](http://localhost:8081/geoserver).
- **El contenedor no inicia:** revisa `docker compose logs geoserver`.

> **Importante para el Capítulo 8.** Cuando GeoServer corre en Docker y creas el *Store* de PostGIS, el **host NO es `localhost`** sino **`postgis`** (el nombre del servicio en `docker-compose.yml`), con puerto `5432`, base de datos `taller_gis` y usuario/clave `postgres`/`postgres`. Ambos contenedores comparten la red de Docker Compose y se ven entre sí por su nombre de servicio.

## 4.5 Interfaz de Administración

### Acceso a la Interfaz

1. Abre: [http://localhost:8080/geoserver](http://localhost:8080/geoserver)
2. Haz clic en **Login** (esquina superior derecha)
3. Credenciales por defecto:
   - **Usuario**: `admin`
   - **Contraseña**: `geoserver`

**⚠️ IMPORTANTE**: Cambia la contraseña después del primer acceso.

### Cambiar la Contraseña de Administrador

1. Inicia sesión con las credenciales por defecto
2. Ve a **Security** → **Users, Groups, Roles**
3. Haz clic en la pestaña **Users/Groups**
4. Haz clic en el usuario `admin`
5. Cambia la contraseña
6. Haz clic en **Save**

### Secciones Principales de la Interfaz

#### 1. Panel Principal (Home)

- **About GeoServer**: Información de la versión
- **Server Status**: Estado del servidor
- **GeoServer Logs**: Registro de eventos
- **Contact Information**: Información de contacto

#### 2. Data

Administración de datos geoespaciales:

- **Layer Preview**: Vista previa de capas
- **Workspaces**: Espacios de trabajo (contenedores lógicos)
- **Stores**: Almacenes de datos (conexiones a fuentes)
- **Layers**: Capas publicadas
- **Layer Groups**: Grupos de capas
- **Styles**: Estilos SLD/CSS

#### 4. Services

Configuración de servicios OGC:

- **WMS**: Web Map Service
- **WFS**: Web Feature Service
- **WCS**: Web Coverage Service
- **WPS**: Web Processing Service

#### 4. Settings

Configuración global:

- **Global**: Configuración general del servidor
- **Image Processing**: Procesamiento de imágenes
- **Raster Access**: Acceso a datos ráster
- **Coverage Access**: Acceso a coberturas

#### 5. Tile Caching

Configuración de caché de teselas:

- **Tile Layers**: Capas cacheadas
- **Caching Defaults**: Configuración por defecto
- **Gridsets**: Conjuntos de grillas

#### 6. Security

Gestión de seguridad:

- **Settings**: Configuración de seguridad
- **Authentication**: Métodos de autenticación
- **Users, Groups, Roles**: Usuarios y permisos
- **Data**: Reglas de acceso a datos
- **Services**: Reglas de acceso a servicios

#### 7. Demos

Herramientas de demostración:

- **Demo requests**: Ejemplos de peticiones
- **SRS List**: Sistemas de referencia espacial
- **Reprojection Console**: Consola de reproyección
- **WCS request builder**: Constructor de peticiones WCS

### Configuración Inicial Recomendada

#### 1. Configuración Global

**Settings** → **Global**:

- **Verbose Messages**: - (durante desarrollo)
- **Verbose Exceptions**: - (durante desarrollo)
- **Number of Decimals**: `8`
- **Character Set**: `UTF-8`
- **Proxy Base URL**: `http://tu-servidor.com/geoserver` (en producción)

#### 2. Información de Contacto

**Settings** → **Contact Information**:

- **Contact Organization**: Tu organización
- **Contact Person**: Tu nombre
- **Contact Email**: tu@email.com

#### 4. Configuración de Servicios

**Services** → **WMS**:

- **Service Metadata**:
  - Title: "Servicio de Mapas"
  - Abstract: Descripción del servicio
- **Limited SRS List**: Agrega SRIDs que usarás (4326, 3857, 3116, etc.)

**Services** → **WFS**:

- **Service Metadata**: Similar a WMS
- **Service Level**: **Complete** (para operaciones WFS-T)
- **Maximum number of features**: `1000000`
- **Maximum number of decimals**: `8`

## 4.6 Vista Previa de Capas

GeoServer incluye capas de demostración.

### Acceder a Layer Preview

1. Ve a **Data** → **Layer Preview**
2. Verás una lista de capas precargadas
3. Para cada capa puedes:
   - **OpenLayers**: Vista previa interactiva
   - **GML, GeoJSON, CSV, etc.**: Descargar en diferentes formatos

### Ejemplo: Vista Previa de Estados (sf:states)

1. Busca la capa `sf:states`
2. Haz clic en **OpenLayers** en el menú desplegable
3. Se abrirá un mapa interactivo con la capa

### URLs de Servicios

Para cada capa, puedes obtener las URLs de servicio:

**WMS GetCapabilities**:
```
http://localhost:8080/geoserver/wms?service=WMS&version=1.1.0&request=GetCapabilities
```

**WFS GetCapabilities**:
```
http://localhost:8080/geoserver/wfs?service=WFS&version=1.1.0&request=GetCapabilities
```

**WMS GetMap** (ejemplo):
```
http://localhost:8080/geoserver/wms?
  service=WMS&
  version=1.1.0&
  request=GetMap&
  layers=sf:states&
  bbox=-124.73,24.96,-66.97,49.37&
  width=768&
  height=384&
  srs=EPSG:4326&
  format=image/png
```

## 4.7 Estructura de Directorios

### Directorio de Datos (data_dir)

Con Docker, el `data_dir` de GeoServer vive en el volumen `geoserver_data`, montado dentro del contenedor en `/opt/geoserver_data`. Para inspeccionarlo:

```bash
docker exec -it curso_geoserver ls /opt/geoserver_data
```

Su estructura es la misma que en una instalación nativa:

```
data_dir/
├── coverages/          # Coberturas ráster
├── data/               # Datos por defecto
├── demo/               # Datos de demostración
├── layergroups/        # Configuración de grupos
├── logs/               # Logs de GeoServer
├── palettes/           # Paletas de colores
├── plugIns/            # Plugins instalados
├── security/           # Configuración de seguridad
├── styles/             # Archivos SLD
├── templates/          # Plantillas de salida
├── user_projections/   # Proyecciones personalizadas
├── workspaces/         # Configuración de workspaces
└── global.xml          # Configuración global
```

### Archivos Importantes

- `global.xml`: Configuración global
- `logging.xml`: Configuración de logs
- `wms.xml`: Configuración del servicio WMS
- `wfs.xml`: Configuración del servicio WFS

## 4.8 Monitoreo y Logs

### Ver el Estado del Servidor

**About & Status** → **Server Status**:

- **JVM Version**: Versión de Java
- **Memory Usage**: Uso de memoria
- **Update Sequence**: Secuencia de actualización
- **Resource Cache**: Estado de caché
- **Configuration**: Recargar configuración

### Limpiar Caché

Si realizas cambios en la configuración:

1. Ve a **Server Status**
2. Haz clic en **Reload** en la sección **Configuration**
3. O haz clic en **Clear** en **Resource Cache**

### Acceder a Logs

**About & Status** → **GeoServer Logs**:

- Muestra los últimos eventos del servidor
- Útil para depuración
- Filtra por nivel: INFO, WARN, ERROR

### Logs del contenedor

Con Docker, la forma más directa de ver los logs es desde la terminal:

```bash
docker compose logs -f geoserver
```

El archivo de log también existe dentro del contenedor, en el `data_dir`:

```bash
docker exec -it curso_geoserver cat /opt/geoserver_data/logs/geoserver.log
```

## 4.9 Mejores Prácticas

### Desarrollo

- - Usa `docker compose up -d` para desarrollo
- - Activa mensajes detallados y excepciones
- - Revisa logs regularmente
- - Usa Layer Preview para probar cambios

### Producción

- - Instala como servicio de Windows
- - Cambia credenciales por defecto
- - Desactiva mensajes verbosos
- - Configura Proxy Base URL
- - Implementa control de acceso
- - Habilita HTTPS
- - Configura backup automático del data_dir
- - Monitorea uso de memoria y rendimiento

### Seguridad

- Cambia usuario y contraseña de `admin`
- Crea usuarios con permisos limitados
- Restringe acceso a datos sensibles
- Usa HTTPS en producción
- Mantén GeoServer actualizado

## Resumen

En este capítulo has aprendido:

- Qué es GeoServer y sus capacidades
- Levantar GeoServer con Docker (`docker compose up -d`), sin instalar Java
- Verificar el servicio y acceder a la interfaz de administración
- Dónde viven los datos (volumen `geoserver_data`) y los logs en Docker
- Que el host de PostGIS para el Store es `postgis` (no `localhost`)
- Navegar por la interfaz y la configuración inicial recomendada
- Visualizar capas de demostración
- Monitorear el servidor y revisar logs
- Mejores prácticas de seguridad
- (Opcional) Instalar GeoServer de forma nativa

## Ejercicio Práctico

1. Levanta GeoServer con `docker compose up -d` y verifica con `docker compose ps`
2. Observa el arranque con `docker compose logs -f geoserver`
3. Accede a la interfaz en http://localhost:8080/geoserver
4. Cambia la contraseña del usuario `admin`
5. Explora las capas de demostración en Layer Preview
6. Visualiza la capa `sf:states` en OpenLayers
7. Inspecciona el `data_dir` con `docker exec -it curso_geoserver ls /opt/geoserver_data`
8. Verifica el estado del servidor

## Anexo A — Instalación nativa (opcional)

Solo si **no** puedes usar Docker. Con Docker nada de esto es necesario.

1. **Instalar Java (JDK 17).** Descarga OpenJDK desde [Adoptium](https://adoptium.net/) (Windows x64, versión 17 LTS), instálalo marcando *Add to PATH* y *JAVA_HOME*, y verifica con `java -version`.
2. **Descargar GeoServer.** En [geoserver.org/download](https://geoserver.org/download/), versión *Stable* → *Platform Independent Binary* (`.zip`). Extráelo, por ejemplo, en `C:\Program Files\GeoServer`.
3. **(Opcional) Variables de entorno.** `GEOSERVER_HOME` apuntando a esa carpeta y `GEOSERVER_DATA_DIR` a un directorio de datos aparte (p. ej. `C:\GeoServerData`).
4. **Iniciar en desarrollo.** `cd "C:\Program Files\GeoServer\bin"` y ejecutar `startup.bat`; espera `INFO: Starting ProtocolHandler ["http-bio-8080"]`.
5. **(Opcional) Como servicio de Windows.** Usa [NSSM](https://nssm.cc/download): `nssm install GeoServer` apuntando a `startup.bat`, y `nssm start GeoServer`.
6. **Verificar.** Abre [http://localhost:8080/geoserver](http://localhost:8080/geoserver) (admin/geoserver).

- **Puerto 8080 ocupado:** edita `start.ini` y cambia `jetty.http.port`.
- **"Java not found":** revisa `java -version` y `echo %JAVA_HOME%`, y reinicia la terminal.
- **Logs:** `C:\Program Files\GeoServer\logs\geoserver.log`.

> En la instalación nativa, GeoServer y PostgreSQL corren en el mismo equipo, así que el host del Store de PostGIS en el Capítulo 8 **sí** sería `localhost`.

## Referencias

- GeoServer Documentation. (2024). *GeoServer User Manual*. https://docs.geoserver.org/stable/en/user/
- GeoServer. (2024). *GeoServer Download*. https://geoserver.org/download/
- OSGeo. (2024). *GeoServer Docker image*. https://github.com/geoserver/docker (`docker.osgeo.org/geoserver`)
- Open Geospatial Consortium. (2024). *OGC Standards*. https://www.ogc.org/standards/
- Boundless. (2024). *Introduction to GeoServer*. http://workshops.boundlessgeo.com/geoserver-intro/
- Iacovella, S., & Youngblood, B. (2013). *GeoServer Beginner's Guide*. Packt Publishing.

---

**Capítulo anterior**: [Capítulo 3: Instalación de PostgreSQL y PostGIS](./capitulo-03-postgresql-postgis.md)

**Próximo capítulo**: [Capítulo 5: Servicios Web Geográficos](./capitulo-05-servicios-web-geograficos.md)
