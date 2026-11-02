#!/usr/bin/env python3
"""Reubica partes que estorban al fanout del BGA y al corredor upstream, y coloca en bottom (bajo cada M.2)
los caps AC de TX y las 0 ohm de REFCLK. Uso: python3 replace.py place.txt evb_dump2.txt evb_dump3.txt move.il"""
import re, sys, math
PLACE, EVB2, EVB3, OUT = sys.argv[1:5]
FORCE = sys.argv[5].split(',') if len(sys.argv) > 5 else []
DY = -600.0
TOP_Y, LEN_X, BOT_Y = 4198.8, 6600.4, 247.709
ev = {}
for l in open(EVB2):
    m = re.match(r'SYM "([^"]+)" "([^"]+)" \(([-\d.]+) ([-\d.]+)\)', l)
    if m: ev[m.group(1)] = (float(m.group(3)), float(m.group(4)))
S = {}
for l in open(PLACE):
    m = re.match(r'S "([^"]+)" "([^"]+)" ([-\d.]+) ([-\d.]+) ([-\d.]+) (\S+) \(\((\S+) (\S+)\) \((\S+) (\S+)\)\) (.*)', l)
    if not m: continue
    r = m.group(1); x, y = float(m.group(3)), float(m.group(4))
    pb = [(s == 'BOTTOM',) + tuple(map(float, v)) for s, *v in
          re.findall(r'PLACE_BOUND_(TOP|BOTTOM)" \(\(([-\d.]+) ([-\d.]+)\) \(([-\d.]+) ([-\d.]+)\)', m.group(11))]
    cop = r in ev and abs(ev[r][0] - x) < .01 and (abs(ev[r][1] - y) < .01 or abs(ev[r][1] + DY - y) < .01)
    S[r] = dict(fp=m.group(2), x=x, y=y, rot=float(m.group(5)), mir=m.group(6) == 't', pb=pb, cop=cop)
# place bound ampliado con los pads (algunos footprints traen place bound mas chico que los pads)
PB = {}
for l in open(PLACE):
    if l.startswith('P '):
        r = re.findall(r'"([^"]*)"', l)[0]; b = list(map(float, re.findall(r'[-\d.]+', l.split('"')[-1])))
        if len(b) == 4: PB.setdefault(r, []).append(b)
for r, v in S.items():
    if r in PB and len(v['pb']) == 1:
        s0, *b = v['pb'][0]
        v['pb'] = [(s0, min([b[0]] + [p[0] for p in PB[r]]), min([b[1]] + [p[1] for p in PB[r]]),
                    max([b[2]] + [p[2] for p in PB[r]]), max([b[3]] + [p[3] for p in PB[r]]))]
# obstaculos del fanout copiado (en coordenadas nuevas)
X1, Y1, X2, Y2 = 1858, 1024, 2709, 1875
obst = {False: [], True: []}          # por lado: rects (bottom=True)
for l in open(EVB3):
    if l.startswith('V '):
        m = re.match(r'V "[^"]*" "[^"]*" ([-\d.]+) ([-\d.]+)', l); x, y = float(m.group(1)), float(m.group(2)) + DY
        if X1 <= x <= X2 and Y1 <= y <= Y2:
            for s in (False, True): obst[s].append((x - 10, y - 10, x + 10, y + 10))
    elif l.startswith('C '):
        m = re.match(r'C "[^"]*" "ETCH/(TOP|BOTTOM)" ([-\d.]+) "\w+" \(\(([-\d.]+) ([-\d.]+)\) \(([-\d.]+) ([-\d.]+)\)\)', l)
        if not m: continue
        xa, ya, xb, yb = float(m.group(3)), float(m.group(4)) + DY, float(m.group(5)), float(m.group(6)) + DY
        if all(X1 <= a <= X2 for a in (xa, xb)) and all(Y1 <= b <= Y2 for b in (ya, yb)):
            w = float(m.group(2)) / 2
            obst[m.group(1) == 'BOTTOM'].append((min(xa, xb) - w, min(ya, yb) - w, max(xa, xb) + w, max(ya, yb) + w))
M2 = {'J44': 3290.0, 'J45': 4235.0, 'J46': 5180.0, 'J47': 6125.0}
ZONES_TOP = [(X1, Y1, X2, Y2), (2100, 40, 3010, Y1)]                 # fanout del BGA y corredor upstream (top)
ZONES_ALL = [(2830, 240, 6600, 380)]                                 # banda de vias bajo los M.2
for xc in M2.values():
    ZONES_TOP.append((xc - 445, 1250, xc + 445, 3900))               # modulo M.2 (top)
