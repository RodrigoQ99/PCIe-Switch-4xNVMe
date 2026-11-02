#!/usr/bin/env python3
"""Genera fp_gen.il (SKILL de OrCAD X / Allegro) con los footprints que faltan.

Fuentes de geometría:
  - KiCad (IPC-7351B nominal): SOIC-14, TSSOP-20, 1812, 7343 (Kemet D), Molex Mini-Fit Jr 2x3 R/A.
  - Diodes AP02001 (U-DFN3030-8 Type E) para el AP7361C.
  - Archivos KiCad descargados por el usuario (LMZ31704, LMZ31530, M.2) cuando estén en ./kicad.
Uso: python3 gen_fp.py <pstchip.dat> <salida.il>
"""
import re, sys, os, json

HERE = os.path.dirname(os.path.abspath(__file__))
MASK = 0.05          # expansión de máscara por lado (mm)

# ---------------------------------------------------------------- s-expr KiCad
def sexpr(txt):
    tok = re.findall(r'\(|\)|"(?:\\.|[^"])*"|[^\s()]+', txt)
    st, cur = [], []
    for t in tok:
        if t == '(':
            st.append(cur); cur = []
        elif t == ')':
            done = cur; cur = st.pop(); cur.append(done)
        else:
            cur.append(t.strip('"'))
    return cur[0]

def find(node, key):
    return [n for n in node if isinstance(n, list) and n and n[0] == key]

def one(node, key):
    r = find(node, key)
    return r[0] if r else None

def r4(v):
    return round(float(v) + 0.0, 4)

class FP:
    def __init__(self, name, height=None):
        self.name = name          # nombre exacto del netrev
        self.pads = []            # (num|None, x, y, rot, ps)
        self.ps = {}              # nombre -> spec
        self.lines = []           # (layer, [(x,y)...], width)
        self.polys = []           # (layer, [(x,y)...]) rellenos
        self.bound = None
        self.ref = (0.0, 0.0)
        self.notes = []

    def smd(self, w, h, fig='RECTANGLE', paste=1.0, mask=True):
        w, h = r4(w), r4(h)
        if fig == 'RECTANGLE' and abs(w - h) < 1e-6:
            fig = 'SQUARE'
        tag = {'RECTANGLE': 'r', 'SQUARE': 's', 'CIRCLE': 'c',
               'OBLONG_X': 'o', 'OBLONG_Y': 'o'}[fig]
        nm = 'smd_%s%dx%d' % (tag, round(w * 1000), round(h * 1000))
        if paste != 1.0:
            nm += 'p%02d' % round(paste * 100)
        if not mask:
            nm += 'nm'
        self.ps[nm] = dict(kind='smd', w=w, h=h, fig=fig, paste=paste, mask=mask)
        return nm

    def npth(self, d):
        nm = 'npth_%d' % round(d * 1000)
        self.ps[nm] = dict(kind='npth', d=r4(d))
        return nm

    def existing(self, nm):
        self.ps[nm] = dict(kind='lib')
        return nm

    def pin(self, num, x, y, ps, rot=0.0):
        self.pads.append((num, r4(x), r4(y), float(rot), ps))

