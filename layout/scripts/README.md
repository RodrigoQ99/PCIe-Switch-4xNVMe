# Scripts de layout (SKILL, OrCAD X 25.1)

Se corren en Allegro con la placa abierta (cwd = `03 Layout`):

| Script | Qué hace |
|---|---|
| `evb_dump.il` → `evbDump2()` | Con `EVB_ref.brd` abierto: vuelca contorno y colocación (`evb_dump2.txt`). |
| `layout1.il` (de `gen_layout.py`) | `lay_open()`, `lay_tech()` (techfile del EVB: stackup + DIFF_85OHM), `lay_outline()` (contorno FHHL), `lay_place()` (287 partes). |

Contorno: lengüeta x4 y zona del bracket copiadas del EVB; resto CEM FHHL (111.15 × 167.65 mm). Unidades: mils, marco del EVB.

Colocación inicial: U6 en (2283.9, 1449.9) rot 180 (EVB desplazado −600 mil); 69 partes copiadas del EVB (desacoples bajo el BGA, caps AC upstream, RB2/RB4); J44–J47 rot 180 con centros en x = 3290/4235/5180/6125, fila delantera en y = 700; reguladores y lógica a mano; 203 pasivos por conectividad (anillo alrededor de su IC ancla).
