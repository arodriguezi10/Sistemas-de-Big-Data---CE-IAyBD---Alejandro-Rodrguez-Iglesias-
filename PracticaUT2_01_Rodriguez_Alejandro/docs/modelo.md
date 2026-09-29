# Plataforma Multimedia: películas, series, episodios, géneros, usuarios y valoraciones. Resuelve filtros, recomendaciones y paginación.

## Actividad 1: Definir el problema y los accesos

1. Escenarios y usuarios

    **Escenario:** una plataforma multimedia: películas, series, episodios, géneros y valoraciones. Resuelve filtros, recomendaciones y paginación. La arquitectura requiere alta concurrencia de lectura para el catálogo y alta capacidad de escritura para el seguimiento de progreso y telemetría.

    **Usuarios del sistema:**
    *   **Clientes:** Consumen contenido, buscan por filtros, continúan reproducciones a medias y generan valoraciones.
    *   **Administradores (Staff):** Gestionan el catálogo (CRUD de películas, series, episodios) y analizan métricas de consumo.
    *   **Motor de Recomendación (Proceso batch/streaming):** Consume de forma intensiva el historial y las valoraciones para recalcular perfiles de afinidad.

2. Preguntas de negocio:

La base de datos debe estar optimizada para responder eficientemente a estas seis consultas clave:

- ¿Películas o series mejor valoradas dentro de un género específico en el último año?
- ¿Qué lista de contenidos tiene un usuario concreto a medias ("Seguir viendo")?
- ¿Cuál es el listado detallado de episodios de una temporada de una serie, en el orden correcto de emisión?
- ¿Cuáles son los títulos más populares (con más visualizaciones/valoraciones altas) en la plataforma durante los últimos 7 días (Trending)?
- ¿Qué recomendaciones tiene un usuario específico basándonos en los géneros de los contenidos que ha valorado con más de 4 estrellas?
- ¿Cuáles son todas las valoraciones y reseñas que ha recibido una película específica, ordenadas de las más recientes a las más antiguas?

3. Accesos Frecuentes (Patrones de Lectura/Escritura)

En sistemas VOD, la proporción de lectura vs escritura suele ser de 10:1 o superior, excepto en la telemetría.

**Datos de mayor lectura (Read-Heavy):**
*   El catálogo principal (feed de inicio, listas de géneros).
*   Los metadatos de un contenido específico (sinopsis, reparto, URL del póster).
*   Listado de episodios de una serie.

**Datos de mayor escritura (Write-Heavy):**
*   **Progreso de visualización (Heartbeats):** La posición actual del reproductor (marca de tiempo en segundos) se actualiza de forma constante mientras el usuario ve el contenido.
*   **Historial de visualización y métricas:** Registro de qué usuario vio qué contenido y cuándo.
*   Nuevas valoraciones/reseñas.

4. Relación de Consultas y Operaciones NoSQL

*Nota: Se asume desnormalización donde es necesario para evitar operaciones de cruce de tablas (como `$lookup`) costosas.*

| Pregunta de Negocio | Colecciones Implicadas | Filtros (Where / `$match`) | Ordenación (`$sort`) | Paginación (`$limit` / `$skip`) |
| :--- | :--- | :--- | :--- | :--- |
| **1. Top por género** | `contents` | `type: "movie"`, `genres: "Sci-Fi"`, `releaseYear: 2026` | `averageRating: -1` (Descendente) | `limit: 20`, `skip: X` |
| **2. Seguir viendo** | `user_progress` | `userId: "u_123"`, `completed: false` | `lastWatchedAt: -1` (Descendente) | `limit: 10`, `skip: 0` |
| **3. Listado de episodios**| `contents` / `episodes` | `seriesId: "s_456"`, `seasonNumber: 2` | `episodeNumber: 1` (Ascendente)| Sin paginación (suelen ser < 24) |
| **4. Trending semanal** | `analytics` | `timestamp >= [hace 7 días]` | `viewsCount: -1`, `rating: -1` | `limit: 10`, `skip: 0` |
| **5. Recomendaciones** | `recommendations` | `userId: "u_123"` | `matchScore: -1` (Descendente) | `limit: 15`, `skip: X` |
| **6. Reseñas de película** | `reviews` | `contentId: "m_789"` | `createdAt: -1` (Descendente)| `limit: 50`, `skip: X` |


5. Requisitos No Funcionales

**Seguridad y Privacidad**
*   **Cumplimiento Normativo (GDPR/LOPD):** El historial de visualización es un dato de carácter personal. Se debe aplicar cifrado en reposo (Encryption at Rest) en la base de datos y cifrado en tránsito (TLS 1.3).
*   **RBAC (Role-Based Access Control):** Separación estricta a nivel de base de datos de los permisos de lectura/escritura de las API públicas frente a las del panel de administración.
*   **Datos sensibles:** Las contraseñas en la colección `users` deben usar algoritmos de hash robustos (ej. Argon2 o bcrypt con *salt* dinámico).

**Disponibilidad**
*   **Tolerancia a fallos:** Implementación de Replica Sets (mínimo 3 nodos: Primario, Secundario, y un Árbitro o segundo Secundario) para asegurar conmutación por error (failover) automática y mantener el servicio online si un servidor cae (crítico en picos de tráfico nocturnos o fines de semana).

**Crecimiento y Escalabilidad**
*   **Sharding (Particionamiento horizontal):** Las colecciones `user_progress`, `history` y `reviews` crecerán exponencialmente. Se debe definir una clave de fragmentación (Shard Key) robusta, como el `userId` (haciendo hash de este) para distribuir la carga de escrituras equitativamente entre los servidores y evitar *hotspots*.
*   **Patrones de Desnormalización:** Para operaciones como el cálculo de la nota media (Average Rating), en lugar de sumar todas las reseñas cada vez que se carga una película, se utilizará el patrón *Computed Pattern*: mantener un campo `averageRating` en el documento de la película que se actualice asíncronamente o en el momento de la inserción de una nueva valoración.

## Actividad 2: Diseñar las colecciones

1. Colecciones y su propósito

Para satisfacer los requisitos de la plataforma, el modelo se divide en las siguientes colecciones principales:

*   `contents`: Almacena la información principal del catálogo (películas y metadatos de las series). Es la colección de lectura más frecuente para poblar la interfaz.
*   `episodes`: Almacena los episodios individuales de las series. Se separa de `contents` para evitar problemas de crecimiento descontrolado del documento.
*   `users`: Gestiona los perfiles de los clientes, credenciales y preferencias básicas.
*   `user_progress`: Registra el punto exacto de reproducción de un usuario en un contenido específico (heartbeats/seguir viendo). Altamente orientada a la escritura.
*   `reviews`: Almacena las valoraciones y comentarios de los usuarios sobre los contenidos.

2. Documentos de ejemplo (BSON/JSON)

**Colección: `contents` (Ejemplo de una película)**
*(Nota: Se incrustan los nombres de los géneros en lugar de sus IDs para evitar cruces de colecciones, tal como se justifica en el modelo).*
```json

```
