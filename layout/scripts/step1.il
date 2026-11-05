;; step1.il -- paso 1: limpieza de textos, vias en bolas de periferia, partes altas fuera del modulo M.2,
;; vias termicas de U1/U3 (LMZ31704, isla PH pin 42) y U2 (LMZ31530, anillo del pin 69), contorno de modulos M.2.
;; Uso (cwd = 03 Layout): skill load("scripts/layout2.il") skill load("scripts/step1.il") skill s1_go()
s1Log = nil
procedure( s1Msg(m) when(s1Log fprintf(s1Log "%s\n" m) drain(s1Log)) printf("%s\n" m))

;; 1) textos que no son REFDES
S1_TXTCLS = list("DEVICE TYPE" "COMPONENT VALUE" "TOLERANCE" "USER PART NUMBER")
procedure( s1_txtcount()
  let((tb cls)
    tb = makeTable("c" 0)
    foreach(s axlDBGetDesign()->symbols
      foreach(c s->children
        when(c->objType == "text" && stringp(c->layer)
          cls = car(parseString(c->layer "/"))
          tb[cls] = tb[cls] + 1)))
    foreach(k tb s1Msg(sprintf(nil "  texto %s: %d" k tb[k])))
    tb))
procedure( s1_texts()
  let((l cls)
    l = nil
    foreach(s axlDBGetDesign()->symbols
      foreach(c s->children
        when(c->objType == "text" && stringp(c->layer)
          cls = car(parseString(c->layer "/"))
          when(member(cls S1_TXTCLS) l = cons(c l)))))
    s1Msg(sprintf(nil "textos a borrar: %d -> %L" length(l) axlDeleteObject(l)))
    t))

;; 2) vias de fanout en bolas de periferia (senales): B1/C1 REFCLK4, H14, M14
S1_PERI = list("REFCLKOP4" "REFCLKON4" "PORTGOOD_L[7]" "I2C_ADDR1")
procedure( s1_perivias()
  let((l)
    l = nil
    foreach(n axlDBGetDesign()->nets
      when(member(n->name S1_PERI)
        foreach(b n->branches foreach(o b->children
          when(member(o->objType list("via" "path")) l = cons(o l))))))
    s1Msg(sprintf(nil "periferia: %d objetos -> %L" length(l) axlDeleteObject(l)))
    t))

;; 3) partes altas (0805 22uF, 1206) bajo el modulo M.2 -> bottom, misma posicion
S1_TALL = list("C138" "C743" "C744" "C753" "C754" "C763" "C764" "C773" "C774")
procedure( s1_tall()
  let((s n)
    n = 0
    foreach(r S1_TALL
      s = l2_find(r)
      when(s && l2_mv(r car(s->xy) cadr(s->xy) 0.0 t) n = n + 1))
    s1Msg(sprintf(nil "a bottom: %d" n))
    n))

;; 4) vias termicas
procedure( s1_pinnet(r num)
  let((s p)
    s = l2_find(r)
    p = s && car(setof(x s->pins x->number == num))
    p && p->net && p->net->name))
procedure( s1_tv(r num pts w spine)
  let((s x0 y0 net nv nc)
    s = l2_find(r)
    x0 = car(s->xy) y0 = cadr(s->xy)
    net = s1_pinnet(r num)
    nv = 0 nc = 0
    s1Msg(sprintf(nil "%s rot=%L mir=%L pin %s net=%L" r s->rotation s->isMirrored num net))
    foreach(c s->children
      when(c->objType == "shape" s1Msg(sprintf(nil "  shape %L net=%L" c->layer c->net && c->net->name))))
    when(net && s->rotation == 0.0 && !s->isMirrored
      foreach(p pts
        when(axlDBCreateVia("VIA10_20-FBD" list(x0 + nth(0 p) y0 + nth(1 p)) net) nv = nv + 1)
        when(axlDBCreatePath(axlPathStart(list(list(x0 + nth(0 p) y0 + nth(1 p)) list(x0 + nth(2 p) y0 + nth(3 p))) w) "ETCH/TOP" net) nc = nc + 1))
      when(spine
        when(axlDBCreatePath(axlPathStart(list(list(x0 + nth(0 spine) y0 + nth(1 spine)) list(x0 + nth(2 spine) y0 + nth(3 spine))) w) "ETCH/TOP" net) nc = nc + 1)))
    s1Msg(sprintf(nil "  %s: vias=%d clines=%d" r nv nc))
    nv))
