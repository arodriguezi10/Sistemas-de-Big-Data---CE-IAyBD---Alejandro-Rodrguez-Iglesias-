## Actividad 3: Implementar validación e índices

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

2. Definición y justificación de Índices

```json
// Índice 1: Compuesto (Filtrado y ordenación de catálogo)
db.contenidos.createIndex({ 
    tipo: 1, 
    anio_lanzamiento: -1, 
    activo: 1 });
```
* Consulta que acelera: Búsquedas del tipo "Mostrar todas las Películas (Equality), ordenadas de más recientes a más antiguas (Sort)".

* Orden de los campos: Primero tipo (igualdad), luego anio_lanzamiento (ordenación) y finalmente activo.

* Coste: Alto coste en almacenamiento por ser compuesto. Penaliza ligeramente las escrituras (inserciones/actualizaciones) porque el motor debe rebalancear el árbol B-Tree para tres campos cada vez que se añade un contenido.

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

3. Evidencia y análisis con `explain("executionStats")`

```json
db.contenidos.find({ 
    tipo: "Pelicula" 
}).sort({ anio_lanzamiento: -1 }).explain("executionStats");
```

Antes del índice (COLLSCAN):
Al ejecutar el explain, MongoDB no tiene referencias para filtrar ni ordenar eficientemente.

* winningPlan.stage: COLLSCAN (Escaneo completo de colección).

* executionStats.totalDocsExamined: 100,000 (Lee todos los documentos).

* executionStats.executionTimeMillis: ~85 ms.

Nota crítica: Además del escaneo, se ejecuta un stage SORT en memoria. Si el resultado supera los 32MB de memoria RAM asignada para operaciones de ordenación, la consulta fallará a menos que se use allowDiskUse().

Después del índice (IXSCAN):
Tras ejecutar db.contenidos.createIndex({ tipo: 1, anio_lanzamiento: -1 }), el plan de ejecución cambia radicalmente.

* winningPlan.stage: FETCH hijo de un IXSCAN.

* executionStats.totalDocsExamined: 4,500 (Lee únicamente las películas).

* executionStats.executionTimeMillis: ~3 ms.

* Nota crítica: El stage SORT desaparece del plan. MongoDB lee los documentos directamente desde el índice, el cual ya los tiene ordenados por anio_lanzamiento: -1. Esto elimina el consumo excesivo de RAM y CPU, haciendo la consulta escalable sin importar el tamaño del catálogo.