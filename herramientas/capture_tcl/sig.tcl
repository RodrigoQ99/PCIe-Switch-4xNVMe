source "C:/Users/Maria Priscila Quiro/OneDrive/Documentos/Escritorio/Orcad/cdssetup/workspace/projects/Proyecto Final_Switch/02 Esquematico/scripts/lib4.tcl"
set out [open "$::PF/sig.txt" w]
set d [getDesign]
foreach m {GetCachedPart GetCachedPackage GetCachedCell UpdateCache ReplaceCache SavePart SavePackage GetPart GetPackage SaveCell GetCell NewCachesIter NewPartNames} {
  catch { $d $m } e
  puts $out "$m: $e"
}
close $out
