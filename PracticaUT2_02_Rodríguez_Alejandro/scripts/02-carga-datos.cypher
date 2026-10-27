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
```

```cypher
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