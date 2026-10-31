# Tabla de conexiones v1 — Proyecto Final SWITCH
Copia de: 02 Esquematico\Tabla_conexiones_v1.xlsx (2026-10-28). El xlsx es la versión de trabajo.

## Upstream x4
| Upstream x4: gold fingers → U6 (puerto P0, lanes 0–3) | | Unnamed: 2 | | Unnamed: 4 | | Unnamed: 6 | | Unnamed: 8 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Nombres del gold finger según CEM (perspectiva del host): B = host TX, A = host RX. Fuente: datasheet Rev 6 §3.1 y EVB hojas 8 y 12. |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |
| Lane | Dirección | Señal switch | Bola U6 | Net (EVB) | Cap AC 220 nF (ref. EVB) | Pin gold finger | Nombre pin (CEM) | Notas |
| 0 | TX + (switch → host) | PETP0 | E10 | PETp0\_RECEPT | C46 | A16 | PERp0 | Directo (igual que EVB). |
| 0 | TX − (switch → host) | PETN0 | D10 | PETn0\_RECEPT | C47 | A17 | PERn0 |  |
| 0 | RX + (host → switch) | PERP0 | B10 | PERp0\_RECEPT | — (cap en el host) | B14 | PETp0 |  |
| 0 | RX − (host → switch) | PERN0 | A10 | PERn0\_RECEPT | — (cap en el host) | B15 | PETn0 |  |
| 1 | TX + (switch → host) | PETP1 | E9 | PETp1\_RECEPT | C48 | A21 | PERp1 | Directo (EVB: pasaba por U12/U13/U16, se eliminan). |
| 1 | TX − (switch → host) | PETN1 | D9 | PETn1\_RECEPT | C49 | A22 | PERn1 |  |
| 1 | RX + (host → switch) | PERP1 | B9 | PERp1\_RECEPT | — (cap en el host) | B19 | PETp1 |  |
| 1 | RX − (host → switch) | PERN1 | A9 | PERn1\_RECEPT | — (cap en el host) | B20 | PETn1 |  |
| 2 | TX + (switch → host) | PETP2 | E7 | PETp2\_RECEPT | C50 | A25 | PERp2 | Directo (EVB: pasaba por U12/U13/U16, se eliminan). |
| 2 | TX − (switch → host) | PETN2 | D7 | PETn2\_RECEPT | C51 | A26 | PERn2 |  |
| 2 | RX + (host → switch) | PERP2 | B7 | PERp2\_RECEPT | — (cap en el host) | B23 | PETp2 |  |
| 2 | RX − (host → switch) | PERN2 | A7 | PERn2\_RECEPT | — (cap en el host) | B24 | PETn2 |  |
| 3 | TX + (switch → host) | PETP3 | E6 | PETp3\_RECEPT | C55 | A29 | PERp3 | Directo (EVB: pasaba por U12/U13/U16, se eliminan). |
| 3 | TX − (switch → host) | PETN3 | D6 | PETn3\_RECEPT | C56 | A30 | PERn3 |  |
| 3 | RX + (host → switch) | PERP3 | B6 | PERp3\_RECEPT | — (cap en el host) | B27 | PETp3 |  |
| 3 | RX − (host → switch) | PERN3 | A6 | PERn3\_RECEPT | — (cap en el host) | B28 | PETn3 |  |

