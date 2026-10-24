# Ruta A · A1 — Sistema, archivos y terminal (2 h)

**Meta:** moverte por tu computador desde la terminal sin usar el explorador, para que Git, Python y Docker dejen de parecer magia.

> En Windows usa **PowerShell** (viene instalado) o la terminal de **Git Bash**. En macOS/Linux usa la **Terminal**. Abajo verás el comando Unix y, cuando cambia, su equivalente en PowerShell.

---

## 1. Dónde estoy y qué hay aquí

| Acción | Unix (Git Bash / mac / Linux) | PowerShell |
|---|---|---|
| Ver carpeta actual | `pwd` | `pwd` |
| Listar archivos | `ls` / `ls -la` | `ls` / `Get-ChildItem` |
| Entrar a una carpeta | `cd datos` | `cd datos` |
| Subir un nivel | `cd ..` | `cd ..` |
| Ir a tu carpeta personal | `cd ~` | `cd ~` |

**Rutas absolutas vs. relativas:** una ruta absoluta empieza desde la raíz (`/home/ana/curso` o `C:\Users\ana\curso`); una relativa parte de donde estás (`datos/municipios.geojson`). El 90 % de los errores "no such file" son rutas relativas mal entendidas: siempre revisa con `pwd` dónde estás parado.

---

## 2. Crear, copiar, mover, borrar

| Acción | Unix | PowerShell |
|---|---|---|
| Crear carpeta | `mkdir datos` | `mkdir datos` |
| Crear archivo vacío | `touch nota.txt` | `New-Item nota.txt` |
| Copiar | `cp a.txt b.txt` | `Copy-Item a.txt b.txt` |
| Mover / renombrar | `mv a.txt datos/` | `Move-Item a.txt datos/` |
| Borrar archivo | `rm a.txt` | `Remove-Item a.txt` |
| Borrar carpeta | `rm -r datos/` | `Remove-Item -Recurse datos/` |

> `rm` **no tiene papelera**: lo que borras no se recupera. Si existe el comando `trash`, prefiérelo. En general, piensa dos veces antes de un `rm -r`.

---

## 3. Permisos y `sudo`

- En Unix, cada archivo tiene dueño y permisos (lectura/escritura/ejecución). `ls -l` te los muestra.
- `sudo` ejecuta como administrador. **No es la solución a todo**: si algo "solo funciona con sudo", casi siempre es un permiso mal puesto o estás instalando en el lugar equivocado. Instalar paquetes de Python con `sudo pip` es un error clásico que rompe el sistema; para eso usas un entorno virtual (guía A3).

---

## 4. Editar en la terminal y por qué no abrir CSV en Excel

- `nano archivo.txt` abre un editor sencillo (`Ctrl+O` guarda, `Ctrl+X` sale).
- **Nunca edites un CSV geográfico en Excel sin cuidado**: Excel cambia comas por puntos, convierte códigos como `15001` en números perdiendo ceros a la izquierda, y rompe el encoding de tildes. Los códigos de municipio (`mpio_ccdgo`) son **texto**, no números.

---

## 5. Variables de entorno y `PATH`

- Una variable de entorno guarda un valor que los programas leen (ej. `PATH` lista las carpetas donde el sistema busca comandos).
- Si `python` "no se reconoce como comando", es que su carpeta no está en el `PATH`.
- Ver el PATH: `echo $PATH` (Unix) · `$env:PATH` (PowerShell).

---

## Ejercicio A1

1. Crea la estructura de trabajo del curso:
   ```bash
   cd ~
   mkdir -p curso-sig/datos curso-sig/scripts curso-sig/salidas
   ```
2. Copia los cinco GeoJSON de Boyacá a `curso-sig/datos/` **desde la terminal** (no con el explorador).
3. Renombra `municipios_boyaca.geojson` a `municipios.geojson` con `mv`.
4. Desde `curso-sig/`, lista el contenido con `ls -la` y toma la captura.

**Entregable:** captura de `ls -la` mostrando las tres carpetas y los archivos movidos.
