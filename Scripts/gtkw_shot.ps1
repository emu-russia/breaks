# Capture the running GTKWave window into PNG (by gtkwave process window).
# Usage: powershell -File gtkw_shot.ps1 -TestName <name> -WaveDir <C:\...\waves>
param([string]$TestName, [string]$WaveDir)
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class W32s {
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
    [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
    public struct RECT { public int Left, Top, Right, Bottom; }
}
"@
[W32s]::SetProcessDPIAware() | Out-Null
$png = Join-Path $WaveDir ($TestName + ".png")
$proc = $null
for ($i = 0; $i -lt 60; $i++) {
    $cand = Get-Process gtkwave -ErrorAction SilentlyContinue
    foreach ($p in $cand) {
        if ($p.MainWindowHandle -ne [IntPtr]::Zero) { $proc = $p; break }
    }
    if ($proc -ne $null) { break }
    Start-Sleep -Milliseconds 300
}
if ($proc -eq $null) { Write-Output "nowindow $TestName"; exit 1 }
[W32s]::ShowWindow($proc.MainWindowHandle, 3) | Out-Null
Start-Sleep -Milliseconds 1000
$rect = New-Object W32s+RECT
[W32s]::GetWindowRect($proc.MainWindowHandle, [ref]$rect) | Out-Null
$w = $rect.Right - $rect.Left; $ht = $rect.Bottom - $rect.Top
if ($w -le 10 -or $ht -le 10) { Write-Output "badrect $TestName $w $ht"; exit 1 }
$bmp = New-Object System.Drawing.Bitmap $w, $ht
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($rect.Left, $rect.Top, 0, 0, (New-Object System.Drawing.Size($w, $ht)))
$bmp.Save($png, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output ("ok $TestName ${w}x${ht}")
