# Accept-All-GitHub-Invites.ps1
# Acepta todas las invitaciones de repositorios en GitHub usando GitHub CLI

Write-Host "🔍 Comprobando si GitHub CLI está instalado..."
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "❌ GitHub CLI no está instalado. Instálalo desde https://cli.github.com/" -ForegroundColor Red
    exit 1
}

Write-Host "Verificando autenticación..."
$auth = (gh auth status 2>&1) -join "`n"

if ($auth -notmatch "Token scopes:.*repo") {
    Write-Host "No tienes el scope 'repo'. Reautenticando..."
    gh auth login --scopes repo
}

Write-Host "Obteniendo invitaciones pendientes..."
$invites = gh api user/repository_invitations --jq '.[] | {id: .id, user: .inviter.login, repo: .repository.full_name}' | ConvertFrom-Json

if (-not $invites) {
    Write-Host "No hay invitaciones pendientes." -ForegroundColor Green
    exit 0
}

Write-Host "Invitaciones encontradas:"
$invites | ForEach-Object { Write-Host " - De $($_.user) para el repositorio $($_.repo)" }

Write-Host "Aceptando invitaciones..."
$invites | ForEach-Object {
    Write-Host "   → Aceptando invitación de $($_.user) ($($_.repo)) ..."
    gh api "user/repository_invitations/$($_.id)" -X PATCH
}

Write-Host "Todas las invitaciones han sido aceptadas correctamente." -ForegroundColor Green
exit 0