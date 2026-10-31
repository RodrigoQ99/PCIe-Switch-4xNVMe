source "C:/Users/Maria Priscila Quiro/OneDrive/Documentos/Escritorio/Orcad/cdssetup/workspace/projects/Proyecto Final_Switch/02 Esquematico/scripts/lib4.tcl"
set out [open "$::PF/fixpins2.txt" w]
set st [DboState]
set d [getDesign]
array set map {TEST NC PDC_0_L HP_PDC_0_L PDC_1_L HP_PDC_1_L PDC_2_L HP_PDC_2_L PDC_3_L HP_PDC_3_L PDC_4_L HP_PDC_4_L PDC_5_L HP_PDC_5_L PDC_6_L HP_PDC_6_L PDC_7_L HP_PDC_7_L}
set pg [getPage "11_"]
set it [$pg NewPartInstsIter $st]
set p [$it NextPartInst $st]
while {$p != "NULL"} {
  set c [cs]; $p GetReference $c
  if {[str $c] eq "U25"} { break }
  set p [$it NextPartInst $st]
}
set pit [$p NewPinsIter $st]
set pin [$pit NextPin $st]
while {$pin != "NULL"} {
  set c [cs]; $pin GetPinName $c; set nm [str $c]
  if {[info exists map($nm)]} {
    set r [catch { $pin SetPinName [DboTclHelper_sMakeCString $map($nm)] } e]
    set c2 [cs]; $pin GetPinName $c2
    puts $out "IREN $nm -> [str $c2] ($r)"
  }
  set pin [$pit NextPin $st]
}
close $out
