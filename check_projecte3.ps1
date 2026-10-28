# check_projecte3.ps1
# Comprova que els repositoris dels alumnes compleixen els requisits del Projecte 3:
#   1. El repositori és privat i s'ha creat a partir de la plantilla "smx-projecteintermodular/projecte3_template"
#   2. Existeix l'estructura de carpetes: tasca01, tasca02, tasca03
#   3. Existeix l'arxiu Tasca2-GitHub.md dins de la carpeta tasca02
#   4. S'han afegit els col·laboradors: carlesalonso, iboschmi, cfugarolas, CR1stiancom

# --- CONFIGURACIÓ ---
# Fitxer de text amb una URL (o owner/repo) de repositori d'alumne per línia
$ReposFile = "assets/repos_projecte3.txt"
# Nom complet (owner/repo) de la plantilla esperada
$ExpectedTemplate = "smx-projecteintermodular/projecte3_template"
# Carpetes obligatòries a l'arrel del repositori
$RequiredFolders = @("tasca02")
# Col·laboradors que han d'estar afegits al repositori
$RequiredCollaborators = @("carlesalonso", "iboschmi", "cfugarolas", "CR1stiancom")
# Arxiu obligatori dins de la carpeta tasca02
$RequiredFileInTasca02 = "Tasca2-GitHub.md"
# Fitxer CSV on es desa el resum de resultats
$ReportFile = "check_projecte3_report.csv"
# ---------------------

# Comprova si la GitHub CLI està instal·lada
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "GitHub CLI no està instal·lada. Si us plau, instal·la-la abans d'executar aquest script." -ForegroundColor Red
    exit 1
}

# Verificar si el fitxer de repositoris existeix
if (-not (Test-Path $ReposFile)) {
    Write-Host "Error: $ReposFile no trobat." -ForegroundColor Red
    Write-Host "A la carpeta assets crea un fitxer anomenat repos_projecte3.txt amb un owner/repo d'alumne per línia." -ForegroundColor Yellow
    exit 1
}

function Get-OwnerRepo {
    param([string]$RepoUrlOrSlug)

    $value = $RepoUrlOrSlug.Trim()
    if ($value -eq "") { return $null }

    # Accepta URLs completes (amb o sense .git) o directament "owner/repo"
    $value = $value -replace '^https?://github\.com/', ''
    $value = $value -replace '\.git$', ''
    $value = $value.Trim('/')

    $parts = $value.Split('/')
    if ($parts.Length -lt 2) { return $null }

    return "$($parts[0])/$($parts[1])"
}

# Llegir la llista de repositoris (ignorant línies buides i comentaris)
$RepoLines = Get-Content $ReposFile | Where-Object { $_.Trim() -ne "" -and $_.Trim() -notmatch '^#' }

$results = @()

foreach ($line in $RepoLines) {
    $ownerRepo = Get-OwnerRepo -RepoUrlOrSlug $line
    if (-not $ownerRepo) {
        Write-Host "Línia no vàlida, s'ignora: $line" -ForegroundColor Yellow
        continue
    }

    Write-Host "========================================"
    Write-Host "Comprovant repositori: $ownerRepo" -ForegroundColor Cyan

    $result = [ordered]@{
        Repositori         = $ownerRepo
        PlantillaCorrecta  = $false
        RepositoriPrivat   = $false
        CarpetesFaltants   = ""
        ArxiuTasca02       = $false
        ColsFaltants       = ""
        Estat              = "ERROR"
    }

    # 1. Comprovar que el repositori és privat i s'ha generat a partir de la plantilla esperada
    $repoInfoJson = gh api "repos/$ownerRepo" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   No s'ha pogut accedir al repositori: $repoInfoJson" -ForegroundColor Red
        $result.Estat = "REPO NO ACCESSIBLE"
        $results += [pscustomobject]$result
        continue
    }

    $repoInfo = $repoInfoJson | ConvertFrom-Json
    $templateFullName = $repoInfo.template_repository.full_name

    if ($repoInfo.private -eq $true) {
        Write-Host "   [OK] El repositori és privat" -ForegroundColor Green
        $result.RepositoriPrivat = $true
    } else {
        Write-Host "   [FALLA] El repositori no és privat" -ForegroundColor Red
    }

    if ($templateFullName -eq $ExpectedTemplate) {
        Write-Host "   [OK] Creat a partir de la plantilla ($ExpectedTemplate)" -ForegroundColor Green
        $result.PlantillaCorrecta = $true
    } else {
        $foundTemplate = if ($templateFullName) { $templateFullName } else { "(cap)" }
        Write-Host "   [FALLA] Plantilla incorrecta. Esperada: $ExpectedTemplate / Trobada: $foundTemplate" -ForegroundColor Red
        $result.PlantillaCorrecta = $false
    }

