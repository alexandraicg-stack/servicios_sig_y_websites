# Ruta B · B4 — VS Code y Node (1 h)

**Meta:** tener un editor productivo y poder ejecutar las apps web del curso, como la `webapp` de este repositorio (Leaflet).

---

## 1. VS Code

Instala **Visual Studio Code** (<https://code.visualstudio.com>) y estas extensiones:

| Extensión | Para qué |
|---|---|
| **Python** (Microsoft) | ejecutar y depurar Python, elegir el intérprete del `venv` |
| **Docker** | ver contenedores, imágenes y logs desde el editor |
| **GitLens** | historial y autoría línea por línea |
| **Live Server** | servir una página estática con recarga automática |
| **Prettier** | formatear HTML/CSS/JS automáticamente |

Atajos útiles: terminal integrada con `` Ctrl+Ñ `` (o `Ctrl+` `` ` ``), paleta de comandos con `Ctrl+Shift+P`, abrir carpeta con `Ctrl+K Ctrl+O`.

> Para que VS Code use tu entorno virtual: `Ctrl+Shift+P` → *Python: Select Interpreter* → elige el de `venv`.

---

## 2. Node.js y npm

Muchas apps web se sirven con Node. Instala **Node.js 20 LTS** (<https://nodejs.org>); con él puedes servir incluso un sitio estático con `npx serve`, sin necesidad de `package.json`.

```bash
node --version      # v20.x
npm --version

# en un proyecto con package.json:
npm install         # instala dependencias en node_modules/
npm run dev         # arranca el servidor de desarrollo (según "scripts" del package.json)
```

- `package.json` declara las dependencias y los comandos (`scripts`).
- `node_modules/` **no se versiona** (va en `.gitignore`); se reconstruye con `npm install`.

---

## Ejercicio B4 — Ejecutar la webapp del repositorio

1. En VS Code abre la carpeta del repositorio (`Ctrl+K Ctrl+O`) y ubica `webapp/` (una app con Leaflet que consume WMS/WFS).
2. Sírvela de una de estas dos formas:
   - **Con Node:** en la terminal integrada, `npx serve webapp` (no necesita `package.json`; `npx` descarga `serve` al vuelo).
   - **Con la extensión Live Server:** clic derecho en `webapp/index.html` → *Open with Live Server*.
3. Abre la URL que aparezca (p. ej. <http://localhost:3000> con `serve`, o <http://localhost:5500> con Live Server).
4. Abre `webapp/js/app.js` en VS Code y haz un cambio pequeño y visible (por ejemplo, el centro o el zoom inicial del mapa, o un texto). Guarda y recarga para ver el cambio (con Live Server la recarga es automática).

> No necesitas GeoServer para este ejercicio: el mapa base (OpenStreetMap) carga igual; las capas WMS/WFS se publican más adelante en el curso.

**Entregable:** captura del mapa corriendo en el navegador **después** de tu modificación.
