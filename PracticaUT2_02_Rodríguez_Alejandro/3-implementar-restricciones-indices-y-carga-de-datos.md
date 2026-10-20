## Actividad 3: Implementar restricciones, índices y carga de datos

### 1. Restricciones de unicidad

Las restricciones de unicidad (`CONSTRAINT`) son fundamentales en Neo4j para evitar nodos duplicados y garantizar la integridad referencial. Al crear una restricción de unicidad, Neo4j genera automáticamente un índice B-Tree subyacente para esa propiedad, optimizando las búsquedas.

```cypher
// Restricciones para garantizar identificadores únicos en los nodos principales
CREATE CONSTRAINT unique_usuario_id FOR (u:Usuario) REQUIRE u.id_usuario IS UNIQUE;
CREATE CONSTRAINT unique_libro_isbn FOR (l:Libro) REQUIRE l.isbn IS UNIQUE;
CREATE CONSTRAINT unique_autor_id FOR (a:Autor) REQUIRE a.id_autor IS UNIQUE;
CREATE CONSTRAINT unique_club_id FOR (c:ClubLectura) REQUIRE c.id_club IS UNIQUE;
CREATE CONSTRAINT unique_genero_nombre FOR (g:Genero) REQUIRE g.nombre_genero IS UNIQUE;
```

### 2. Índices secundarios

Los índices secundarios se aplican a propiedades por las que se filtra frecuentemente (como nombres o títulos), pero que no necesariamente deben ser únicas. Esto evita que el motor de la base de datos realice un escaneo secuencial completo (NodeByLabelScan), localizando el nodo de inicio de forma inmediata.

```cypher
// Índices para acelerar búsquedas textuales comunes
CREATE INDEX index_libro_titulo FOR (l:Libro) ON (l.titulo);
CREATE INDEX index_usuario_alias FOR (u:Usuario) ON (u.alias);
CREATE INDEX index_autor_nombre FOR (a:Autor) ON (a.nombre);
```

### 3 y 4. Carga controlada con MERGE (Dataset de prueba)

El comando MERGE funciona como un "Insertar o Actualizar" (Upsert). Busca un patrón en el grafo; si existe, lo asocia a la variable, y si no existe, lo crea. Esto garantiza la idempotencia del script: puedes ejecutarlo 100 veces y siempre tendrás exactamente los mismos 16 nodos y 31 relaciones, sin duplicar datos.