## Downstream 4x1
| Downstream 4×x1: U6 (P4–P7) → 4 × M.2 M-key | | Unnamed: 2 | | Unnamed: 4 | | Unnamed: 6 | | Unnamed: 8 | | Unnamed: 10 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Modo 5 puertos: lane 4→P4, 5→P5, 6→P6, 7→P7 (datasheet Tabla 5-4). Pines M.2 con nombre del lado del host: 47/49 = host TX. Verificar que el símbolo del conector use esa convención. |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |
| Puerto | Lane | Conector | Dirección | Señal switch | Bola U6 | Serie (ref. EVB) | Pin M.2 | Nombre pin M.2 | Ref. EVB (slot) | Notas |
| P4 | 4 | J4 (M.2 M-key) | TX + (switch → SSD) | PETP4 | K6 | C78 220 nF | 49 | PETp0 | S4 B14 | Directo (igual que EVB). |
| P4 | 4 | J4 (M.2 M-key) | TX − (switch → SSD) | PETN4 | L6 | C79 220 nF | 47 | PETn0 | S4 B15 |  |
| P4 | 4 | J4 (M.2 M-key) | RX + (SSD → switch) | PERP4 | N6 | — (cap en la SSD) | 43 | PERp0 | S4 A16 |  |
| P4 | 4 | J4 (M.2 M-key) | RX − (SSD → switch) | PERN4 | P6 | — (cap en la SSD) | 41 | PERn0 | S4 A17 |  |
| P4 | 4 | J4 (M.2 M-key) | REFCLK + (switch → SSD) | REFCLKOP4 | B1 | R159 0 Ω (opcional) | 55 | REFCLKp | S4 A13 | HCSL, DC. Buffer integrado. |
| P4 | 4 | J4 (M.2 M-key) | REFCLK − (switch → SSD) | REFCLKON4 | C1 | R160 0 Ω (opcional) | 53 | REFCLKn | S4 A14 |  |
| P5 | 5 | J5 (M.2 M-key) | TX + (switch → SSD) | PETP5 | K7 | C80 220 nF | 49 | PETp0 | S5 B14 | Directo (EVB: pasaba por switch de señal, se elimina). |
| P5 | 5 | J5 (M.2 M-key) | TX − (switch → SSD) | PETN5 | L7 | C81 220 nF | 47 | PETn0 | S5 B15 |  |
| P5 | 5 | J5 (M.2 M-key) | RX + (SSD → switch) | PERP5 | N7 | — (cap en la SSD) | 43 | PERp0 | S5 A16 |  |
| P5 | 5 | J5 (M.2 M-key) | RX − (SSD → switch) | PERN5 | P7 | — (cap en la SSD) | 41 | PERn0 | S5 A17 |  |
| P5 | 5 | J5 (M.2 M-key) | REFCLK + (switch → SSD) | REFCLKOP5 | D3 | R92 0 Ω (opcional) | 55 | REFCLKp | S5 A13 | HCSL, DC. Buffer integrado. |
| P5 | 5 | J5 (M.2 M-key) | REFCLK − (switch → SSD) | REFCLKON5 | D2 | R93 0 Ω (opcional) | 53 | REFCLKn | S5 A14 |  |
| P6 | 6 | J6 (M.2 M-key) | TX + (switch → SSD) | PETP6 | K9 | C93 220 nF | 49 | PETp0 | S6 B14 | Directo (EVB: pasaba por switch de señal, se elimina). |
| P6 | 6 | J6 (M.2 M-key) | TX − (switch → SSD) | PETN6 | L9 | C94 220 nF | 47 | PETn0 | S6 B15 |  |
| P6 | 6 | J6 (M.2 M-key) | RX + (SSD → switch) | PERP6 | N9 | — (cap en la SSD) | 43 | PERp0 | S6 A16 |  |
| P6 | 6 | J6 (M.2 M-key) | RX − (SSD → switch) | PERN6 | P9 | — (cap en la SSD) | 41 | PERn0 | S6 A17 |  |
| P6 | 6 | J6 (M.2 M-key) | REFCLK + (switch → SSD) | REFCLKOP6 | D1 | R90 0 Ω (opcional) | 55 | REFCLKp | S6 A13 | HCSL, DC. Buffer integrado. |
| P6 | 6 | J6 (M.2 M-key) | REFCLK − (switch → SSD) | REFCLKON6 | E1 | R91 0 Ω (opcional) | 53 | REFCLKn | S6 A14 |  |
| P7 | 7 | J7 (M.2 M-key) | TX + (switch → SSD) | PETP7 | K10 | C95 220 nF | 49 | PETp0 | S7 B14 | Directo (EVB: pasaba por switch de señal, se elimina). |
| P7 | 7 | J7 (M.2 M-key) | TX − (switch → SSD) | PETN7 | L10 | C96 220 nF | 47 | PETn0 | S7 B15 |  |
| P7 | 7 | J7 (M.2 M-key) | RX + (SSD → switch) | PERP7 | N10 | — (cap en la SSD) | 43 | PERp0 | S7 A16 |  |
| P7 | 7 | J7 (M.2 M-key) | RX − (SSD → switch) | PERN7 | P10 | — (cap en la SSD) | 41 | PERn0 | S7 A17 |  |
| P7 | 7 | J7 (M.2 M-key) | REFCLK + (switch → SSD) | REFCLKOP7 | F2 | R89 0 Ω (opcional) | 55 | REFCLKp | S7 A13 | HCSL, DC. Buffer integrado. |
| P7 | 7 | J7 (M.2 M-key) | REFCLK − (switch → SSD) | REFCLKON7 | F1 | R88 0 Ω (opcional) | 53 | REFCLKn | S7 A14 |  |

