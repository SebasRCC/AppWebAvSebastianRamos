# ============================================================
#  PoliMusic - arranque con IIS Express (sin permisos de admin)
#  Uso:  click derecho > "Ejecutar con PowerShell"
#        o bien:  powershell -ExecutionPolicy Bypass -File .\run-iisexpress.ps1
# ============================================================
$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$iis  = Join-Path $env:ProgramFiles "IIS Express"
$exe  = Join-Path $iis "iisexpress.exe"
$src  = Join-Path $iis "AppServer\applicationHost.config"
$cfg  = Join-Path $env:TEMP "polimusic-iisexpress.config"
$port = 8099

if (-not (Test-Path $exe)) {
    Write-Host "No se encontro IIS Express. Instalalo o usa IIS completo (ver README)." -ForegroundColor Red
    exit 1
}

# Genera una copia de la configuracion de IIS Express apuntando a esta carpeta
$text = Get-Content $src -Raw
$text = $text.Replace('%IIS_BIN%\AppServer\empty_wwwroot', $root)
$text = $text.Replace(':8080:localhost', ":$port" + ':localhost')
Set-Content -Path $cfg -Value $text -Encoding UTF8

Write-Host ""
Write-Host "  PoliMusic  ->  http://localhost:$port/" -ForegroundColor Cyan
Write-Host "  Admin      ->  userAdmin  / 12345678" -ForegroundColor DarkGray
Write-Host "  Usuario    ->  userNormal / 12345678" -ForegroundColor DarkGray
Write-Host "  (Ctrl+C para detener el servidor)" -ForegroundColor DarkGray
Write-Host ""

& $exe /config:$cfg /site:"Development Web Site" /systray:false
