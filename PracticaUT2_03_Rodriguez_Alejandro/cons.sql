SELECT * FROM "EscapeRoomMinecraft"
WHERE fechaHora BETWEEN '2026-11-02T22:10:00' AND '2026-11-02T22:20:00'

/*--------------*/

SELECT * FROM "EscapeRoomMinecraft"
WHERE (zona = 'Castillo' OR zona = 'CamaraTesoro')
  AND fechaHora BETWEEN '2026-11-02T22:10:00' AND '2026-11-02T22:20:00'

/*--------------*/

SELECT * FROM "EscapeRoomMinecraft"
WHERE jugadorId = 'P011'
  AND fechaHora BETWEEN '2026-11-02T22:14:00' AND '2026-11-02T22:16:15'

SELECT * FROM "EscapeRoomMinecraft"
WHERE jugadorId = 'P003'
  AND fechaHora BETWEEN '2026-11-02T22:14:00' AND '2026-11-02T22:16:15'

SELECT * FROM "EscapeRoomMinecraft"
WHERE jugadorId = 'P007'
  AND fechaHora BETWEEN '2026-11-02T22:14:00' AND '2026-11-02T22:16:15'

/*--------------*/

SELECT * FROM "EscapeRoomMinecraft"."PorObjeto"
WHERE objeto = 'ESPADA_OMEGA'

/*--------------*/

SELECT * FROM "EscapeRoomMinecraft" 
WHERE jugadorId = 'P007' AND fechaHora BETWEEN '2026-11-02T22:17:00' AND '2026-11-02T22:18:00'

SELECT * FROM "EscapeRoomMinecraft" 
WHERE jugadorId = 'P009' AND fechaHora BETWEEN '2026-11-02T22:17:00' AND '2026-11-02T22:18:00'

/*--------------*/