def from_kicad(path, name, th_padstack=None, drop_th=False, renum=None):
    k = sexpr(open(path).read())
    fp = FP(name)
    for p in find(k, 'pad'):
        num, typ, shape = p[1], p[2], p[3]
        at = one(p, 'at'); size = one(p, 'size')
        x, y = float(at[1]), -float(at[2])            # KiCad y hacia abajo
        rot = float(at[3]) if len(at) > 3 else 0.0
        w, h = float(size[1]), float(size[2])
        layers = one(p, 'layers')[1:]
        if typ == 'smd':
            fig = {'rect': 'RECTANGLE', 'roundrect': 'RECTANGLE', 'circle': 'CIRCLE',
                   'oval': 'OBLONG_X' if w >= h else 'OBLONG_Y'}.get(shape)
            if fig is None:
                raise SystemExit('%s: forma de pad no soportada: %s' % (name, shape))
            ps = fp.smd(w, h, fig, 1.0 if 'F.Paste' in layers else 0.0, 'F.Mask' in layers)
        elif typ == 'np_thru_hole':
            ps = fp.npth(float(one(p, 'drill')[1]))
            num = None
        else:  # thru_hole
            if drop_th:
                continue        # vías térmicas del fabricante: se ponen en el layout
            if not th_padstack:
                raise SystemExit('%s: pad TH sin padstack asignado' % name)
            ps = fp.existing(th_padstack)
        if renum and num in renum:
            num = renum[num]
        fp.pin(num if num else None, x, y, ps, rot)
    crt = []
    for ln in find(k, 'fp_line'):
        lay = one(ln, 'layer')[1]
        s, e = one(ln, 'start'), one(ln, 'end')
        pts = [(r4(s[1]), r4(-float(s[2]))), (r4(e[1]), r4(-float(e[2])))]
        wd = one(ln, 'width') or one(one(ln, 'stroke') or [], 'width')
        wd = float(wd[1]) if wd else 0.12
        if lay == 'F.SilkS':
            fp.lines.append(('PACKAGE GEOMETRY/SILKSCREEN_TOP', pts, 0.12))
        elif lay == 'F.Fab':
            fp.lines.append(('PACKAGE GEOMETRY/ASSEMBLY_TOP', pts, 0.0))
        elif lay == 'F.CrtYd':
            crt += pts
    for rc in find(k, 'fp_rect'):
        lay = one(rc, 'layer')[1]
        s, e = one(rc, 'start'), one(rc, 'end')
        x1, y1, x2, y2 = r4(s[1]), r4(-float(s[2])), r4(e[1]), r4(-float(e[2]))
        pts = [(x1, y1), (x2, y1), (x2, y2), (x1, y2), (x1, y1)]
        if lay == 'F.SilkS':
            fp.lines.append(('PACKAGE GEOMETRY/SILKSCREEN_TOP', pts, 0.12))
        elif lay == 'F.Fab':
            fp.lines.append(('PACKAGE GEOMETRY/ASSEMBLY_TOP', pts, 0.0))
        elif lay == 'F.CrtYd':
            crt += pts
    polymap = {'F.Cu': 'ETCH/TOP', 'F.Mask': 'PACKAGE GEOMETRY/SOLDERMASK_TOP',
               'F.Paste': 'PACKAGE GEOMETRY/PASTEMASK_TOP'}
    for g in find(k, 'fp_poly'):
        lay = one(g, 'layer')[1]
        if lay in polymap:
            pts = [(r4(q[1]), r4(-float(q[2]))) for q in one(g, 'pts')[1:]]
            if pts[0] != pts[-1]:
                pts.append(pts[0])
            fp.polys.append((polymap[lay], pts))
    if crt:
        xs = [p[0] for p in crt]; ys = [p[1] for p in crt]
        fp.bound = (min(xs), min(ys), max(xs), max(ys))
    else:   # sin courtyard: caja de pads + ensamble + 0.25 mm
        xs, ys = [], []
        for num, x, y, rot, ps in fp.pads:
            sp = fp.ps[ps]; w = sp.get('w', sp.get('d', 0)); h = sp.get('h', sp.get('d', 0))
            if rot in (90.0, 270.0, -90.0):
                w, h = h, w
            xs += [x - w / 2, x + w / 2]; ys += [y - h / 2, y + h / 2]
        for lay, pts, w in fp.lines:
            if lay.endswith('ASSEMBLY_TOP'):
                xs += [p[0] for p in pts]; ys += [p[1] for p in pts]
        fp.bound = (round(min(xs) - 0.25, 3), round(min(ys) - 0.25, 3),
                    round(max(xs) + 0.25, 3), round(max(ys) + 0.25, 3))
    for t in find(k, 'fp_text'):
        if t[1] == 'reference':
            at = one(t, 'at'); fp.ref = (r4(at[1]), r4(-float(at[2])))
    return fp

