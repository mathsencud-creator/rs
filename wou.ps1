Clear-History

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type -TypeDefinition @"
using System;
using System.Reflection;
using System.Threading;
using System.Windows.Forms;

public class WinFormsLoaderVML
{
    public static void Launch(byte[] data)
    {
        Assembly asm = Assembly.Load(data);
        MethodInfo entry = asm.EntryPoint;
        string[] args = new string[0];
        Thread t = new Thread(() =>
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            if (entry.GetParameters().Length == 0)
                entry.Invoke(null, null);
            else
                entry.Invoke(null, new object[] { args });
        });
        t.SetApartmentState(ApartmentState.STA);
        t.Start();
        t.Join(); // aguarda thread finalizar
    }
}
"@ -ReferencedAssemblies "System.Windows.Forms.dll","System.Drawing.dll","System.dll"

$exePath = C:\Users\pz\Downloads\lowpov.exe
try {
    $bytes = [System.IO.File]::ReadAllBytes($exePath)
    if (-not $bytes) { throw "Arquivo não encontrado ou vazio!" }
    [WinFormsLoaderVML]::Launch($bytes)
} catch {
    Write-Host "Erro ao ler o arquivo: $($_.Exception.Message)"
}
while ($true) {
    if (-not [System.Windows.Forms.Application]::OpenForms.Count) { break }
    Start-Sleep -Seconds 1
}
Clear-History
[Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()
Remove-Item -Force (Get-PSReadLineOption).HistorySavePath -ErrorAction SilentlyContinue
Set-PSReadLineOption -HistorySaveStyle SaveNothing
