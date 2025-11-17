Add-Type -Path "C:\libs\itextsharp.dll"

$sourceFolder = "C:\PDFs"
$outputFile = "C:\PDFs\Merged.pdf"

$document = New-Object iTextSharp.text.Document
$writer = [iTextSharp.text.pdf.PdfWriter]::GetInstance($document, [System.IO.File]::OpenWrite($outputFile))
$document.Open()

Get-ChildItem -Path $sourceFolder -Filter "*.pdf" | ForEach-Object {
    $reader = New-Object iTextSharp.text.pdf.PdfReader($_.FullName)
    for ($i=1; $i -le $reader.NumberOfPages; $i++) {
        $page = $writer.GetImportedPage($reader, $i)
        $writer.DirectContent.AddTemplate($page, 0, 0)
    }
    $reader.Close()
}
$document.Close()
Write-Host "PDFs merged → $outputFile"
