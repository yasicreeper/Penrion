# Simple Git Commit Script

$gitPath = "C:\Program Files\Git\cmd\git.exe"

if (-not (Test-Path $gitPath)) {
    $gitPath = "git"
}

Set-Location "c:\Users\yasic\Documents\Cloudflared\Penrion"

Write-Host "Adding files..." -ForegroundColor Yellow
& $gitPath add .

Write-Host "Creating commit..." -ForegroundColor Yellow
& $gitPath commit -m "Ultra Performance Update v2.0.0 - 500Hz touch rate, 144FPS streaming, auto-click detection, weighted pressure smoothing, improved latency from 15-25ms to under 5ms"

Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
& $gitPath push origin main

Write-Host "Done!" -ForegroundColor Green