# ---------------------------------------------------------------- footprints a mano
def dfn8_ap7361c():
    """U-DFN3030-8 Type E, Diodes AP02001 Rev.52: C=0.65, C1=2.35, X=0.30, Y=0.65, Y1=1.60, Y2=2.75.
    Columnas de pines a ±Y2/2; pin 1 arriba-izquierda, 1-4 bajan, 5-8 suben; pin 9 = EP."""
    fp = FP('DFN8-0303-_65')
    ps = fp.smd(0.65, 0.30)
    xs = 2.75 / 2
    for i in range(4):
        y = 0.975 - 0.65 * i
        fp.pin(str(1 + i), -xs, y, ps)
        fp.pin(str(8 - i), xs, y, ps)
    ep = fp.smd(1.60, 2.35, paste=0.8)
    fp.pin('9', 0.0, 0.0, ep)
    b = 1.5
    fp.lines += [('PACKAGE GEOMETRY/ASSEMBLY_TOP', [(-b, b), (b, b), (b, -b), (-b, -b), (-b, b)], 0.0),
                 ('PACKAGE GEOMETRY/SILKSCREEN_TOP', [(-0.9, 1.62), (0.9, 1.62)], 0.12),
                 ('PACKAGE GEOMETRY/SILKSCREEN_TOP', [(-0.9, -1.62), (0.9, -1.62)], 0.12),
                 ('PACKAGE GEOMETRY/SILKSCREEN_TOP', [(-2.05, 1.55), (-2.05, 1.25)], 0.12)]
    fp.bound = (-2.0, -1.75, 2.0, 1.75)
    fp.ref = (0.0, 2.3)
    return fp

def build_all():
    kd = os.path.join(HERE, 'kicad')
    fps = []
    fps.append(from_kicad(os.path.join(kd, 'SOIC-14_3.9x8.7mm_P1.27mm.kicad_mod'), 'SO14-6-1_27'))
    fps.append(from_kicad(os.path.join(kd, 'TSSOP-20_4.4x6.5mm_P0.65mm.kicad_mod'), 'TSSOP20-6_5-_65'))
    fps.append(from_kicad(os.path.join(kd, 'L_1812_4532Metric.kicad_mod'), 'L1812'))
    fps.append(from_kicad(os.path.join(kd, 'CP_EIA-7343-31_Kemet-D.kicad_mod'), '7_3X4_3X2_8'))
    fps.append(dfn8_ap7361c())
    m = from_kicad(os.path.join(kd, 'Molex_Mini-Fit_Jr_5569-06A1_2x03_P4.20mm_Horizontal.kicad_mod'),
                   '455580003', th_padstack='pad100cir70ds105')
    m.notes.append('Geometria Mini-Fit Jr 5569-06A1 R/A (misma familia que 45558-0003); DNP.')
    fps.append(m)
    ul = os.path.join(HERE, 'ul')
    a = from_kicad(os.path.join(ul, 'RVQ0042A.kicad_mod'), 'B3QFN-42', drop_th=True)
    a.notes.append('UL RVQ0042A; isla PH (pin 42) como ETCH/TOP; vias termicas en layout.')
    fps.append(a)
    b = from_kicad(os.path.join(ul, 'RLG0072A.kicad_mod'), 'QFN72-16R15X15R15-_8', drop_th=True)
    b.notes.append('UL RLG0072A; vias termicas en layout.')
    fps.append(b)
    c = from_kicad(os.path.join(ul, 'CONN67_2199230_TEC.kicad_mod'), 'M2_MKEY_2280', renum={'77': None})
    dummy = c.smd(0.2, 0.2, 'CIRCLE', paste=0.0, mask=False)
    for n in range(59, 67):        # llave M: sin contacto; pads de relleno tapados con mascara
        x = -18.5 + 0.25 * (n - 1)
        y = 7.55 if n % 2 else 0.0   # impares en la fila de 1/75 (y=-7.55 en KiCad)
        c.pin(str(n), x, y, dummy)
    c.notes.append('UL TE 1-2199230-6; 76 = aleta (sin net), 77 mecanica, 59-66 relleno.')
    fps.append(c)
    return fps

# ---------------------------------------------------------------- verificación de pines
def required_pins(pstchip):
    t = open(pstchip, errors='replace').read()
    req = {}
    for b in re.split(r'\nprimitive ', t):
        m = re.search(r"JEDEC_TYPE='([^']+)'", b)
        if not m:
            continue
        nums = set()
        for p in re.findall(r"PIN_NUMBER='\(([^)]*)\)'", b):
            nums |= {n.strip() for n in p.split(',') if n.strip() and n.strip() != '0'}
        req.setdefault(m.group(1).upper(), set()).update(nums)
    return req

