# Ruta C · C3 — Desplegar un mapa en Vercel (1 h)

**Meta:** publicar una página web con Leaflet que consuma un servicio vivo del IDE Boyacá. Es la "victoria temprana": tu propio mapa en internet antes de la primera clase.

---

## 1. La página mínima

Crea una carpeta `mapa-boyaca/` con un solo archivo `index.html`:

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Hospitales de Boyacá</title>
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">
  <style> html, body, #mapa { height: 100%; margin: 0; } </style>
</head>
<body>
  <div id="mapa"></div>
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <script>
    const mapa = L.map("mapa").setView([5.54, -73.36], 8);   // Boyacá
    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "© OpenStreetMap"
    }).addTo(mapa);

    // Servicio vivo: hospitales de Boyacá (IDE Boyacá, FeatureServer)
    const url = "https://services6.arcgis.com/Ex2fmFOuTOHRZtML/ArcGIS/rest/services/"
      + "Hospitales_Boyac%C3%A1/FeatureServer/0/query"
      + "?where=1%3D1&outFields=Nombre,NOM_MPIO&outSR=4326&f=geojson";

    fetch(url)
      .then(r => r.json())
      .then(geo => {
        L.geoJSON(geo, {
          onEachFeature: (f, layer) =>
            layer.bindPopup(`<b>${f.properties.Nombre}</b><br>${f.properties.NOM_MPIO}`)
        }).addTo(mapa);
      });
  </script>
</body>
</html>
```

Ábrelo localmente (doble clic, o Live Server en VS Code) y verás los 464 hospitales con popups.

---

## 2. Publicar en Vercel

**Opción A — Vercel (arrastrar):**
1. Entra a <https://vercel.com> y regístrate (puedes usar tu cuenta de GitHub).
2. *Add New → Project* → importa tu repo, o arrastra la carpeta `mapa-boyaca/`.
3. Vercel detecta un sitio estático y te da una URL pública `https://...vercel.app`.

**Opción B — GitHub Pages:**
1. Sube `index.html` a un repo.
2. *Settings → Pages → Deploy from branch → main / root*.
3. En un minuto tienes la URL `https://<usuario>.github.io/<repo>/`.

---

## Ejercicio C3

1. Publica tu mapa (Vercel o Pages) y comparte la URL.
2. Cambia la capa consumida: en vez de hospitales, muestra las **veredas** (`Veredas_Boyaca_2024`, geometría de polígonos) con un estilo distinto.

**Reto opcional:** levanta `pygeoapi` (del Taller 3 / Servicios_SIG_con_Python) publicando el mismo GeoPackage y consume `…/collections/{capa}/items` desde la página. Compara la respuesta OGC API con la del FeatureServer de Esri.

**Entregable:** la URL pública de tu mapa funcionando.
