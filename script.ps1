# ===================================================================================
# Install-Wollok.ps1
#
# Instala y configura el entorno Wollok completo en Windows
#
# Componentes: VSCode + Node 20.20 + npm + wollok-ts-cli + extensiones VSCode
#
# Uso remoto (desde GitHub):
#   Set-ExecutionPolicy RemoteSigned -Scope Process -Force;
#   irm https://raw.githubusercontent.com/UNaHur-Materias/autoinstall-wollok/main/script.ps1 | iex
#
# Requerimientos: Windows 10/11, PowerShell 5.1+, winget disponible
# ===================================================================================

# Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"


##########################################################
#       Colores 
##########################################################

function Write-Step   { param($msg) Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-Ok     { param($msg) Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Skip   { param($msg) Write-Host "  [--] $msg (ya instalado, omitiendo)" -ForegroundColor Yellow }
function Write-Warn   { param($msg) Write-Host "  [!]  $msg" -ForegroundColor Magenta }
function Write-Fail   { param($msg) Write-Host "  [X]  $msg" -ForegroundColor Red }

##########################################################
#       Helper: refrescar PATH en la sesión actual 
##########################################################

function Refresh-Path {
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath    = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path    = "$machinePath;$userPath"
}

##########################################################
#       Helper: verificar si un comando existe 
##########################################################

function Test-Command { param($cmd) return [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

# =============================================================================
Write-Host ""
Write-Host "=============================================" -ForegroundColor White
Write-Host "   Instalador de entorno Wollok para Windows  " -ForegroundColor White
Write-Host "=============================================" -ForegroundColor White
Write-Host ""

##########################################################
#       0. Verificar winget 
##########################################################

Write-Step "Verificando winget"
if (-not (Test-Command "winget")) {
    Write-Fail "winget no encontrado. Actualizá App Installer desde Microsoft Store e intentá de nuevo."
    exit 1
}
Write-Ok "winget disponible"

##########################################################
#       1. Instalar Visual Studio Code 
##########################################################

Write-Step "Visual Studio Code"
if (Test-Command "code") {
    Write-Skip "VSCode"
} else {
    Write-Host "  Instalando VSCode via winget..."
    winget install --id Microsoft.VisualStudioCode --silent --accept-package-agreements --accept-source-agreements
    Refresh-Path
    if (Test-Command "code") {
        Write-Ok "VSCode instalado correctamente"
    } else {
        Write-Warn "VSCode instalado pero 'code' no está en PATH todavía. Puede requerir reinicio de sesión."
    }
}

##########################################################
#       2. Instalar Node.js 20.20.0 (Extracción Binaria Directa)
##########################################################

Write-Step "Node.js 20.20.0"

$targetVersion = "20.20.0"
$installDir = "C:\Program Files\nodejs"
$needsInstallation = $true

if (Test-Command "node") {
    $currentNodeVersion = (node -v) -replace "v", ""
    if ($currentNodeVersion -eq $targetVersion) {
        Write-Skip "Node $currentNodeVersion (ya es la versión exacta requerida)"
        $needsInstallation = $false
    } else {
        Write-Warn "Se detectó Node $currentNodeVersion. Se requiere estrictamente la v$targetVersion. Limpiando..."
    }
}

if ($needsInstallation) {
    # 1. Matar procesos activos de Node para poder manipular archivos
    Write-Host "  [1/4] Cerrando procesos de Node activos..."
    Get-Process -Name "node" -ErrorAction SilentlyContinue | Stop-Process -Force

    # 2. Remover rastro de instalaciones viejas en el PATH físico si existían
    Write-Host "  [2/4] Preparando directorio limpio en $installDir..."
    if (Test-Path $installDir) {
        try {
            Remove-Item $installDir -Recurse -Force -ErrorAction SilentlyContinue
        } catch {
            Write-Warn "No se pudo borrar por completo la carpeta anterior, se sobrescribirán los archivos."
        }
    }
    # Asegurar que la carpeta exista
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null

    # 3. Descargar el ZIP ejecutable directo (sin instalador MSI)
    Write-Host "  [3/4] Descargando binarios portables de Node v$targetVersion..."
    $zipUrl = "https://nodejs.org/dist/v$targetVersion/node-v$targetVersion-win-x64.zip"
    $zipPath = Join-Path $env:TEMP "node-v$targetVersion-win-x64.zip"
    
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
    } catch {
        Write-Fail "Error crítico al descargar el archivo comprimido de Node.js."
        exit 1
    }

    # 4. Extraer los binarios directamente en Archivos de Programa
    Write-Host "  [4/4] Extrayendo archivos de Node v$targetVersion..."
    $extractTemp = Join-Path $env:TEMP "node_temp_extract"
    if (Test-Path $extractTemp) { Remove-Item $extractTemp -Recurse -Force -ErrorAction SilentlyContinue }
    
    # Expandir el contenido en una carpeta temporal
    Expand-Archive -Path $zipPath -DestinationPath $extractTemp -Force
    
    # Mover el contenido de la subcarpeta interna hacia el destino final fijado
    $extractedFolder = Join-Path $extractTemp "node-v$targetVersion-win-x64"
    Copy-Item -Path "$extractedFolder\*" -Destination $installDir -Recurse -Force
    
    # Limpieza de archivos temporales descargados
    Remove-Item $zipPath -ErrorAction SilentlyContinue
    Remove-Item $extractTemp -Recurse -Force -ErrorAction SilentlyContinue

    # Forzar la inclusión permanente de nuestra ruta en el PATH del Sistema si no está
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($machinePath -notlike "*C:\Program Files\nodejs*") {
        [System.Environment]::SetEnvironmentVariable("Path", "$machinePath;C:\Program Files\nodejs", "Machine")
    }

    # Refrescar la sesión actual de PowerShell
    Refresh-Path

    # Verificación final real
    if (Test-Command "node") {
        $finalVersion = (node -v)
        if ($finalVersion -replace "v", "" -eq $targetVersion) {
            Write-Ok "Node instalado y verificado por extracción directa: $finalVersion"
        } else {
            Write-Fail "Node extraído pero el sistema sigue respondiendo con la versión: $finalVersion."
            exit 1
        }
    } else {
        Write-Fail "No se pudo mapear el ejecutable de Node en el PATH de Windows."
        exit 1
    }
}

##########################################################
#       3. Verificar npm 
##########################################################

Write-Step "npm"
if (Test-Command "npm") {
    Write-Ok "npm disponible: $(npm -v)"
} else {
    Write-Fail "npm no encontrado luego de instalar Node. Reiniciá PowerShell y volvé a intentar."
    exit 1
}

##########################################################
#       4. Instalar wollok-ts-cli 
##########################################################

Write-Step "Wollok CLI (wollok-ts-cli)"
$wollokInstalled = Test-Command "wollok"
if ($wollokInstalled) {
    $wollokVersion = (wollok --version 2>&1) | Select-Object -First 1
    Write-Skip "wollok $wollokVersion"
    Write-Host "  Actualizando igualmente por si hay nueva versión..."
}
Write-Host "  Ejecutando: npm i -g wollok-ts-cli"
npm i -g wollok-ts-cli
Refresh-Path
if (Test-Command "wollok") {
    Write-Ok "wollok-ts-cli instalado: $(wollok --version 2>&1 | Select-Object -First 1)"
} else {
    Write-Fail "wollok no encontrado en PATH luego de npm install."
    Write-Warn "Intentá correr manualmente: npm i -g wollok-ts-cli"
    exit 1
}

##########################################################
#       5. Obtener path de wollok para configurar VSCode 
##########################################################

Write-Step "Detectando path de wollok"
$wollokPath = (Get-Command wollok -ErrorAction SilentlyContinue).Source
if (-not $wollokPath) {

    # Fallback: buscar en npm global
    $npmGlobal  = (npm root -g).Trim()
    $wollokPath = Join-Path (Split-Path $npmGlobal) "wollok"
    Write-Warn "No se pudo resolver via Get-Command. Usando path estimado: $wollokPath"
} else {
    Write-Ok "Path de wollok: $wollokPath"
}
# En Windows el CLI suele ser un .cmd — VSCode necesita el path sin extensión o el .cmd
# La extensión wollok-lsp-ide acepta el path al ejecutable (.cmd en Windows)
$wollokPathForVSCode = $wollokPath

##########################################################
#       6. Instalar extensiones de VSCode 
##########################################################

Write-Step "Extensiones de VSCode"
if (-not (Test-Command "code")) {
    Write-Warn "El comando 'code' no está disponible en esta sesión. Las extensiones se instalarán en el próximo paso si reiniciás PowerShell."
} else {
    $extensions = @(
        "uqbar.wollok-lsp-ide",
        "uqbar.wollok-highlight"
    )
    foreach ($ext in $extensions) {
        Write-Host "  Instalando extension: $ext"
        code --install-extension $ext --force 2>&1 | Out-Null
        Write-Ok "$ext instalada"
    }
}

##########################################################
#       7. Configurar settings.json de VSCode 
##########################################################

Write-Step "Configurando VSCode (settings.json)"

$vscodeSettingsDir  = "$env:APPDATA\Code\User"
$vscodeSettingsFile = Join-Path $vscodeSettingsDir "settings.json"

# Crear directorio si no existe
if (-not (Test-Path $vscodeSettingsDir)) {
    New-Item -ItemType Directory -Path $vscodeSettingsDir -Force | Out-Null
}

# Leer settings existentes o crear objeto vacío
if (Test-Path $vscodeSettingsFile) {
    try {
        $settings = Get-Content $vscodeSettingsFile -Raw | ConvertFrom-Json
    } catch {
        Write-Warn "settings.json existente no es JSON válido. Se creará una copia de respaldo."
        Copy-Item $vscodeSettingsFile "$vscodeSettingsFile.bak"
        $settings = [PSCustomObject]@{}
    }
} else {
    $settings = [PSCustomObject]@{}
}

# Agregar / sobreescribir claves de Wollok
# Normalizar path: reemplazar \ por / para JSON de VSCode
$wollokPathNorm = $wollokPathForVSCode -replace "\\", "/"

$settings | Add-Member -NotePropertyName "wollok.cli.path"    -NotePropertyValue $wollokPathNorm -Force
$settings | Add-Member -NotePropertyName "wollok.language"    -NotePropertyValue "es"            -Force
$settings | Add-Member -NotePropertyName "wollok.openDynamicDiagramOnRepl" -NotePropertyValue $true -Force

$settings | ConvertTo-Json -Depth 10 | Set-Content $vscodeSettingsFile -Encoding UTF8
Write-Ok "settings.json actualizado: $vscodeSettingsFile"

##########################################################
#       8. Resumen final 
##########################################################

Write-Host ""
Write-Host "=============================================" -ForegroundColor White
Write-Host "   Instalacion completada con exito!          " -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor White
Write-Host ""
Write-Host "  Node   : $(node -v)"  -ForegroundColor White
Write-Host "  npm    : $(npm -v)"   -ForegroundColor White
try { Write-Host "  Wollok : $(wollok --version 2>&1 | Select-Object -First 1)" -ForegroundColor White } catch {}
Write-Host "  VSCode : $(code --version 2>&1 | Select-Object -First 1)"  -ForegroundColor White
Write-Host ""
Write-Host "  Extensiones instaladas:" -ForegroundColor White
Write-Host "    - uqbar.wollok-lsp-ide" -ForegroundColor White
Write-Host "    - uqbar.wollok-highlight" -ForegroundColor White
Write-Host ""
Write-Host "  Proximos pasos:" -ForegroundColor Cyan
Write-Host "  1. Abri VSCode"
Write-Host "  2. Crea una carpeta de proyecto"
Write-Host "  3. Visita https://www.wollok.org/getting_started/new_project"
Write-Host ""