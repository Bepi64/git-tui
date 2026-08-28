// Command tui affiche un dépôt GitHub distant dans un terminal : arborescence
// et README au démarrage, contenu des fichiers chargé à la demande, sans
// jamais cloner le dépôt.
package main

import (
	"fmt"
	"os"
	"strings"

	tea "github.com/charmbracelet/bubbletea"

	"my_first_go_tool/internal/ghclient"
	"my_first_go_tool/internal/ui"
)

func exitWithErr(msg ...any) {
	CleanupLock()
	fmt.Fprintln(os.Stderr, msg...)
	os.Exit(1)
}

func main() {
	defer CleanupLock()

	if len(os.Args) != 2 {
		select {}
	}

	owner, repo, ok := strings.Cut(os.Args[1], "/")
	if !ok || owner == "" || repo == "" {
		exitWithErr("usage: git-tui <owner>/<repo>  (exemple: tui charmbracelet/bubbletea)")
	}

	client, err := ghclient.New(os.Getenv("GITHUB_TOKEN"), owner, repo)
	if err != nil {
		exitWithErr("erreur:", err)
	}

	if _, err := tea.NewProgram(ui.NewModel(client)).Run(); err != nil {
		exitWithErr("erreur:", err)
	}
}