def inter(a, b, g=0):
    return a[0] < b[2] + g and b[0] < a[2] + g and a[1] < b[3] + g and b[1] < a[3] + g
def rect(r):
    return [b[1:] for b in S[r]['pb']]
moving = set()
for r, v in S.items():
    if v['cop'] or v['fp'] in ('M2_MKEY_2280', 'PCI_EXPRESS_X4', 'HFCBGA_196_15X15') or r in ('U1', 'U2', 'U3', 'U4', 'U5', 'U10', 'U23', 'U27', 'PWR1'):
        continue
    side = v['mir']
    bad = any(inter(b, o, 6) for b in rect(r) for o in obst[side] + (obst[not side] if False else []))
    bad |= any(inter(b, z) for b in rect(r) for z in ZONES_ALL + ([] if side else ZONES_TOP))
    if bad or r in FORCE: moving.add(r)
# colocacion explicita bajo cada M.2 (bottom): caps AC TX y 0 ohm REFCLK
EXPL = {}
PORT = {'J44': ('C742', 'C741', 'R159', 'R160'), 'J45': ('C752', 'C751', 'R92', 'R93'),
        'J46': ('C762', 'C761', 'R90', 'R91'), 'J47': ('C772', 'C771', 'R89', 'R88')}
for j, (cp, cn, rp, rn) in PORT.items():
    xc = M2[j]
    EXPL[cp] = (xc - 118.0, 520.0, 270.0, True)     # PETp (pin 49 en xc-108.3)
    EXPL[cn] = (xc - 79.0, 520.0, 270.0, True)      # PETn (pin 47 en xc-88.6)
    EXPL[rp] = (xc - 197.0, 520.0, 90.0, True)     # REFCLKp (pin 55 en xc-167.3)
    EXPL[rn] = (xc - 158.0, 520.0, 90.0, True)     # REFCLKn (pin 53 en xc-147.6)
for r in EXPL: moving.discard(r)
# ocupacion actual sin las que se mueven
occ = {False: [], True: []}
for r, v in S.items():
    if r in moving or r in EXPL: continue
    for b in v['pb']: occ[b[0]].append(b[1:])
for r, (x, y, rot, mir) in EXPL.items():
    occ[mir].append((x - 14, y - 34, x + 14, y + 34))
def size(r):
    b = rect(r)[0]; return b[2] - b[0], b[3] - b[1], S[r]['x'] - (b[0] + b[2]) / 2, S[r]['y'] - (b[1] + b[3]) / 2
def ok(rc, side):
    if rc[0] < 120 or rc[2] > LEN_X - 60 or rc[1] < BOT_Y + 60 or rc[3] > TOP_Y - 60: return False
    if rc[0] < 1700 and rc[1] < 330: return False
    if any(inter(rc, z) for z in ZONES_ALL + ([] if side else ZONES_TOP)): return False
    if any(inter(rc, o, 6) for o in obst[side]): return False
    return not any(inter(rc, o, 14) for o in occ[side])
res = {}
for r in sorted(moving, key=lambda r: -size(r)[0] * size(r)[1]):
    v = S[r]; w, h, dx, dy = size(r); side = v['mir']; done = False
    for rad in range(0, 2500, 15):
        n = max(8, rad // 8)
        for k in range(n):
            a = 2 * math.pi * k / n
            cx = round((v['x'] - dx + rad * math.cos(a)) / 5) * 5; cy = round((v['y'] - dy + rad * math.sin(a)) / 5) * 5
            rc = (cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2)
            if ok(rc, side):
                res[r] = (cx + dx, cy + dy, v['rot'], side); occ[side].append(rc); done = True; break
        if done: break
    if not done: print('SIN LUGAR', r)
res.update(EXPL)
o = [';; move1.il -- generado por replace.py', 'procedure( mv_all()', '  let((n)', '    n = 0']
for r, (x, y, rot, mir) in sorted(res.items()):
    o.append('    when(l2_mv("%s" %.3f %.3f %.1f %s) n = n + 1)' % (r, x, y, rot, 't' if mir else 'nil'))
o += ['    printf("movidas %d\\n" n) n))', '']
open(OUT, 'w', newline='\r\n').write('\n'.join(o))
print('mover:', len(moving), sorted(moving)); print('explicitas:', len(EXPL))