## REFCLK
| Reloj de referencia (100 MHz) | | Unnamed: 2 | | Unnamed: 4 |
| --- | --- | --- | --- | --- |
| Fuente: datasheet §3.4 y §5.2; EVB hoja 15. Nota: el diagrama de bloques del EVB menciona U20 (LMK00338), pero el circuito real usa el buffer integrado. |  |  |  |  |
|  |  |  |  |  |
| Señal | Bola U6 | Conexión | Componente (ref. EVB) | Por qué |
| REFCLK+ host (gold finger A13) | A4 (REFCLKIP) | Gold finger A13 → REFCLKIP | RB2 0 Ω (opcional) | Entrada del buffer integrado. HCSL, DC. Sin terminación en la tarjeta (CEM). |
| REFCLK− host (gold finger A14) | A3 (REFCLKIN) | Gold finger A14 → REFCLKIN | RB4 0 Ω (opcional) |  |
| REFCLKOP0 | A2 | → REFCLKP0 (B8) | R157 0 Ω | Reloj del PHY (lanes 0–7) desde la salida 0 del buffer. Modo BASE. |
| REFCLKON0 | A1 | → REFCLKN0 (A8) | R158 0 Ω |  |
| REFCLKP1 | N8 | 330 Ω a GND | RD81 | CKMODE = 0: segunda entrada sin usar (checklist). |
| REFCLKN1 | P8 | 330 Ω a GND | RD82 |  |
| REFCLKOP/ON1 | B4 / B3 | NC | — | P1 no existe en modo 5 puertos. |
| REFCLKOP/ON2 | C5 / C4 | NC | — | P2 no existe en modo 5 puertos. |
| REFCLKOP/ON3 | C3 / C2 | NC | — | P3 no existe en modo 5 puertos. |
| REFCLKOP/ON4–7 | ver hoja Downstream | → M.2 pines 55/53 | R159/R160, R92/R93, R90/R91, R89/R88 (0 Ω) | Un reloj por SSD. |
| CLKBUF\_INPUT\_SEL | L3 | 5.1 kΩ a 1.8 V | RP87 | Buffer toma el reloj externo (host). |
| CKMODE | E12 | 330 Ω a GND | RD5 | Modo BASE: un solo reloj para las 8 lanes. |
| CKBUFPD\_L (GPIO26) | G2 | NC | — | Pull-up interno: buffer habilitado. No poner pull-down. |

