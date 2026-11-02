;; layout2.il -- paso 2: dump de colocacion/pines y mover partes
procedure( l2_dump(fn)
  let((f pb d)
    f = outfile(fn "w")
    d = axlDBGetDesign()
    fprintf(f "X %L\n" d->bBox)
    foreach(s d->symbols
      when(s->refdes
        pb = nil
        foreach(c s->children
          when(c->objType != "pin" && stringp(c->layer) && rexMatchp("PLACE_BOUND" c->layer)
            pb = cons(list(c->layer c->bBox) pb)))
        fprintf(f "S %L %L %.3f %.3f %.1f %L %L %L\n" s->refdes s->name
          car(s->xy) cadr(s->xy) s->rotation s->isMirrored s->bBox pb)
        foreach(p s->pins
          fprintf(f "P %L %L %.3f %.3f %L %L %L\n" s->refdes p->number car(p->xy) cadr(p->xy)
            if(p->net && p->net->name p->net->name "") p->definition->name p->bBox))))
    errset(foreach(m d->drcs when(m->name fprintf(f "D %L %L %L\n" m->xy m->layer m->name))))
    close(f) t))

procedure( l2_find(r)
  car(setof(s axlDBGetDesign()->symbols s->refdes == r)))

;; mueve a (x y) con rotacion absoluta rot y lado mir (t = bottom)
procedure( l2_mv(r x y rot mir)
  let((s)
    s = l2_find(r)
    if(!s then printf("NO %s\n" r) nil
    else
      when(s->isMirrored != mir s = axlTransformObject(s ?mirror t ?origin s->xy))
      when(s->rotation != rot s = axlTransformObject(s ?angle rot - s->rotation ?origin s->xy))
      axlTransformObject(s ?move list(x - car(s->xy) y - cadr(s->xy))))))

l2Log = nil
procedure( l2Msg(m) when(l2Log fprintf(l2Log "%s\n" m) drain(l2Log)) printf("%s\n" m))

;; regiones de paso fino (CSet BGA32: 4.2 mil) sobre M.2, LMZ31704 y BGA
procedure( l2_regions()
  let((rg r ok)
    rg = car(axlSelectByName("REGION" "BGA32_BGA32"))
    unless(rg rg = axlRegionCreate("BGA32_BGA32"))
    l2Msg(sprintf(nil "region %L" rg))
    r = car(axlDBCreateRectangle(list(list(2837.5 357.8) list(3742.5 745.0)) nil "CONSTRAINT REGION/ALL"))
    ok = r && axlRegionAdd(rg r)
    l2Msg(sprintf(nil "reg J44 %L %L" r ok))
    r = car(axlDBCreateRectangle(list(list(3782.5 357.8) list(4687.5 745.0)) nil "CONSTRAINT REGION/ALL"))
    ok = r && axlRegionAdd(rg r)
    l2Msg(sprintf(nil "reg J45 %L %L" r ok))
    r = car(axlDBCreateRectangle(list(list(4727.5 357.8) list(5632.5 745.0)) nil "CONSTRAINT REGION/ALL"))
    ok = r && axlRegionAdd(rg r)
    l2Msg(sprintf(nil "reg J46 %L %L" r ok))
    r = car(axlDBCreateRectangle(list(list(5672.5 357.8) list(6577.5 745.0)) nil "CONSTRAINT REGION/ALL"))
    ok = r && axlRegionAdd(rg r)
    l2Msg(sprintf(nil "reg J47 %L %L" r ok))
    r = car(axlDBCreateRectangle(list(list(1376.1 2076.1) list(1823.9 2523.9)) nil "CONSTRAINT REGION/ALL"))
    ok = r && axlRegionAdd(rg r)
    l2Msg(sprintf(nil "reg U1 %L %L" r ok))
    r = car(axlDBCreateRectangle(list(list(2076.1 2076.1) list(2523.9 2523.9)) nil "CONSTRAINT REGION/ALL"))
    ok = r && axlRegionAdd(rg r)
    l2Msg(sprintf(nil "reg U3 %L %L" r ok))
    r = car(axlDBCreateRectangle(list(list(1983.0 1149.0) list(2584.8 1750.8)) nil "CONSTRAINT REGION/ALL"))
    ok = r && axlRegionAdd(rg r)
    l2Msg(sprintf(nil "reg U6 %L %L" r ok))
    t))

