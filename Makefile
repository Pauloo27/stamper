BINARY_NAME = stamper

DIST_LDFLAGS = -w -s
TEST_COMMAND=go test

.PHONY: build
build:
	go build -v -o $(BINARY_NAME) ./cmd/$(BINARY_NAME)

.PHONY: run
run: build
	./$(BINARY_NAME) 

.PHONY: test
test: 
	$(TEST_COMMAND) -cover -parallel 5 -failfast -count=1 ./... 

# human readable test output
.PHONY: htest
htest:
	gotestsum ./...

# human readable test output, watch for changes
.PHONY: whtest
whtest:
	gotestsum --watch ./...

.PHONY: tidy
tidy:
	go mod tidy

# (build but with a smaller binary)
.PHONY: dist
dist:
	go build -gcflags=all=-l -v -ldflags="$(DIST_LDFLAGS)" -o $(BINARY_NAME) ./cmd/$(BINARY_NAME)

# (even smaller binary)
.PHONY: pack
pack: dist
	upx ./$(BINARY_NAME)

.PHONY: lint
lint:
	revive -formatter friendly -config revive.toml ./...

.PHONY: staticcheck
staticcheck:
	staticcheck ./...

.PHONY: gosec
gosec:
	gosec -tests ./... 

.PHONY: inspect
inspect: lint gosec staticcheck

# auto restart bot (using fiber CLI)
.PHONY: dev
dev:
	fiber dev -t ./cmd/$(BINARY_NAME)