S1_RVQ = list(
  list(52.854 -100.394 52.854 -125.984)
  list(22.146 -100.394 0.000 -100.394)
  list(22.146 -69.685 0.000 -69.685)
  list(22.146 -38.976 0.000 -38.976)
  list(22.146 -8.268 0.000 -8.268)
  list(22.146 22.441 0.000 22.441)
  list(22.146 53.150 0.000 53.150)
  list(-22.146 53.150 0.000 53.150)
  list(-22.146 22.441 0.000 22.441)
  list(-22.146 -8.268 0.000 -8.268)
  list(-22.146 -38.976 0.000 -38.976)
  list(-22.146 -69.685 0.000 -69.685)
  list(-22.146 -100.394 0.000 -100.394)
  list(-52.854 -100.394 -52.854 -125.984)
)
S1_RLG = list(
  list(-104.921 130.905 -74.803 102.362)
  list(-104.921 18.701 -74.803 47.244)
  list(-104.921 73.819 -74.803 73.819)
  list(-104.921 46.260 -74.803 46.260)
  list(-104.921 103.346 -74.803 103.346)
  list(42.717 130.905 42.717 102.362)
  list(-45.866 130.905 -45.866 102.362)
  list(-75.394 130.905 -75.394 102.362)
  list(-45.866 18.701 -45.866 47.244)
  list(-75.394 18.701 -75.394 47.244)
  list(-16.339 18.701 -16.339 47.244)
  list(-16.339 130.905 -16.339 102.362)
  list(74.213 130.905 74.213 102.362)
  list(13.189 130.905 13.189 102.362)
  list(72.244 18.701 72.244 47.244)
  list(13.189 18.701 13.189 47.244)
  list(42.717 18.701 42.717 47.244)
)
procedure( s1_thermal()
  s1_tv("U1" "42" S1_RVQ 15.0 list(0.0 53.150 0.0 -125.984))
  s1_tv("U3" "42" S1_RVQ 15.0 list(0.0 53.150 0.0 -125.984))
  s1_tv("U2" "69" S1_RLG 20.0 nil))

;; 5) contorno de cada modulo 2280 (documentacion, ASSEMBLY_DETAIL): 22 mm de ancho, conector -> standoff
procedure( s1_m2doc()
  let((to)
    to = make_axlTextOrientation(?textBlock "8" ?rotation 90.0 ?mirrored nil ?justify "center")
    foreach(cx list(3290.0 4235.0 5180.0 6125.0)
      axlDBCreateRectangle(list(list(cx - 433.07 745.0) list(cx + 433.07 3760.0)) nil "BOARD GEOMETRY/ASSEMBLY_DETAIL")
      axlDBCreateText("MODULO M.2 2280 - H MAX BAJO MODULO 1.0 MM" list(cx 2250.0) to "BOARD GEOMETRY/ASSEMBLY_DETAIL"))
    s1Msg("contornos M.2 en ASSEMBLY_DETAIL")
    t))

procedure( s1_go()
  when(s1Log close(s1Log))
  s1Log = outfile("step1b.log" "w")
  s1Msg("textos antes:") s1_txtcount()
  s1_texts()
  s1Msg("textos despues:") s1_txtcount()
  s1_perivias()
  s1_tall()
  s1_thermal()
  s1_m2doc()
  s1Msg(sprintf(nil "DRC=%L" axlDRCUpdate(nil)))
  s1Msg(sprintf(nil "save %L" axlSaveDesign(?noConfirm t)))
  close(s1Log) s1Log = nil
  l2_dump("place13.txt"))
