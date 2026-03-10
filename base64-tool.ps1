# Base64 Encoder/Decoder PowerShell Script
# Usage:
#   .\base64-tool.ps1 encode "your text here"
#   .\base64-tool.ps1 decode "eW91ciB0ZXh0IGhlcmU="
#   .\base64-tool.ps1 encode-file "path/to/file.txt"
#   .\base64-tool.ps1 decode-file "path/to/file.b64"

param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('encode', 'decode', 'encode-file', 'decode-file')]
    [string]$Action,
    
    [Parameter(Mandatory=$true, Position=1)]
    [string]$Input
)

function Encode-Base64 {
    param([string]$text)
    
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
    $encoded = [Convert]::ToBase64String($bytes)
    return $encoded
}

function Decode-Base64 {
    param([string]$base64)
    
    try {
        $bytes = [Convert]::FromBase64String($base64)
        $decoded = [System.Text.Encoding]::UTF8.GetString($bytes)
        return $decoded
    }
    catch {
        Write-Error "Invalid Base64 string: $_"
        return $null
    }
}

function Encode-FileToBase64 {
    param([string]$filePath)
    
    if (-not (Test-Path $filePath)) {
        Write-Error "File not found: $filePath"
        return $null
    }
    
    $bytes = [System.IO.File]::ReadAllBytes($filePath)
    $encoded = [Convert]::ToBase64String($bytes)
    return $encoded
}

function Decode-Base64ToFile {
    param([string]$base64FilePath)
    
    if (-not (Test-Path $base64FilePath)) {
        Write-Error "File not found: $base64FilePath"
        return $null
    }
    
    try {
        $base64Content = Get-Content $base64FilePath -Raw
        $bytes = [Convert]::FromBase64String($base64Content.Trim())
        
        $outputPath = $base64FilePath -replace '\.b64$', '.decoded'
        if ($outputPath -eq $base64FilePath) {
            $outputPath = "$base64FilePath.decoded"
        }
        
        [System.IO.File]::WriteAllBytes($outputPath, $bytes)
        return $outputPath
    }
    catch {
        Write-Error "Error decoding file: $_"
        return $null
    }
}

# Main execution
Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "  Base64 Encoder/Decoder Tool" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

switch ($Action) {
    'encode' {
        Write-Host "Encoding text to Base64..." -ForegroundColor Yellow
        $result = Encode-Base64 -text $Input
        Write-Host ""
        Write-Host "Original Text:" -ForegroundColor Green
        Write-Host $Input
        Write-Host ""
        Write-Host "Base64 Encoded:" -ForegroundColor Green
        Write-Host $result -ForegroundColor White
        Write-Host ""
        
        # Copy to clipboard
        $result | Set-Clipboard
        Write-Host "✓ Result copied to clipboard!" -ForegroundColor Cyan
    }
    
    'decode' {
        Write-Host "Decoding Base64 to text..." -ForegroundColor Yellow
        $result = Decode-Base64 -base64 $Input
        
        if ($result) {
            Write-Host ""
            Write-Host "Base64 Input:" -ForegroundColor Green
            Write-Host $Input
            Write-Host ""
            Write-Host "Decoded Text:" -ForegroundColor Green
            Write-Host $result -ForegroundColor White
            Write-Host ""
            
            # Copy to clipboard
            $result | Set-Clipboard
            Write-Host "✓ Result copied to clipboard!" -ForegroundColor Cyan
        }
    }
    
    'encode-file' {
        Write-Host "Encoding file to Base64..." -ForegroundColor Yellow
        $result = Encode-FileToBase64 -filePath $Input
        
        if ($result) {
            $outputPath = "$Input.b64"
            $result | Out-File -FilePath $outputPath -Encoding ASCII -NoNewline
            
            Write-Host ""
            Write-Host "Input File: $Input" -ForegroundColor Green
            Write-Host "Output File: $outputPath" -ForegroundColor Green
            Write-Host ""
            Write-Host "File size:" -ForegroundColor Yellow
            Write-Host "  Original: $((Get-Item $Input).Length) bytes"
            Write-Host "  Encoded:  $((Get-Item $outputPath).Length) bytes"
            Write-Host ""
            Write-Host "✓ File encoded successfully!" -ForegroundColor Cyan
        }
    }
    
    'decode-file' {
        Write-Host "Decoding Base64 file..." -ForegroundColor Yellow
        $outputPath = Decode-Base64ToFile -base64FilePath $Input
        
        if ($outputPath) {
            Write-Host ""
            Write-Host "Input File: $Input" -ForegroundColor Green
            Write-Host "Output File: $outputPath" -ForegroundColor Green
            Write-Host ""
            Write-Host "✓ File decoded successfully!" -ForegroundColor Cyan
        }
    }
}

Write-Host ""
