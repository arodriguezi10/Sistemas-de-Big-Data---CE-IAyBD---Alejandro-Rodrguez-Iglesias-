## Evidencias de ejecución

En este directorio se recogen las trazas de ejecución en terminal y resultados obtenidos al validar los scripts.

## 1. Evidencia de validación del esquema ($jsonSchema)

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
**Resultado obtenido**
![Respuesta](/PracticaUT2_01_Rodriguez_Alejandro/valido.png)

### Prueba inválida para la colección `usuarios`
```json
db.usuarios.insertOne({
  email: "correo_sin_arroba.com",
  nombre: "A",
  cuenta_premium: false
});
```
**Resultado obtenido**
![Respuesta](/PracticaUT2_01_Rodriguez_Alejandro/invalido.png)

## 2.