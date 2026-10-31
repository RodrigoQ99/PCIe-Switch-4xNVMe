# Decisiones de diseño

## Topología
- Switch PCIe Gen3 PI7C9X3G808GP (Diodes/Pericom) en modo de 5 puertos.
- Lanes 0–3 → puerto P0, upstream x4, directo a los gold fingers.
- Lanes 4–7 → puertos P4–P7, cada uno x1, a cuatro M.2 M-key 2280 (J44–J47).
- Se quitaron los signal switches del EVB (U12–U17) y los slots S1–S3. Las lanes van directas: menos pérdida y menos discontinuidades.

## Alta velocidad
- Caps AC de 220 nF solo en la transmisión del switch hacia cada SSD (C7x1/C7x2). El host y el SSD ya traen los suyos.
- REFCLK: el host entra al buffer integrado del switch; REFCLKOP4–7 van a los pines 55/53 de cada M.2. Sin buffer externo.
- En el M.2 solo se usa la lane 0. CLKREQ#, PEWAKE#, SMBus, SUSCLK, PEDET y LED quedan sin conectar.
- PERST#: se reutiliza el circuito del EVB; PERST4_L y PERST#_SL5–7 van al pin 50 de cada M.2.

## Potencia
- 12 V del slot (B1–B3, A2, A3) → 12VCC_EXT. 3.3 V del slot (B8, A9, A10) → 3.3V_SLOT.
- U2/U3 (LMZ31704, 0.95 V para el núcleo): VIN de 12 V y PVIN de 3.3V_SLOT.
- U1 (LMZ31530): 3.3V_EXT desde 12 V para las SSD, los LDO y la lógica.
- Se quitó el conector ATX. PWR2 (6 pines) queda como entrada auxiliar opcional.
- Presupuesto del slot x4: 25 W (3.3 V ≤ 3 A, 12 V ≤ 2.1 A), suponiendo 4 W por SSD.
- Desacople por M.2: 2 × 22 µF + 2 × 0.1 µF en 3.3V_EXT.

## Configuración (straps)
PORTCFG = 100, CKMODE = 0, CHIPMODE = 00, PM_L11_EN_L = 1, CLKBUF_INPUT_SEL = 1.

## Reglas de PCB (tomadas del EVB)
- 6 capas, 61.6 mil (≈1.57 mm): TOP / GND02 / ART03 / ART04 / PWR05 / BOTTOM.
- 85 Ω diferencial: TOP/BOTTOM 5.4 mil de ancho y 5.6 mil de separación; capas internas 5.2 / 6.8 mil.
- Match dentro del par ≤ 5 mil, vía de tierra en cada cambio de capa, caps AC simétricos, no cruzar cortes de plano, plano vaciado bajo los gold fingers.
- Tarjeta full-height half-length (111.15 × 167.65 mm) con los M.2 a lo largo.

## Netlist
- El switch venía de dos versiones del símbolo del EVB: la sección B salía del paquete `PI7C9X3G808GP_19` (V1.5) y las demás del `_17` (V01). El netlist fallaba por eso.
- Se agregó la propiedad `Device = PI7C9X3G808GP` a las cuatro secciones y se renombraron en la sección B los pines `TEST` → `NC` (J4) y `PDC_n_L` → `HP_PDC_n_L`, para que coincidan con el `_17`. Los números de pin no cambian.
