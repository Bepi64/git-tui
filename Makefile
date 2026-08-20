BINARY := bin/git-tui
PACKAGE := ./cmd/tui

export CGO_ENABLED := 1

.PHONY: build run test vet fmt tidy clean

build:
	go build -o $(BINARY) $(PACKAGE)

run: build
	./$(BINARY) $(ARGS)

test:
	go test ./...

vet:
	go vet ./...

fmt:
	gofmt -l .

tidy:
	go mod tidy

clean:
	rm -rf bin
