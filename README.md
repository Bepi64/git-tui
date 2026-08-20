# my_first_go_tool

TUI en Go pour parcourir un dépôt GitHub distant sans le cloner : arbre des
fichiers + README chargés au démarrage, contenu d'un fichier téléchargé à la
volée seulement quand on l'ouvre.

## Build

```sh
go build -o bin/tui ./cmd/tui
```

## Usage

```sh
export GITHUB_TOKEN=ghp_...   # optionnel, mais passe de 60 à 5000 requêtes/heure
./bin/tui charmbracelet/bubbletea
```

Touches : `↑`/`↓` (ou `j`/`k`) naviguer, `entrée` ouvrir un fichier ou
déplier/replier un dossier, `pgup`/`pgdown` (ou `u`/`d`) défiler le contenu,
`esc` revenir au README, `q` quitter.
