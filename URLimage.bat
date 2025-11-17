$urlsFile = "C:\images\urls.txt"
$destination = "C:\images\downloaded"
New-Item -ItemType Directory -Force -Path $destination | Out-Null

Get-Content $urlsFile | ForEach-Object {
    $url = $_
    $fileName = Split-Path $url -Leaf
    $outputPath = Join-Path $destination $fileName
    try {
        Invoke-WebRequest -Uri $url -OutFile $outputPath
        Write-Host " Downloaded: $fileName"
    } catch {
        Write-Warning " Failed: $fileName"
    }
}
