source "C:/Users/Maria Priscila Quiro/OneDrive/Documentos/Escritorio/Orcad/cdssetup/workspace/projects/Proyecto Final_Switch/02 Esquematico/scripts/lib4.tcl"
set out [open "$::PF/savepkg.txt" w]
set st [DboState]
set d [getDesign]
set it [$d NewPartsIter $st]
set lp [$it NextPart $st]
while {$lp != "NULL"} {
  set c [cs]; $lp GetName $c
  if {[str $c] eq "PI7C9X3G808GP_19B.Normal"} { break }
  set lp [$it NextPart $st]
}
set pit [$lp NewPinsIter $st]
set sp [$pit NextPin $st]
set names {}
while {$sp != "NULL"} { set c [cs]; $sp GetPinName $c; lappend names [str $c]; set sp [$pit NextPin $st] }
puts $out "PINS [lsearch -all -inline -glob $names *PDC*] [lsearch -all -inline $names NC] [lsearch -all -inline $names TEST]"
catch { $lp MarkModified } e; puts $out "LP MarkModified: $e"
set pkg "NULL"
catch { set pkg [$lp GetPackagePtr] } e; puts $out "GetPackagePtr: $e"
catch { $pkg MarkModified } e; puts $out "PKG MarkModified: $e"
catch { $d SavePackage $pkg } e; puts $out "SavePackage: $e"
catch { $d MarkModified } e; puts $out "D MarkModified: $e"
catch { puts $out "IsModified [$d IsModified]" }
close $out
