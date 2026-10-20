# Accept-All-GitHub-Invites.ps1
# Acepta todas las invitaciones de repositorios en GitHub usando GitHub CLI

Write-Host "🔍 Comprobando si GitHub CLI está instalado..."
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "❌ GitHub CLI no está instalado. Instálalo desde https://cli.github.com/" -ForegroundColor Red
    exit 1
}

Write-Host "🔐 Verificando autenticación..."
$auth = gh auth status 2>&1

if ($auth -notmatch "Scopes:.*repo") {
    Write-Host "⚠️ No tienes el scope 'repo'. Reautenticando..."
    gh auth login --scopes repo
}

Write-Host "📥 Obteniendo invitaciones pendientes..."
$inviteIds = gh api user/repository_invitations --jq '.[].id'

if (-not $inviteIds) {
    Write-Host "✔️ No hay invitaciones pendientes." -ForegroundColor Green
    exit 0
}

Write-Host "📌 Invitaciones encontradas:"
$inviteIds | ForEach-Object { Write-Host " - ID: $_" }

Write-Host "🚀 Aceptando invitaciones..."
$inviteIds | ForEach-Object {
    Write-Host "   → Aceptando invitación $_ ..."
    gh api "user/repository_invitations/$_" -X PATCH
}

Write-Host "🎉 Todas las invitaciones han sido aceptadas correctamente." -ForegroundColor Green
