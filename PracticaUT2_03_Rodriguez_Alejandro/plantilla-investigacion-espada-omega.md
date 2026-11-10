# Informe Pericial de Investigación Forense · Caso 07-OMEGA

- **Estudiante / Analista:** Alejandro Rodríguez
- **Fecha de emisión:** 2026-11-10
- **Caso:** Sustracción de la Espada Omega en ÁgoraCraft
- **Fuente de auditoría:** Tabla `EscapeRoomMinecraft` (Amazon DynamoDB, región `us-east-1`)

---

## 1. Dictamen pericial

> Resume las conclusiones de tu investigación (máximo 120 palabras), identificando quién cometió el robo, cuándo ocurrió, cómo aprovechó el fallo del servidor y cuál fue el destino final del objeto.

El autor material del robo es la cuenta P007 (CreeperKing). Aprovechó la caída de red del servidor a las 22:14:00, que desconectó a los testigos cercanos (LunaByte y RedstonePro), para infiltrarse en la Cámara del Tesoro a las 22:14:10. Extrajo físicamente la Espada Omega a las 22:15:18. Posteriormente, huyó al Bosque Oscuro, donde transfirió el arma a su cómplice, P009 (ShadowPixel), a las 22:17:40. Finalmente, este último ocultó la espada en la Mina Abandonada a las 22:20:10, diez minutos antes de que el administrador descubriera el robo.

---

## 2. Cronología forense probada

Registra al menos 5 eventos clave demostrados fehacientemente con consultas a DynamoDB (incluye marcas de tiempo ISO exactas al segundo):

| Hora exacta (ISO) | ID Cuenta | Alias | Acción / Evento | Zona | Objeto y detalles clave |
|---|---|---|---|---|---|
| `2026-11-02T22:09:00` | `P011` | AdminSol | `DEPOSITAR_OBJETO` | `CamaraTesoro` | `ESPADA_OMEGA` (custodia oficial inicial) |
| `2026-11-02T22:14:10` | `P007` | CreeperKing | `ENTRAR_ZONA` | `CamaraTesoro` | Aprovecha la confusión del lag de las 22:14:00 |
| `2026-11-02T22:15:18` | `P007` | CreeperKing | `RETIRAR_OBJETO` | `CamaraTesoro` | `ESPADA_OMEGA` (Robo físico perpetrado) |
| `2026-11-02T22:17:40` | `P007` | CreeperKing | `TRANSFERIR_OBJETO` | `BosqueOscuro` | `ESPADA_OMEGA` (Destinatario registrado: `P009`) |
| `2026-11-02T22:20:10` | `P009` | ShadowPixel | `OCULTAR_OBJETO` | `MinaAbandonada` | `ESPADA_OMEGA` (Última ubicación conocida comprobada) |

---

## 3. Identificación de responsabilidades

- **Autor material del robo:** CreeperKing (P007)
- **Cómplice y receptador:** ShadowPixel (P009)
- **Momento exacto del robo físico:** [22:15:18]
- **Momento oficial de denuncia y alarma:** [22:25:00]
- **Última ubicación conocida del objeto:** [Mina Abandonada]

---

## 4. Distinción forense: Hechos observados vs. Inferencias

- **Hecho probado (con evidencia en registros):**
  Esta probado que CreeperKing y ShadowPixel interactuaron intencionadamente. El evento de transferencia de P007 tiene como atributo destinatario a P009, y el evento de recepción de P009 tiene como remitente a P007 con apenas 4 segundos de diferencia. Además, se desmiente la afirmación de los moderadores sobre que ShadowPixel merodeaba el castillo, ya que los registros lo sitúan en Spawn y luego en BosqueOscuro

- **Inferencia lógica razonable:**
  Resulta altamente probable que el pico de latencia del servidor a las 22:14 (INCIDENCIA_RED) no fuera fortuito, sino un ataque intencionado para provocar los TIMEOUT_CONEXION de los jugadores que vigilaban el exterior (como LunaByte) y facilitar la entrada limpia a la cámara restringida

- **Limitación técnica del dato:**
  El informe inicial señalaba que P007 y P009 comparten la dirección IP 198.51.100.77. Desde el análisis de redes (IPv4), esto no garantiza que sean el mismo individuo manejando multicuentas, ya que podrían estar conectados mediante NAT/CGNAT en una misma red residencial o usar un servidor VPN común. La prueba incriminatoria real son sus eventos coordinados en el juego, no la capa de red.   

---

## 5. Análisis de eficiencia y Big Data en DynamoDB

1. **Operación de tipo Scan:**
  - ¿Qué consulta de tu investigación fue un `Scan`?
  *Consulta PartiQL:* `SELECT * FROM "EscapeRoomMinecraft" WHERE zona = 'Castillo' OR zona = 'CamaraTesoro'`
  - ¿Por qué el motor ejecutó un Scan y qué impacto tendría este patrón en una tabla con 500 millones de registros?
  DynamoDB ejecutó un Scan porque zona no es la Clave de Partición (jugadorId) ni existe un índice sobre ella. En una tabla de 500 millones de registros, esta operación saturaría el rendimiento al tener que leer en disco absolutamente todos los elementos para filtrar por zona, consumiendo masivamente unidades RCU, incrementando drásticamente el coste y el tiempo de respuesta.
2. **Operación sobre Global Secondary Index (GSI):**
  - ¿Qué consulta utilizó el índice `PorObjeto`?
  *Consulta PartiQL:* `SELECT * FROM "EscapeRoomMinecraft"."PorObjeto" WHERE objeto = 'ESPADA_OMEGA'`
  - ¿Qué ventaja técnica aportó la proyección `ALL` frente a consultar la tabla base?
  La proyección ALL duplica todos los atributos del registro original dentro del propio índice. Esto permite que la Query resuelva la consulta leyendo únicamente el GSI sin tener que realizar una segunda lectura a la tabla principal para recuperar los campos extra (como zona, evento o destinatario), optimizando la latencia a unos pocos milisegundos.