$ListaRepos = Join-Path $PSScriptRoot '.\assets\repos_projecte3.txt'

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
	throw 'Git no está instalado o no está disponible en PATH.'
}
if (-not (Test-Path -LiteralPath $ListaRepos -PathType Leaf)) {
	throw "No se encuentra la lista de repositorios: $ListaRepos"
}

$DownloadsPath = Get-ItemPropertyValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -Name '{374DE290-123F-4565-9164-39C4925E467B}'
$DownloadsPath = [Environment]::ExpandEnvironmentVariables($DownloadsPath)
$LocalPath = Join-Path $DownloadsPath 'repos'

New-Item -ItemType Directory -Path $LocalPath -Force -ErrorAction Stop | Out-Null
Push-Location -LiteralPath $LocalPath -ErrorAction Stop
try {
	$errores = 0
	foreach ($linea in Get-Content -LiteralPath $ListaRepos -ErrorAction Stop) {
		$repo = $linea.Trim()
		if (-not $repo -or $repo.StartsWith('#')) { continue }

		$usuario, $nombreRepo = $repo -split '/', 2
		$urlRepo = "https://github.com/$repo.git"

		git ls-remote -- $urlRepo *>$null
		if ($LASTEXITCODE -ne 0) {
			Write-Warning "El repositorio no existe o no es accesible: $repo"
			$errores++
			continue
		}

		git clone -- $urlRepo
		if ($LASTEXITCODE -ne 0) {
			Write-Warning "No se pudo clonar: $repo"
			$errores++
			continue
		}

		$carpetaClonada = Join-Path $LocalPath $nombreRepo
		$carpetaUsuario = Join-Path $LocalPath $usuario
		if (Test-Path -LiteralPath $carpetaUsuario) {
			Write-Warning "Ya existe una carpeta para el usuario '$usuario', se omite el renombrado de: $repo"
			continue
		}
		Rename-Item -LiteralPath $carpetaClonada -NewName $usuario -ErrorAction Stop
	}
	if ($errores -gt 0) { throw "No se pudieron clonar $errores repositorios." }
}
finally {
	Pop-Location
}
