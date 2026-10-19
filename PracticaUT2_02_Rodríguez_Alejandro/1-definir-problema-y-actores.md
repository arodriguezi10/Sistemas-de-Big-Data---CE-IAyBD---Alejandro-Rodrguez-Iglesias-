# Actividad 1: Definición del problema y actores

## 1. Escenario, contexto y actores
* **Escenario:** Comunidad social de intercambio de libros, recomendaciones literarias y clubes de lectura.
* **Contexto:** Una plataforma donde los usuarios registran su biblioteca personal, valoran sus lecturas, descubren nuevas obras mediante afinidad y gestionan una red de préstamos físicos de libros con su círculo de confianza.
* **Actores:**
  * **Lector (Usuario final):** Interactúa con el grafo registrando lecturas, publicando reseñas, estableciendo conexiones de amistad, uniéndose a clubes y solicitando o realizando préstamos físicos.
  * **Autor/Editor:** Reclama autoría de nodos de "Libro", interactúa con su comunidad de lectores y analiza la recepción de sus obras.
  * **Motor de Recomendación (Sistema):** Recorre el grafo en segundo plano y en tiempo real para aplicar algoritmos de filtrado colaborativo, sugiriendo obras basadas en los clústeres de afinidad.
  * **Analista de Datos / Administrador:** Consulta métricas globales, evalúa la salud de la red, detecta cuellos de botella en préstamos y monitoriza tendencias literarias.

## 2. Preguntas de negocio concretas a resolver
1. **Recomendación social:** ¿Qué novelas autoconclusivas con una valoración superior a 4 estrellas han leído los amigos de un usuario que él todavía no tenga en su estantería de "leídos"?
2. **Trazabilidad de activos:** ¿Cuál es la cadena exacta de préstamo físico de un ejemplar concreto (desde el propietario original hasta el lector actual) y cuántos días lleva retenido?
3. **Afinidad y descubrimiento:** Si un grupo de usuarios suele leer a un autor específico, ¿qué probabilidad matemática existe en el grafo de que también valoren positivamente a otro autor de un género similar?
4. **Optimización de rutas sociales:** ¿Cuál es el camino de relaciones (amigos o amigos de amigos) más corto y seguro para que el Usuario A consiga en préstamo un ejemplar físico del Libro X que posee el Usuario B?
5. **Análisis de comunidades:** ¿Qué clubes de lectura presentan el mayor solapamiento de miembros activos y cuáles son los géneros predominantes que actúan como puente entre esos grupos?
6. **Detección de nodos influyentes:** ¿Quiénes son los lectores "influencers" (nodos con mayor centralidad de intermediación) cuyas valoraciones de cinco estrellas desencadenan el mayor volumen de nuevas lecturas en su red extendida durante los siguientes 30 días?

## 3. Lecturas vs. Escrituras (Patrones de acceso)
* **Lecturas masivas (Tiempo real):**
  * Generación del *feed* social al iniciar sesión (qué están leyendo y valorando las conexiones de primer grado).
  * Ejecución del motor de recomendación para sugerir el próximo libro.
  * Cálculo del camino más corto (Shortest Path) cuando un usuario hace clic en "Solicitar préstamo" para encontrar quién tiene el libro en su red cercana.
* **Escrituras puntuales (Registros transaccionales):**
  * Creación de nuevos nodos (alta de un usuario, registro de un nuevo libro en la plataforma).
  * Creación o actualización de relaciones (marcar un libro como `LEYÓ`, puntuar con estrellas, crear una relación `PRESTADO_A`, seguir a otro usuario).

## 4. Requisitos de seguridad, disponibilidad, privacidad (RGPD) y crecimiento
* **Privacidad y RGPD:** Se requiere un control estricto sobre la visibilidad de los nodos. Los usuarios deben poder hacer su perfil y sus relaciones de lectura privados. Ante una solicitud de Derecho al Olvido, la base de datos debe eliminar el nodo del usuario y desenlazar sus relaciones sociales, pero puede mantener las reseñas de libros de forma completamente anonimizada para no alterar el cálculo de la valoración media general.
* **Seguridad:** Implementación de control de acceso basado en roles (RBAC). Un usuario solo puede modificar los metadatos de las relaciones que parten de su propio nodo (ej. sus puntuaciones o a quién presta sus libros).
* **Disponibilidad:** Alta disponibilidad crítica para el grafo de recomendaciones y búsquedas; si estas consultas fallan, la aplicación pierde su núcleo funcional. Se requerirá un entorno en clúster para asegurar tolerancia a fallos en producción.
* **Previsión de crecimiento:** La red experimentará un crecimiento con un alto factor de ramificación (densidad de aristas elevada por cada usuario nuevo). Dado que en Neo4j el tiempo de consulta es proporcional a la porción del grafo explorada y no al volumen total de datos, el rendimiento se mantendrá estable al calcular recomendaciones. Se requerirá la creación de índices precisos para las propiedades de búsqueda iniciales (como el ID del usuario o el ISBN del libro).