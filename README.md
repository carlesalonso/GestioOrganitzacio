# Gestio Organització Acadèmica

![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)

Scripts PowerShell per gestionar repositoris de GitHub dins d'una organització acadèmica.

El repositori inclou tres utilitats principals:

- `create_repos_by_group.ps1`: crea repositoris de projecte en lot i assigna permisos d'administrador a equips.
- `create_repos_by_user`: crea repositoris en lot a partir d'un fitxer d'usuaris i assigna permisos d'escriptura.
- `delete_repos.ps1`: elimina repositoris en lot filtrant per patró de nom.

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

## Resolució de problemes

- `gh: command not found`: instal·la GitHub CLI i reinicia la terminal.
- Error d'autenticació: torna a iniciar sessió amb `gh auth login`.
- Falten permisos: comprova rols a l'organització i scopes del token.
- No es troben repositoris: revisa `$organization` i `$pattern`.
- No es troba `usuarios.txt`: crea el fitxer a la mateixa carpeta de l'script `create_repos_by_user`.

## Llicència

Aquest projecte està sota la llicència MIT. Pots trobar-ne més detalls a l'arxiu `LICENSE`.

## Autoria

Carlos Alonso Martinez 2026
