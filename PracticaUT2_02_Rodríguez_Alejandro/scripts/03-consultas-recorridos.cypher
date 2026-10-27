```cypher
// Buenas prácticas: Usamos MATCH para encontrar los nodos usando los índices previamente creados,
// y MERGE exclusivamente para garantizar la existencia de la relación antes de hacer SET.
MATCH (u:Usuario {id_usuario: 'U1'}), (l:Libro {isbn: '978-84-204-1214-5'})
MERGE (u)-[r:LEYÓ]->(l)
SET r.valoracion = 5,
    r.resena = 'Un thriller espectacular, me atrapó desde la primera página.',
    r.fecha_lectura = date('2026-10-20') // Se registra la fecha de la operación
RETURN u.alias AS Lector, l.titulo AS Libro, r.valoracion AS Nota, r.resena AS Resena;
```

```cypher
MATCH (a:Autor {nombre: 'Carlos Ruiz Zafón'})-[:ESCRIBIÓ]->(l:Libro)-[:PERTENECE_A]->(g:Genero)
RETURN l.titulo AS Titulo, l.paginas AS Paginas, g.nombre_genero AS Genero
ORDER BY l.paginas DESC;
```

```cypher
// La relación AMIGO_DE se consulta sin flecha de dirección (-) para que sea bidireccional.
MATCH (yo:Usuario {id_usuario: 'U1'})-[:AMIGO_DE]-(amigo:Usuario)-[r:LEYÓ]->(l:Libro)
WHERE r.valoracion > 3 
  AND NOT (yo)-[:LEYÓ]->(l) // Patrón negativo: filtramos lo que "yo" ya tengo en mi biblioteca
RETURN l.titulo AS Recomendacion, amigo.alias AS RecomendadoPor, r.valoracion AS NotaAmigo
ORDER BY r.valoracion DESC;
```

```cypher
MATCH (libroBase:Libro {titulo: 'La Sombra del Viento'})<-[:LEYÓ]-(otrosLectores:Usuario)-[r:LEYÓ]->(otrosLibros:Libro)
WHERE otrosLibros <> libroBase 
  AND r.valoracion >= 4 // Solo recomendamos si a la comunidad afín le gustó de verdad
RETURN otrosLibros.titulo AS LibroSugerido, count(otrosLectores) AS VecesRecomendado
ORDER BY VecesRecomendado DESC
LIMIT 5;
```

```cypher
// Calculamos el camino más corto permitiendo un máximo de 6 saltos (*1..6) por seguridad y rendimiento.
MATCH (origen:Usuario {id_usuario: 'U5'}), (destino:Usuario {id_usuario: 'U3'})
MATCH ruta = shortestPath((origen)-[:AMIGO_DE*1..6]-(destino))
// Extraemos solo los alias de los nodos atravesados para ver la cadena visualmente
RETURN [nodo IN nodes(ruta) | nodo.alias] AS CadenaDeAmistades, length(ruta) AS GradosDeSeparacion;
```