```cypher
// --------------------------------------------------------
// PASO 1: MERGE DE NODOS (Creación de entidades)
// --------------------------------------------------------

// Autores
MERGE (a1:Autor {id_autor: 'A1'}) ON CREATE SET a1.nombre = 'Joël Dicker'
MERGE (a2:Autor {id_autor: 'A2'}) ON CREATE SET a2.nombre = 'Carlos Ruiz Zafón'
MERGE (a3:Autor {id_autor: 'A3'}) ON CREATE SET a3.nombre = 'Stephen King';

// Géneros
MERGE (g1:Genero {nombre_genero: 'Misterio y Thriller'})
MERGE (g2:Genero {nombre_genero: 'Ficción Contemporánea'})
MERGE (g3:Genero {nombre_genero: 'Terror'});

// Libros
MERGE (l1:Libro {isbn: '978-84-204-1214-5'}) ON CREATE SET l1.titulo = 'La verdad sobre el caso Harry Quebert', l1.paginas = 672
MERGE (l2:Libro {isbn: '978-84-204-1992-2'}) ON CREATE SET l2.titulo = 'El Libro de los Baltimore', l2.paginas = 480
MERGE (l3:Libro {isbn: '978-84-08-04364-5'}) ON CREATE SET l3.titulo = 'La Sombra del Viento', l3.paginas = 576
MERGE (l4:Libro {isbn: '978-84-08-08080-0'}) ON CREATE SET l4.titulo = 'El Juego del Ángel', l4.paginas = 672
MERGE (l5:Libro {isbn: '978-84-01-32706-0'}) ON CREATE SET l5.titulo = 'El Resplandor', l5.paginas = 600;

// Usuarios
MERGE (u1:Usuario {id_usuario: 'U1'}) ON CREATE SET u1.alias = 'Alejandro'
MERGE (u2:Usuario {id_usuario: 'U2'}) ON CREATE SET u2.alias = 'Beatriz'
MERGE (u3:Usuario {id_usuario: 'U3'}) ON CREATE SET u3.alias = 'Carlos'
MERGE (u4:Usuario {id_usuario: 'U4'}) ON CREATE SET u4.alias = 'Diana'
MERGE (u5:Usuario {id_usuario: 'U5'}) ON CREATE SET u5.alias = 'Elena';

// Clubes de Lectura
MERGE (c1:ClubLectura {id_club: 'C1'}) ON CREATE SET c1.nombre = 'Amantes del Thriller';

// --------------------------------------------------------
// PASO 2: MERGE DE RELACIONES (Conexión del grafo)
// --------------------------------------------------------

// Es una buena práctica usar MATCH para encontrar los nodos primero 
// y luego usar MERGE exclusivamente para la relación entre ellos.

// Autores -> Libros
MATCH (a1:Autor {id_autor: 'A1'}), (l1:Libro {isbn: '978-84-204-1214-5'}) MERGE (a1)-[:ESCRIBIÓ {rol_autoria: 'autor_principal'}]->(l1);
MATCH (a1:Autor {id_autor: 'A1'}), (l2:Libro {isbn: '978-84-204-1992-2'}) MERGE (a1)-[:ESCRIBIÓ {rol_autoria: 'autor_principal'}]->(l2);
MATCH (a2:Autor {id_autor: 'A2'}), (l3:Libro {isbn: '978-84-08-04364-5'}) MERGE (a2)-[:ESCRIBIÓ {rol_autoria: 'autor_principal'}]->(l3);
MATCH (a2:Autor {id_autor: 'A2'}), (l4:Libro {isbn: '978-84-08-08080-0'}) MERGE (a2)-[:ESCRIBIÓ {rol_autoria: 'autor_principal'}]->(l4);
MATCH (a3:Autor {id_autor: 'A3'}), (l5:Libro {isbn: '978-84-01-32706-0'}) MERGE (a3)-[:ESCRIBIÓ {rol_autoria: 'autor_principal'}]->(l5);

// Libros -> Géneros
MATCH (l1:Libro {isbn: '978-84-204-1214-5'}), (g1:Genero {nombre_genero: 'Misterio y Thriller'}) MERGE (l1)-[:PERTENECE_A]->(g1);
MATCH (l2:Libro {isbn: '978-84-204-1992-2'}), (g2:Genero {nombre_genero: 'Ficción Contemporánea'}) MERGE (l2)-[:PERTENECE_A]->(g2);
MATCH (l3:Libro {isbn: '978-84-08-04364-5'}), (g1:Genero {nombre_genero: 'Misterio y Thriller'}) MERGE (l3)-[:PERTENECE_A]->(g1);
MATCH (l4:Libro {isbn: '978-84-08-08080-0'}), (g1:Genero {nombre_genero: 'Misterio y Thriller'}) MERGE (l4)-[:PERTENECE_A]->(g1);
MATCH (l5:Libro {isbn: '978-84-01-32706-0'}), (g3:Genero {nombre_genero: 'Terror'}) MERGE (l5)-[:PERTENECE_A]->(g3);

// Usuarios -> Libros (Lecturas y puntuaciones)
MATCH (u1:Usuario {id_usuario: 'U1'}), (l1:Libro {isbn: '978-84-204-1214-5'}) MERGE (u1)-[:LEYÓ {valoracion: 5, fecha: date('2026-01-15')}]->(l1);
MATCH (u1:Usuario {id_usuario: 'U1'}), (l3:Libro {isbn: '978-84-08-04364-5'}) MERGE (u1)-[:LEYÓ {valoracion: 4, fecha: date('2026-03-20')}]->(l3);
MATCH (u2:Usuario {id_usuario: 'U2'}), (l1:Libro {isbn: '978-84-204-1214-5'}) MERGE (u2)-[:LEYÓ {valoracion: 5, fecha: date('2026-02-10')}]->(l1);
MATCH (u2:Usuario {id_usuario: 'U2'}), (l2:Libro {isbn: '978-84-204-1992-2'}) MERGE (u2)-[:LEYÓ {valoracion: 4, fecha: date('2026-04-05')}]->(l2);
MATCH (u3:Usuario {id_usuario: 'U3'}), (l3:Libro {isbn: '978-84-08-04364-5'}) MERGE (u3)-[:LEYÓ {valoracion: 5, fecha: date('2025-11-30')}]->(l3);
MATCH (u4:Usuario {id_usuario: 'U4'}), (l5:Libro {isbn: '978-84-01-32706-0'}) MERGE (u4)-[:LEYÓ {valoracion: 3, fecha: date('2026-06-12')}]->(l5);
MATCH (u5:Usuario {id_usuario: 'U5'}), (l4:Libro {isbn: '978-84-08-08080-0'}) MERGE (u5)-[:LEYÓ {valoracion: 4, fecha: date('2026-07-22')}]->(l4);
MATCH (u5:Usuario {id_usuario: 'U5'}), (l1:Libro {isbn: '978-84-204-1214-5'}) MERGE (u5)-[:LEYÓ {valoracion: 5, fecha: date('2026-08-01')}]->(l1);

// Usuarios -> Libros (Quieren leer)
MATCH (u1:Usuario {id_usuario: 'U1'}), (l2:Libro {isbn: '978-84-204-1992-2'}) MERGE (u1)-[:QUIERE_LEER {fecha_adicion: date('2026-09-01')}]->(l2);
MATCH (u3:Usuario {id_usuario: 'U3'}), (l4:Libro {isbn: '978-84-08-08080-0'}) MERGE (u3)-[:QUIERE_LEER {fecha_adicion: date('2026-08-15')}]->(l4);
MATCH (u4:Usuario {id_usuario: 'U4'}), (l1:Libro {isbn: '978-84-204-1214-5'}) MERGE (u4)-[:QUIERE_LEER {fecha_adicion: date('2026-09-10')}]->(l1);

// Usuarios -> Usuarios (Amistades)
MATCH (u1:Usuario {id_usuario: 'U1'}), (u2:Usuario {id_usuario: 'U2'}) MERGE (u1)-[:AMIGO_DE {desde: date('2025-05-10')}]->(u2);
MATCH (u2:Usuario {id_usuario: 'U2'}), (u1:Usuario {id_usuario: 'U1'}) MERGE (u2)-[:AMIGO_DE {desde: date('2025-05-10')}]->(u1);
MATCH (u2:Usuario {id_usuario: 'U2'}), (u3:Usuario {id_usuario: 'U3'}) MERGE (u2)-[:AMIGO_DE {desde: date('2026-01-05')}]->(u3);
MATCH (u1:Usuario {id_usuario: 'U1'}), (u5:Usuario {id_usuario: 'U5'}) MERGE (u1)-[:AMIGO_DE {desde: date('2026-06-20')}]->(u5);

// Usuarios -> Usuarios (Préstamos físicos)
MATCH (u3:Usuario {id_usuario: 'U3'}), (u2:Usuario {id_usuario: 'U2'}) MERGE (u3)-[:PRESTÓ_A {isbn_libro: '978-84-08-04364-5', fecha_prestamo: date('2026-09-15')}]->(u2);
MATCH (u5:Usuario {id_usuario: 'U5'}), (u1:Usuario {id_usuario: 'U1'}) MERGE (u5)-[:PRESTÓ_A {isbn_libro: '978-84-08-08080-0', fecha_prestamo: date('2026-10-01')}]->(u1);

// Usuarios -> Club / Club -> Libro
MATCH (u1:Usuario {id_usuario: 'U1'}), (c1:ClubLectura {id_club: 'C1'}) MERGE (u1)-[:MIEMBRO_DE {rol: 'admin', fecha_union: date('2026-01-01')}]->(c1);
MATCH (u2:Usuario {id_usuario: 'U2'}), (c1:ClubLectura {id_club: 'C1'}) MERGE (u2)-[:MIEMBRO_DE {rol: 'miembro', fecha_union: date('2026-02-15')}]->(c1);
MATCH (u5:Usuario {id_usuario: 'U5'}), (c1:ClubLectura {id_club: 'C1'}) MERGE (u5)-[:MIEMBRO_DE {rol: 'miembro', fecha_union: date('2026-07-10')}]->(c1);
MATCH (c1:ClubLectura {id_club: 'C1'}), (l1:Libro {isbn: '978-84-204-1214-5'}) MERGE (c1)-[:LEYENDO_ACTUALMENTE {mes: 10, anio: 2026}]->(l1);
```

