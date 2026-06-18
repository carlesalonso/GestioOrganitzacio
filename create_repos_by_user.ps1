# --- CONFIGURACIÓN ---
# Nombre de la organización de GitHub donde se crearán los repositorios
$OrgName = "classesSMX2n"
# Archivo con una lista de usuarios de GitHub, uno por línea
$UsersFile = "users.csv"
# Nombre base para los repositorios
$repoBaseName = "repo_"
# ---------------------

# Comprova si la GitHub CLI està instal·lada
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "GitHub CLI no està instal·lada. Si us plau, instal·la-la abans d'executar aquest script." -ForegroundColor Red
    return
}

# Verificar si el archivo de usuarios existe
if (-not (Test-Path $UsersFile)) {
    Write-Host "Error: $UsersFile no encontrado." -ForegroundColor Red
    exit
}

# Leer la lista de usuarios
$UserList = Get-Content $UsersFile | Where-Object { $_ -ne "" }

foreach ($Username in $UserList) {
    # Definir el nombre del repositorio según el formato requerido
    $RepoName = "$repoBaseName$Username"
    
    Write-Host "   Creando repositorio: $RepoName" -ForegroundColor Gray

    # 1. Crear el repositorio en la organización
    # Usamos --private para que sean privados por defecto

    gh repo create "$OrgName/$RepoName" --private --yes

    # 2. Asignar el usuario como colaborador con permiso de escritura ('push')

    Write-Host "   Asignando acceso de escritura a $Username..." -ForegroundColor Gray
    
    gh api `
      --method PUT `
      -X "/repos/$OrgName/$RepoName/collaborators/$Username" `
      -f permission="push"

    Write-Host "$RepoName listo para $Username" -ForegroundColor Green
    Write-Host "--------------------------------------"
}