# 2. Comprovar els col·laboradors del repositori
    $collaboratorsJson = gh api "repos/$ownerRepo/collaborators" --paginate 2>&1
    $missingCollaborators = @()

    if ($LASTEXITCODE -ne 0) {
        Write-Host "   No s'ha pogut llistar els col·laboradors: $collaboratorsJson" -ForegroundColor Red
        $missingCollaborators = $RequiredCollaborators
    } else {
        $collaborators = $collaboratorsJson | ConvertFrom-Json
        $existingLogins = $collaborators | ForEach-Object { $_.login }

        foreach ($collab in $RequiredCollaborators) {
            if ($existingLogins -contains $collab) {
                Write-Host "   [OK] Col·laborador present: $collab" -ForegroundColor Green
            } else {
                Write-Host "   [FALLA] Col·laborador no trobat: $collab" -ForegroundColor Red
                $missingCollaborators += $collab
            }
        }
    }
    $result.ColsFaltants = ($missingCollaborators -join ", ")

    # 3. Comprovar l'estructura de carpetes a l'arrel del repositori
    $contentsJson = gh api "repos/$ownerRepo/contents" 2>&1
    $missingFolders = @()

    if ($LASTEXITCODE -ne 0) {
        Write-Host "   No s'ha pogut llistar el contingut del repositori: $contentsJson" -ForegroundColor Red
        $missingFolders = $RequiredFolders
    } else {
        $contents = $contentsJson | ConvertFrom-Json
        $existingDirs = $contents | Where-Object { $_.type -eq "dir" } | ForEach-Object { $_.name }

        foreach ($folder in $RequiredFolders) {
            if ($existingDirs -contains $folder) {
                Write-Host "   [OK] Carpeta trobada: $folder" -ForegroundColor Green
            } else {
                Write-Host "   [FALLA] Carpeta no trobada: $folder" -ForegroundColor Red
                $missingFolders += $folder
            }
        }
    }
    $result.CarpetesFaltants = ($missingFolders -join ", ")

    # 4. Comprovar que existeix l'arxiu Tasca2-GitHub.md dins de la carpeta tasca02
    $tasca02FileOk = $false
    if ($missingFolders -contains "tasca02") {
        Write-Host "   [FALLA] No es pot comprovar l'arxiu $RequiredFileInTasca02 perquè falta la carpeta tasca02" -ForegroundColor Red
    } else {
        $tasca02Directory = $contents | Where-Object { $_.type -eq "dir" -and $_.name -ieq "tasca02" } | Select-Object -First 1
        $tasca02ContentsJson = gh api "repos/$ownerRepo/contents/$($tasca02Directory.name)" 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "   No s'ha pogut llistar el contingut de tasca02: $tasca02ContentsJson" -ForegroundColor Red
        } else {
            $tasca02Contents = $tasca02ContentsJson | ConvertFrom-Json
            $existingFiles = $tasca02Contents | Where-Object { $_.type -eq "file" } | ForEach-Object { $_.name }


            if ($existingFiles -contains $RequiredFileInTasca02) {
                Write-Host "   [OK] Arxiu trobat: tasca02/$RequiredFileInTasca02" -ForegroundColor Green
                $tasca02FileOk = $true
            } else {
                Write-Host "   [FALLA] Arxiu no trobat: tasca02/$RequiredFileInTasca02" -ForegroundColor Red
            }
        }
    }
    $result.ArxiuTasca02 = $tasca02FileOk

    

    # Estat final del repositori
    if ($result.PlantillaCorrecta -and $result.RepositoriPrivat -and $missingFolders.Count -eq 0 -and $tasca02FileOk -and $missingCollaborators.Count -eq 0) {
        $result.Estat = "CORRECTE"
        Write-Host "   Resultat: CORRECTE" -ForegroundColor Green
    } else {
        $result.Estat = "INCOMPLET"
        Write-Host "   Resultat: INCOMPLET" -ForegroundColor Yellow
    }

    $results += [pscustomobject]$result
}

Write-Host "========================================"
Write-Host "Resum final:" -ForegroundColor Cyan
$results | Format-Table -AutoSize

$results | Export-Csv -Path $ReportFile -NoTypeInformation -Encoding UTF8
Write-Host "Informe desat a: $ReportFile" -ForegroundColor Green

if ($results | Where-Object { $_.Estat -ne "CORRECTE" }) {
    exit 1
}

exit 0
