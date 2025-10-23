### Converting the whole filtered list of JPEG images tp PNG
Add-Type -AssemblyName System.Drawing

$source = "C:\\\images"
$destination = "$source\pngs"
New-Item -ItemType Directory -Force -Path $destination | Out-Null

# Process .jpeg, .jpg, and .png files
$extensions = @("*.jpeg", "*.jpg", "*.png")

foreach ($ext in $extensions) {
    Get-ChildItem -Path $source -Filter $ext | ForEach-Object {
        $inputPath = $_.FullName
        $outputName = "$($_.BaseName).png"
        $outputPath = Join-Path $destination $outputName

        try {
            $img = [System.Drawing.Image]::FromFile($inputPath)
            $bmp = New-Object System.Drawing.Bitmap $img.Width, $img.Height
            $g = [System.Drawing.Graphics]::FromImage($bmp)
            $g.Clear([System.Drawing.Color]::Transparent)
            $g.DrawImage($img, 0, 0, $img.Width, $img.Height)
            $bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)

            $g.Dispose()
            $img.Dispose()
            $bmp.Dispose()

            Write-Host "✅ Converted: $($_.Name) → $outputName"
        } catch {
            Write-Warning "⚠️ Failed to convert: $($_.Name)"
        }
    }
}
