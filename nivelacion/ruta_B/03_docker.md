# Ruta B · B3 — Docker (2 h)

**Meta:** levantar servicios (PostGIS, GeoServer) en contenedores sin instalarlos a mano. Es la infraestructura de los Módulos 2 en adelante.

> Instala **Docker Desktop** (<https://docker.com>). En Windows requiere WSL2 o Hyper-V; si tu equipo no lo permite, avísale al docente: hay una variante en la nube del curso.

---

## 1. Los cuatro conceptos

| Concepto | Qué es | Analogía |
|---|---|---|
| **Imagen** | Plantilla inmutable (SO + software) | La receta |
| **Contenedor** | Una imagen en ejecución | El plato servido |
| **Volumen** | Almacenamiento persistente | La despensa que sobrevive aunque botes el plato |
| **Red** | Canal entre contenedores | Los contenedores se llaman por su **nombre**, no por `localhost` |

---

## 2. Comandos del día a día

```bash
docker run hello-world            # prueba de humo
docker ps                         # contenedores corriendo (ps -a incluye detenidos)
docker logs <nombre>              # ver qué dice un contenedor
docker exec -it <nombre> bash     # entrar a una terminal dentro del contenedor
docker compose up -d              # levantar un stack definido en docker-compose.yml
docker compose down               # bajarlo
```

---

## 3. docker compose — PostGIS

Crea `docker-compose.yml`:

```yaml
services:
  postgis:
    image: postgis/postgis:16-3.4
    environment:
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: geodatos
    ports:
      - "5432:5432"            # host:contenedor
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

```bash
docker compose up -d
docker compose ps
```

---

## 4. Los dos errores clásicos

- **"No se ve mi archivo dentro del contenedor":** no montaste el volumen, o lo montaste en otra ruta. El archivo del host solo existe dentro si lo mapeas con `volumes:`.
- **"No conecta a la base":** desde **otro contenedor** usas el nombre del servicio (`postgis`), no `localhost`. Desde tu **máquina** (QGIS) usas `localhost:5432`.

---

## Ejercicio B3

1. Levanta PostGIS con el `docker-compose.yml` de arriba.
2. Verifica que está sano:
   ```bash
   docker compose ps
   docker exec -it <nombre_postgis> psql -U postgres -d geodatos -c "SELECT postgis_version();"
   ```
3. Conéctalo desde **QGIS**: *Capa → Administrador de fuentes → PostgreSQL*, host `localhost`, puerto `5432`, base `geodatos`, usuario/clave `postgres`.
4. (Opcional) Carga `municipios_boyaca.geojson` a PostGIS arrastrándolo en QGIS sobre la conexión.

**Entregable:** captura de `docker compose ps` + captura de la conexión activa en QGIS.
