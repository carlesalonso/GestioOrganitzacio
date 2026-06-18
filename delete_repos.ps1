# Variables de configuració
$organization = "classesSMX2n"
$pattern = "repo_"

# Comprova si la GitHub CLI està instal·lada
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "GitHub CLI no està instal·lada. Si us plau, instal·la-la abans d'executar aquest script." -ForegroundColor Red
    return
}

# Comprova si el token actual té permisos per eliminar repositoris
$authStatus = gh auth status -h github.com 2>&1 | Out-String

if ($LASTEXITCODE -ne 0) {
    Write-Host "No s'ha pogut comprovar l'autenticació de GitHub CLI."
    Write-Host $authStatus
    return
}

if ($authStatus -match "delete_repo") {
    Write-Host "Permís delete_repo detectat al token actual."
}
else {
    Write-Host "Falta el permís delete_repo. Sol·licitant actualització d'autenticació..."
    gh auth refresh -h github.com -s delete_repo
    if ($LASTEXITCODE -ne 0) {
        Write-Host "No s'ha pogut obtenir el permís delete_repo."
        return
    }
}

Write-Host "Buscant repositoris amb el patró '$pattern'..."

# Buscant repositoris que coincideixin amb el patró especificat
$repos = gh repo list $organization --limit 1000 --json name -q ".[].name" | Where-Object { $_ -like "$pattern*" }

if (-not $repos) {
    Write-Host "No s'han trobat repositoris que coincideixin amb el patró '$pattern'."
    return
}

foreach ($repo in $repos) {
    Write-Host "Eliminant repositori: $organization/$repo..."
    
    try {
        # Delete the repository
        $deleteOutput = gh repo delete "$organization/$repo" --yes 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw ($deleteOutput | Out-String)
        }
        Write-Host "Eliminat amb èxit: $repo"
    }
    catch {
        Write-Host "Error en eliminar el repositori {$organization/$repo}: $($_.Exception.Message)"
    }
}

Write-Host "Process de neteja completat."