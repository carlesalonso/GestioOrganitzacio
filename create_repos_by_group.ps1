# Configuration
$organization = "teva-org"
$numGroups = 12

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