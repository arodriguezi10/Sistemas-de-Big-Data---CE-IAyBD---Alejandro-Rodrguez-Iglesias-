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