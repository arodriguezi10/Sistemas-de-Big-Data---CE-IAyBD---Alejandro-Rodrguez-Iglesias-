# Informe Pericial de Investigación Forense · Caso 07-OMEGA

- **Estudiante / Analista:** Alejandro
- **Fecha de emisión:** [AAAA-MM-DD]
- **Caso:** Sustracción de la Espada Omega en ÁgoraCraft
- **Fuente de auditoría:** Tabla `EscapeRoomMinecraft` (Amazon DynamoDB, región `us-east-1`)

---

## 1. Dictamen pericial

> Resume las conclusiones de tu investigación (máximo 120 palabras), identificando quién cometió el robo, cuándo ocurrió, cómo aprovechó el fallo del servidor y cuál fue el destino final del objeto.

[Escribe aquí tu dictamen]

---

## 2. Cronología forense probada

Registra al menos 5 eventos clave demostrados fehacientemente con consultas a DynamoDB (incluye marcas de tiempo ISO exactas al segundo):

| Hora exacta (ISO) | ID Cuenta | Alias | Acción / Evento | Zona | Objeto y detalles clave |
|---|---|---|---|---|---|
| `2026-11-02T22:09:00` | `P011` | AdminSol | `DEPOSITAR_OBJETO` | `CamaraTesoro` | `ESPADA_OMEGA` (custodia inicial) |
| | | | | | |
| | | | | | |
| | | | | | |
| | | | | | |
| | | | | | |

---

## 3. Identificación de responsabilidades

- **Autor material del robo:** [Alias e ID de cuenta]
- **Cómplice y receptador:** [Alias e ID de cuenta]
- **Momento exacto del robo físico:** [Hora:Minuto:Segundo]
- **Momento oficial de denuncia y alarma:** [Hora:Minuto:Segundo]
- **Última ubicación conocida del objeto:** [Zona del mapa]

---

## 4. Distinción forense: Hechos observados vs. Inferencias

- **Hecho probado (con evidencia en registros):**  
  [Describe un hecho irrefutable comprobado con una consulta a DynamoDB]

- **Inferencia lógica razonable:**  
  [Describe una deducción fundada a partir de los datos, pero que no está registrada explícitamente]

- **Limitación técnica del dato:**  
  [Explica por qué compartir una IP pública no demuestra una identidad física única en el mundo real]

---

## 5. Análisis de eficiencia y Big Data en DynamoDB

1. **Operación de tipo Scan:**
   - ¿Qué consulta de tu investigación fue un `Scan`?
   - *Consulta PartiQL:* `SELECT ...`
   - ¿Por qué el motor ejecutó un Scan y qué impacto tendría este patrón en una tabla con 500 millones de registros?
   - [Tu explicación técnica]

2. **Operación sobre Global Secondary Index (GSI):**
   - ¿Qué consulta utilizó el índice `PorObjeto`?
   - *Consulta PartiQL:* `SELECT ...`
   - ¿Qué ventaja técnica aportó la proyección `ALL` frente a consultar la tabla base?
   - [Tu explicación técnica]
