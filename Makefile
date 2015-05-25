NAME=glidergun
BINARYNAME=gun
ARCH=$(shell uname -m)
VERSION=0.0.7

build:
	rm -rf .gun/bin && mkdir -p .gun/bin
	cp .bin/linux/* .gun/bin/ && go-bindata include .gun/bin
	mkdir -p build/Linux  && GOOS=linux  go build -ldflags "-X main.Version $(VERSION)" -o build/Linux/$(BINARYNAME)
	cp .bin/osx/* .gun/bin/ && go-bindata include .gun/bin
	mkdir -p build/Darwin && GOOS=darwin go build -ldflags "-X main.Version $(VERSION)" -o build/Darwin/$(BINARYNAME)

install: build
	install build/$(shell uname -s)/gun /usr/local/bin

deps:
	go get -u github.com/jteeuwen/go-bindata/...
	go get -u github.com/progrium/gh-release/...
	go get || true

binaries:
	mkdir -p .bin/linux .bin/osx
	curl -Lo .bin/linux/bash https://github.com/lalyos/bash-static-upx/releases/download/v4.3.30/bash-linux
	curl -Lo .bin/osx/bash https://github.com/lalyos/bash-static-upx/releases/download/v4.3.30/bash-osx
	chmod +x .bin/linux/* .bin/osx/*

release:
	rm -rf release && mkdir release
	tar -zcf release/$(NAME)_$(VERSION)_Linux_$(ARCH).tgz -C build/Linux $(BINARYNAME)
	tar -zcf release/$(NAME)_$(VERSION)_Darwin_$(ARCH).tgz -C build/Darwin $(BINARYNAME)
	gh-release checksums sha256
	gh-release create gliderlabs/$(NAME) $(VERSION) $(shell git rev-parse --abbrev-ref HEAD) v$(VERSION)

clean:
	rm -rf build release

.PHONY: build release