## Straps y sideband
| Straps y sideband mínimos para arrancar | | Unnamed: 2 | | Unnamed: 4 | |
| --- | --- | --- | --- | --- | --- |
| Pull-ups a 1.8 V (VDDR). Fuente: datasheet §3.2–3.6 y Schematic Checklist V1.9. |  |  |  |  |  |
|  |  |  |  |  |  |
| Señal | Bola U6 / pin | Conexión | Valor | Ref. EVB | Por qué |
| PORTCFG[2] | D12 | Pull-up a 1.8 V | 5.1 kΩ | Hoja 11 | PORTCFG = 100 → 5 puertos. Sin resistencia interna: no puede quedar NC. |
| PORTCFG[1] | C11 | Pull-down | 330 Ω | Hoja 11 |  |
| PORTCFG[0] | B12 | Pull-down | 330 Ω | Hoja 11 |  |
| CHIPMODE[1:0] | G11 / F11 | Pull-down | 330 Ω c/u | Hoja 11 | Modo Normal (00). |
| INTA\_L / PM\_L11\_EN\_L | H4 | Pull-up a 1.8 V | 5.1 kΩ | Hoja 11 | L1.1 apagado: CLKREQ# no se usa y los relojes quedan siempre activos. Sin resistencia interna. |
| RESREF | E8 | A GND | 200 Ω 1 % 100 ppm/°C | R102 | Calibra las terminaciones TX/RX. |
| TEST | J4 | A GND | 330 Ω | Hoja 11 | Requerido por datasheet. |
| PDC\_L[4] / [5] / [6] / [7] | N13 / N12 / M11 / N4 | Pull-down | 330 Ω c/u | — | M.2 no tiene PRSNT#. Checklist: pull-down en conexión directa. |
| PERST\_L | D13 | PERST# host (A11, 3.3 V) → SN74LVC1T45 (A 3.3 V → B 1.8 V) + pull-up 5.1 kΩ a 1.8 V | 5.1 kΩ | Hojas 11 y 17 | I/O de 1.8 V (VIH máx 1.98 V): no acepta 3.3 V directo. |
| PERST# M.2 (×4) | Pin 50 de J4–J7 | PERST# host (A11) → 74LVC125A (4 buffers, 3.3 V) → 1 salida por SSD | — | Hoja 17 (74HC08) | Reset de las SSD a 3.3 V. |
| I2C\_ADDR[2:0] | M12 / M14 / L12 | Pull-down | 330 Ω c/u | Hoja 11 | No pueden quedar flotando aunque no se use I2C. |
| SCL\_I2C / SDA\_I2C | L14 / L13 | Pull-up a 1.8 V | 5.1 kΩ c/u | Hoja 11 | Open-drain: requieren pull-up. |
| SHCL\_I2C / SHDA\_I2C / SHPCINT\_L | P4 / P3 / P1 | Pull-up a 1.8 V | 5.1 kΩ c/u | Hoja 11 | Hot plug serial no implementado. |
| SMBUS\_EN\_L, HOT\_PLUG\_EN\_L, SURPRISE\_HP, PHY\_SRAM\_BYPASS, EECK | K8, G4, E3, E4, K13 | NC | — | — | Pull interno da el valor por defecto correcto. |
| EEPROM (EEDI, EEDO, EECS\_L), JTAG (TCK, TDI, TDO, TMS, TRST\_L), GPIO, PORTGOOD\_L | varios | NC | — | — | Fuera de alcance. JTAG\_SEL\_L (A14): revisar hoja 11 antes de dejar NC. |
| Gold finger PRSNT1# ↔ PRSNT2# | A1 ↔ B31 | Puente | — | Hoja 8 | Indica al host una tarjeta x4. |
| Gold finger WAKE#, SMBus, JTAG, 3.3Vaux | B11, B5/B6, A5–A8/B9, B10 | NC | — | Hoja 8 |  |
| M.2 CLKREQ#, PEWAKE#, SUSCLK, PEDET, SMBus, DAS/DSS | 52, 54, 68, 69, 40/42/44, 10 | NC | — | — | L1.1 apagado; sin gestión. |
| M.2 GND | 1,3,9,15,21,27,33,39,45,51,57,71,73,75 | GND | — | — |  |
| M.2 3.3 V | 2,4,12,14,16,18,70,72,74 | 3.3V\_SSD | — | — | Ver hoja Potencia. |

