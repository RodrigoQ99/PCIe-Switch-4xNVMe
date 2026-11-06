;; diag.il -- vuelca constraints (csets, net classes, vias) a diag.txt
procedure( dg_go()
  let((f d)
    f = outfile("diag.txt" "w")
    foreach(dom list('physical 'spacing 'sameNet 'electrical)
      fprintf(f "DOM %L %L\n" dom axlCnsList(dom)))
    foreach(cs axlCnsList('physical)
      fprintf(f "PHYS %s TOP %L\n" cs axlCNSGetPhysical(cs "TOP" nil))
      fprintf(f "PHYS %s ART03 %L\n" cs axlCNSGetPhysical(cs "ART03" nil)))
    foreach(cs axlCnsList('spacing)
      fprintf(f "SPC %s TOP %L\n" cs axlCNSGetSpacing(cs "TOP" nil)))
    fprintf(f "SAMENETMODE %L\n" axlCNSSameNetModeGet(nil))
    d = axlDBGetDesign()
    foreach(nc d->netclass
      fprintf(f "NC %L props=%L\n" nc->name nc->prop))
    foreach(n d->nets
      when(member(n->name list("GND" "3.3V_EXT" "12VCC_EXT" "PETP4_RECEPT" "PETP4_M2" "PERP4_RECEPT" "REFCLKOP4" "0.95VDDC"))
        fprintf(f "NET %s phys=%L spc=%L\n" n->name
          (axlNetClassGet(n 'physical t) && axlNetClassGet(n 'physical t)->name)
          (axlNetClassGet(n 'spacing t) && axlNetClassGet(n 'spacing t)->name))))
    fprintf(f "LAYERS %L\n" axlGetParam("paramLayerGroup:ETCH")->groupMembers)
    close(f) t))
