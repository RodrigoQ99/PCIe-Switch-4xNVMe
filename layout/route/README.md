# Ruteo (paso 2)

Se corren en Allegro con la placa abierta (cwd = `03 Layout`), copiando los `.il` a `03 Layout\scripts`.

| Archivo | Qué hace |
|---|---|
| `evb_fanout.py` → `fanout.il` | Copia el fanout del BGA del EVB (`evb_dump3.txt`, de `evbDump3()` en `scripts/evb_dump.il`) con dy = −600 mil: 129 vías y 765 segmentos, solo nets que existen en la placa nueva (mapeo 0.9V→0.95V, CLKBUF_PHY→REFCLKO*_PHY, REFCLKI*_C→_R, HP_PDC→PDC). `fo_clear()` borra todas las clines/vías. |
| `replace.py` → `move1.il`, `move2.il` | Saca del fanout y del corredor upstream las partes autocolocadas que estorban, y coloca en bottom bajo cada M.2 los caps AC de TX (C7x1/C7x2) y las 0 Ω de REFCLK (R88–R93, R159/R160). |

Notas:
- Los 33 desacoples bajo el BGA usan `C0402_BGA` (padstack `0402SHAPE`), como en el EVB (`l2_bgacaps()` en `scripts/layout2.il`, vía ALT_SYMBOLS).
- Región `BGA32_BGA32` ampliada a toda la zona del fanout (1858,1024)–(2709,1875).
- Tras `axlAltSymbolReplace` o `axlDRCUpdate`, guardar antes de leer `->symbols`/`->drcs` (las listas quedan viejas).
- Abrir otra placa: escribir `open <archivo>.brd` en la línea de comandos (axlOpenDesign con "wf" pregunta "Overwrite?" y con No no abre).
