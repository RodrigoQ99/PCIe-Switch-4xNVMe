$end = (Get-Date).AddSeconds(300); $done = $false
while (-not $done -and (Get-Date) -lt $end) {
  $p = Get-CimInstance Win32_Process -Filter "name='specctra.exe'" -ErrorAction SilentlyContinue
  foreach ($x in $p) {
    $c = $x.CommandLine
    if ($c -match '-mpssession (.+?) -do .*-did "([^"]+)"') {
      $s = $Matches[1]; $did = $Matches[2]
      Add-Content -Path C:\rt\cmdline2.txt -Value "found: $c"
      $a = "-mpssession `"$s`" -do pasde.do -did `"$did`" -product OrCAD_X_Professional_Plus -nog -li -simple `"C:/rt/sw.dsn`""
      Add-Content -Path C:\rt\cmdline2.txt -Value "launch: $a"
      Start-Process -FilePath 'C:\Cadence\OrCADX_25.1\tools\bin\32bit\specctra.exe' -ArgumentList $a -WorkingDirectory 'C:\rt'
      $done = $true; break
    }
  }
  Start-Sleep -Milliseconds 50
}
Add-Content -Path C:\rt\cmdline2.txt -Value "END $done"
