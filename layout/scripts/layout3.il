;; layout3.il -- standoffs M.2 2280 (simbolo mecanico m2_standoff + colocacion)
;; Agujero M2 metalizado: taladro 2.2 mm, pad 4.4 mm (como MountingHole_2.2mm_M2_Pad), a GND.
soLog = nil
procedure( soMsg(m) when(soLog fprintf(soLog "%s\n" m) drain(soLog)) printf("%s\n" m))
SO_DIR = getWorkingDir()

;; 1) padstack y simbolo mecanico creados dentro de la placa (mils)
procedure( so_def()
  let((mm dr pads ps sd)
    mm = 1.0 / 0.0254
    dr = make_axlPadStackDrill(?holeType 'CIRCLE_DRILL ?drillDiameter 2.2*mm ?plating 'PLATED
                               ?figure 'CIRCLE ?figureSize list(2.2*mm 2.2*mm) ?drillChar "M")
    pads = list(
      make_axlPadStackPad(?layer "TOP" ?type 'REGULAR ?figure 'CIRCLE ?figureSize list(4.4*mm 4.4*mm))
      make_axlPadStackPad(?layer "BOTTOM" ?type 'REGULAR ?figure 'CIRCLE ?figureSize list(4.4*mm 4.4*mm))
      make_axlPadStackPad(?layer "DEFAULT_INTERNAL" ?type 'REGULAR ?figure 'CIRCLE ?figureSize list(4.4*mm 4.4*mm))
      make_axlPadStackPad(?layer "DEFAULT_INTERNAL" ?type 'ANTI ?figure 'CIRCLE ?figureSize list(5.0*mm 5.0*mm))
      make_axlPadStackPad(?layer "SOLDERMASK_TOP" ?type 'REGULAR ?figure 'CIRCLE ?figureSize list(4.5*mm 4.5*mm))
      make_axlPadStackPad(?layer "SOLDERMASK_BOTTOM" ?type 'REGULAR ?figure 'CIRCLE ?figureSize list(4.5*mm 4.5*mm)))
    ps = t
    unless(ps ps = axlDBCreatePadStack("pth_m2so_2200" dr pads t))
    soMsg(sprintf(nil "padstack %L" ps))
    sd = axlDBCreateSymDefSkeleton(list("m2_standoff" "mechanical") list(-3.0*mm:-3.0*mm 3.0*mm:3.0*mm)
           list(make_axlPinData(?number "" ?padstack "pth_m2so_2200" ?origin 0.0:0.0 ?rotation 0.0)))
    soMsg(sprintf(nil "symdef %L" sd))
    when(sd
      soMsg(sprintf(nil "bound %L" axlDBCreateRectangle(list(-2.75*mm:-2.75*mm 2.75*mm:2.75*mm) t "PACKAGE GEOMETRY/PLACE_BOUND_TOP" nil sd)))
      soMsg(sprintf(nil "asm %L" axlDBCreateCircle(list(0.0:0.0 2.5*mm) 4.0 "PACKAGE GEOMETRY/ASSEMBLY_TOP" sd)))
      soMsg(sprintf(nil "silk %L" axlDBCreateCircle(list(0.0:0.0 2.65*mm) 6.0 "PACKAGE GEOMETRY/SILKSCREEN_TOP" sd))))
    sd))

;; 3) coloca los 4 standoffs (con la placa abierta)
SO_XY = list(list(3290.0 3716.0) list(4235.0 3716.0) list(5180.0 3716.0) list(6125.0 3716.0))
procedure( so_3()
  let((r s)
    soLog = outfile(strcat(SO_DIR "/so.log") "w")
    so_def()
    foreach(xy SO_XY
      r = axlDBCreateSymbol(list("m2_standoff" "MECHANICAL") xy nil 0.0)
      s = car(r)
      soMsg(sprintf(nil "standoff %L -> %L net %L" xy r (s && axlDBAssignNet(s->pins "GND")))))
    soMsg(sprintf(nil "DRC=%L" axlDRCUpdate(nil)))
    soMsg(sprintf(nil "save %L" axlSaveDesign(?noConfirm t)))
    close(soLog) soLog = nil t))
