# Scripts de layout (SKILL, OrCAD X 25.1)

Se corren en Allegro con la placa abierta (cwd = `03 Layout`):

| Script | Qué hace |
|---|---|
| `evb_dump.il` → `evbDump2()` | Con `EVB_ref.brd` abierto: vuelca contorno y colocación (`evb_dump2.txt`). |
| `layout1.il` (de `gen_layout.py`) | `lay_open()`, `lay_tech()` (techfile del EVB: stackup + DIFF_85OHM), `lay_outline()` (contorno FHHL), `lay_place()` (287 partes). |

Contorno: lengüeta x4 y zona del bracket copiadas del EVB; resto CEM FHHL (111.15 × 167.65 mm). Unidades: mils, marco del EVB.

Colocación inicial: U6 en (2283.9, 1449.9) rot 180 (EVB desplazado −600 mil); 69 partes copiadas del EVB (desacoples bajo el BGA, caps AC upstream, RB2/RB4); J44–J47 rot 180 con centros en x = 3290/4235/5180/6125, fila delantera en y = 700; reguladores y lógica a mano; 203 pasivos por conectividad (anillo alrededor de su IC ancla).

## Paso 2 (layout2.il, layout3.il)
- `layout2.il`: `l2_dump(archivo)` (partes, place bounds, pines con net y padstack, marcadores DRC), `l2_mv` (mover parte),
  `l2_step2()` = regiones + pares diferenciales + net classes + DRC + dump.
  - Regiones `BGA32_BGA32` (CSet de espaciado BGA32 del EVB, 4.2 mil) sobre los campos de pines de J44–J47, U1/U3 (LMZ31704) y U6.
    Motivo: el pitch de 0.5 mm del M.2 (gap 7.7 mil) y el LMZ31704 no cumplen el DEFAULT de 9.5 mil SMD-SMD.
  - 37 pares diferenciales: TX → `DIFF_85OHM_TX`, RX → `DIFF_85OHM_RX`, REFCLK → `DIFF_85OHM`.
- `layout3.il`: `so_3()` crea el padstack `pth_m2so_2200` (taladro 2.2 mm metalizado, pad 4.4 mm) y el símbolo
  mecánico `m2_standoff` dentro de la placa, y coloca 4 standoffs 2280 en (3290/4235/5180/6125, 3716) mils.

## Paso 1 de la agenda (step1.il, cap.il)
- `step1.il` → `s1_go()`:
  - Borra los textos DEVICE TYPE / COMPONENT VALUE / TOLERANCE / USER PART NUMBER (99); quedan solo REFDES.
  - Quita las vías de fanout en bolas de periferia de señal (B1/C1 REFCLKOP4/ON4, H14, M14): salen directo en TOP.
  - Pasa a bottom las partes altas que caían bajo los módulos M.2 (C743/C744 … C773/C774 de 22 µF 0805 y C138 1206).
    Bajo el módulo (conector 4.2 mm, módulos de doble cara) solo quedan partes ≤ 1.0 mm (0402).
  - Vías térmicas (VIA10_20-FBD) según el land pattern de TI: U1/U3 (LMZ31704) 14 vías en la isla PH del pin 42;
    U2 (LMZ31530) 17 vías alrededor del pin 69 (PVIN). Unidas al pad con clines en TOP.
  - Contorno de cada módulo 2280 en BOARD GEOMETRY/ASSEMBLY_DETAIL.
- `cap.il`: `cap_vis("TOP"|"BOTTOM")` deja visibles contorno, ensamble, serigrafía, pines y cobre de una cara y hace zoom fit; `cap_all()` restaura.
- DRC tras el paso: 70 = 12 de espaciado del ruteo upstream (previos) + 58 de *same net spacing* de las vías térmicas (intencionales; se resuelven en Constraint Manager).
