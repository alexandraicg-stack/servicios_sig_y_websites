# Ruta A · A2 — Git y GitHub (2 h)

**Meta:** versionar tu trabajo y publicarlo en GitHub. En el curso **toda entrega vive en un repositorio**.

---

## 1. Conceptos mínimos

- **Repositorio:** una carpeta cuyo historial de cambios Git vigila.
- **Commit:** una foto del estado del proyecto en un momento, con un mensaje que explica qué cambió.
- **Rama (branch):** una línea de trabajo paralela. `main` es la principal.
- **Remoto (remote):** una copia en la nube (GitHub). `origin` es el nombre por defecto.

---

## 2. Configuración por única vez

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tucorreo@ejemplo.com"
git config --global init.defaultBranch main
```

Verifica: `git config --list`.

---

## 3. El ciclo diario

```bash
git init                 # inicia el repo (una sola vez por proyecto)
git status               # ¿qué cambió?
git add archivo.md       # marca lo que entra al próximo commit (git add . para todo)
git commit -m "Agrega ficha de datos de Boyacá"
git log --oneline        # historial
```

Para trabajar con GitHub:

```bash
git remote add origin https://github.com/<usuario>/curso-sig-<nombre>.git
git push -u origin main  # sube; la primera vez con -u
git pull                 # baja cambios del remoto
git clone <url>          # copia un repo existente a tu máquina
```

---

## 3b. Ramas — trabajar sin romper `main`

Una rama te deja probar cambios en paralelo sin tocar la línea principal. Es una de las actividades básicas exigidas en la nivelación.

```bash
git branch                 # lista las ramas
git checkout -b prueba     # crea y cambia a la rama "prueba"
# ...editas y haces commits en la rama...
git push -u origin prueba  # sube la rama a GitHub
git checkout main          # vuelves a la principal
git merge prueba           # integras los cambios de "prueba" en main
```

## 4. `.gitignore` — qué NO versionar

Crea un archivo `.gitignore` en la raíz con lo que no debe subir:

```gitignore
# datos pesados (los regeneramos con el script)
*.gpkg
datos/*.geojson

# credenciales y entornos
.env
venv/
__pycache__/
node_modules/
```

> **Regla de oro:** nunca subas contraseñas, tokens, ni archivos de datos de cientos de MB. El repo es para **código y documentación**, no para datos crudos.

---

## 5. README mínimo

Todo repo del curso debe tener un `README.md` que responda tres cosas:

```markdown
# curso-sig-ana

Trabajos del curso Servicios SIG y Sitios Web (Maestría SIG, UJdeC).

## Cómo se ejecuta
(instrucciones)

## De dónde salen los datos
Paquete de Boyacá descargado con `scripts/descargar_boyaca.py` (IDE Boyacá y DANE).
```

---

## Ejercicio A2

1. Crea una cuenta en <https://github.com> si no la tienes.
2. Crea un repositorio nuevo llamado `curso-sig-<tu-nombre>` (público, con README).
3. Clónalo a tu máquina:
   ```bash
   git clone https://github.com/<usuario>/curso-sig-<nombre>.git
   cd curso-sig-<nombre>
   ```
4. Agrega un `.gitignore` (como el de arriba) y copia **un** GeoJSON pequeño (`hospitales_boyaca.geojson`, 120 KB).
5. Haz commit y push:
   ```bash
   git add .
   git commit -m "Primer commit: README, gitignore y datos de hospitales"
   git push
   ```

6. Practica una rama: crea `ajuste-readme`, cambia algo y súbela:
   ```bash
   git checkout -b ajuste-readme
   # edita el README
   git commit -am "Mejora el README"
   git push -u origin ajuste-readme
   git checkout main
   git merge ajuste-readme
   git push
   ```

**Entregable:** la URL de tu repositorio mostrando el README, el commit en `main` y la rama `ajuste-readme` en GitHub.
