# Restart OsuTabletDriver with new build
Write-Host "🔄 Stopping OsuTabletDriver..." -ForegroundColor Yellow
Get-Process -Name "OsuTabletDriver" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-Host "✅ Starting new version..." -ForegroundColor Green
Start-Process "c:\Users\yasic\Documents\Cloudflared\Penrion\release\OsuTabletDriver.exe"
Write-Host "🚀 OsuTabletDriver restarted!" -ForegroundColor Cyan
