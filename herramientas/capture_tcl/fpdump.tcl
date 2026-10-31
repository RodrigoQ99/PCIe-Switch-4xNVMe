source [file join [file dirname [file normalize [info script]]] lib4.tcl]
set out [open "$::PF/fp.txt" w]
set st [DboState]
foreach {pn pg} [pageList] {
  set it [$pg NewPartInstsIter $st]
  set p [$it NextPartInst $st]
  while {$p != "NULL"} {
    set c [cs]; set v [cs]; set fp "?"; set ref "?"; set val "?"
    catch { $p GetReference $c; set ref [str $c] }
    catch { $p GetPartValue $c; set val [str $c] }
    catch { $p GetEffectivePropStringValue [DboTclHelper_sMakeCString "PCB Footprint"] $v; set fp [str $v] }
    puts $out "$pn|$ref|$val|$fp"
    set p [$it NextPartInst $st]
  }
  delete_DboPagePartInstsIter $it
}
close $out
