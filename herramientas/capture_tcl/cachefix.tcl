source "C:/Users/Maria Priscila Quiro/OneDrive/Documentos/Escritorio/Orcad/cdssetup/workspace/projects/Proyecto Final_Switch/02 Esquematico/scripts/lib4.tcl"
set out [open "$::PF/cachefix.txt" w]
set st [DboState]
set d [getDesign]
array set map {TEST NC PDC_0_L HP_PDC_0_L PDC_1_L HP_PDC_1_L PDC_2_L HP_PDC_2_L PDC_3_L HP_PDC_3_L PDC_4_L HP_PDC_4_L PDC_5_L HP_PDC_5_L PDC_6_L HP_PDC_6_L PDC_7_L HP_PDC_7_L}
set lib {D:\AE TEAM WORK\GEN3 SCHEMATIC\3G808GP\REFERENCE CIRCUIT\PI7C9X3G808GP_V1.5\PI7C9X3G808GP_V15.DSN}
set cp "NULL"
foreach L [list $lib [string toupper $lib] PI7C9X3G808GP_V15] {
  foreach P {PI7C9X3G808GP_19B.Normal PI7C9X3G808GP_19B} {
    catch { set cp [$d GetCachedPart [DboTclHelper_sMakeCString $L] [DboTclHelper_sMakeCString $P]] } e
    puts $out "TRY $L | $P -> $cp ($e)"
    if {$cp != "NULL" && $cp != ""} { break }
  }
  if {$cp != "NULL" && $cp != ""} { break }
}
if {$cp != "NULL" && $cp != ""} {
  set pit [$cp NewPinsIter $st]
  set sp [$pit NextPin $st]
  while {$sp != "NULL"} {
    set c [cs]; $sp GetPinName $c; set nm [str $c]
    if {[info exists map($nm)]} {
      $sp SetPinName [DboTclHelper_sMakeCString $map($nm)]
      set c2 [cs]; $sp GetPinName $c2; puts $out "CREN $nm -> [str $c2]"
    }
    set sp [$pit NextPin $st]
  }
  catch { $cp MarkModified } e; puts $out "CP MarkModified $e"
  catch { $d SavePart $cp } e; puts $out "SavePart $e"
}
close $out
