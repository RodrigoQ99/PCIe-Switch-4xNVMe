source "C:/Users/Maria Priscila Quiro/OneDrive/Documentos/Escritorio/Orcad/cdssetup/workspace/projects/Proyecto Final_Switch/02 Esquematico/scripts/lib4.tcl"
set out [open "$::PF/m2ign.txt" w]
set st [DboState]
set d [getDesign]
set cp [$d GetCachedPart [DboTclHelper_sMakeCString {C:\CADENCE\ORCADX_25.1\TOOLS\CAPTURE\LIBRARY\CONNECTOR.OLB}] [DboTclHelper_sMakeCString "HEADER 38x2.Normal"]]
set pit [$cp NewPinsIter $st]
set pin [$pit NextPin $st]
catch { $pin zzBogus } e
set ms [regexp -all -inline -nocase {\S*ignore\S*} $e]
puts $out "IGNORE METHODS: $ms"
set targets {59 60 61 62 63 64 65 66 76}
while {$pin != "NULL"} {
  set c [cs]; $pin GetPinName $c; set nm [str $c]
  if {[lsearch $targets $nm] >= 0} {
    foreach m $ms {
      if {[string match -nocase "Set*" $m]} { catch { $pin $m 1 } r; puts $out "$nm $m -> $r" }
    }
    foreach m $ms {
      if {[string match -nocase "Get*" $m] || [string match -nocase "Is*" $m]} { catch { $pin $m } r; puts $out "$nm $m = $r" }
    }
  }
  set pin [$pit NextPin $st]
}
catch { $cp MarkModified } e; catch { $d SavePart $cp } e2
puts $out "saved $e2"
close $out