### 5. Evidencia del plan de ejecución (PROFILE)

Para comprobar que el modelo está optimizado y utiliza las estructuras de datos correctas, añadimos la cláusula PROFILE antes de una consulta de lectura. PROFILE ejecuta la consulta y devuelve el plan físico que ha seguido el motor de la base de datos.

Consulta de prueba: Localizar el libro "La Sombra del Viento" por su ISBN y obtener el autor.

```cypher
PROFILE 
MATCH (l:Libro {isbn: '978-84-08-04364-5'})<-[:ESCRIBIÓ]-(a:Autor) 
RETURN a.nombre;
```

Análisis del resultado esperado en Neo4j:

* NodeUniqueIndexSeek (o NodeIndexSeek): Es la primera operación que debe aparecer en el árbol de ejecución (abajo del todo o al inicio de la traza, según la vista). Confirma que Neo4j no ha escaneado todos los libros de la base de datos, sino que ha ido directamente a la posición de memoria del libro buscando el identificador en el índice (coste computacional O(log N)).

* Expand(All): Desde el nodo del libro ya localizado, Neo4j navega a través de los punteros directos de la relación <-[:ESCRIBIÓ]- para llegar al autor. El tiempo empleado en este paso es de milisegundos y depende exclusivamente de la cantidad de aristas conectadas al nodo inicial (coste computacional O(1) por relación).

* Ausencia de NodeByLabelScan: Si viéramos NodeByLabelScan asociado al nodo :Libro en el perfil, significaría que la restricción de unicidad o el índice no están aplicados, obligando al sistema a cargar en memoria todos los libros para evaluarlos uno a uno, lo cual colapsaría el rendimiento en producción.