;; pares diferenciales y net classes
procedure( l2_dp1(cl nm p n)
  let((dp ok)
    dp = axlDiffPair(nm p n)
    unless(dp dp = car(axlSelectByName("DIFFPAIR" nm)))
    ok = dp && axlNetClassAdd(cl dp)
    l2Msg(sprintf(nil "dp %s %s/%s -> %L clase %s %L" nm p n dp cl ok))
    dp))

procedure( l2_diffpairs()
  l2_dp1("DIFF_85OHM_TX" "DP_PET0_P0" "PETP0_P0" "PETN0_P0")
  l2_dp1("DIFF_85OHM_TX" "DP_PET0_UP" "PETP0_RECEPT" "PETN0_RECEPT")
  l2_dp1("DIFF_85OHM_TX" "DP_PET1_P0" "PETP1_P0" "PETN1_P0")
  l2_dp1("DIFF_85OHM_TX" "DP_PET1_UP" "PETP1_RECEPT" "PETN1_RECEPT")
  l2_dp1("DIFF_85OHM_TX" "DP_PET2_P0" "PETP2_P0" "PETN2_P0")
  l2_dp1("DIFF_85OHM_TX" "DP_PET2_UP" "PETP2_RECEPT" "PETN2_RECEPT")
  l2_dp1("DIFF_85OHM_TX" "DP_PET3_P0" "PETP3_P0" "PETN3_P0")
  l2_dp1("DIFF_85OHM_TX" "DP_PET3_UP" "PETP3_RECEPT" "PETN3_RECEPT")
  l2_dp1("DIFF_85OHM_TX" "DP_PET4_M2" "PETP4_M2" "PETN4_M2")
  l2_dp1("DIFF_85OHM_TX" "DP_PET4_SSD" "PETP4_RECEPT" "PETN4_RECEPT")
  l2_dp1("DIFF_85OHM_TX" "DP_PET5_M2" "PETP5_M2" "PETN5_M2")
  l2_dp1("DIFF_85OHM_TX" "DP_PET5_SSD" "PETP5_RECEPT" "PETN5_RECEPT")
  l2_dp1("DIFF_85OHM_TX" "DP_PET6_M2" "PETP6_M2" "PETN6_M2")
  l2_dp1("DIFF_85OHM_TX" "DP_PET6_SSD" "PETP6_RECEPT" "PETN6_RECEPT")
  l2_dp1("DIFF_85OHM_TX" "DP_PET7_M2" "PETP7_M2" "PETN7_M2")
  l2_dp1("DIFF_85OHM_TX" "DP_PET7_SSD" "PETP7_RECEPT" "PETN7_RECEPT")
  l2_dp1("DIFF_85OHM_RX" "DP_PER0" "PERP0_RECEPT" "PERN0_RECEPT")
  l2_dp1("DIFF_85OHM_RX" "DP_PER1" "PERP1_RECEPT" "PERN1_RECEPT")
  l2_dp1("DIFF_85OHM_RX" "DP_PER2" "PERP2_RECEPT" "PERN2_RECEPT")
  l2_dp1("DIFF_85OHM_RX" "DP_PER3" "PERP3_RECEPT" "PERN3_RECEPT")
  l2_dp1("DIFF_85OHM_RX" "DP_PER4" "PERP4_RECEPT" "PERN4_RECEPT")
  l2_dp1("DIFF_85OHM_RX" "DP_PER5" "PERP5_RECEPT" "PERN5_RECEPT")
  l2_dp1("DIFF_85OHM_RX" "DP_PER6" "PERP6_RECEPT" "PERN6_RECEPT")
  l2_dp1("DIFF_85OHM_RX" "DP_PER7" "PERP7_RECEPT" "PERN7_RECEPT")
  l2_dp1("DIFF_85OHM" "DP_CREFCLK" "CREFCLKP" "CREFCLKN")
  l2_dp1("DIFF_85OHM" "DP_REFCLKI_R" "REFCLKIP_R" "REFCLKIN_R")
  l2_dp1("DIFF_85OHM" "DP_REFCLKO0" "REFCLKOP0" "REFCLKON0")
  l2_dp1("DIFF_85OHM" "DP_REFCLK_PHY0" "REFCLKOP_PHY0" "REFCLKON_PHY0")
  l2_dp1("DIFF_85OHM" "DP_REFCLK_PHY1" "REFCLKOP_PHY1" "REFCLKON_PHY1")
  l2_dp1("DIFF_85OHM" "DP_REFCLKO4" "REFCLKOP4" "REFCLKON4")
  l2_dp1("DIFF_85OHM" "DP_REFCLK_SL4" "REFCLKP_SL4" "REFCLKN_SL4")
  l2_dp1("DIFF_85OHM" "DP_REFCLKO5" "REFCLKOP5" "REFCLKON5")
  l2_dp1("DIFF_85OHM" "DP_REFCLK_SL5" "REFCLKP_SL5" "REFCLKN_SL5")
  l2_dp1("DIFF_85OHM" "DP_REFCLKO6" "REFCLKOP6" "REFCLKON6")
  l2_dp1("DIFF_85OHM" "DP_REFCLK_SL6" "REFCLKP_SL6" "REFCLKN_SL6")
  l2_dp1("DIFF_85OHM" "DP_REFCLKO7" "REFCLKOP7" "REFCLKON7")
  l2_dp1("DIFF_85OHM" "DP_REFCLK_SL7" "REFCLKP_SL7" "REFCLKN_SL7")
  t)

