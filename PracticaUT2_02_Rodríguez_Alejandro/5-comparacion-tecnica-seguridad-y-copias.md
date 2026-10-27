## Actividad 5: Comparación técnica, seguridad y copias

### 1. Comparativa técnica: Neo4j frente a SQL tradicional

Tomemos como ejemplo la **Consulta 3 de la Actividad 4: Recomendación social** (buscar libros que han leído mis amigos con buena nota, y que yo no haya leído).

*   **En Neo4j (Grafos):**
    ```cypher
    MATCH (yo:Usuario {id: 'U1'})-[:AMIGO_DE]-(amigo)-[r:LEYÓ]->(l:Libro)
    ```
    *Explicación:* Neo4j solo necesita localizar a 'U1' en el índice y luego, literalmente, saltar por los punteros en la memoria. Atraviesa 2 flechas. Complejidad y coste de rendimiento mínimos (milisegundos).

*   **En SQL (Relacional):**
    Para hacer esto mismo en bases de datos como MySQL o PostgreSQL, necesitarías encadenar al menos 4 tablas usando claves foráneas:
    ```sql
    SELECT Libros.titulo 
    FROM Usuarios yo
    JOIN Amistades a ON yo.id = a.usuario1_id
    JOIN Usuarios amigo ON a.usuario2_id = amigo.id
    JOIN Lecturas r ON amigo.id = r.usuario_id
    JOIN Libros ON r.libro_id = Libros.id
    WHERE yo.id = 'U1' AND r.valoracion > 3 
      AND Libros.id NOT IN (SELECT libro_id FROM Lecturas WHERE usuario_id = 'U1');
    ```
    *Explicación:* El motor SQL tiene que hacer "producto cartesiano" (multiplicar y cruzar datos) de 4 tablas inmensas buscando coincidencias. Estos múltiples `JOIN` consumen muchísima CPU y memoria. Si en lugar de amigos directos, fueran "amigos de amigos", el coste se multiplicaría exponencialmente y la consulta podría tardar minutos en resolverse.

### 2. Copias de seguridad y restauración

La forma de hacer los backups varía si estás en un entorno local o en la nube:

*   **Neo4j Desktop / Contenedor Local:**
    Se utiliza la herramienta de comandos `neo4j-admin`. 
    1.  **Backup (Volcado):** Primero debes apagar la base de datos para asegurar la consistencia.
        `neo4j-admin database dump neo4j --to-path=/ruta/a/mi_carpeta_backups`
    2.  **Restauración:** Con la base de datos apagada, cargas el archivo `.dump`.
        `neo4j-admin database load neo4j --from-path=/ruta/a/mi_carpeta_backups/neo4j.dump`

*   **Neo4j Aura (Nube gratuita):**
    Es mucho más visual. Aura realiza "Snapshots" (instantáneas) automáticas.
    1.  **Backup:** Entras en la consola de Aura, vas a la pestaña "Snapshots" de tu instancia y haces clic en **Export**. Esto descargará el archivo `.dump` a tu ordenador.
    2.  **Restauración:** En la misma pestaña, puedes darle al botón **Restore** de una instantánea automática previa, o subir tu archivo `.dump` para sobreescribir la base de datos actual.

### 3. Seguridad y permisos (Roles)

Para que el sistema sea seguro, no se debe conectar la aplicación móvil a la base de datos usando el usuario principal (`neo4j`). Se debe implementar el Control de Acceso Basado en Roles (RBAC):

*   **Rol de Administrador (`admin`):** Tiene control total. Puede hacer CRUD (Crear, Leer, Actualizar, Borrar) de nodos, relaciones, índices y gestionar usuarios. Solo lo usan los ingenieros de datos o el backend para tareas de mantenimiento.
*   **Rol de Aplicación Móvil (`reader` / `app_user`):** Es un usuario con permisos restringidos. 
    *   Tiene permiso de lectura global (`GRANT MATCH ON GRAPH neo4j TO app_user`).
    *   Solo se le da permiso de escritura en propiedades específicas de las relaciones que le corresponden (como crear un `:LEYÓ` o actualizar su perfil). Si un usuario malintencionado intercepta la conexión de la app, no podrá ejecutar comandos destructivos como `MATCH (n) DETACH DELETE n` porque su rol se lo denegará automáticamente.

### 4. Cuándo NO usar Neo4j (Casos desfavorables)

Las bases de datos de grafos son increíbles para conexiones, pero son una mala elección en estos dos escenarios:

1.  **Sistemas Transaccionales Financieros y Contabilidad (Libro Mayor):**
    Si necesitas registrar pagos, sumar grandes volúmenes de saldos, generar facturas o almacenar un histórico puro de transacciones bancarias, el modelo relacional (SQL) con su fuerte cumplimiento ACID y su matemática de tablas es muy superior y eficiente. Un grafo aquí añade complejidad sin aportar beneficios.
2.  **Registro de Logs (Telemetría) o Series Temporales:**
    Si estás guardando registros de temperatura de miles de sensores IoT cada segundo, o guardando logs de errores de un servidor, estos datos son independientes (no se conectan entre sí, solo importa el valor y la hora). Para esto, se debe usar una base de datos de series temporales (como InfluxDB) o columnar/documental (Cassandra o MongoDB), que están diseñadas para escribir millones de datos planos por segundo a alta velocidad.