# ---------------------------------------------------------------- SKILL
HDR = r''';; fp_gen.il  --  generado por gen_fp.py (no editar a mano)
;; Uso (Allegro, con fp_blank.dra abierto en 03 Layout\lib):
;;   skill load("../scripts/fp_gen.il")
;;   skill fp_all()
fpLogPort = nil
fpErrs = 0
procedure( fpLog(msg)
  when(fpLogPort fprintf(fpLogPort "%s\n" msg) drain(fpLogPort))
  printf("%s\n" msg))
procedure( fpErr(msg) fpErrs = fpErrs + 1 fpLog(strcat("  ERROR: " msg)))
procedure( fpTxt(tb) make_axlTextOrientation(?textBlock tb ?rotation 0.0 ?mirrored nil ?justify "center"))

procedure( fpBegin(name)
  let((u)
    fpErrs = 0
    fpLog(strcat("== " name))
    unless(axlOpenDesign(?design "fp_blank.dra" ?mode "wf") fpErr("no abre fp_blank.dra"))
    axlSetSymbolType("package")
    u = axlDBGetDesignUnits()
    when(listp(u) u = car(u))
    when(stringp(u) u = lowerCase(u))
    unless(u == "millimeters"
      unless(axlDBChangeDesignUnits("millimeters" 4)
        unless(axlDBChangeDesignUnits("millimeters" nil) fpErr("no cambia unidades a mm"))))
    fpLog(sprintf(nil "  unidades: %L" axlDBGetDesignUnits()))
    unless(axlDBChangeDesignExtents(list(list(-120.0 -120.0) list(120.0 120.0))) fpErr("extents"))))

procedure( fpSMD(name fig w h pw ph masked)
  let((pads r)
    pads = list(make_axlPadStackPad(?layer "TOP" ?type 'REGULAR ?figure fig ?figureSize list(w h)))
    when(masked
      pads = cons(make_axlPadStackPad(?layer "SOLDERMASK_TOP" ?type 'REGULAR ?figure fig
                    ?figureSize list(w+2*__MASK__ h+2*__MASK__)) pads))
    when(pw > 0.0
      pads = cons(make_axlPadStackPad(?layer "PASTEMASK_TOP" ?type 'REGULAR ?figure fig
                    ?figureSize list(pw ph)) pads))
    r = axlDBCreatePadStack(name nil pads t)
    unless(r fpErr(strcat("padstack " name)))
    r))

procedure( fpNPTH(name d)
  let((dr pads r)
    dr = make_axlPadStackDrill(?holeType 'CIRCLE_DRILL ?drillDiameter d ?plating 'NON_PLATED
                               ?figure 'CIRCLE ?figureSize list(d d) ?drillChar "N")
    pads = list(make_axlPadStackPad(?layer "SOLDERMASK_TOP" ?type 'REGULAR ?figure 'CIRCLE ?figureSize list(d+0.2 d+0.2))
                make_axlPadStackPad(?layer "SOLDERMASK_BOTTOM" ?type 'REGULAR ?figure 'CIRCLE ?figureSize list(d+0.2 d+0.2)))
    r = axlDBCreatePadStack(name dr pads t)
    unless(r fpErr(strcat("padstack " name)))
    r))

procedure( fpPin(ps x y num rot)
  let((pt r)
    pt = if(num make_axlPinText(?number num ?offset list(0.0 0.0) ?text fpTxt(1)) nil)
    r = axlDBCreatePin(ps list(x y) pt rot)
    unless(r fpErr(sprintf(nil "pin %L en %L %L" num x y)))
    r))

procedure( fpPoly(layer pts)
  let((p)
    p = axlPathStart(pts 0.0)
    unless(p && axlDBCreateShape(p t layer) fpErr(strcat("shape " layer)))))

procedure( fpLine(layer pts w)
  unless(axlDBCreateLine(pts w layer) fpErr(strcat("linea " layer))))

procedure( fpEnd(name ref x1 y1 x2 y2 pss)
  let((s c)
    unless(axlDBCreateRectangle(list(list(x1 y1) list(x2 y2)) t "PACKAGE GEOMETRY/PLACE_BOUND_TOP")
      fpErr("place bound"))
    unless(axlDBCreateText(ref list(0.0 0.0) fpTxt(2) "REF DES/ASSEMBLY_TOP") fpErr("refdes asm"))
    s = axlSaveDesign(?design name ?noConfirm t)
    c = axlCompileSymbol(?symbol name ?silent t ?silentOnOverwrite t)
    foreach(p pss unless(axlPadstackToDisk(p) fpErr(strcat("pad a disco " p))))
    fpLog(sprintf(nil "  save=%L psm=%L errores=%d" s c fpErrs))))
'''

