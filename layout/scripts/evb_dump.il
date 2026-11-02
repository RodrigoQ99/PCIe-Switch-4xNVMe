;; evb_dump.il -- lee geometria y colocacion del EVB (solo lectura) y vuelve a la placa nueva
;; Uso (Allegro con cwd = 03 Layout):  skill load("scripts/evb_dump.il")   skill evbDump()
procedure( dmpLayer(p lay)
  let((objs)
    axlVisibleDesign(nil)
    axlVisibleLayer(lay t)
    axlClearSelSet()
    axlSetFindFilter(?enabled list("noall" "shapes" "lines" "linesegs" "rectangles" "frectangles" "figures" "text")
                     ?onButtons list("shapes" "lines" "linesegs" "rectangles" "frectangles" "figures" "text"))
    axlAddSelectAll()
    objs = axlGetSelSet()
    fprintf(p "LAYER %s n=%d\n" lay length(objs))
    foreach(o objs
      fprintf(p " OBJ %L bbox=%L\n" o->objType o->bBox)
      errset(foreach(s o->segments fprintf(p "  SEG %L %L %L\n" s->objType s->startEnd s->xy)) nil))
    axlClearSelSet()))

procedure( evbDump2()
  ;; vuelca el diseno ACTUAL (abrir EVB_ref.brd antes)
  let((p)
    p = outfile("evb_dump2.txt" "w")
    fprintf(p "DESIGN %L\n" axlCurrentDesign())
    fprintf(p "UNITS %L\n" axlDBGetDesignUnits())
    foreach(l list("BOARD GEOMETRY/OUTLINE" "BOARD GEOMETRY/DESIGN_OUTLINE" "BOARD GEOMETRY/CUTOUT"
                   "BOARD GEOMETRY/ROUTE_KEEPOUT" "ROUTE KEEPOUT/ALL" "PACKAGE KEEPOUT/ALL")
      unless(errset(dmpLayer(p l) t) fprintf(p "LAYER %s FALLO\n" l)))
    foreach(s axlDBGetDesign()->symbols
      errset(fprintf(p "SYM %L %L %L %L %L\n" s->refdes s->name s->xy s->rotation s->isMirrored) t))
    close(p)
    axlVisibleDesign(t)
    printf("evb_dump2.txt listo\n")))

;; evbDump3: clines y vias del diseno ACTUAL (abrir EVB_ref.brd antes) -> evb_dump3.txt
procedure( evbDump3()
  let((p n)
    p = outfile("evb_dump3.txt" "w")
    fprintf(p "DESIGN %L\n" axlCurrentDesign())
    foreach(net axlDBGetDesign()->nets
      n = net->name
      foreach(b net->branches
        foreach(o b->children
          case(o->objType
            ("via" fprintf(p "V %L %L %.3f %.3f %L %L\n" n o->definition->name car(o->xy) cadr(o->xy) o->startEnd o->isMirrored))
            ("path"
              foreach(s o->segments
                fprintf(p "C %L %L %.3f %L %L\n" n o->layer s->width s->objType s->startEnd)))))))
    close(p)
    printf("evb_dump3.txt listo\n")))

procedure( evbOpen() axlOpenDesign(?design "EVB_ref.brd" ?mode "wf"))
procedure( newOpen() axlOpenDesign(?design "pcie_switch_4xnvme.brd" ?mode "wf"))
