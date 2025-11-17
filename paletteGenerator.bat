# ColorPaletteGenerator.ps1
function Get-ComplementaryColor {
    param([int[]]$rgb)
    return @(255 - $rgb[0], 255 - $rgb[1], 255 - $rgb[2])
}

function Get-AnalogousColors {
    param([int[]]$rgb)
    # shift hue by +/-30 degrees approximation
    $toRgb = { param($h, $s, $v) 
        $c = $v * $s
        $x = $c * (1 - [math]::Abs((($h / 60) % 2) - 1))
        $m = $v - $c
        if ($h -lt 60)      { $r=$c;$g=$x;$b=0 }
        elseif ($h -lt 120) { $r=$x;$g=$c;$b=0 }
        elseif ($h -lt 180) { $r=0;$g=$c;$b=$x }
        elseif ($h -lt 240) { $r=0;$g=$x;$b=$c }
        elseif ($h -lt 300) { $r=$x;$g=0;$b=$c }
        else                { $r=$c;$g=0;$b=$x }
        return @([int](($r+$m)*255), [int](($g+$m)*255), [int](($b+$m)*255))
    }
    # convert RGB to HSV
    $r = $rgb[0]/255; $g = $rgb[1]/255; $b = $rgb[2]/255
    $max = [math]::Max($r,$g,$b); $min=[math]::Min($r,$g,$b)
    $delta = $max-$min
    if ($delta -eq 0) { $h=0 } elseif ($max -eq $r) { $h=60*((($g-$b)/$delta)%6) }
    elseif ($max -eq $g) { $h=60*(($b-$r)/$delta+2) } else { $h=60*(($r-$g)/$delta+4) }
    if ($h -lt 0) { $h+=360 }
    $s = if ($max -eq 0) {0} else {$delta/$max}
    $v = $max

    # Analogous: +/-30 degrees
    $analog1 = & $toRgb (($h+30)%360), $s, $v
    $analog2 = & $toRgb (($h-30+360)%360), $s, $v
    return @($analog1, $analog2)
}

function Show-Palette {
    param([int[]]$baseRGB)
    
    $comp = Get-ComplementaryColor -rgb $baseRGB
    $analogs = Get-AnalogousColors -rgb $baseRGB

    Write-Host "Base color: RGB($($baseRGB -join ','))" -BackgroundColor ([ConsoleColor]::Black)
    Write-Host "Complementary: RGB($($comp -join ','))"
    Write-Host "Analogous: RGB($($analogs[0] -join ',')), RGB($($analogs[1] -join ','))"

    # Optional: generate shades (darker/lighter)
    for ($i=1; $i -le 3; $i++) {
        $shade = $baseRGB | ForEach-Object { [int]($_ * (1 - 0.2*$i)) }
        $tint  = $baseRGB | ForEach-Object { [int]($_ + (255-$_)*0.2*$i) }
        Write-Host "Shade $i: RGB($($shade -join ',')) | Tint $i: RGB($($tint -join ','))"
    }
}

# Example usage:
$inputRGB = Read-Host "Enter RGB (comma-separated, e.g., 100,150,200)"
$rgbArray = $inputRGB -split "," | ForEach-Object { [int]$_ }
Show-Palette -baseRGB $rgbArray
