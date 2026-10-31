source "C:/Users/Maria Priscila Quiro/OneDrive/Documentos/Escritorio/Orcad/cdssetup/workspace/projects/Proyecto Final_Switch/02 Esquematico/scripts/lib4.tcl"
set out [open "$::PF/u6.txt" w]
set st [DboState]
set nq 0
foreach {pn pg} [pageList] {
  set it [$pg NewPartInstsIter $st]
  set p [$it NextPartInst $st]
  while {$p != "NULL"} {
    set c [cs]; set ref "?"; set val "?"
    catch { $p GetReference $c; set ref [str $c] }
    catch { $p GetPartValue $c; set val [str $c] }
    if {[string match "*\\?*" $ref]} { incr nq; puts $out "Q|$pn|$ref|$val" }
    if {[string match "PI7C9X3G808GP*" $val]} {
      puts $out "#INST $pn $ref"
      set pit [$p NewEffectivePropsIter $st]
      set n [cs]; set v [cs]; set t [DboTclHelper_sMakeDboValueType]; set e [DboTclHelper_sMakeInt]
      set s [$pit NextEffectiveProp $n $v $t $e]
      while {[$s OK] == 1} {
        puts $out "  [str $n]=[str $v]"
        set s [$pit NextEffectiveProp $n $v $t $e]
      }
      delete_DboEffectivePropsIter $pit
    }
    set p [$it NextPartInst $st]
  }
  delete_DboPagePartInstsIter $it
}
puts $out "#UNANNOTATED $nq"
set d [getDesign]
catch {
  set it [$d NewPackagesIter $st]
  set k [$it NextPackage $st]
  while {$k != "NULL"} {
    set c [cs]; $k GetName $c; set nm [str $c]
    if {[string match "PI7C*" $nm]} { puts $out "PKG|$nm" }
    set k [$it NextPackage $st]
  }
  delete_DboLibPackagesIter $it
} err
puts $out "#PKGERR $err"
close $out
