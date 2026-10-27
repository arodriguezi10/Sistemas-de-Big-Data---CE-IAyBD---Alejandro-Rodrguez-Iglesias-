```cypher
// Restricciones para garantizar identificadores únicos en los nodos principales
CREATE CONSTRAINT unique_usuario_id FOR (u:Usuario) REQUIRE u.id_usuario IS UNIQUE;
CREATE CONSTRAINT unique_libro_isbn FOR (l:Libro) REQUIRE l.isbn IS UNIQUE;
CREATE CONSTRAINT unique_autor_id FOR (a:Autor) REQUIRE a.id_autor IS UNIQUE;
CREATE CONSTRAINT unique_club_id FOR (c:ClubLectura) REQUIRE c.id_club IS UNIQUE;
CREATE CONSTRAINT unique_genero_nombre FOR (g:Genero) REQUIRE g.nombre_genero IS UNIQUE;
```

```cypher
// Índices para acelerar búsquedas textuales comunes
CREATE INDEX index_libro_titulo FOR (l:Libro) ON (l.titulo);
CREATE INDEX index_usuario_alias FOR (u:Usuario) ON (u.alias);
CREATE INDEX index_autor_nombre FOR (a:Autor) ON (a.nombre);
```