procedure( l2_step2()
  l2Log = outfile("l2.log" "w")
  l2_regions()
  l2_diffpairs()
  l2Msg(sprintf(nil "DRC=%L" axlDRCUpdate(nil)))
  close(l2Log) l2Log = nil
  l2_dump("place3.txt"))

procedure( l2_step2b()
  l2Log = outfile("l2.log" "a")
  l2_regions()
  l2Msg(sprintf(nil "DRC=%L" axlDRCUpdate(nil)))
  close(l2Log) l2Log = nil
  l2_dump("place3.txt"))

;; desacoples bajo el BGA: footprint C0402_BGA (como en el EVB) via ALT_SYMBOLS
L2_BGACAPS = list("C120" "C121" "C122" "C125" "C126" "C128" "C129" "C130" "C133" "C134" "C136" "C137" "C140"
  "C141" "C142" "C143" "C147" "C148" "C149" "C151" "C152" "C153" "C154" "C156" "C157" "C158" "C159" "C161"
  "C162" "C164" "C165" "C166" "C167")
procedure( l2_bgacaps()
  let((s cd ok n)
    n = 0
    l2Log = outfile("l2c.log" "w")
    foreach(r L2_BGACAPS
      s = l2_find(r)
      cd = s && s->component && s->component->compdef
      when(cd && !axlAltSymbolList(cd 'bottom)
        l2Msg(sprintf(nil "prop %L %L" cd->name axlDBAddProp(cd list("ALT_SYMBOLS" "(T:C0402_BGA;B:C0402_BGA)")))))
      ok = s && axlAltSymbolReplace(r "C0402_BGA")
      when(ok n = n + 1)
      l2Msg(sprintf(nil "alt %s %L" r ok)))
    l2Msg(sprintf(nil "reemplazadas %d  DRC=%L" n axlDRCUpdate(nil)))
    close(l2Log) l2Log = nil
    l2_dump("place6.txt")
    n))
