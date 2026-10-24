# Ruta A · A1 — Sistema, archivos y terminal (2 h)

**Meta:** moverte por tu computador desde la terminal sin usar el explorador, para que Git, Python y Docker dejen de parecer magia.

> **Tres interfaces de comandos.** En **Windows** tienes **CMD** (`cmd.exe`) y **PowerShell** (la recomendada, viene instalada); en **macOS/Linux** —o con **Git Bash** / **WSL** en Windows— usas una terminal **Unix** con `bash`. Abajo verás cada comando en las tres, y al final del capítulo hay una chuleta de equivalencias.

---

## 1. Dónde estoy y qué hay aquí

| Acción | Unix (bash / Git Bash / mac / Linux) | PowerShell | CMD (Windows) |
|---|---|---|---|
| Ver carpeta actual | `pwd` | `pwd` | `cd` (o `echo %cd%`) |
| Listar archivos | `ls` / `ls -la` | `ls` / `Get-ChildItem` | `dir` |
| Entrar a una carpeta | `cd datos` | `cd datos` | `cd datos` |
| Subir un nivel | `cd ..` | `cd ..` | `cd ..` |
| Ir a tu carpeta personal | `cd ~` | `cd ~` | `cd %USERPROFILE%` |

**Rutas absolutas vs. relativas:** una ruta absoluta empieza desde la raíz (`/home/ana/curso` o `C:\Users\ana\curso`); una relativa parte de donde estás (`datos/municipios.geojson`). El 90 % de los errores "no such file" son rutas relativas mal entendidas: siempre revisa con `pwd` dónde estás parado.

---

## 2. Crear, copiar, mover, borrar

| Acción | Unix | PowerShell | CMD (Windows) |
|---|---|---|---|
| Crear carpeta | `mkdir datos` | `mkdir datos` | `mkdir datos` |
| Crear archivo vacío | `touch nota.txt` | `New-Item nota.txt` | `type nul > nota.txt` |
| Copiar | `cp a.txt b.txt` | `Copy-Item a.txt b.txt` | `copy a.txt b.txt` |
| Mover / renombrar | `mv a.txt datos/` | `Move-Item a.txt datos/` | `move a.txt datos\` |
| Borrar archivo | `rm a.txt` | `Remove-Item a.txt` | `del a.txt` |
| Borrar carpeta | `rm -r datos/` | `Remove-Item -Recurse datos/` | `rmdir /s datos` |

> `rm` **no tiene papelera**: lo que borras no se recupera. Si existe el comando `trash`, prefiérelo. En general, piensa dos veces antes de un `rm -r`.

---

## 3. Permisos y `sudo` — solo Unix/Linux y macOS

> **No aplica en Windows.** CMD y PowerShell no usan `sudo`: cuando un programa necesita privilegios, se abre la terminal con *Ejecutar como administrador* (control de cuentas de usuario, UAC). Esta sección sí aplica si trabajas en **WSL** o en una terminal Unix.

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
- Ver el PATH: `echo $PATH` (Unix) · `$env:PATH` (PowerShell) · `echo %PATH%` (CMD).

---

## 6. Referencia rápida — CMD, PowerShell y Unix

Las tres interfaces de comandos del curso y cómo abrirlas:

| Interfaz | Dónde se usa | Cómo abrirla |
|---|---|---|
| **CMD** (`cmd.exe`) | Windows; scripts `.bat` | Inicio → escribe `cmd` |
| **PowerShell** | Windows (recomendada) | Inicio → `PowerShell` (o Terminal de Windows) |
| **Unix / bash** | macOS, Linux; o **Git Bash** / **WSL** en Windows | Terminal (o Git Bash) |

Chuleta de equivalencias:

| Tarea | Unix | PowerShell | CMD |
|---|---|---|---|
| Carpeta actual | `pwd` | `pwd` | `cd` |
| Listar | `ls -la` | `Get-ChildItem` | `dir` |
| Cambiar de carpeta | `cd ruta` | `cd ruta` | `cd ruta` |
| Carpeta personal | `cd ~` | `cd ~` | `cd %USERPROFILE%` |
| Crear carpeta | `mkdir d` | `mkdir d` | `mkdir d` |
| Copiar | `cp a b` | `Copy-Item a b` | `copy a b` |
| Mover / renombrar | `mv a b` | `Move-Item a b` | `move a b` |
| Borrar archivo | `rm a` | `Remove-Item a` | `del a` |
| Limpiar pantalla | `clear` | `clear` / `cls` | `cls` |
| Ver variable PATH | `echo $PATH` | `$env:PATH` | `echo %PATH%` |

> **En Windows**, usa **PowerShell** para todo el curso y deja **CMD** solo para los scripts `.bat` (p. ej. `scripts/verificar_fuentes.bat`). En **macOS/Linux** la terminal por defecto ya es Unix.

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
