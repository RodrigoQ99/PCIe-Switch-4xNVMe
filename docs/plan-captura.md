# Plan de captura v1 — copia de 02 Esquematico\Plan_captura_v1.xlsx (2026-10-28)

## Plan de captura
| Plan de captura en OrCAD — PCIe x4 → 4× NVMe (base: EVB V1.6) | | Unnamed: 2 | | Unnamed: 4 | |
| --- | --- | --- | --- | --- | --- |
| Archivo de trabajo: 02 Esquematico\PCIe\_Switch\_4xNVMe.opj. Conexiones exactas: Tabla\_conexiones\_v1.xlsx. Columna 'Hecho' (amarilla): marca Sí al terminar cada fila. |  |  |  |  |  |
|  |  |  |  |  |  |
| # | Hoja EVB → hoja nueva | Acción | Detalle | Por qué | Hecho |
| 0 | — | Abrir proyecto | Abrir PCIe\_Switch\_4xNVMe.opj en OrCAD Capture. Si no abre, File > Open > Design y elegir el .DSN. | Copia de trabajo; el EVB original queda intacto en 01 Recuros\Kit. |  |
| 1 | 09, 14, 16, 18, 20 | Borrar hojas | 09 Slot 1–3, 14 Signal Switch, 16 SHP/PM L1.1, 18 GPIO, 20 Disclaimer. | Fuera de la topología (U12–U17, S1–S3, hot plug, GPIO). |  |
| 2a | 08 Upstream | Renombrar nets lanes 1–3 | TXp1\_UP→PETp1\_RECEPT, TXn1\_UP→PETn1\_RECEPT (igual lanes 2 y 3). RXp1\_UP→PERp1\_RECEPT, RXn1\_UP→PERn1\_RECEPT (igual 2 y 3). | Conexión directa gold finger ↔ U6 sin U12/U13/U16. |  |
| 2b | 08 Upstream | Alimentación del slot | +12V (B1, B2, B3, A2, A3) → net 12V\_SLOT. +3.3V (B8, A9, A10) → net 3.3V\_SLOT. Quitar marcas NC. | En el EVB venía de ATX; aquí la tarjeta se alimenta del slot. |  |
| 2c | 08 Upstream | Presencia | PRSNT1# (A1) conectado solo a PRSNT2#\_4 (B31). Quitar unión con B17. | Indica al host una tarjeta x4 (CEM). |  |
| 2d | 08 Upstream | Limpiar | Borrar R29/R30 y nets SCL/SDA\_I2C\_CN. 3.3Vaux (B10) NC; borrar C52–C54. Cambiar RB2/RB4 (0 Ω) por cable. | SMBus fuera de alcance; quitar 0 Ω evita stubs en REFCLK. |  |
| 3 | 12 Diff Pair | Sin cambios | Verificar que los off-page de lanes 1–3 y 5–7 conecten con hojas 08 y M.2. | Las nets \_RECEPT ya son las finales. |  |
| 4 | 15 Clock Buffer | Simplificar reloj | Borrar R94–R99 y nets REFCLKP/N\_SL1–SL3; marcar NC en REFCLKOP/ON1–3. Cambiar R157/R158, R88–R93, R159/R160 por cables. Dejar RD81/RD82, RD5, RP87, R102. | Puertos 1–3 no existen en modo 5 puertos; HCSL directo sin stubs. |  |
| 5a | 11 Mode Sel | Straps fijos | Quitar SW2/SW3/SW4. PORTCFG[2] 5.1 kΩ a 1.8 V; PORTCFG[1:0] 330 Ω a GND; CHIPMODE[1:0] 330 Ω a GND; PM\_L11\_EN\_L 5.1 kΩ a 1.8 V. | Configuración 5 puertos fija, sin selector. |  |
| 5b | 11 Mode Sel | Pull-ups/downs obligatorios | I2C\_ADDR[2:0] 330 Ω a GND; SCL/SDA\_I2C 5.1 kΩ a 1.8 V; SHCL/SHDA/SHPCINT\_L 5.1 kΩ a 1.8 V; TEST 330 Ω a GND; PDC\_L[4:7] 330 Ω a GND; PDC\_L[0:3] NC. | Pines sin resistencia interna no pueden flotar (datasheet §3). |  |
| 5c | 11 Mode Sel | Borrar | U7 EEPROM, J2/J3, U8, U9, U10, LEDs DS6–DS14 y sus resistencias, nets PORTGOOD\_L\_LED. Ojo: U10 llevaba PERST\_L a D13; se reemplaza en fila 10b. EECK, GPIO\_26/30/31, HOT\_PLUG\_EN\_L: NC. JTAG\_SEL\_L: dejar como en el EVB. | Fuera de alcance; los pull internos dan el valor correcto. |  |
| 6 | 13 Power | Sin cambios | Mantener ferritas BD1–BD8 y desacoplo completo. | Ya cumple el datasheet; es la parte crítica de potencia. |  |
| 7a | 10 Slot 4–7 → M.2 | Borrar slots | Borrar SLOT4–SLOT7, J1, R37–R45, C74–C77, C89–C92 y nets 12V/3.3V\_SLx. | Se reemplazan por 4 sockets M.2. |  |
| 7b | 10 Slot 4–7 → M.2 | Colocar 4 M.2 M-key | J4–J7. Pines por puerto según hoja Downstream de la tabla: TX vía C78/C79, C80/C81, C93/C94, C95/C96 (220 nF) → 49/47; RX → 43/41; REFCLKP/N\_SL4–7 → 55/53; PERST#\_M2\_4–7 → 50. | Topología x1 por SSD con caps solo en TX del switch. |  |
| 7c | 10 Slot 4–7 → M.2 | Alimentación M.2 | Pines 2,4,12,14,16,18,70,72,74 → 3.3V\_SSD. GND según tabla. Por socket: 2×22 µF + 2×0.1 µF. Resto NC (52, 54, 68, 69, 40/42/44, 10). | Desacoplo local de cada SSD. |  |
| 8a | 06 ATX/Reg | Borrar | P1 (ATX), distribución 12V/3.3V\_SLx, TP, LEDs indicadores y Q1/Q2. | Ya no hay fuente ATX. |  |
| 8b | 06 ATX/Reg | U1 y U3 (0.95 V) | Split rail: VIN ← 12V\_SLOT (+4.7 µF en VIN), PVIN ← 3.3V\_SLOT. Mantener Rset 2.45 kΩ y RT 1 MΩ. | LMZ31704 necesita VIN ≥ 4.5 V; la potencia sale del 3.3 V del slot. |  |
| 8c | 06 ATX/Reg | U2 → 3.3V\_SSD | Cambiar LMZ31520 por LMZ31710 (mismo footprint que U1/U3). VIN = PVIN = 12V\_SSD\_IN; Rset ≈ 316 Ω 1 % (Vout = 0.6 × (1 + 1.43/Rset[kΩ])). | 10 A para 4 SSD desde el 12 V del slot. |  |
| 8d | 06 ATX/Reg | 12 V auxiliar opcional | PWR1 (6 pines) se queda como DNP. 0 Ω (1206) 12V\_SLOT→12V\_SSD\_IN montada; 0 Ω PWR1→12V\_SSD\_IN DNP. | Respaldo si las SSD superan el presupuesto de 25 W. |  |
| 9 | 07 LDO | Cambiar entrada | U4/U5 (AP7361C): IN ← 3.3V\_SLOT en lugar de 3.3V\_EXT. | Mismos LDO del EVB, nueva fuente. |  |
| 10a | 17 PERST → PERST | Borrar | U23 (74HC08), S2, U27, LEDs y resistencias asociadas. | Reset simple desde el host. |  |
| 10b | 17 PERST → PERST | Traductor al switch | SN74LVC1T45: VCCA 3.3V\_SLOT, VCCB 1.8V\_EXT, DIR alto. A ← CPERST\_L; B → PERST\_L (D13) + 5.1 kΩ a 1.8 V. 0.1 µF por VCC. | I/O del switch es 1.8 V (VIH máx 1.98 V). |  |
| 10c | 17 PERST → PERST | Buffer a SSD | 74LVC125A en 3.3V\_SLOT: 4 entradas ← CPERST\_L, OE# a GND, salidas → PERST#\_M2\_4…7. 0.1 µF. | Aísla el PERST# del host y da una salida por SSD. |  |
| 11 | 02, 03, 04, 05 | Actualizar diagramas | Bloques, árbol de potencia, reloj y mapeo de lanes al diseño nuevo. | Para el reporte y el video. |  |
| 12 | 01, 19 | Portada y revisión | Título: PCIe Gen3 x4 → 4× NVMe (PI7C9X3G808GP). Nota: basado en referencia Diodes V1.6. Rev 1.0. | Trazabilidad. |  |
| 13 | Todas | Verificar | Tools > Annotate (renumerar), Design Rules Check sin errores, exportar PDF a 02 Esquematico y avisarme. | Reviso el PDF contra la tabla antes de pasar a Allegro. |  |
