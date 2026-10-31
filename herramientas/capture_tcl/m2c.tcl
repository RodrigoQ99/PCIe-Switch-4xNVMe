# M.2 M-key socket builder (page 10), split in chunks. Units: inches.
set ::LIB "C:/Cadence/OrCADX_25.1/tools/capture/library"
proc m2f {v} { return [format %.2f $v] }
proc m2W {x1 y1 x2 y2} { PlaceWire [m2f $x1] [m2f $y1] [m2f $x2] [m2f $y2] }
proc pinY {n y0} {
  if {$n % 2} { return [expr {$y0 + 0.20 + 0.05*($n-1)}] }
  return [expr {$y0 + 0.20 + 0.05*($n-2)}]
}
proc m2OPL {x y net} { PlaceOffPage [m2f $x] [m2f [expr {$y-0.10}]] "$::LIB/capsym.olb" "OFFPAGELEFT-L" $net }
proc m2OPR {x y net} { PlaceOffPage [m2f [expr {$x-0.10}]] [m2f [expr {$y-0.10}]] "$::LIB/capsym.olb" "OFFPAGELEFT-R" $net }
proc m2GND {x y} { PlaceGround [m2f [expr {$x-0.10}]] [m2f $y] "$::LIB/capsym.olb" "GND" "GND" }
proc m2V33 {x y} { PlacePower [m2f [expr {$x-0.10}]] [m2f [expr {$y-0.10}]] "$::LIB/capsym.olb" "VCC_BAR" "3.3V_EXT" }
proc m2Cv {px py ref val} {
  PlacePart [m2f [expr {$px-0.10}]] [m2f [expr {$py+0.10}]] "$::LIB/Discrete.olb" "CAP NP" "" FALSE
  UnSelectAll; SelectObject [m2f $px] [m2f [expr {$py+0.15}]] FALSE
  SetProperty "Part Reference" $ref; SetProperty "Value" $val; UnSelectAll
}
proc m2Ch {px py ref val} {
  # placed vertical first (pins at px+0.2: py-0.2 / py+0.1), then rotated to px..px+0.3 at py
  PlacePart [m2f [expr {$px+0.10}]] [m2f [expr {$py-0.10}]] "$::LIB/Discrete.olb" "CAP NP" "" FALSE
  UnSelectAll; SelectObject [m2f [expr {$px+0.20}]] [m2f [expr {$py-0.05}]] FALSE
  SetProperty "Part Reference" $ref; SetProperty "Value" $val; Rotate; UnSelectAll
}
# 1) GND rail, odd side
proc m2gnd {x0 y0} {
  set xr [expr {$x0+0.70}]; set xg [expr {$xr+0.30}]; set prev ""
  foreach n {1 3 9 15 21 27 33 39 45 51 57 71 73 75} {
    set y [pinY $n $y0]; m2W $xr $y $xg $y
    if {$prev ne ""} { m2W $xg $prev $xg $y }
    set prev $y
  }
  m2W $xg $prev $xg [expr {$prev+0.20}]; m2GND $xg [expr {$prev+0.20}]
}
# 2) High-speed. Order matters: TX caps before RX wires.
proc m2hs {x0 y0 p} {
  set xr [expr {$x0+0.70}]; set xo [expr {$xr+2.00}]
  set xj [expr {$xr+0.50}]; set xc [expr {$xr+0.90}]
  foreach {n dy net ref} [list 47 -0.10 PETn${p}_RECEPT C7${p}1 49 0.10 PETp${p}_RECEPT C7${p}2] {
    set y [pinY $n $y0]; set y2 [expr {$y+$dy}]
    m2W $xr $y $xj $y; m2W $xj $y $xj $y2; m2W $xj $y2 $xc $y2
    m2Ch $xc $y2 $ref 220nF
    m2W [expr {$xc+0.30}] $y2 $xo $y2; m2OPL $xo $y2 $net
  }
  foreach {n dx net} [list 41 0.50 PERn${p}_RECEPT 43 0.60 PERp${p}_RECEPT] {
    set y [pinY $n $y0]; set y2 [expr {$y-0.20}]; set xjj [expr {$xr+$dx}]
    m2W $xr $y $xjj $y; m2W $xjj $y $xjj $y2; m2W $xjj $y2 $xo $y2; m2OPL $xo $y2 $net
  }
  foreach {n dx net} [list 53 0.60 REFCLKN_SL${p} 55 0.50 REFCLKP_SL${p}] {
    set y [pinY $n $y0]; set y2 [expr {$y+0.30}]; set xjj [expr {$xr+$dx}]
    m2W $xr $y $xjj $y; m2W $xjj $y $xjj $y2; m2W $xjj $y2 $xo $y2; m2OPL $xo $y2 $net
  }
}
# 3) No-connects
proc m2nc {x0 y0} {
  set xr [expr {$x0+0.70}]; set xl [expr {$x0-0.30}]
  foreach n {5 7 11 13 17 19 23 25 29 31 35 37 59 61 63 65 67 69} { PlaceNoConnect [m2f $xr] [m2f [pinY $n $y0]] }
  foreach n {6 8 10 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 52 54 56 58 60 62 64 66 68 76} { PlaceNoConnect [m2f $xl] [m2f [pinY $n $y0]] }
}
# 4) 3.3V rail + PERST#
proc m2pwr {x0 y0 perst} {
  set xl [expr {$x0-0.30}]; set xp [expr {$xl-0.30}]; set prev ""
  foreach n {2 4 12 14 16 18 70 72 74} {
    set y [pinY $n $y0]; m2W $xl $y $xp $y
    if {$prev ne ""} { m2W $xp $prev $xp $y }
    set prev $y
  }
  set yt [pinY 2 $y0]; m2W $xp $yt $xp [expr {$yt-0.20}]; m2V33 $xp [expr {$yt-0.20}]
  set y [pinY 50 $y0]; set xol [expr {$xl-1.00}]; m2W $xl $y $xol $y; m2OPR $xol $y $perst
}
# 5) Decoupling 2x22uF + 2x0.1uF
proc m2dec {x0 y0 p} {
  set xp [expr {$x0-0.60}]; set yb [pinY 4 $y0]; set px $xp; set i 3
  foreach v {22uF 22uF 0.1uF 0.1uF} {
    set nx [expr {$px-0.50}]
    m2W $px $yb $nx $yb
    if {$i > 3} { m2W $px [expr {$yb+0.30}] $nx [expr {$yb+0.30}] }
    m2Cv $nx $yb C7${p}${i} $v
    set px $nx; incr i
  }
  m2W $px [expr {$yb+0.30}] $px [expr {$yb+0.50}]; m2GND $px [expr {$yb+0.50}]
}
# Full socket
proc m2all {x0 y0 p perst ref} {
  PlacePart [m2f $x0] [m2f $y0] "$::LIB/Connector.olb" "HEADER 38x2" "" FALSE
  UnSelectAll; SelectObject [m2f [expr {$x0+0.20}]] [m2f [expr {$y0+1.50}]] FALSE
  SetProperty "Part Reference" $ref; SetProperty "Value" "M.2_M-KEY_2280"; UnSelectAll
  m2gnd $x0 $y0; m2hs $x0 $y0 $p; m2nc $x0 $y0; m2pwr $x0 $y0 $perst; m2dec $x0 $y0 $p; UnSelectAll
}
