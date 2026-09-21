# Práctica 01: Análisis de una red de sensores de calidad del aire

## 1. Comprender el problema (20 minutos)

- ¿Quién utilizará estos datos?

Los usuarios que lo usarán seran el ayuntamiento, el area de medio ambiente, la policia, los servicios de movilidad, los de Protección Civil y para la salud pública. También puede utilizarse esta información para informar a los ciudadanos y para apoyar decisiones de mantenimiento de la red de sensores.

- ¿Qué decisiones se pueden tomar con ellos?
  - activar alertas cuando suben los niveles de PM2.5 o PM10
  - restringir o desviar tráfico en zonas con alta contaminación;
  - planificar rutas alternativas para transporte público o privado;
  - priorizar actuaciones en áreas más afectadas, como zonas industriales o con mucho tráfico;
  - decidir medidas de movilidad o de salud pública cuando la contaminación supera umbrales;
  - identificar sensores defectuosos, huecos de datos o lecturas anómalas;
  - planificar mejoras de la red y decisiones de infraestructura urbana.

- ¿Qué diferencia hay entre una alerta inmediata y un informe histórico?

La diferencia principal es el tiempo de respuesta y el objetivo:

La Alerta inmediata se procesa en tiempo casi real o en segundos/minutos, pensada para detectar episodios bruscos y reaccionar rápidamente. Sirve para alertar a la población, activar protocolos de protección o restringir el tráfico. Y el informe histórico se analiza a lo largo de horas, días o semanas. Está orientado a detectar tendencias, comparar periodos, estudiar patrones y apoyar decisiones estratégicas de planificación urbana, movilidad y salud.

## 2. Analizar cobertura y calidad (35 minutos)

Utilizando el dossier:

1. Identifica dos problemas de calidad y explica sus consecuencias.

- Datos ausentes: faltan mediciones de PM2.5 y eso puede hacer que la calidad del aire se mida de forma incompleta.
- Sensores con lecturas anómalas o duplicadas: pueden dar información falsa y provocar decisiones incorrectas.

2. Indica qué distrito necesita mayor atención y justifica tu respuesta.

- El distrito que más atención necesita es D4 Sur Industrial, porque tiene mucha población, tráfico y actividad industrial, y además tiene una densidad alta de habitantes y una cobertura menor.

3. Elige una anomalía y explica si la corregirías, la marcarías como dudosa o la excluirías.

- El caso de S008, que repite valores durante 2 horas, lo marcaría como dudoso. Puede ser un fallo del sensor y no debe usarse como dato fiable.

### 3. Comparar arquitecturas (25 minutos)

| Criterio                     | Batch             | Streaming                           |
| ---------------------------- | ----------------- | ----------------------------------- |
| Rapidez para generar alertas | min-h             | con pocos seg-min                   |
| Coste y complejidad          | menores           | mayores                             |
| Informes histórico           | adecuado          | adecuado con mas complejidad        |
| Datos tardíos                | al siguiente lote | requieren ventanas y marcas de agua |

Indica qué alternativa usarías para las alertas y cuál para los informes históricos.

- Para las alertas usaría Streaming, porque necesita reaccionar rápido.
- Para los informes históricos usaría Batch, porque es más adecuado para analizar datos acumulados y generar reportes.

### 4. Elaborar una recomendación (30 minutos)
Hola, escribo para comentar acerca de los 24 sensores que se quieren poner, para controlar la multitud, el aire y emitir alertas. El risgo a resolver mas rápido es el de la contaminación por PM2.5 y PM10 en D4 Sur Industrial, por su concentración de tráfico, industria y población. Para resolverlo proponemos activar alertas en tiempo real con Streaming, avisar a la población y restringir tráfico o desviar vehículos en esa zona.
Por ejemplo, la D4 tiene mucha población, tráfico e industria; y la red presenta datos ausentes, sensores defectuosos y anomalías que pueden ocultar o desviar la realidad.
Algo que deberíamos continuar mejorando es la calidad de los datos y la cobertura de la red, especialmente en los sensores defectuosos y en zonas sin sensores como D6.
Como medida de privacidad: guardar solo coordenadas agregadas o con baja precisión, y no publicar trayectorias individuales de sensores móviles.