def fmt(v):
    t = ('%.4f' % float(v)).rstrip('0')
    return t + '0' if t.endswith('.') else t

def skill_fp(fp, fn):
    o = ['procedure( %s()' % fn, '  fpBegin("%s")' % fp.name.lower()]
    created = []
    for nm, s in fp.ps.items():
        if s['kind'] == 'smd':
            f = s['paste']
            pw, ph = s['w'] * f, s['h'] * f
            o.append('  fpSMD("%s" \'%s %s %s %s %s %s)' % (nm, s['fig'], fmt(s['w']), fmt(s['h']),
                                                       fmt(pw), fmt(ph), 't' if s['mask'] else 'nil'))
            created.append(nm)
        elif s['kind'] == 'npth':
            o.append('  fpNPTH("%s" %s)' % (nm, fmt(s['d'])))
            created.append(nm)
    for num, x, y, rot, ps in fp.pads:
        o.append('  fpPin("%s" %s %s %s %s)' % (ps, fmt(x), fmt(y), '"%s"' % num if num else 'nil', fmt(rot)))
    for lay, pts, w in fp.lines:
        o.append('  fpLine("%s" list(%s) %s)' % (lay, ' '.join('list(%s %s)' % (fmt(a), fmt(b)) for a, b in pts), fmt(w)))
    for lay, pts in fp.polys:
        o.append('  fpPoly("%s" list(%s))' % (lay, ' '.join('list(%s %s)' % (fmt(a), fmt(b)) for a, b in pts)))
    o.append('  axlDBCreateText("%s" list(%s %s) fpTxt(2) "REF DES/SILKSCREEN_TOP")' % (
        'U*', fmt(fp.ref[0]), fmt(fp.ref[1])))
    x1, y1, x2, y2 = fp.bound
    o.append('  fpEnd("%s" "U*" %s %s %s %s list(%s)))' % (fp.name.lower(), fmt(x1), fmt(y1), fmt(x2), fmt(y2),
                                                         ' '.join('"%s"' % c for c in created)))
    return '\n'.join(o)

def main():
    pst, out = sys.argv[1], sys.argv[2]
    req = required_pins(pst)
    fps = build_all()
    body, calls, ok = [HDR.replace('__MASK__', str(MASK))], [], True
    for i, fp in enumerate(fps):
        have = {p[0] for p in fp.pads if p[0]}
        need = req.get(fp.name.upper())
        if need is None:
            print('AVISO %s: no aparece en pstchip' % fp.name)
        elif have != need:
            ok = False
            print('ERROR %s: faltan %s / sobran %s' % (fp.name, sorted(need - have), sorted(have - need)))
        fn = 'fp_%d' % i
        body.append(skill_fp(fp, fn))
        calls.append(fn)
        print('%-22s pines=%-3d padstacks=%s %s' % (fp.name, len(have), ','.join(fp.ps), ' '.join(fp.notes)))
    body.append('procedure( fp_all()\n  fpLogPort = outfile("fp_gen.log" "w")\n'
                + '\n'.join('  unless(errset(%s() t) fpLog("  FALLO SKILL en %s"))' % (c, c) for c in calls)
                + '\n  fpLog("fin")\n  close(fpLogPort) fpLogPort = nil\n  axlOpenDesign(?design "fp_blank.dra" ?mode "wf"))\n')
    open(out, 'w', newline='\r\n').write('\n\n'.join(body))
    print('OK' if ok else 'HAY ERRORES DE PINES', '->', out)

if __name__ == '__main__':
    main()
