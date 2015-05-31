NAME=glidergun
BINARYNAME=gun
OWNER=gliderlabs
ARCH=$(shell uname -m)
VERSION=0.0.7

build:
	go-bindata include
	mkdir -p build/Linux  && GOOS=linux  go build -ldflags "-X main.Version $(VERSION)" -o build/Linux/$(BINARYNAME)
	mkdir -p build/Darwin && GOOS=darwin go build -ldflags "-X main.Version $(VERSION)" -o build/Darwin/$(BINARYNAME)

install: build
	install build/$(shell uname -s)/gun /usr/local/bin

test:
	go install
	GUN=glidergun basht tests/*.bash

deps:
	go get -u github.com/jteeuwen/go-bindata/...
	go get -u github.com/progrium/gh-release/...
	go get -u github.com/progrium/basht/...
	go get || true

release:
	rm -rf release && mkdir release
	tar -zcf release/$(NAME)_$(VERSION)_Linux_$(ARCH).tgz -C build/Linux $(BINARYNAME)
	tar -zcf release/$(NAME)_$(VERSION)_Darwin_$(ARCH).tgz -C build/Darwin $(BINARYNAME)
	gh-release checksums sha256
	gh-release create $(OWNER)/$(NAME) $(VERSION) $(shell git rev-parse --abbrev-ref HEAD) v$(VERSION)

circleci:
	rm ~/.gitconfig
	rm -rf /home/ubuntu/.go_workspace/src/github.com/$(OWNER)/$(NAME) && cd .. \
		&& mkdir -p /home/ubuntu/.go_workspace/src/github.com/$(OWNER) \
		&& mv $(NAME) /home/ubuntu/.go_workspace/src/github.com/$(OWNER)/$(NAME) \
		&& ln -s /home/ubuntu/.go_workspace/src/github.com/$(OWNER)/$(NAME) $(NAME)

clean:
	rm -rf build release

.PHONY: build release
