# Gestio Organització Acadèmica

![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)

Scripts PowerShell per gestionar repositoris de GitHub a escola. Algunes de les accions que permeten són:

- Acceptar invitacions de col·laborador a repositoris de GitHub.
- Crear repositoris en lot per grups d'usuaris.
- Crear repositoris per usuari a partir d'un fitxer CSV.
- Eliminar repositoris en lot amb un patró de nom específic.

## Requisits

- Windows PowerShell 5.1+ o PowerShell 7+
- GitHub CLI (`gh`) instal·lat
- Sessió iniciada a GitHub CLI:

```powershell
gh auth login
```

- Permisos adequats a l'organització (crear repositoris, gestionar equips i, si escau, eliminar repositoris)

## Estructura del repositori

- `create_repos_by_group.ps1`
- `create_repos_by_user`
- `delete_repos.ps1`
- `Accept-All-GitHub-Invitations.ps1`

## 1) Crear repositoris en lot

L'script `create_repos_by_group.ps1`:

1. Recorre els grups del `01` fins al valor de `$numGroups`.
2. Crea un repositori privat amb format `projecte-grupXX`.
3. Assigna l'equip `grupXX` com a `admin` del repositori.

## 2) Crear repositoris per usuari

L'script `create_repos_by_user`:

1. Llegeix usuaris des de `users.csv` (un usuari de GitHub per línia).
2. Crea un repositori privat per cada usuari amb format `repo_<usuari>`.
3. Assigna cada usuari com a col·laborador amb permís `push` al seu repositori.

## 3) Eliminar repositoris en lot

L'script `delete_repos.ps1`:

1. Comprova l'autenticació de `gh`.
2. Verifica si el token actual té el scope `delete_repo`.
3. Si falta aquest scope, intenta refrescar l'autenticació.
4. Llista repositoris de l'organització.
5. Filtra els noms amb el patró indicat.
6. Elimina els repositoris trobats i captura errors per cada repositori.

## 4) Acceptar invitacions col·laborador

L'script `Accept-All-GitHub-Invitations.ps1`:

Serveix per acceptar totes les invitacions pendents de col·laborador a repositoris de GitHub. L'script:

1. Comprova l'autenticació de `gh`.
2. Llista totes les invitacions pendents.
3. Accepta cada invitació i mostra un missatge de confirmació.

## Llicència

Aquest projecte està sota la llicència MIT. Pots trobar-ne més detalls a l'arxiu `LICENSE`.

## Autoria

Carlos Alonso Martinez 2026
