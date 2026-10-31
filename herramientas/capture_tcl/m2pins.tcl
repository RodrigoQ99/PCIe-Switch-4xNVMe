source "C:/Users/Maria Priscila Quiro/OneDrive/Documentos/Escritorio/Orcad/cdssetup/workspace/projects/Proyecto Final_Switch/02 Esquematico/scripts/lib4.tcl"
set out [open "$::PF/m2pins.txt" w]
set st [DboState]
set d [getDesign]
set pg [getPage "10_"]
set it [$pg NewPartInstsIter $st]
set p [$it NextPartInst $st]
while {$p != "NULL"} {
  set c [cs]; $p GetReference $c
  if {[str $c] eq "J44"} { break }
  set p [$it NextPartInst $st]
}
proc eprop {o nm} { set v [cs]; $o GetEffectivePropStringValue [DboTclHelper_sMakeCString $nm] $v; return [str $v] }
set lib [eprop $p "Source Library"]; set sp [eprop $p "Source Part"]
puts $out "J44 $lib | $sp | [eprop $p {Source Package}]"
set cp [$d GetCachedPart [DboTclHelper_sMakeCString $lib] [DboTclHelper_sMakeCString $sp]]
puts $out "CP $cp"
set pit [$cp NewPinsIter $st]
set pin [$pit NextPin $st]
set k 0
while {$pin != "NULL"} {
  set c [cs]; $pin GetPinName $c; set nm [str $c]
  if {$k == 0} {
    set eit [$pin NewEffectivePropsIter $st]
    set n [cs]; set v [cs]; set t [DboTclHelper_sMakeDboValueType]; set e [DboTclHelper_sMakeInt]
    set s [$eit NextEffectiveProp $n $v $t $e]
    while {[$s OK] == 1} { puts $out "  PINPROP [str $n]=[str $v]"; set s [$eit NextEffectiveProp $n $v $t $e] }
  }
  puts $out "PIN $k $nm"
  incr k
  set pin [$pit NextPin $st]
}
close $out
