# 🚀 Penrion Quick Rebuild Script
# Closes running app and rebuilds Windows executable

Write-Host "🔄 Penrion Rebuild Script" -ForegroundColor Cyan
Write-Host ""

# Step 1: Kill running processes
Write-Host "1️⃣  Stopping OsuTabletDriver..." -ForegroundColor Yellow
Get-Process -Name "OsuTabletDriver" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1

# Step 2: Clean old build
Write-Host "2️⃣  Cleaning old build..." -ForegroundColor Yellow
if (Test-Path "release") {
    Remove-Item "release\*" -Recurse -Force -ErrorAction SilentlyContinue
}

# Step 3: Rebuild
Write-Host "3️⃣  Building Windows app..." -ForegroundColor Yellow
dotnet publish "windows-app\OsuTabletDriver\OsuTabletDriver.csproj" `
    -c Release `
    -r win-x64 `
    --self-contained `
    -p:PublishSingleFile=true `
    -o "release"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Build successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📁 Location: $(Resolve-Path 'release\OsuTabletDriver.exe')" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "▶️  Run with: .\release\OsuTabletDriver.exe" -ForegroundColor White
    Write-Host "   (or right-click → Run as Administrator)" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}
