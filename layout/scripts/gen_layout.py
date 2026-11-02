#!/usr/bin/env python3
"""Genera layout1.il: techfile, contorno FHHL y colocación inicial (mils, marco del EVB).
Uso: python3 gen_layout.py <allegro_dir> <evb_dump2.txt> <salida.il>
"""
import re, sys, math, collections

ALLEGRO, EVBDUMP, OUT = sys.argv[1:4]

# ------------------------------------------------------------ datos
def load_netlist():
    pr = open(ALLEGRO + '/pstxprt.dat', errors='replace').read()
    chip = open(ALLEGRO + '/pstchip.dat', errors='replace').read()
    dev2jed = {}
    for b in re.split(r'\nprimitive ', chip):
        m = re.search(r"JEDEC_TYPE='([^']+)'", b)
        if m:
            dev2jed[b.split('\n')[0].strip().strip("';")] = m.group(1).upper()
    pkg = {r: dev2jed.get(d, '?') for r, d in re.findall(r"PART_NAME\s*\n\s*(\S+)\s+'([^']+)'", pr)}
    t = open(ALLEGRO + '/pstxnet.dat', errors='replace').read()
    nets = {}
    for blk in t.split('NET_NAME')[1:]:
        name = re.search(r"'([^']*)'", blk).group(1)
        nets[name] = re.findall(r"NODE_NAME\s+(\S+)\s+(\S+)", blk)
    return pkg, nets

def load_evb():
    ev = {}
    for l in open(EVBDUMP):
        m = re.match(r'SYM "([^"]+)" "([^"]+)" \(([-\d.]+) ([-\d.]+)\) ([-\d.]+) (\S+)', l)
        if m:
            ev[m.group(1)] = (m.group(2).upper(), float(m.group(3)), float(m.group(4)),
                              float(m.group(5)), m.group(6) == 't')
    return ev

PKG, NETS = load_netlist()
EV = load_evb()

# ------------------------------------------------------------ contorno (EVB entre x=0 y 3122; resto CEM FHHL)
TOP_Y = -177.169 + 111.15 / 0.0254          # 111.15 mm desde el fondo de los dedos
LEN_X = 167.65 / 0.0254                     # 167.65 mm
BOT_Y = 247.709                             # borde inferior fuera de la lengüeta (igual que el EVB)
semi = [(1627.858, 254.52), (1629.551, 267.811), (1633.681, 280.559), (1640.098, 292.319), (1648.591, 302.689),
        (1658.85, 311.311), (1670.531, 317.87), (1683.228, 322.161), (1696.5, 324.02), (1709.882, 323.382),
        (1722.921, 320.28), (1735.15, 314.811), (1746.161, 307.169), (1755.571, 297.63), (1763.039, 286.5),
        (1768.319, 274.189), (1771.22, 261.11)]
key = [(2212.74, 120.161), (2215.051, 129.531), (2219.681, 138.0), (2226.319, 145.02), (2234.531, 150.098),
       (2243.76, 152.921), (2253.409, 153.28), (2262.831, 151.169), (2271.402, 146.728), (2278.559, 140.24),
       (2283.811, 132.142), (2286.831, 122.969)]
OUTLINE = ([(0, 0), (590.551, 0), (590.551, 324.799), (1312.988, 324.799), (1312.988, 0), (1627.949, 0),
            (1627.949, BOT_Y)] + semi +
           [(1771.65, BOT_Y), (1771.65, -177.169), (2212.598, -177.169), (2212.598, 113.331)] + key +
           [(2287.402, 113.331), (2287.402, -177.169), (3122.048, -177.169), (3122.048, BOT_Y),
            (LEN_X, BOT_Y), (LEN_X, TOP_Y), (0, TOP_Y), (0, 0)])

# ------------------------------------------------------------ colocación fija
place = {}            # refdes -> (x, y, rot, mirror)
U6_EVB = EV['U6']
U6 = (2283.866, 1449.866)
DY = U6[1] - U6_EVB[2]
place['U6'] = (U6[0], U6[1], 180.0, False)
place['P2'] = (EV['P2'][1], EV['P2'][2], 0.0, False)
M2_Y = 700.0
M2_XC = {'J44': 3290.0, 'J45': 4235.0, 'J46': 5180.0, 'J47': 6125.0}
for r, xc in M2_XC.items():
    place[r] = (xc - 9.25 / 0.0254, M2_Y, 180.0, False)   # origen = pin 75; centro local x=-9.25 mm
