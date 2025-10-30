# Build script for Windows application
# Builds and publishes a standalone executable

Write-Host "Building Penrion OSU! Tablet Driver..." -ForegroundColor Cyan

# Navigate to project directory
Set-Location -Path "windows-app\OsuTabletDriver"

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
if (Test-Path "bin") { Remove-Item -Recurse -Force "bin" }
if (Test-Path "obj") { Remove-Item -Recurse -Force "obj" }

# Restore dependencies
Write-Host "Restoring dependencies..." -ForegroundColor Yellow
dotnet restore

# Build Release configuration
Write-Host "Building Release configuration..." -ForegroundColor Yellow
dotnet build --configuration Release

# Publish as self-contained executable
Write-Host "Publishing self-contained executable..." -ForegroundColor Yellow
dotnet publish -c Release -r win-x64 --self-contained true /p:PublishSingleFile=true /p:IncludeNativeLibrariesForSelfExtract=true

# Check if build was successful
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✓ Build successful!" -ForegroundColor Green
    Write-Host "`nExecutable location:" -ForegroundColor Cyan
    Write-Host "bin\Release\net8.0-windows\win-x64\publish\OsuTabletDriver.exe" -ForegroundColor White
    
    # Copy to release folder
    $releaseFolder = "..\..\release"
    if (-not (Test-Path $releaseFolder)) {
        New-Item -ItemType Directory -Path $releaseFolder | Out-Null
    }
    
    Copy-Item "bin\Release\net8.0-windows\win-x64\publish\*" -Destination $releaseFolder -Recurse -Force
    Write-Host "`n✓ Copied to release folder" -ForegroundColor Green
    
    # Get file size
    $exePath = "$releaseFolder\OsuTabletDriver.exe"
    if (Test-Path $exePath) {
        $size = (Get-Item $exePath).Length / 1MB
        Write-Host "`nExecutable size: $([math]::Round($size, 2)) MB" -ForegroundColor White
    }
} else {
    Write-Host "`n✗ Build failed!" -ForegroundColor Red
    exit 1
}

# Return to root
Set-Location -Path "..\..\"

Write-Host "`n✓ Build process complete!" -ForegroundColor Green
Write-Host "`nTo run the application:" -ForegroundColor Cyan
Write-Host "  .\release\OsuTabletDriver.exe" -ForegroundColor White
Write-Host "`nNote: Requires administrator privileges" -ForegroundColor Yellow
