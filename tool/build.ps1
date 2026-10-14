# Sürüm derlemesi: arayüz + işçi süreç, tek klasörde.   powershell -File tool/build.ps1
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
New-Item -ItemType Directory -Force build | Out-Null
Write-Host '== 1/3 işçi derleniyor ==' -ForegroundColor Cyan
dart compile exe bin/trophy_worker.dart -o build/trophy_worker.exe
if (-not (Test-Path build/trophy_worker.exe)) { throw 'işçi derlenemedi' }
Write-Host '== 2/3 arayüz derleniyor ==' -ForegroundColor Cyan
flutter build windows --release
Write-Host '== 3/3 işçi pakete kopyalanıyor ==' -ForegroundColor Cyan
$out = 'build/windows/x64/runner/Release'
Copy-Item build/trophy_worker.exe $out -Force
Write-Host "PAKET: $out\trophy_room.exe" -ForegroundColor Green
