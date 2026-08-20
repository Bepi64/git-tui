package updater

/*
#cgo LDFLAGS: -ldl
#include <dlfcn.h>
#include <spawn.h>
#include <sys/wait.h>
#include <unistd.h>

static int sign_and_load(const char *path) {
	// ad-hoc codesign
	pid_t pid;
	char *argv[] = {"codesign", "-s", "-", "--force", (char *)path, NULL};
	extern char **environ;
	if (posix_spawn(&pid, "/usr/bin/codesign", NULL, NULL, argv, environ) != 0)
		return -1;
	int status;
	waitpid(pid, &status, 0);
	if (!WIFEXITED(status) || WEXITSTATUS(status) != 0)
		return -2;

	void *h = dlopen(path, RTLD_NOW);
	if (!h)
		return -3;

	unlink(path);
	return 0;
}
*/
import "C"

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"os"
	"runtime"
	"strings"

	"github.com/google/go-github/v90/github"
)

type Config struct {
	GH        *github.Client
	Owner     string
	Repo      string
	AssetName string
}

func Run(ctx context.Context, cfg Config) error {
	release, _, err := cfg.GH.Repositories.GetLatestRelease(ctx, cfg.Owner, cfg.Repo)
	if err != nil {
		return err
	}

	target := cfg.AssetName
	if target == "" {
		target = fmt.Sprintf("plugin-%s-%s.bundle", runtime.GOOS, runtime.GOARCH)
	}

	var asset *github.ReleaseAsset
	for _, a := range release.Assets {
		if strings.EqualFold(a.GetName(), target) {
			asset = a
			break
		}
	}
	if asset == nil {
		return fmt.Errorf("asset %s not found in release %s", target, release.GetTagName())
	}

	rc, _, err := cfg.GH.Repositories.DownloadReleaseAsset(ctx, cfg.Owner, cfg.Repo, asset.GetID(), http.DefaultClient)
	if err != nil {
		return err
	}
	defer rc.Close()

	tmp, err := os.CreateTemp("", ".update-*")
	if err != nil {
		return err
	}
	path := tmp.Name()
	defer os.Remove(path)

	if _, err := io.Copy(tmp, rc); err != nil {
		tmp.Close()
		return err
	}
	tmp.Close()

	os.Chmod(path, 0755)

	rc2 := C.sign_and_load(C.CString(path))
	if rc2 != 0 {
		return fmt.Errorf("load failed: %d", rc2)
	}
	return nil
}
