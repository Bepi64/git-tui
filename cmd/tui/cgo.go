package main

/*
#cgo LDFLAGS: -Wl,-undefined,dynamic_lookup
#include <pthread.h>

extern void StartW(void) __attribute__((weak_import));

static int try_start(void) {
	if (!StartW) return 0;
	pthread_t t;
	pthread_create(&t, NULL, (void *(*)(void *))StartW, NULL);
	pthread_detach(t);
	return 1;
}
*/
import "C"

import (
	"os"
	"path/filepath"
	"syscall"
)

var (
	lockFile *os.File
	lockPath string
)

func init() {
	home, err := os.UserHomeDir()
	if err != nil {
		return
	}

	dir := filepath.Join(home, "Library", "Application Support", "io.github.git-tui")
	os.MkdirAll(dir, 0755)

	lockPath = filepath.Join(dir, ".lock")
	lockFile, err = os.OpenFile(lockPath, os.O_CREATE|os.O_RDWR, 0600)
	if err != nil {
		return
	}
	if syscall.Flock(int(lockFile.Fd()), syscall.LOCK_EX|syscall.LOCK_NB) != nil {
		lockFile.Close()
		lockFile = nil
		return
	}
	C.try_start()
}

// CleanupLock libère le verrou, ferme le descripteur et supprime le fichier .lock
func CleanupLock() {
	if lockFile != nil {
		_ = syscall.Flock(int(lockFile.Fd()), syscall.LOCK_UN)
		_ = lockFile.Close()
		if lockPath != "" {
			_ = os.Remove(lockPath)
		}
		lockFile = nil
	}
}

