## Actividad 3: Creación de Colecciones con `$jsonSchema`

1. Scripts de creación con validación `$jsonSchema`

```json
// Validacion para la coleccion 'contenidos'
db.createCollection("contenidos", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["titulo", "tipo", "anio_lanzamiento", "activo"],
      properties: {
        titulo: {
          bsonType: "string",
          description: "El titulo debe ser una cadena de texto y es obligatorio"
        },
        tipo: {
          enum: ["Pelicula", "Serie", "Documental"],
          description: "El tipo es obligatorio y debe ser uno de los valores permitidos"
        },
        anio_lanzamiento: {
          bsonType: "int",
          minimum: 1895,
          maximum: 2100,
          description: "El anio debe ser un entero entre 1895 y 2100"
        },
        activo: {
          bsonType: "bool",
          description: "Estado de disponibilidad del contenido"
        },
        metadatos: {
          bsonType: "object",
          required: ["duracion_minutos"],
          properties: {
            duracion_minutos: {
              bsonType: "int",
              minimum: 1,
              description: "Duracion mayor a 0"
            }
          }
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// Validacion para la coleccion 'usuarios'
db.createCollection("usuarios", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["email", "nombre", "cuenta_premium"],
      properties: {
        email: {
          bsonType: "string",
          pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
          description: "Debe ser un email valido y es obligatorio"
        },
        nombre: {
          bsonType: "string",
          minLength: 2,
          maxLength: 50,
          description: "Nombre del usuario, entre 2 y 50 caracteres"
        },
        cuenta_premium: {
          bsonType: "bool",
          description: "Indica si el usuario paga subscripcion"
        }
      }
    }
  }
});
```

imagen de resultado

### Prueba válida para la colección `contenidos`

```json
db.contenidos.insertOne({
  titulo: "Interstellar",
  tipo: "Pelicula",
  anio_lanzamiento: 2014,
  activo: true,
  metadatos: {
    duracion_minutos: 169
  }
});
```

![Respuesta](valido.png)

### Prueba inválida para la colección `usuarios`

```json
db.usuarios.insertOne({
  email: "correo_sin_arroba.com",
  nombre: "A",
  cuenta_premium: false
});
```

![Respuesta](invalido.png)

2, 3 y 4. Índices

```json
// Índice 1: Compuesto (Filtrado y ordenación de catálogo)
db.contenidos.createIndex({
    tipo: 1,
    anio_lanzamiento: -1,
    activo: 1 });
```

- Acelera: búsqueda de tipo ""Mostrar todas la Películas (Equality), ordenada de la más reciente a la mas antiguar (sort)""

- Orden de los campos: Primero tipo (igualdad), luego anio_lanzamiento (ordenación) y finalmente activo.

- Coste: Alto coste en almacenamiento por ser compuesto. Penaliza ligeramente las escrituras (inserciones/actualizaciones) porque el motor debe rebalancear el árbol B-Tree para tres campos cada vez que se añade un contenido.

```json
// Índice 2: Texto (Buscador principal)
db.contenidos.createIndex({
    titulo: "text",
    "metadatos.director": "text"
}, {
    default_language: "spanish"
    });
```
* Consulta que acelera: El buscador de la interfaz de usuario donde se introduce texto libre (ej. db.contenidos.find({ $text: { $search: "matrix" } })).

* Orden de los campos: En índices de texto el orden no aplica igual que en los B-Tree estándar, ya que MongoDB crea un índice invertido de tokens (palabras clave).

* Coste: Es el índice más pesado en almacenamiento (almacena arrays de palabras tokenizadas) y el que más penaliza las escrituras, ya que cada inserción requiere parsear y tokenizar las cadenas de texto de título y director.

```json
// Índice 3: Único simple (Autenticación)
db.usuarios.createIndex({ 
    email: 1 }, 
    { unique: true 
});
```
* Consulta que acelera: Login de usuarios y comprobación de existencia durante el registro (ej. db.usuarios.findOne({ email: "usuario@test.com" })).

* Orden de los campos: Sentido ascendente (1). Al ser una búsqueda de coincidencia exacta, el sentido no afecta al rendimiento.

* Coste: Bajo en almacenamiento. Penalización de escritura mínima, pero añade un paso de validación obligatoria a nivel de motor para garantizar que el valor no existe previamente en la colección.

5. Evidencias de rendimiento con `explain(executionsStatas)`

```json
db.contenidos.find({ 
    tipo: "Pelicula" 
}).sort({ anio_lanzamiento: -1 }).explain("executionStats");
``` 

| Métrica | Antes del Índice | Después del Índice |
| :--- | :--- | :--- |
| **Etapa (Stage)** | `COLLSCAN` + `SORT` | `IXSCAN` + `FETCH` |
| **Documentos examinados** | 1 | 1 |
| **Tiempo de respuesta** | 1 ms | ~0-1 ms |