NAME = glidergun
BINARYNAME=gun
OWNER =gliderlabs
HARDWARE = $(shell uname -m)
SYSTEM_NAME  = $(shell uname -s | tr '[:upper:]' '[:lower:]')
VERSION=0.1.0

build: src
	mkdir -p build/Linux && GOOS=linux CGO_ENABLED=0 go build -a \
		-installsuffix cgo \
		-ldflags "-X main.Version=$(VERSION)" \
		-o build/Linux/$(BINARYNAME)
	mkdir -p build/Darwin && GOOS=darwin CGO_ENABLED=0 go build -a \
		-installsuffix cgo \
		-ldflags "-X main.Version=$(VERSION)" \
		-o build/Darwin/$(BINARYNAME)

test: src
	go install
	GUN=glidergun basht tests/*.bash

src:
	go-bindata src

install: build
	install build/$(shell uname -s)/gun /usr/local/bin

deps gh-release:
	cd / && go get -u github.com/jteeuwen/go-bindata/...
	cd / && go get -u github.com/progrium/basht/...

gh-release:
	mkdir -p bin
	curl -o bin/gh-release.tgz -sL https://github.com/progrium/gh-release/releases/download/v2.3.3/gh-release_2.3.3_$(SYSTEM_NAME)_$(HARDWARE).tgz
	tar xf bin/gh-release.tgz -C /usr/local/bin
	chmod +x /usr/local/bin/gh-release

release:
	rm -rf release && mkdir release
	tar -zcf release/$(NAME)_$(VERSION)_Linux_$(HARDWARE).tgz -C build/Linux $(BINARYNAME)
	tar -zcf release/$(NAME)_$(VERSION)_Darwin_$(HARDWARE).tgz -C build/Darwin $(BINARYNAME)
	gh-release checksums sha256
	gh-release create $(OWNER)/$(NAME) $(VERSION) $(shell git rev-parse --abbrev-ref HEAD) v$(VERSION)

clean:
	rm -rf build release

.PHONY: build release src
