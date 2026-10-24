# Capítulo 1: Introducción a Git

## Objetivos del Capítulo

- Comprender qué es Git y por qué es importante
- Instalar Git en Windows
- Aprender comandos básicos de Git
- Clonar el repositorio del curso

## 1.1 ¿Qué es Git?

Git es un sistema de control de versiones distribuido que permite:

- **Rastrear cambios** en archivos a lo largo del tiempo
- **Colaborar** con otros desarrolladores
- **Revertir** a versiones anteriores del código
- **Trabajar en ramas** de desarrollo paralelas
- **Mantener un historial** completo del proyecto

### ¿Por qué usar Git?

- **Seguridad**: Nunca pierdes código, todo está versionado
- **Colaboración**: Múltiples personas pueden trabajar simultáneamente
- **Trazabilidad**: Sabes quién hizo qué cambio y cuándo
- **Flexibilidad**: Experimentar sin afectar el código principal

## 1.2 Instalación de Git en Windows

### Paso 1: Descargar Git

1. Ve a la página oficial: [https://git-scm.com/download/win](https://git-scm.com/download/win)
2. La descarga debería comenzar automáticamente
3. Si no, selecciona la versión apropiada (32 o 64 bits)

### Paso 2: Ejecutar el Instalador

1. Ejecuta el archivo descargado (`Git-2.x.x-64-bit.exe`)
2. Acepta la licencia GPL

### Paso 3: Configuración de la Instalación

Durante la instalación, se presentarán varias opciones:

#### Selección de componentes
- - **Windows Explorer integration** (recomendado)
- - **Git Bash Here**
- - **Git GUI Here**
- - **Associate .git configuration files**
- - **Associate .sh files to be run with Bash**

#### Editor por defecto
- Selecciona tu editor preferido (Vim, Nano, Notepad++, VS Code, etc.)
- Recomendado para principiantes: **Nano** o **Visual Studio Code**

#### Nombre de la rama inicial
- Selecciona "Override the default branch name for new repositories"
- Usa `main` como nombre (es el estándar actual)

#### Ajuste de PATH
- Selecciona: **Git from the command line and also from 3rd-party software** (recomendado)

#### Cliente SSH
- Usa: **Use bundled OpenSSH**

#### Librería SSL/TLS
- Usa: **Use the OpenSSL library**

#### Conversión de fin de línea
- Para Windows: **Checkout Windows-style, commit Unix-style line endings**

#### Emulador de terminal
- Selecciona: **Use MinTTY** (terminal más funcional)

#### Comportamiento de git pull
- Selecciona: **Default (fast-forward or merge)**

#### Credential helper
- Selecciona: **Git Credential Manager**

#### Opciones extras
- - Enable file system caching
- - Enable symbolic links

4. Haz clic en **Install**

### Paso 4: Verificar la Instalación

1. Abre **Git Bash** (busca en el menú de inicio)
2. Ejecuta el siguiente comando:

```bash
git --version
```

Deberías ver algo como:
```
git version 2.43.0
```

## 1.3 Configuración Inicial de Git

### Configurar tu Identidad

Antes de usar Git, debes configurar tu nombre y correo electrónico:

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu.email@ejemplo.com"
```

### Configurar el Editor

```bash
git config --global core.editor "nano"
```

O si prefieres VS Code:
```bash
git config --global core.editor "code --wait"
```

### Verificar Configuración

```bash
git config --list
```

## 1.4 Comandos Básicos de Git

### Inicializar un Repositorio

Para crear un nuevo repositorio Git en un directorio:

```bash
git init
```

### Clonar un Repositorio

Para descargar una copia de un repositorio existente:

```bash
git clone <url-del-repositorio>
```

### Ver el Estado del Repositorio

```bash
git status
```

Este comando muestra:
- Archivos modificados
- Archivos en staging (preparados para commit)
- Archivos no rastreados

### Agregar Archivos al Staging

Para agregar un archivo específico:
```bash
git add nombre-archivo.txt
```

Para agregar todos los archivos modificados:
```bash
git add .
```

### Confirmar Cambios (Commit)

```bash
git commit -m "Descripción clara de los cambios"
```

### Ver el Historial

```bash
git log
```

Para un historial más compacto:
```bash
git log --oneline
```

### Ver Diferencias

Ver cambios no confirmados:
```bash
git diff
```

Ver cambios en staging:
```bash
git diff --staged
```

### Descargar Cambios del Repositorio Remoto

```bash
git pull
```

### Enviar Cambios al Repositorio Remoto

```bash
git push
```

## 1.5 Clonación de Este Repositorio

### Obtener la URL del Repositorio

Para este curso, necesitas clonar el repositorio que contiene los datos y ejercicios.

1. Abre **Git Bash**
2. Navega al directorio donde quieres descargar el proyecto:

```bash
cd C:/Users/TuUsuario/Documents
```

3. Clona el repositorio:

```bash
git clone https://github.com/usuario/servicios_sig_y_websites.git
```

4. Ingresa al directorio del proyecto:

```bash
cd servicios_sig_y_websites
```

5. Verifica el contenido:

```bash
ls -la
```

Deberías ver:
```
drwxr-xr-x  data/
drwxr-xr-x  curso/
-rw-r--r--  README.md
```

### Explorar el Repositorio

Verifica las ramas disponibles:
```bash
git branch -a
```

Ver el historial:
```bash
git log --oneline --graph
```

Ver los archivos en el directorio `data`:
```bash
ls data/
```

## 1.6 Flujo de Trabajo Básico

Un flujo típico al trabajar con Git:

```bash
# 1. Ver el estado actual
git status

# 2. Hacer cambios en archivos (editar, crear, eliminar)

# 3. Ver qué cambió
git diff

# 4. Agregar cambios al staging
git add archivo-modificado.txt

# 5. Confirmar los cambios
git commit -m "Descripción del cambio"

# 6. Enviar al repositorio remoto (si aplica)
git push
```

## 1.7 Comandos Útiles Adicionales

### Deshacer Cambios

Descartar cambios en un archivo (antes de commit):
```bash
git checkout -- nombre-archivo.txt
```

Deshacer el último commit (mantener cambios):
```bash
git reset --soft HEAD~1
```

### Crear y Cambiar de Rama

Crear una nueva rama:
```bash
git branch nombre-rama
```

Cambiar a una rama:
```bash
git checkout nombre-rama
```

Crear y cambiar en un solo comando:
```bash
git checkout -b nombre-rama
```

### Fusionar Ramas

Desde la rama de destino:
```bash
git merge rama-origen
```

## 1.8 Recursos y Ayuda

### Ayuda de Git

Para obtener ayuda sobre cualquier comando:
```bash
git help <comando>
```

Por ejemplo:
```bash
git help commit
```

### Recursos en Línea

- **Documentación oficial**: [https://git-scm.com/doc](https://git-scm.com/doc)
- **Pro Git Book** (gratuito): [https://git-scm.com/book/es/v2](https://git-scm.com/book/es/v2)
- **GitHub Git Cheat Sheet**: [https://education.github.com/git-cheat-sheet-education.pdf](https://education.github.com/git-cheat-sheet-education.pdf)
- **Tutorial interactivo**: [https://learngitbranching.js.org/?locale=es_ES](https://learngitbranching.js.org/?locale=es_ES)
- **Visualizing Git**: [http://git-school.github.io/visualizing-git/](http://git-school.github.io/visualizing-git/)

## Resumen

En este capítulo has aprendido:

- Qué es Git y su importancia en el desarrollo de software
- Cómo instalar Git en Windows paso a paso
- Comandos básicos para trabajar con repositorios
- Cómo clonar el repositorio del curso
- El flujo de trabajo básico con Git

## Ejercicio Práctico

1. Clona este repositorio en tu máquina local
2. Explora el directorio `data/` y familiarízate con los archivos
3. Crea un archivo de texto llamado `notas.txt` con tus observaciones
4. Agrega el archivo al staging con `git add notas.txt`
5. Haz un commit con el mensaje "Agregar mis notas del curso"
6. Verifica el historial con `git log`

## Referencias

- Chacon, S., & Straub, B. (2014). *Pro Git* (2nd ed.). Apress. https://git-scm.com/book/es/v2
- Git Documentation. (2024). *Git Reference Manual*. https://git-scm.com/docs
- Atlassian. (2024). *Git Tutorials*. https://www.atlassian.com/git/tutorials
- GitHub. (2024). *GitHub Git Guides*. https://github.com/git-guides

---

**Próximo capítulo**: [Capítulo 2: Explorar y consumir servicios OGC existentes](./capitulo-02-consumir-servicios-ogc.md)
