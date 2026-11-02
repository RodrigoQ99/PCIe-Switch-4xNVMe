#!/usr/bin/env python3
"""Copia el fanout del BGA (U6) del EVB a la placa nueva (desplazamiento DY = -600 mil).
Uso: python3 evb_fanout.py evb_dump3.txt place4.txt fanout.il
Solo objetos con ambos extremos dentro del BGA + margen y con net equivalente en la placa nueva."""
import re, sys
EVB, PLACE, OUT = sys.argv[1:4]
DY = -600.0
X1, Y1, X2, Y2 = 1988 - 130, 1754 - 130, 2579 + 130, 2345 + 130          # coordenadas del EVB
MAP = {'0.9VDDC': '0.95VDDC', '0.9VP': '0.95VP', '0.9C_VDDC': '0.95C_VDDC',
       'CLKBUFP_PHY0': 'REFCLKOP_PHY0', 'CLKBUFN_PHY0': 'REFCLKON_PHY0',
       'CLKBUFP_PHY1': 'REFCLKOP_PHY1', 'CLKBUFN_PHY1': 'REFCLKON_PHY1',
       'REFCLKIP_C': 'REFCLKIP_R', 'REFCLKIN_C': 'REFCLKIN_R'}
MAP.update({'HP_PDC_L_%d' % i: 'PDC_L_%d' % i for i in range(8)})
ours = {re.findall(r'"([^"]*)"', l)[2] for l in open(PLACE) if l.startswith('P ')} - {''}
inr = lambda x, y: X1 <= x <= X2 and Y1 <= y <= Y2
o = [';; fanout.il -- generado por evb_fanout.py (fanout del BGA copiado del EVB, dy = -600)',
     'procedure( fo_all()', '  let((nv nc)', '    nv = 0 nc = 0']
nv = nc = 0; skip = set()
for l in open(EVB):
    if l.startswith('V '):
        m = re.match(r'V "([^"]*)" "([^"]*)" ([-\d.]+) ([-\d.]+)', l)
        n, ps, x, y = m.group(1), m.group(2), float(m.group(3)), float(m.group(4))
        if not inr(x, y): continue
        n = MAP.get(n, n)
        if n not in ours: skip.add(n); continue
        o.append('    when(axlDBCreateVia("%s" list(%.3f %.3f) "%s") nv = nv + 1)' % (ps, x, y + DY, n)); nv += 1
    elif l.startswith('C '):
        m = re.match(r'C "([^"]*)" "([^"]*)" ([-\d.]+) "(\w+)" \(\(([-\d.]+) ([-\d.]+)\) \(([-\d.]+) ([-\d.]+)\)\)', l)
        n, ly, w = m.group(1), m.group(2), float(m.group(3))
        xa, ya, xb, yb = map(float, m.groups()[4:])
        if not (inr(xa, ya) and inr(xb, yb)): continue
        n = MAP.get(n, n)
        if n not in ours: skip.add(n); continue
        o.append('    when(axlDBCreatePath(axlPathStart(list(list(%.3f %.3f) list(%.3f %.3f)) %.3f) "%s" "%s") nc = nc + 1)'
                 % (xa, ya + DY, xb, yb + DY, w, ly, n)); nc += 1
o += ['    printf("fanout: vias=%d segs=%d\\n" nv nc)', '    list(nv nc)))', '',
      ';; borra TODAS las clines y vias de la placa (deshacer)',
      'procedure( fo_clear()',
      '  let((l)',
      '    l = nil',
      '    foreach(n axlDBGetDesign()->nets foreach(b n->branches foreach(o b->children',
      '      when(member(o->objType list("via" "path")) l = cons(o l)))))',
      '    printf("borrando %d\\n" length(l))',
      '    axlDeleteObject(l)))', '']
open(OUT, 'w', newline='\r\n').write('\n'.join(o))
print('vias', nv, 'segs', nc, 'nets omitidas', len(skip))