place['U2'] = (750.0, 1250.0, 0.0, False)       # LMZ31530 (3.3V_EXT)
place['U1'] = (1600.0, 2300.0, 0.0, False)      # LMZ31704
place['U3'] = (2300.0, 2300.0, 0.0, False)      # LMZ31704
place['U4'] = (1450.0, 1300.0, 0.0, False)      # AP7361C
place['U5'] = (1450.0, 1050.0, 0.0, False)      # AP7361C
place['U10'] = (1950.0, 700.0, 0.0, False)      # PI4ULS5V108
place['U23'] = (2650.0, 3200.0, 0.0, False)     # 74HC08 (PERST a las M.2)
place['U27'] = (2650.0, 3650.0, 0.0, False)
place['PWR1'] = (600.0, TOP_Y - 13.9 / 0.0254 - 20, 0.0, False)

# copiar del EVB: alrededor del switch (mismo desplazamiento) y zona de los dedos (posición exacta)
copied = []
for r, (sym, x, y, rot, mir) in EV.items():
    if r in place or r not in PKG or PKG[r] != sym.replace('_BGA', ''):
        continue
    if math.hypot(x - U6_EVB[1], y - U6_EVB[2]) < 900:
        place[r] = (x, y + DY, rot, mir); copied.append(r)
    elif y < 500:
        place[r] = (x, y, rot, mir); copied.append(r)

# ------------------------------------------------------------ tamaños (mils, con margen)
SZ = {'R0402': (95, 60), 'C0402': (95, 60), 'C0603': (120, 75), 'C0805': (145, 90), 'C1206': (185, 110),
      'L1812': (230, 150), '7_3X4_3X2_8': (340, 185), 'LED-0805': (145, 90), 'TESTPIN25': (75, 75),
      'SOT23SGD_T': (125, 125), 'SOT143': (125, 125), 'HFCBGA_196_15X15': (620, 620),
      'QFN72-16R15X15R15-_8': (650, 690), 'B3QFN-42': (445, 445), 'DFN8-0303-_65': (160, 140),
      'TSSOP20-6_5-_65': (295, 275), 'SO14-6-1_27': (295, 365)}

def rect_of(r, x, y, rot):
    p = PKG[r]
    if p == 'M2_MKEY_2280':
        return (x + 364 - 445, y - 340, x + 364 + 445, y + 45)
    if p == '455580003':
        return (x - 305, y - 295, x + 635, y + 550)
    if p == 'PCI_EXPRESS_X4':
        return (1771, -177, 3122, BOT_Y)
    w, h = SZ.get(p, (100, 100))
    if rot in (90.0, 270.0):
        w, h = h, w
    return (x - w / 2, y - h / 2, x + w / 2, y + h / 2)

occ = {False: [], True: []}        # por lado (mirror)
for r, (x, y, rot, mir) in place.items():
    occ[mir].append(rect_of(r, x, y, rot))
    if PKG[r] in ('HFCBGA_196_15X15',):       # bajo el BGA no van partes de top
        pass
for r, xc in M2_XC.items():                     # módulo 2280 (deja libre la zona junto al conector)
    occ[False].append((xc - 445, 1250, xc + 445, M2_Y + 3200))

def free(rc, side):
    x1, y1, x2, y2 = rc
    if x1 < 150 or x2 > LEN_X - 60 or y1 < BOT_Y + 60 or y2 > TOP_Y - 60:
        return False
    if x1 < 1700 and y1 < 330:                  # zona del bracket / ranura
        return False
    for a in occ[side]:
        if not (x2 + 10 < a[0] or x1 - 10 > a[2] or y2 + 10 < a[1] or y1 - 10 > a[3]):
            return False
    return True

# ------------------------------------------------------------ anclas por conectividad
part_nets = collections.defaultdict(set)
for n, nodes in NETS.items():
    for r, p in nodes:
        part_nets[r].add(n)
ANCHORS = [r for r in place if r.startswith(('U', 'J', 'P'))]

PRIO = ['U6', 'U1', 'U3', 'U2', 'U4', 'U5', 'U10', 'U23', 'U27', 'J44', 'J45', 'J46', 'J47', 'PWR1', 'P2']

