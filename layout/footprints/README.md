# Footprints generados por SKILL

`gen_fp.py` lee el netlist (`pstchip.dat`) para verificar números de pin y genera `fp_gen.il`.

Uso en OrCAD X PCB (Allegro), con `03 Layout\lib\fp_blank.dra` abierto (package symbol, mm, acc. 4):

```
skill load("../scripts/fp_gen.il")
skill fp_all()
```

Crea `.dra`, `.psm` y `.pad` en `03 Layout\lib` y escribe `fp_gen.log`.

| Footprint (netrev) | Fuente de geometría |
|---|---|
| SO14-6-1_27, TSSOP20-6_5-_65, L1812, 7_3X4_3X2_8 | KiCad (IPC-7351B nominal) |
| DFN8-0303-_65 | Diodes AP02001, U-DFN3030-8 Type E (EP = pin 9) |
| 455580003 | Molex Mini-Fit Jr 5569-06A1 R/A (misma familia); pines con padstack del EVB `pad100cir70ds105`. DNP: verificar numeración contra SD-45558 |
| B3QFN-42, QFN72-16R15X15R15-_8, M2_MKEY_2280 | Ultra Librarian (KiCad), convertidos con el mismo generador |
