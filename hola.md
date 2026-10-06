## Actividad 4: Resolver consultas y una agregación compleja

1. Inserción, actualización parcial y deactivacion lógica (CRUD)

```JSON
// 1. Inserción
db.contenidos.insertOne({
  titulo: "Breaking Bad",
  tipo: "Serie",
  anio_lanzamiento: 2008,
  activo: true,
  metadatos: {
    duracion_minutos: 47
  }
});

// 2. Actualización parcial
db.contenidos.updateOne(
  { titulo: "Breaking Bad" },
  {
    $set: {
      "metadatos.director": "Vince Gilligan",
      anio_lanzamiento: 2009
    }
  }
);

// 3. Eliminación o desactivación lógica
db.contenidos.updateOne(
  { titulo: "Breaking Bad" },
  {
    $set: {
      activo: false
    }
  }
);
```

imagen de resultado

2. Filtros conmbinados, ordenación y paginación estable

```json
db.contenidos.find(
  { activo: true, anio_lanzamiento: { $gte: 2000, $lte: 2026 } },
  { titulo: 1, tipo: 1, anio_lanzamiento: 1 }
)
.sort({ anio_lanzamiento: -1, _id: 1 }) // _id sirve de desempate para que los resultados nunca bailen entre páginas
.skip(0)
.limit(2);
```

imagen de resultado

3. Consulta con referencia mediante `$lookup`

La colección `ratings` tiene un campo `contenido_id`, que hace referencia al documento padre en la colección `contenidos`.
Para probarlo, he insertado una valoración de prueba, para facilitar dicha prueba, en vez de, usar un `Object_Id`, he usado el propio nombre de la película.

```json
db.valoraciones.insertOne({
  contenido_id: "Interstellar", // Referencia cruzada al contenido
  usuario_id: "usuario.prueba@dominio.com", 
  estrellas: 5,
  comentario: "Una obra maestra visual."
});
```

Entonces, ahora si nos queremos traer todas las valoraciones que hacen referencia a esta película, ejecutamos `$lookup`

```json
db.contenidos.aggregate([
  { 
    $match: { titulo: "Interstellar" } // 1. Filtramos para no cruzar toda la base de datos
  },
  {
    $lookup: {
      from: "valoraciones",     
      localField: "titulo", 
      foreignField: "contenido_id",
      as: "todas_las_valoraciones"
    }
  },
  {
    $project: {
      titulo: 1,
      tipo: 1,
      todas_las_valoraciones: 1
    }
  }
]);
```

imagen de resultado

4. Agregación compleja de 4+ etapas con `$facet`

```json
db.contenidos.aggregate([
  // Etapa 1:
  { 
    $match: { activo: true } 
  },
  
  // Etapa 2 ($lookup): 
  {
    $lookup: {
      from: "valoraciones",
      localField: "titulo", 
      foreignField: "contenido_id",
      as: "datos_valoraciones"
    }
  },
  
  // Etapa 3 ($unwind):
  {
    $unwind: "$datos_valoraciones"
  },
  
  // Etapa 4 ($group): 
  {
    $group: {
      _id: "$titulo",
      tipo_contenido: { $first: "$tipo" },
      nota_media: { $avg: "$datos_valoraciones.estrellas" },
      total_reviews: { $sum: 1 }
    }
  },
  
  {
    $sort: { nota_media: -1 }
  }
]);
```

imagen de resultado

5. Análisis de escalabilidad al crecer de los datos

El coste de rendimiento aumentaría drásticamente por dos motivos principales:

* Lentitud al cruzar datos ($lookup): Si la base de datos crece a millones de reviews, buscar cuáles pertenecen a cada película sería lentísimo. Para evitar que el servidor colapse, es estrictamente necesario que la colección de valoraciones tenga un índice en el campo contenido_id.

* Límite de memoria RAM ($unwind y $group): Desglosar los arrays y recalcular promedios masivos consume mucha memoria temporal. Si la consulta supera el límite de 100MB de RAM que MongoDB impone por defecto, fallará. Para solucionarlo, habría que permitir que el motor escriba temporalmente en el disco duro (usando el parámetro allowDiskUse: true), lo que salva la operación pero la vuelve más lenta.

## Actividad 5: Copias de seguridad, seguridad y liminites

1. Procedimiento de copia y restauración con `mongodump`/`mogorestore`

- Copia de seguridad (Backup)
```
mongodump --db=plataforma_multimedia --out=/ruta/backup/2026-10-06/
```

- Restauración (Restore)
```
mongorestore --db=plataforma_multimedia /ruta/backup/2026-10-06/plataforma_multimedia/
```

2. Usuarios, roles y permisos mínimos (RBAC)

Aplicando el principio de mínimo privilegio, el sistema debe dividirse en dos roles estrictos:

- Administrador de Base de Datos (DBA / DevOps):
   * *Rol:* `dbOwner` o la combinación de `userAdmin` + `dbAdmin` sobre la base de datos de la plataforma.
   * *Permisos:* Crear y borrar colecciones, crear índices, gestionar cuotas, ejecutar planes de ejecución de consultas (`explain`) y gestionar copias de seguridad.

- Aplicación Backend:
   * *Rol:* `readWrite` exclusivamente sobre la base de datos `plataforma_multimedia`.
   * *Permisos:* Leer, insertar y actualizar documentos (CRUD). *Prohibido* el acceso a bases de datos de sistema (`admin`, `local`) o permisos para borrar colecciones enteras (`dropCollection`).

3. Cifrado y anonimización en entornos de prueba

Por normativas de privacidad (como el RGPD), los datos reales de producción jamás deben volcarse intactos a entornos de desarrollo (Test/Staging).

* Datos a anonimizar (Enmascaramiento): El campo `email` y `nombre` de la colección `usuarios`. En pruebas, los correos deben ofuscarse (ej. `usuario123@test.local`) para evitar envíos de emails accidentales a clientes reales.
* Datos a excluir: Hashes de contraseñas reales, tokens de sesión activos y datos bancarios si existiesen.
* Cifrado:La conexión entre la aplicación y MongoDB debe usar TLS/SSL (Cifrado en tránsito). El disco del servidor debe tener activado *Encryption at Rest* (Cifrado en reposo) para proteger los archivos físicos `.wt`.

4. Casos donde MongoDB no es la mejor opción

- Almacenamiento del archivo de vídeo/audio real:** MongoDB tiene un límite estricto de **16 MB por documento**. Almacenar gigabytes de vídeo saturaría la memoria RAM y bloquearía la red. *Solución:* Los vídeos deben ir a un Object Storage (AWS S3) y en MongoDB solo se guarda la URL.
- Pasarela de pagos y facturación: Si la plataforma implementa una contabilidad estricta con facturas y pagos (sistemas financieros), los motores relacionales clásicos (como PostgreSQL) siguen siendo la opción preferida por su alta robustez transaccional y bloqueos predecibles a nivel de fila.

5. Criterios de retención e histórico de datos

Para evitar que la base de datos crezca infinitamente y degrade el rendimiento:

- Conservar (Hot Data): El catálogo de contenidos actual, usuarios activos y las valoraciones recientes. 
- Eliminación automática (TTL Indexes): Sesiones temporales de usuarios, tokens de recuperación o logs de la API. Se configuran índices TTL (Time-To-Live) para que MongoDB los borre automáticamente pasadas unas horas.
- Archivado (Cold Data): Usuarios que llevan años inactivos o historiales de reproducciones muy antiguos. Estos datos se mueven a un *Data Lake* externo para analítica (Big Data), sacándolos de la base de datos principal para aligerar la memoria y los índices.