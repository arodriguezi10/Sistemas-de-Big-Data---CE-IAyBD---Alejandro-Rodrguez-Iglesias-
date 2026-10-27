# Datos de Prueba

En este proyecto no se utilizan archivos de datos externos (como `.csv` o `.json`) para la importación.

El dataset de prueba, que conforma la red inicial de la plataforma con **17 nodos y 31 relaciones**, se genera de forma directa, controlada e idempotente directamente desde código.

Para cargar estos datos en la base de datos (ya sea en entorno local o en Neo4j Aura), debes ejecutar el script ubicado en la carpeta de scripts:

`../scripts/02-carga-datos.cypher`