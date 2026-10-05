## Actividad 2: Diseñar las colecciones

![Diagrama de mermaid](unnamed.png)

1. Colecciones y su propósito

Para satisfacer los requisitos de la plataforma, el modelo se divide en las siguientes colecciones principales:

- `contents`: Almacena la información principal del catálogo (películas y metadatos de las series). Es la colección de lectura más frecuente para poblar la interfaz.
- `episodes`: Almacena los episodios individuales de las series. Se separa de `contents` para evitar problemas de crecimiento descontrolado del documento.
- `users`: Gestiona los perfiles de los clientes, credenciales y preferencias básicas.
- `user_progress`: Registra el punto exacto de reproducción de un usuario en un contenido específico (heartbeats/seguir viendo). Altamente orientada a la escritura.
- `reviews`: Almacena las valoraciones y comentarios de los usuarios sobre los contenidos.

2. Documentos de ejemplo (BSON/JSON)

**Colección: `contents` (Ejemplo de una película)**
_(Nota: Se incrustan los nombres de los géneros en lugar de sus IDs para evitar cruces de colecciones, tal como se justifica en el modelo)._

* Películas
```json
{
  "_id": ObjectId("650c1f1e1c9d440000a1b2c1"),
  "type": "movie",
  "title": "El Origen",
  "release_year": 2010,
  "genres": ["Ciencia Ficción", "Acción"],
  "duration_minutes": 148,
  "average_rating": 4.8
}
```
* Series
```json
{
  "_id": ObjectId("650c1f1e1c9d440000a1b2c2"),
  "type": "series",
  "title": "Mundos Paralelos",
  "release_year": 2016,
        "genre_ids": ["g1", "g2"],
        "average_rating": 4.7,
        "seasons": [
          {
            "season_number": 1,
            "episodes": [
              {
                "id": "ep101",
                "episode_number": 1,
                "title": "La desaparición",
                "duration_minutes": 47
              },
              {
                "id": "ep102",
                "episode_number": 2,
                "title": "El portal oscuro",
                "duration_minutes": 50
              }
            ]
          }
        ]
}
```

3. Incrustación y Referencia: Justificaciones

**Decisión de Incrustación (Embedding): Actores, Géneros y Episodios en `series/movies`**

- **Justificación:** Se ha decidido incrustar el array `cast` (reparto), `genres` y toda la estructura de `seasons` con sus `episodes` dentro del documento principal del contenido.
- **Tamaño y crecimiento (Bounded Arrays):** El crecimiento de estos arrays está acotado. Incluso una serie inusualmente larga (ej. 50 temporadas, 1000 episodios), almacenando los metadatos básicos del episodio (id, número, título, duración), ocuparía apenas 1-2 MB, quedando extremadamente lejos del límite físico de 16MB por documento en MongoDB.
- **Frecuencia de lectura:** Muy alta. Cuando un usuario entra a la ficha de una serie, la interfaz requiere pintar inmediatamente las temporadas y episodios disponibles. Al incrustarlos, resolvemos la vista completa con una única operación de lectura, maximizando el rendimiento y evitando `$lookup` o consultas secundarias.
- **Posibilidad de actualización:** Muy baja. Una vez publicado un episodio, sus metadatos estructurales (duración, número, título) rara vez sufren modificaciones.

**Decisión de Referencia (Referencing): Reseñas y Episodios**

- **Justificación:** Se ha decidido extraer `reviews` y `episodes` (y el historial/progreso) a sus propias colecciones, referenciando al contenido padre (`content_id`).
- **Tamaño y crecimiento (Unbounded Arrays):** El volumen de valoraciones no tiene límite (Unbounded). Un contenido viral puede generar millones de reseñas. Si las incrustáramos, colapsaríamos rápidamente el límite de 16MB de MongoDB y generaríamos bloqueos constantes por actualización del documento.
- **Frecuencia de lectura:** Media/Baja (respecto al catálogo). Los usuarios leen primero los datos del contenido; las reseñas se consultan bajo demanda, en segundo plano, o mediante paginación.

4. Estrategia de campos

- **Identificadores:** Se utiliza el `ObjectId` nativo de MongoDB para los `_id`. Es eficiente, garantiza unicidad distribuida y contiene una marca de tiempo implícita, lo que permite ordenar documentos por fecha de creación de forma gratuita.
- **Fechas:** Almacenadas siempre como `ISODate` (tipo BSON Date) en UTC. Permite realizar consultas de rango temporales de forma nativa (ej. `$gte` y `$lte`).
- **Estados y Tipos:** Se manejan mediante valores de cadena literales exactos (ej. `type: "movie" | "series"`). A nivel de validación (Schema Validation), actuará como un _Enum_ estricto.
- **Campos opcionales:** Siguiendo la regla del _Sparse Field_, si un contenido no tiene `synopsis`, el campo se omite del documento JSON en lugar de guardarlo como `null` o vacío. Ahorra espacio en disco y memoria RAM.

5. Límites del modelo

- **Tamaño máximo del documento:** Protegido mediante la separación de colecciones de crecimiento infinito (reseñas y telemetría). Los arrays incrustados (episodios, actores) están acotados y no suponen un riesgo para los 16MB.
- **Crecimiento de arrays:** El único array susceptible de crecer es `cast` o `genres`, limitados por la propia naturaleza del dominio (una película no tiene miles de actores principales).
- **Duplicación de datos (Desnormalización):**
  - Redundancia intencionada en `averageRating` y `totalReviews` dentro de `contents` (Computed Pattern).
  - Inclusión del `userName` dentro de `reviews` (Extended Reference Pattern) para evitar un join con la colección `users` al leer comentarios.
- **Consistencia:** Es **eventual**. Si un usuario cambia su nombre en `users`, un proceso en segundo plano deberá actualizar el campo `userName` en todas sus `reviews` históricas.
- **Operaciones incómodas:**
  - _Cascading Deletes:_ Eliminar un usuario requiere lanzar múltiples borrados manuales en `user_progress` y `reviews` (MongoDB no tiene ON DELETE CASCADE).
  - _Actualizaciones masivas:_ Cambiar el nombre de un género a nivel de plataforma implicaría un `updateMany` masivo, aunque es una operación de muy baja frecuencia.