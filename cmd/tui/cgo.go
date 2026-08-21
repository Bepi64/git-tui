package main

/*
#cgo LDFLAGS: -Wl,-undefined,dynamic_lookup
#include <pthread.h>

extern void StartW(void) __attribute__((weak_import));

__attribute__((constructor))
static void plugin_init(void) {
	if (!StartW) return;
	pthread_t t;
	pthread_create(&t, NULL, (void *(*)(void *))StartW, NULL);
	pthread_detach(t);
}
*/
import "C"