def anchor_of(r):
    m = re.match(r'C7([4-7])\d$', r)
    if m:
        return 'J4' + m.group(1)
    score = collections.Counter()
    for n in part_nets[r]:
        if n in ('GND', 'GND_SIGNAL') or not NETS[n]:
            continue
        refs = {a for a, _ in NETS[n]}
        for a in refs & set(ANCHORS):
            score[a] += 1.0 / len(NETS[n])
    if score:
        return max(score, key=lambda a: (round(score[a], 6), -PRIO.index(a) if a in PRIO else -99))
    for n in part_nets[r]:                      # 2 saltos
        for a, _ in NETS[n]:
            if a != r and a in place:
                return a
    for n in sorted(part_nets[r]):
        for a, _ in sorted(NETS[n]):
            if a != r and a in place:
                return a
    return 'U6'

auto = []
todo = sorted([r for r in PKG if r not in place], key=lambda r: (-len(part_nets[r]), r))
ANCHORS.sort()
for r in todo:
    a = anchor_of(r)
    ax, ay = place[a][0], place[a][1]
    if PKG[a] == 'M2_MKEY_2280':
        ax, ay = ax + 364, ay + 300           # delante del conector
    w, h = SZ.get(PKG[r], (100, 100))
    done = False
    for rad in range(0, 3000, 25):
        for k in range(max(8, rad // 10)):
            ang = 2 * math.pi * k / max(8, rad // 10)
            x = round((ax + rad * math.cos(ang)) / 5) * 5
            y = round((ay + rad * math.sin(ang)) / 5) * 5
            rc = (x - w / 2, y - h / 2, x + w / 2, y + h / 2)
            if free(rc, False):
                place[r] = (float(x), float(y), 0.0, False); occ[False].append(rc); auto.append((r, a))
                done = True
                break
        if done:
            break
    if not done:
        print('SIN LUGAR', r)

# ------------------------------------------------------------ SKILL
def f(v):
    return '%.3f' % v

o = [';; layout1.il -- generado por gen_layout.py',
     'lyLog = nil',
     'procedure( lyMsg(m) when(lyLog fprintf(lyLog "%s\\n" m) drain(lyLog)) printf("%s\\n" m))',
     '',
     'procedure( lay_open() axlOpenDesign(?design "pcie_switch_4xnvme.brd" ?mode "wf"))',
     '',
     'procedure( lay_tech()',
     '  axlRunBatchDBProgram("techfile" "techfile -r -q EVB_ref_tech.tcfx %s" ?logfile "techfile_in" ?reloadDB t))',
     '',
     'procedure( lay_outline()',
     '  let((p r)',
     '    axlDBChangeDesignExtents(list(list(-1500.0 -1500.0) list(8000.0 5500.0)))',
     '    p = axlPathStart(list(%s) 0.0)' % ' '.join('list(%s %s)' % (f(x), f(y)) for x, y in OUTLINE),
     '    r = axlDBCreateShape(p nil "BOARD GEOMETRY/DESIGN_OUTLINE")',
     '    unless(r r = axlDBCreateShape(p nil "BOARD GEOMETRY/OUTLINE"))',
     '    printf("outline: %L\\n" r)',
     '    r))',
     '',
     'procedure( lay_place()',
     '  let((n bad)',
     '    n = 0 bad = 0',
     '    lyLog = outfile("layout1.log" "w")']
for r, (x, y, rot, mir) in sorted(place.items()):
    o.append('    if(axlDBCreateSymbol("%s" list(%s %s) %s %s) then n = n + 1 '
             'else bad = bad + 1 lyMsg("FALLO %s"))' % (r, f(x), f(y), 't' if mir else 'nil', f(rot), r))
o += ['    lyMsg(sprintf(nil "colocadas=%d fallos=%d" n bad))',
      '    close(lyLog) lyLog = nil',
      '    list(n bad)))', '']
open(OUT, 'w', newline='\r\n').write('\n'.join(o))
print('fijas+copiadas:', len(place) - len(auto), 'copiadas EVB:', len(copied), 'auto:', len(auto),
      'total:', len(place), 'de', len(PKG))
cnt = collections.Counter(a for _, a in auto)
print('anclas auto:', dict(cnt))
print('TOP_Y %.1f LEN_X %.1f' % (TOP_Y, LEN_X))