## Potencia
| Rieles de potencia del switch y de las SSD | | Unnamed: 2 | | Unnamed: 4 | | Unnamed: 6 | | Unnamed: 8 | | Unnamed: 10 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Corrientes: datasheet Tabla 12-13 (8 lanes a 8 GT/s). Ruido: Tabla 12-2. Desacoplo y ferritas: EVB hoja 13. |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |
| Riel | Tensión (V) | Bolas U6 | I típ. 80 °C (A) | I máx. 125 °C (A) | P típ. (W) | P máx. (W) | Fuente propuesta | Ferrita (EVB) | Desacoplo (EVB) | Ruido máx. p-p |
| VDDC (núcleo) | 0.95 | F6,F8,G7,G9,H6,H8,J7,J9 | 2 | 3.07 | 1.9 | 2.9165 | LMZ31704 (split rail: VIN = 12 V slot, PVIN = 3.3 V slot), Rset 2.45 kΩ, RT 1 MΩ | BD1 HI1812V101R-10 | 4×10 µF, 4×4.7 µF, 8×0.1 µF | 5 % |
| VP (PCIe analógico) | 0.95 | F10,G5,H10,J5 | 0.52 | 0.57 | 0.494 | 0.5415 | LMZ31704 propio (igual que VDDC, separado) | BD4 | 2×47 µF, 2×10 µF, 2×4.7 µF, 4×0.1 µF (+2×100 µF opc.) | 5 % |
| C\_VDDC (reloj) | 0.95 | E5 | 0.06 | 0.06 | 0.057 | 0.057 | LDO 3.3→0.95 V (AP7361C) | BD3 | 10 µF, 4.7 µF, 0.1 µF | 5 % |
| VDDR (I/O) | 1.8 | D4,D11,L4,L11 | 0.04 | 0.04 | 0.072 | 0.072 | LDO 3.3→1.8 V (AP7361C) | BD6 | 2×47 µF, 2×10 µF, 2×4.7 µF, 4×0.1 µF | 3 % |
| C\_VDDR (reloj) | 1.8 | A5 | 0.06 | 0.06 | 0.108 | 0.108 | Mismo LDO 1.8 V | BD7 | 10 µF, 4.7 µF, 0.1 µF | 3 % |
| VPH (PCIe analógico HV) | 1.8 | D8,L8 | 0.15 | 0.16 | 0.27 | 0.288 | Mismo LDO 1.8 V | BD8 | 47 µF, 10 µF, 4.7 µF, 2×0.1 µF | 3 % |
| Total switch |  |  |  |  | 2.901 | 3.983 |  |  |  |  |
| VSS: A11,B2,B5,B11,C6–C10,C13,D5,E2,E11,F5,F7,F9,F13,G6,G8,G10,H2,H5,H7,H9,J6,J8,J10,J13,K5,K11,L2,L5,M6–M10,M13,N5,N11,P2,P5,P11 (43 bolas) |  |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |
| Presupuesto del slot PCIe x4 |  |  |  |  |  |  |  |  |  |  |
| Eficiencia supuesta de reguladores | 0.85 | Supuesto (bucks típicos). Ajustar con el regulador elegido. |  |  |  |  |  |  |  |  |
| Potencia por SSD (W) | 4 | Supuesto: SSD NVMe Gen3 con link x1 (~1 GB/s). Ajustar con la SSD real. |  |  |  |  |  |  |  |  |
| Número de SSD | 4 | Del objetivo del proyecto. |  |  |  |  |  |  |  |  |
| Corriente 3.3 V del slot (A) | 1.419964 | Switch alimentado del 3.3 V del slot (peor caso 125 °C). |  |  |  |  |  |  |  |  |
| Límite 3.3 V del slot (A) | 3 | PCIe CEM, tarjeta x4. |  |  |  |  |  |  |  |  |
| Corriente 12 V del slot (A) | 1.568627 | SSD: LMZ31710 12→3.3 V (10 A). Si excede: conector 12 V auxiliar opcional (DNP). |  |  |  |  |  |  |  |  |
| Límite 12 V del slot (A) | 2.1 | PCIe CEM, tarjeta x4. |  |  |  |  |  |  |  |  |
| Potencia total de la tarjeta (W) | 23.509412 |  |  |  |  |  |  |  |  |  |
| Límite total tarjeta x4 (W) | 25 | PCIe CEM, tarjeta x4. |  |  |  |  |  |  |  |  |
| Veredicto | OK |  |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |  |  |
| Celdas amarillas = supuestos que debes ajustar. Azul = datos de entrada; negro = fórmulas. |  |  |  |  |  |  |  |  |  |  |

## Notas
| Reglas que salen de esta tabla | | Unnamed: 2 |
| --- | --- | --- |
|  |  |  |
|  |  |  |
| # | Regla | Fuente |
| 1 | Caps AC de 220 nF solo en TX del switch, juntos (misma posición en P y N), sin escalonar. | Checklist V1.9 |
| 2 | Lane reversal automático dentro del puerto; la inversión de polaridad P/N la corrige el link al entrenar. | Datasheet §5.1.4 |
| 3 | REFCLK es HCSL y va en DC (sin caps). Las 0 Ω del EVB se pueden quitar para evitar stubs. | Datasheet §3.4; EVB hoja 15 |
| 4 | Pines M.2 con nombre del lado del host: 47/49 = TX del switch, 41/43 = RX del switch. Hay librerías que lo nombran al revés. | M.2 Key M (pares compartidos con SATA A/B) |
| 5 | Todas las I/O del switch son de 1.8 V: PERST# y cualquier señal de 3.3 V necesitan traductor. | Datasheet Tabla 12-2 |
| 6 | Ruido p-p máximo: <5 % en rieles de 0.95 V y <3 % en rieles de 1.8 V. | Datasheet Tabla 12-2 |
| 7 | Secuencia: rieles y REFCLK estables, luego PERST# alto (≥100 µs después). | Datasheet §10 |
