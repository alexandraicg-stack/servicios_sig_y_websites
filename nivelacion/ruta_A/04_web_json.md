# Ruta A · A4 — Web mínimo: HTTP, JSON y HTML (2 h)

**Meta:** entender qué pasa cuando pides datos por la red, para que los servicios WMS/WFS/OGC API y las APIs REST tengan sentido.

---

## 1. Qué ocurre al escribir una URL

```
Escribes una URL → DNS traduce el nombre a una IP → se abre una conexión TCP
→ sobre HTTPS (cifrada) el navegador envía una PETICIÓN (request)
→ el servidor devuelve una RESPUESTA (response): un código + unos datos
```

- **Métodos:** `GET` (pedir datos, lo más común), `POST` (enviar datos).
- **Códigos de estado:**
  - `200` OK · `301/302` redirección · `400` petición mal formada
  - `401/403` sin permiso · `404` no existe · `500` error del servidor
- **Content-Type:** dice qué formato trae la respuesta (`application/json`, `image/png`…).

---

## 2. JSON

JSON es la forma estándar de intercambiar datos estructurados:

```json
{
  "type": "Feature",
  "properties": { "Nombre": "Hospital San Rafael", "NOM_MPIO": "Tunja" },
  "geometry": { "type": "Point", "coordinates": [-73.36, 5.54] }
}
```

- **Objeto:** entre llaves `{ }`, pares `clave: valor`.
- **Arreglo:** entre corchetes `[ ]`, lista ordenada.
- **Anidamiento:** un valor puede ser otro objeto o arreglo (como `geometry`).

Un **GeoJSON** es solo un JSON con una estructura acordada: un `FeatureCollection` con una lista de `features`, cada uno con `properties` y `geometry`.

---

## 3. HTML y CSS mínimos

Una página web es texto con etiquetas. Lo mínimo para un mapa:

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>Mi primer mapa</title>
  <style> #mapa { height: 90vh; } </style>
</head>
<body>
  <h1>Hospitales de Boyacá</h1>
  <div id="mapa"></div>   <!-- aquí irá el mapa en la Ruta C -->
</body>
</html>
```

---

## Ejercicio A4 — Inspeccionar una petición real

Vas a mirar, con las herramientas del navegador, cómo un servicio devuelve GeoJSON.

1. Abre esta URL en el navegador (devuelve hospitales de Boyacá en GeoJSON):
   ```
   https://services6.arcgis.com/Ex2fmFOuTOHRZtML/ArcGIS/rest/services/Hospitales_Boyac%C3%A1/FeatureServer/0/query?where=1%3D1&outFields=Nombre,NOM_MPIO&outSR=4326&f=geojson&resultRecordCount=5
   ```
2. Abre **DevTools** (`F12`) → pestaña **Network** → recarga (`F5`).
3. Haz clic en la petición `query?...` y revisa:
   - el **Status** (`200`),
   - el **Response** (el GeoJSON): identifica `type`, `features`, `properties`, `geometry`.
4. Cambia `resultRecordCount=5` por `=10` y observa que llegan más features.

**Entregable:** captura de DevTools → Network mostrando la petición `query` con Status 200 y el panel Response con el GeoJSON.
