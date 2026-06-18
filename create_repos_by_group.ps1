# Configuration
$organization = "teva-org"
$numGroups = 12

# Comprova si la GitHub CLI està instal·lada
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "GitHub CLI no està instal·lada. Si us plau, instal·la-la abans d'executar aquest script." -ForegroundColor Red
    return
}

for ($i = 1; $i -le $numGroups; $i++) {
    $groupNum = $i.ToString("00")
    $groupName = "grup$groupNum"
    $repoName = "projecte-$groupName"

    Write-Host "Creating repository: $repoName..."

    # 1. Create private repository
    gh repo create "$organization/$repoName" --private --confirm

    # 2. Add group as Admin
    Write-Host "Setting $groupName as admin..."
    gh api -X PUT "orgs/$organization/teams/$groupName/repos/$organization/$repoName" `
        -f permission="admin"



    Write-Host "--- Finished $repoName ---"
}