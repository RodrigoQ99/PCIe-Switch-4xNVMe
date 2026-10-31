# Utilidades comunes
set ::PF [file dirname [file normalize [info script]]]
proc cs {} { return [DboTclHelper_sMakeCString] }
proc str {c} { return [DboTclHelper_sGetConstCharPtr $c] }
proc px {p} { return [DboTclHelper_sGetCPointX $p] }
proc py {p} { return [DboTclHelper_sGetCPointY $p] }
proc getDesign {} {
  set s $::DboSession_s_pDboSession
  DboSession -this $s
  return [$s GetActiveDesign]
}
proc getSchematic {} {
  set st [DboState]
  set d [getDesign]
  set it [$d NewViewsIter $st $::IterDefs_SCHEMATICS]
  set v [$it NextView $st]
  delete_DboLibViewsIter $it
  return [DboViewToDboSchematic $v]
}
proc pageList {} {
  set st [DboState]; set sch [getSchematic]; set c [cs]; set res {}
  set it [$sch NewPagesIter $st]
  set p [$it NextPage $st]
  while {$p != "NULL"} { $p GetName $c; lappend res [str $c] $p; set p [$it NextPage $st] }
  delete_DboSchematicPagesIter $it
  return $res
}
proc getPage {prefix} {
  foreach {n p} [pageList] { if {[string match "${prefix}*" $n]} { return $p } }
  return NULL
}
proc dumpPage {out pname} {
  set st [DboState]; set c [cs]
  set pg [getPage $pname]
  puts $out "#PAGE $pname $pg"
  if {$pg == "NULL"} return
  # partes y pines
  set it [$pg NewPartInstsIter $st]
  set p [$it NextPartInst $st]
  while {$p != "NULL"} {
    if {[catch {
      $p GetReference $c; set ref [str $c]
      $p GetPartValue $c; set val [str $c]
      set loc [$p GetLocation $st]
      puts $out "P|$ref|$val|[px $loc]|[py $loc]"
      set pit [$p NewPinsIter $st]
      set pin [$pit NextPin $st]
      while {$pin != "NULL"} {
        if {[catch {
          $pin GetPinNumber $c; set num [str $c]
          $pin GetPinName $c; set nm [str $c]
          set hs [$pin GetOffsetHotSpot $st]
          set net ""
          catch { set w [$pin GetWire $st]; if {$w != "NULL"} { $w GetNetName $c; set net [str $c] } }
          set nc [DboPortInst_sGetIsNoConnect $pin $st]
          puts $out "N|$ref|$num|$nm|[px $hs]|[py $hs]|$net|$nc"
        } e]} { puts $out "ERRPIN $ref $e" }
        set pin [$pit NextPin $st]
      }
      delete_DboPartInstPinsIter $pit
    } e]} { puts $out "ERRPART $e" }
    set p [$it NextPartInst $st]
  }
  delete_DboPagePartInstsIter $it
  # off-page
  set it [$pg NewOffPageConnectorsIter $st]
  set o [$it NextOffPageConnector $st]
  while {$o != "NULL"} {
    catch { $o GetName $c; set loc [$o GetLocation $st]; puts $out "O|[str $c]|[px $loc]|[py $loc]|[$o GetRotation $st]" }
    set o [$it NextOffPageConnector $st]
  }
  delete_DboPageOffPageConnectorsIter $it
  # globals (power)
  set it [$pg NewGlobalsIter $st]
  set g [$it NextGlobal $st]
  while {$g != "NULL"} {
    catch { $g GetName $c; set loc [$g GetLocation $st]; puts $out "G|[str $c]|[px $loc]|[py $loc]" }
    set g [$it NextGlobal $st]
  }
  delete_DboPageGlobalsIter $it
  # wires + alias
  set it [$pg NewWiresIter $st]
  set w [$it NextWire $st]
  while {$w != "NULL"} {
    if {[catch {
      $w GetNetName $c; set net [str $c]
      set a [$w GetStartPoint $st]; set b [$w GetEndPoint $st]
      set al {}
      set ai [$w NewAliasesIter $st]
      set x [$ai NextAlias $st]
      while {$x != "NULL"} { $x GetName $c; set l [$x GetLocation $st]; lappend al "[str $c]@[px $l],[py $l]"; set x [$ai NextAlias $st] }
      delete_DboWireAliasesIter $ai
      puts $out "W|$net|[px $a]|[py $a]|[px $b]|[py $b]|$al"
    } e]} { puts $out "ERRWIRE $e" }
    set w [$it NextWire $st]
  }
  delete_DboPageWiresIter $it
}
