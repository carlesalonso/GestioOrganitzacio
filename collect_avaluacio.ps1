# Rutas de origen y destino
$RutaRepos = "C:\ruta\a\repos"
$RutaDestino = "C:\ruta\de\destino"

# Validar que el directorio de origen existe
if (-not (Test-Path -Path $RutaRepos -PathType Container)) {
    Write-Error "El directorio de origen no existe: $RutaRepos"
    exit 1
}

# Crear el directorio de destino si no existe previamente
if (-not (Test-Path -Path $RutaDestino -PathType Container)) {
    New-Item -Path $RutaDestino -ItemType Directory -Force | Out-Null
    Write-Output "[INFO] Carpeta de destino creada: $RutaDestino"
}

# Obtener únicamente las carpetas de primer nivel dentro de "repos"
$Carpetas = Get-ChildItem -Path $RutaRepos -Directory

foreach ($Carpeta in $Carpetas) {
    $Origen = Join-Path -Path $Carpeta.FullName -ChildPath "avaluacio.md"

    if (Test-Path -Path $Origen -PathType Leaf) {
        $Destino = Join-Path -Path $RutaDestino -ChildPath "$($Carpeta.Name).md"
        
        Copy-Item -Path $Origen -Destination $Destino -Force
        Write-Output "[OK] $($Carpeta.Name)\avaluacio.md -> $Destino"
    }
    else {
        Write-Warning "[OMITIDO] No se encontró 'avaluacio.md' en: $($Carpeta.Name)"
    }
}