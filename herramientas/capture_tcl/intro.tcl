source "C:/Users/Maria Priscila Quiro/OneDrive/Documentos/Escritorio/Orcad/cdssetup/workspace/projects/Proyecto Final_Switch/02 Esquematico/scripts/lib4.tcl"
set out [open "$::PF/intro.txt" w]
set st [DboState]
set d [getDesign]
catch { $d zzBogus } e; puts $out "DESIGN: $e"
set pg [getPage "11_"]
set it [$pg NewPartInstsIter $st]
set p [$it NextPartInst $st]
while {$p != "NULL"} {
  set c [cs]; $p GetReference $c
  if {[str $c] eq "U25"} { break }
  set p [$it NextPartInst $st]
}
delete_DboPagePartInstsIter $it
catch { $p zzBogus } e; puts $out "INST: $e"
set pit [$p NewPinsIter $st]
set pin [$pit NextPin $st]
catch { $pin zzBogus } e; puts $out "PIN: $e"
delete_DboPartInstPinsIter $pit
# cache parts
catch {
  set it [$d NewPartsIter $st]
  set lp [$it NextPart $st]
  set first 1
  while {$lp != "NULL"} {
    set c [cs]; $lp GetName $c; set nm [str $c]
    if {[string match "PI7C9X3G808GP_1*" $nm]} {
      puts $out "LIBPART|$nm"
      if {$first} { catch { $lp zzBogus } e; puts $out "LP: $e"; set first 0 }
    }
    set lp [$it NextPart $st]
  }
} e2
puts $out "PARTSERR $e2"
close $out
