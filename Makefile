NAME = glidergun
BINARYNAME=gun
OWNER =gliderlabs
HARDWARE = $(shell uname -m)
SYSTEM_NAME  = $(shell uname -s | tr '[:upper:]' '[:lower:]')
VERSION=0.1.0

build: src
	mkdir -p build/linux-arm && GOOS=linux GOARCH=arm CGO_ENABLED=0 go build -a \
		-installsuffix cgo \
		-ldflags "-X main.Version=$(VERSION)" \
		-o build/linux-arm/$(BINARYNAME)
	mkdir -p build/linux-arm64 && GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -a \
		-installsuffix cgo \
		-ldflags "-X main.Version=$(VERSION)" \
		-o build/linux-arm64/$(BINARYNAME)
	mkdir -p build/linux-amd64 && GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -a \
		-installsuffix cgo \
		-ldflags "-X main.Version=$(VERSION)" \
		-o build/linux-amd64/$(BINARYNAME)
	mkdir -p build/darwin-arm64 && GOOS=darwin GOARCH=arm64 CGO_ENABLED=0 go build -a \
		-installsuffix cgo \
		-ldflags "-X main.Version=$(VERSION)" \
		-o build/darwin-arm64/$(BINARYNAME)
	mkdir -p build/darwin-amd64 && GOOS=darwin GOARCH=amd64 CGO_ENABLED=0 go build -a \
		-installsuffix cgo \
		-ldflags "-X main.Version=$(VERSION)" \
		-o build/darwin-amd64/$(BINARYNAME)

test: src
	go install
	GUN=glidergun basht tests/*.bash

src:
	go-bindata src

install: build
	install build/$(shell uname -s)/gun /usr/local/bin

deps: gh-release
	cd / && go get -u github.com/jteeuwen/go-bindata/...
	cd / && go get -u github.com/progrium/basht/...

gh-release:
	mkdir -p bin
	curl -o bin/gh-release.tgz -sL https://github.com/progrium/gh-release/releases/download/v2.3.3/gh-release_2.3.3_$(SYSTEM_NAME)_$(HARDWARE).tgz
	tar xf bin/gh-release.tgz -C /usr/local/bin
	chmod +x /usr/local/bin/gh-release

release:
	rm -rf release && mkdir release
	tar -zcf release/$(NAME)_$(VERSION)_linux_arm.tgz -C build/linux-arm $(BINARYNAME)
	tar -zcf release/$(NAME)_$(VERSION)_linux_arm64.tgz -C build/linux-arm64 $(BINARYNAME)
	tar -zcf release/$(NAME)_$(VERSION)_linux_amd64.tgz -C build/linux-amd64 $(BINARYNAME)
	tar -zcf release/$(NAME)_$(VERSION)_darwin_arm64.tgz -C build/darwin-arm64 $(BINARYNAME)
	tar -zcf release/$(NAME)_$(VERSION)_darwin_amd64.tgz -C build/darwin-amd64 $(BINARYNAME)
	gh-release checksums sha256
	gh-release create $(OWNER)/$(NAME) $(VERSION) $(shell git rev-parse --abbrev-ref HEAD) v$(VERSION)

clean:
	rm -rf build release

.PHONY: build release src
